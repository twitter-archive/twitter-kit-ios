/*
 * Copyright (C) 2017 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#import "TWTRTweetRepository.h"
#import <TwitterCore/TWTRAPIConstants.h>
#import <TwitterCore/TWTRAPIServiceConfig.h>
#import <TwitterCore/TWTRAPIServiceConfigRegistry.h>
#import <TwitterCore/TWTRAssertionMacros.h>
#import <TwitterCore/TWTRConstants.h>
#import <TwitterCore/TWTRSessionStore.h>
#import "TWTRAPIClient.h"
#import "TWTRAPIConstantsStatus.h"
#import "TWTRStore.h"
#import "TWTRSubscriber.h"
#import "TWTRSubscription.h"
#import "TWTRTweet.h"
#import "TWTRTweetCache.h"
#import "TWTRTwitter.h"
#import "TWTRUser.h"

typedef void (^TWTRTweetCacheLoadTweetIDsCompletion)(NSArray *cachedTweets, NSArray *cacheMissTweetIDs);
static NSString *const TWTRTweetCachePath = @"cache/tweets";
static const NSUInteger MB = 1048576;
static const NSUInteger TWTRTweetCacheMaxSize = 5 * MB;

@interface TWTRTweetRepository ()

@property (nonatomic, strong) id<TWTRTweetCache> cache;

@end

@implementation TWTRTweetRepository

#pragma mark - Singleton Accessor

+ (instancetype)sharedInstance
{
    static TWTRTweetRepository *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [self cacheDirectoryPath];
        TWTRTweetCache *cache = [[TWTRTweetCache alloc] initWithPath:path maxSize:TWTRTweetCacheMaxSize];
        sharedInstance = [[TWTRTweetRepository alloc] initWithCache:cache];
    });

    return sharedInstance;
}

#pragma mark - Init

- (instancetype)initWithCache:(id<TWTRTweetCache>)cache
{
    self = [super init];

    if (self) {
        _cache = cache;
    }

    return self;
}

#pragma mark - Tweet API Methods

- (void)loadTweetsWithIDs:(NSArray<NSString *> *)tweetIDStrings APIClient:(TWTRAPIClient *)client additionalParameters:(nullable NSDictionary *)parameters completion:(TWTRLoadTweetsCompletion)completion
{
    TWTRCheckArgumentWithCompletion2(client, completion);
    if ([tweetIDStrings count] < 1) {
        completion(@[], nil);
        return;
    }

    NSString *userIDString = client.userID;

    [self loadCachedTweetsWithIDs:tweetIDStrings
                      perspective:userIDString
                       completion:^(NSArray *cachedTweets, NSArray *cacheMissTweetIDs) {
                           // Fire off network request if there's any Tweets we need to backfill
                           if ([cacheMissTweetIDs count] > 0) {
                               // Set up the completion block to backfill the cache
                               TWTRNetworkCompletion networkRespCompletion = ^(NSURLResponse *resp, NSData *data, NSError *error) {
                                   if (!data || error) {
                                       completion(nil, error);
                                       return;
                                   }

                                   NSError *jsonSerializationErr;
                                   NSArray *tweetListDicts = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonSerializationErr];

                                   if (jsonSerializationErr) {
                                       completion(nil, jsonSerializationErr);
                                       return;
                                   }

                                   NSArray *networkTweets = [TWTRTweet tweetsWithJSONArray:tweetListDicts];

                                   for (TWTRTweet *tweet in networkTweets) {
                                       [self cacheTweet:tweet perspective:userIDString];
                                       [[TWTRStore sharedInstance] notifySubscribersOfChangesToObject:tweet withID:tweet.tweetID];
                                   }

                                   NSArray *combinedTweets = [networkTweets arrayByAddingObjectsFromArray:cachedTweets];
                                   NSArray *sortedTweets = [TWTRTweetRepository sortedArrayWithArray:combinedTweets withIDsArray:tweetIDStrings];

                                   // The api will return 200 and just drop the tweets which have invalid ids. We want
                                   // to return successfully loaded tweets and an error that includes a list of IDs that
                                   // failed to load.
                                   NSError *invalidTweetIDError;
                                   if ([networkTweets count] < [cacheMissTweetIDs count]) {
                                       NSMutableArray *failedTweetIDs = [tweetIDStrings mutableCopy];
                                       for (TWTRTweet *tweet in sortedTweets) {
                                           [failedTweetIDs removeObject:tweet.tweetID];
                                       }

                                       NSString *errorMessage = [NSString stringWithFormat:@"Failed to fetch one or more of the following tweet IDs: %@.", [failedTweetIDs componentsJoinedByString:@", "]];
                                       invalidTweetIDError = [NSError errorWithDomain:TWTRErrorDomain code:TWTRErrorCodeInvalidResourceID userInfo:@{NSLocalizedDescriptionKey: errorMessage, TWTRTweetsNotLoadedKey: [failedTweetIDs copy]}];
                                   }

                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       completion(sortedTweets, invalidTweetIDError);
                                   });
                               };

                               // Get the request for cache miss Tweets
                               NSError *requestError;
                               NSURLRequest *request = [self lookupRequestForTweetIDs:cacheMissTweetIDs APIClient:client additionalParameters:parameters error:&requestError];
                               if (requestError) {
                                   completion(nil, requestError);
                                   return;
                               }
                               [client sendTwitterRequest:request completion:networkRespCompletion];
                           } else {
                               completion(cachedTweets, nil);
                           }
                       }];
}

- (void)cacheTweet:(TWTRTweet *)tweet
{
    [self cacheTweet:tweet perspective:tweet.perspectivalUserID];
}

- (void)cacheTweet:(TWTRTweet *)tweet perspective:(NSString *)perspective
{
    [self.cache storeTweet:tweet perspective:perspective];
    [[TWTRStore sharedInstance] notifySubscribersOfChangesToObject:tweet withID:tweet.tweetID];
}

#pragma mark - Helpers

// TODO: this is a temporary fix, refactor `TWTRTweetCache` to expose async CRUD methods in the long run
- (void)loadCachedTweetsWithIDs:(NSArray *)tweetIDs perspective:(NSString *)perspective completion:(TWTRTweetCacheLoadTweetIDsCompletion)completion
{
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);

        NSMutableArray *cachedTweets = [NSMutableArray array];
        NSMutableArray *cacheMissTweetIDs = [NSMutableArray array];

        for (NSString *tweetID in [tweetIDs copy]) {
            TWTRTweet *cachedTweet = [self.cache tweetWithID:tweetID perspective:[perspective copy]];

            // Cache hit, so invoke the completion with the cached entry and return without
            // falling back to a network request.
            if (cachedTweet) {
                [cachedTweets addObject:cachedTweet];
            } else {
                [cacheMissTweetIDs addObject:tweetID];
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            completion(cachedTweets, cacheMissTweetIDs);
        });
    });
}

/**
 *  Returns a new array by sorting the array according to the ordering of IDs in the IDsArray
 *
 *  @param anArray  an array of elements to fill
 *  @param IDsArray array of IDs in the order we want the combined array to be based on
 *
 *  @return array of elements from both of the arrays in the ordering of the originalArray
 */
+ (NSArray *)sortedArrayWithArray:(NSArray *)anArray withIDsArray:(NSArray *)IDsArray
{
    NSMutableDictionary *idToTweetDict = [NSMutableDictionary dictionary];
    for (TWTRTweet *tweet in anArray) {
        idToTweetDict[tweet.tweetID] = tweet;
    }

    NSMutableArray *orderedTweetsArray = [NSMutableArray arrayWithCapacity:[IDsArray count]];
    for (NSString *tweetIDString in IDsArray) {
        TWTRTweet *tweet = idToTweetDict[tweetIDString];
        if (tweet) {
            [orderedTweetsArray addObject:tweet];
        }
    }

    return orderedTweetsArray;
}

+ (NSString *)cacheDirectoryPath
{
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *tweetCacheFullPath = [cacheDir stringByAppendingPathComponent:TWTRTweetCachePath];

    return tweetCacheFullPath;
}

#pragma mark - Request Builders

- (NSURLRequest *)lookupRequestForTweetIDs:(NSArray *)tweetIDsStrings APIClient:(TWTRAPIClient *)client additionalParameters:(nullable NSDictionary *)additionalParams error:(NSError **)error
{
    id<TWTRAPIServiceConfig> config = [[TWTRAPIServiceConfigRegistry defaultRegistry] configForType:TWTRAPIServiceConfigTypeDefault];
    NSURL *URL = TWTRAPIURLWithPath(config, TWTRAPIConstantsStatusLookUpURL);

    NSString *tweetIDParamString = [tweetIDsStrings componentsJoinedByString:@","];

    NSMutableDictionary *params = additionalParams ? [additionalParams mutableCopy] : [NSMutableDictionary dictionary];
    params[TWTRAPIConstantsParamID] = tweetIDParamString;

    return [client URLRequestWithMethod:@"GET" URLString:URL.absoluteString parameters:params error:error];
}

@end
