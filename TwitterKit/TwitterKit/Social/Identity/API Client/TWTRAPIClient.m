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

#import "TWTRAPIClient.h"
#import <AVFoundation/AVFoundation.h>
#import <TwitterCore/TWTRAPIConstantsUser.h>
#import <TwitterCore/TWTRAPIErrorCode.h>
#import <TwitterCore/TWTRAPINetworkErrorsShim.h>
#import <TwitterCore/TWTRAPIServiceConfig.h>
#import <TwitterCore/TWTRAPIServiceConfigRegistry.h>
#import <TwitterCore/TWTRAssertionMacros.h>
#import <TwitterCore/TWTRConstants.h>
#import <TwitterCore/TWTRDictUtil.h>
#import <TwitterCore/TWTRGuestAuthRequestSigner.h>
#import <TwitterCore/TWTRMultipartFormDocument.h>
#import <TwitterCore/TWTRNetworkingConstants.h>
#import <TwitterCore/TWTRNetworkingPipeline.h>
#import <TwitterCore/TWTRSessionStore.h>
#import <TwitterCore/TWTRSessionStore_Private.h>
#import <TwitterCore/TWTRURLSessionDelegate.h>
#import <TwitterCore/TWTRUserAuthRequestSigner.h>
#import "TWTRAPIClient_Private.h"
#import "TWTRAPIConstantsStatus.h"
#import "TWTRAPIConstantsTimelines.h"
#import "TWTRJSONSerialization.h"
#import "TWTRMediaType.h"
#import "TWTRTimelineCursor.h"
#import "TWTRTimelineFilterManager.h"
#import "TWTRTimelineParser.h"
#import "TWTRTweet.h"
#import "TWTRTweetRepository.h"
#import "TWTRTweet_Private.h"
#import "TWTRTwitterAPIConfiguration.h"
#import "TWTRTwitterAPIServiceConfig.h"
#import "TWTRTwitter_Private.h"
#import "TWTRURLSessionConfig.h"
#import "TWTRUser.h"

NSString *const TWTRTweetsNotLoadedKey = @"TweetsNotLoaded";
static NSString *const TWTRAPIConstantsCreateTweetPath = @"/1.1/statuses/update.json";
static NSString *const TWTRAPIConstantsLikeTweetPath = @"/1.1/favorites/create.json";
static NSString *const TWTRAPIConstantsUnlikeTweetPath = @"/1.1/favorites/destroy.json";
static NSString *const TWTRAPIConstantsRetweetPath = @"/1.1/statuses/retweet/%@.json";
static NSString *const TWTRAPIConstantsUnretweetPath = @"/1.1/statuses/unretweet/%@.json";
static NSString *const TWTRAPIConstantsUploadMediaPath = @"/1.1/media/upload.json";
static NSString *const TWTRAPIConstantsAPIConfigurationPath = @"/1.1/help/configuration.json";
static NSString *const TWTRAPIConstantsCreateCardPath = @"/v2/cards/create.json";

static NSString *const TWTRMediaIDStringKey = @"media_id_string";

static id<TWTRSessionStore_Private> TWTRSharedSessionStore = nil;

@implementation TWTRAPIClient

/**
 * This method provides a mechanism for injecting a session store to be used by all networking requests.
 * This pattern was chosen because we do not want to have the TWTRAPIClient to rely on the Twitter instance
 * which is what holds on to the session store object. We also do not want to have the session store object
 * be a singleton object which the session store uses.
 *
 * By allowing a session store to be injected we can still expose a private initializer to enable testing
 * with different session stores.
 */
+ (void)registerSharedSessionStore:(id<TWTRSessionStore_Private>)sessionStore
{
    TWTRSharedSessionStore = sessionStore;
}

#pragma mark - Initialization

- (instancetype)init
{
    return [self initWithUserID:nil];
}

- (instancetype)initWithUserID:(nullable NSString *)userID
{
    return [self initWithSessionStore:TWTRSharedSessionStore userID:userID];
}

+ (instancetype)clientWithCurrentUser
{
    return [[self alloc] initWithUserID:[TWTRTwitter sharedInstance].sessionStore.session.userID];
}

- (instancetype)initWithSessionStore:(id<TWTRSessionStore_Private>)sessionStore userID:(NSString *)userID
{
    TWTRParameterAssertOrReturnValue(sessionStore, nil);

    self = [super init];
    if (self) {
        _sessionStore = sessionStore;
        _userID = [userID copy];

        // TODO: keeping this for now just for the factory methods to construct NSURLRequest objects
        _networkingClient = [[TWTRNetworking alloc] initWithAuthConfig:sessionStore.authConfig];
    }

    return self;
}

#pragma mark - Networking Stack

+ (TWTRNetworkingPipeline *)networkingPipeline
{
    static TWTRNetworkingPipeline *pipeline = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        TWTRAPIResponseValidator *validator = [[TWTRAPIResponseValidator alloc] init];
        pipeline = [[TWTRNetworkingPipeline alloc] initWithURLSession:[self URLSession] responseValidator:validator];
    });

    return pipeline;
}

+ (NSURLSession *)URLSession
{
    static NSURLSession *URLSession = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        TWTRURLSessionDelegate *sessionDelegate = [[TWTRURLSessionDelegate alloc] init];

        NSOperationQueue *delegateQueue = [[NSOperationQueue alloc] init];
        delegateQueue.maxConcurrentOperationCount = 1;  // we want this to be serial
        delegateQueue.name = @"com.twittercore.sdk.url-session-queue";

        NSURLSessionConfiguration *sessionConfig = [TWTRURLSessionConfig defaultConfiguration];
        URLSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:sessionDelegate delegateQueue:delegateQueue];
    });

    return URLSession;
}

+ (id<TWTRAPIServiceConfig>)defaultServiceConfig
{
    return [[TWTRAPIServiceConfigRegistry defaultRegistry] configForType:TWTRAPIServiceConfigTypeDefault];
}

#pragma mark - Public Methods

- (void)sendTweetWithText:(NSString *)tweetText completion:(TWTRSendTweetCompletion)completion
{
    TWTRParameterAssertOrReturn(tweetText);
    TWTRParameterAssertOrReturn(completion);

    [self postToAPIPath:TWTRAPIConstantsCreateTweetPath
             parameters:@{@"status": tweetText}
             completion:^(NSURLResponse *response, NSDictionary *responseDict, NSError *error) {
                 TWTRTweet *tweet = nil;

                 if (!error) {
                     tweet = [[TWTRTweet alloc] initWithJSONDictionary:responseDict];
                 }

                 [self callGenericResponseBlock:completion withObject:tweet error:error];
             }];
}

- (void)sendTweetWithText:(NSString *)tweetText image:(UIImage *)image completion:(TWTRSendTweetCompletion)completion
{
    TWTRParameterAssertOrReturn(image);
    TWTRParameterAssertOrReturn(tweetText);
    TWTRParameterAssertOrReturn(completion);

    NSData *media = UIImageJPEGRepresentation(image, 0.9);
    [self uploadMedia:media
          contentType:@"image/jpeg"
           completion:^(NSString *mediaID, NSError *mediaError) {
               if (mediaID) {
                   [self sendTweetWithText:tweetText mediaID:mediaID completion:completion];
               } else {
                   completion(nil, mediaError);
               }
           }];
}

- (void)sendTweetWithText:(NSString *)tweetText mediaID:(NSString *)mediaID completion:(TWTRSendTweetCompletion)completion
{
    TWTRParameterAssertOrReturn(tweetText);
    TWTRParameterAssertOrReturn(mediaID);
    TWTRParameterAssertOrReturn(completion);

    NSDictionary *parameters = @{@"status": tweetText, @"media_ids": mediaID};
    [self postToAPIPath:TWTRAPIConstantsCreateTweetPath
             parameters:parameters
             completion:^(NSURLResponse *response, NSDictionary *responseDict, NSError *error) {

                 TWTRTweet *tweet = nil;
                 if (!error) {
                     tweet = [[TWTRTweet alloc] initWithJSONDictionary:responseDict];
                 }
                 [self callGenericResponseBlock:completion withObject:tweet error:error];
             }];
}

- (void)uploadVideoWithVideoData:(NSData *)videoData completion:(TWTRMediaUploadResponseCompletion)completion
{
    TWTRParameterAssertOrReturn(videoData);
    TWTRParameterAssertOrReturn(completion);

    NSString *videoSize = @(videoData.length).stringValue;
    NSString *videoString = [videoData base64EncodedStringWithOptions:0];
    NSDictionary *parameters = @{@"command": @"INIT", @"total_bytes": videoSize, @"media_type": @"video/mp4"};

    [self uploadWithParameters:parameters
                    completion:^(NSURLResponse *response, NSDictionary *responseDict, NSError *error) {
                        if (error) {
                            completion(nil, error);
                        } else {
                            if ([responseDict objectForKey:TWTRMediaIDStringKey]) {
                                [self postAppendWithMediaID:responseDict[TWTRMediaIDStringKey] videoString:videoString completion:completion];
                            } else {
                                NSError *missingKeyError = [NSError errorWithDomain:TWTRErrorDomain code:TWTRErrorCodeMissingParameter userInfo:@{NSLocalizedDescriptionKey: @"API returned dictionary but did not have \"media_id_string\""}];
                                completion(nil, missingKeyError);
                            }
                        }
                    }];
}

- (void)postAppendWithMediaID:(nonnull NSString *)mediaID videoString:(nonnull NSString *)videoString completion:(TWTRMediaUploadResponseCompletion)completion
{
    if (!mediaID) {
        NSError *error = [NSError errorWithDomain:TWTRErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"Error: mediaID is required."}];
        completion(nil, error);
        return;
    }
    NSDictionary *parameters = @{@"command": @"APPEND", @"media_id": mediaID, @"segment_index": @"0", @"media": videoString};
    [self uploadWithParameters:parameters
                    completion:^(NSURLResponse *response, id responseObject, NSError *error) {
                        if (error) {
                            completion(nil, error);
                        } else {
                            [self postFinalizeWithMediaID:mediaID completion:completion];
                        }
                    }];
}

- (void)postFinalizeWithMediaID:(nonnull NSString *)mediaID completion:(TWTRMediaUploadResponseCompletion)completion
{
    NSDictionary *parameters = @{@"command": @"FINALIZE", @"media_id": mediaID};
    [self uploadWithParameters:parameters
                    completion:^(NSURLResponse *response, NSDictionary *responseDict, NSError *error) {
                        if (error) {
                            completion(nil, error);
                        } else {
                            completion(mediaID, error);
                        }
                    }];
}
- (void)sendTweetWithText:(NSString *)tweetText videoData:(NSData *)videoData completion:(TWTRSendTweetCompletion)completion
{
    // Keep the limit to be 5M to qualify for image/media upload, not using separate chunk upload
    const long long kVideoMaxFileSize = 5 * 1024 * 1024;

    if (videoData == nil) {
        NSLog(@"Error: video data is empty");
        [self sendTweetWithText:tweetText completion:completion];
        return;
    } else if (videoData.length == 0) {
        NSLog(@"Error: video data is too small");
        NSError *sizeError = [NSError errorWithDomain:TWTRErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"Error: video data is too small"}];
        completion(nil, sizeError);
        return;
    } else if (videoData.length > kVideoMaxFileSize) {
        NSLog(@"Error: video data is too big");
        NSError *sizeError = [NSError errorWithDomain:TWTRErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: @"Error: video data is bigger than 5 MB"}];
        completion(nil, sizeError);
        return;
    }

    [self uploadVideoWithVideoData:videoData
                        completion:^(NSString *mediaID, NSError *error) {
                            if (error) {
                                completion(nil, error);
                            } else {
                                [self sendTweetWithText:tweetText mediaID:mediaID completion:completion];
                            }
                        }];
}

- (void)loadUserWithID:(NSString *)userIDString completion:(TWTRLoadUserCompletion)completion
{
    TWTRCheckArgumentWithCompletion2(userIDString, completion);

    NSURL *url = TWTRAPIURLWithPath([[self class] defaultServiceConfig], TWTRAPIConstantsUserShowURL);
    NSDictionary *params = @{TWTRAPIConstantsUserParamUserID: userIDString};
    NSError *requestError = nil;
    NSURLRequest *request = [self URLRequestWithMethod:@"GET" withURL:url parameters:params error:&requestError];
    if (requestError) {
        [self callGenericResponseBlock:completion withObject:nil error:requestError];
        return;
    }
    [self sendTwitterRequest:request
                       queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                  completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                      if (connectionError) {
                          [self callGenericResponseBlock:completion withObject:nil error:connectionError];
                          return;
                      };
                      NSError *jsonSerializationErr;
                      NSDictionary *userDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonSerializationErr];
                      if (jsonSerializationErr) {
                          [self callGenericResponseBlock:completion withObject:nil error:jsonSerializationErr];
                          return;
                      }
                      TWTRUser *user = [[TWTRUser alloc] initWithJSONDictionary:userDict];
                      [self callGenericResponseBlock:completion withObject:user error:nil];
                  }];
}

- (void)loadTweetWithID:(NSString *)tweetIDString completion:(TWTRLoadTweetCompletion)completion
{
    if (tweetIDString == nil) {
        NSError *error = [NSError errorWithDomain:TWTRErrorDomain code:TWTRErrorCodeInvalidResourceID userInfo:@{NSLocalizedDescriptionKey: @"Tweet ID cannot be nil."}];
        completion(nil, error);
        return;
    }

    [self loadTweetsWithIDs:@[tweetIDString]
                 completion:^(NSArray *tweets, NSError *error) {
                     completion([tweets firstObject], error);
                 }];
}

- (void)loadTweetsWithIDs:(NSArray *)tweetIDStrings completion:(TWTRLoadTweetsCompletion)completion
{
    TWTRLoadTweetsCompletion completionWithPerspectivalUserID = ^(NSArray *tweets, NSError *error) {
        NSArray *perspectivalTweets = [[self class] perspectivalTweets:tweets userID:self.userID];
        completion(perspectivalTweets, error);
    };

    NSDictionary *params = [[self class] baseTweetQueryParametersByAppendingParameters:nil];
    [[TWTRTweetRepository sharedInstance] loadTweetsWithIDs:tweetIDStrings APIClient:self additionalParameters:params completion:completionWithPerspectivalUserID];
}

#pragma mark - Temporarily Protected Methods

+ (NSDictionary *)queryParametersForIncludingCards
{
    return @{@"include_cards": @"true", @"cards_platform": @"TwitterKit-13"};
}

+ (NSMutableDictionary *)baseTweetQueryParametersByAppendingParameters:(nullable NSDictionary *)params
{
    NSMutableDictionary *parameters = params ? [params mutableCopy] : [NSMutableDictionary dictionary];
    [parameters addEntriesFromDictionary:[self queryParametersForIncludingCards]];
    parameters[@"tweet_mode"] = @"extended";

    return parameters;
}

- (void)loadTweetsForCollectionID:(NSString *)collectionID parameters:(NSDictionary *)params timelineFilterManager:(TWTRTimelineFilterManager *)timelineFilterManager completion:(TWTRLoadTimelineCompletion)completion
{
    TWTRCheckArgumentWithCompletion(collectionID, completion);

    NSMutableDictionary *parameters = [[self class] baseTweetQueryParametersByAppendingParameters:params];
    parameters[@"id"] = [NSString stringWithFormat:@"custom-%@", collectionID];

    [self loadJSONDictionaryFromAPIPath:TWTRAPIConstantsCollectionsRetrievePath
                             parameters:parameters
                             completion:^(NSURLResponse *response, NSDictionary *responseDict, NSError *error) {
                                 NSArray<TWTRTweet *> *tweets = nil;
                                 TWTRTimelineCursor *cursor = nil;

                                 if (!error) {
                                     NSArray<TWTRTweet *> *APITweets = [TWTRTimelineParser tweetsFromCollectionAPIResponseDictionary:responseDict];
                                     tweets = [[self class] perspectivalTweets:APITweets userID:self.userID];
                                     cursor = [[TWTRTimelineCursor alloc] initWithMaxPosition:nil minPosition:[TWTRTimelineParser minPositionFromCollectionAPIResponseDictionary:responseDict]];
                                 }

                                 // if a filter is provided, filter the tweets before completing.
                                 if (timelineFilterManager) {
                                     tweets = [timelineFilterManager filterTweets:tweets];
                                 }

                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     completion(tweets, cursor, error);
                                 });
                             }];
}

- (void)loadTweetsForSearchQuery:(NSString *)query parameters:(NSDictionary *)params timelineFilterManager:(TWTRTimelineFilterManager *)timelineFilterManager completion:(TWTRLoadTimelineCompletion)completion
{
    TWTRCheckArgumentWithCompletion(query, completion);

    NSMutableDictionary *parameters = [[self class] baseTweetQueryParametersByAppendingParameters:params];
    parameters[@"q"] = query;

    [self loadJSONDictionaryFromAPIPath:TWTRAPIConstantsSearchTweetsPath
                             parameters:parameters
                             completion:^(NSURLResponse *response, NSDictionary *responseDict, NSError *error) {
                                 NSArray<TWTRTweet *> *tweets = nil;
                                 TWTRTimelineCursor *cursor = nil;

                                 if (!error) {
                                     NSArray<TWTRTweet *> *APITweets = [TWTRTimelineParser tweetsFromSearchAPIResponseDictionary:responseDict];
                                     tweets = [[self class] perspectivalTweets:APITweets userID:self.userID];
                                     NSString *minPosition = [TWTRTimelineParser lastTweetIDFromTweets:tweets];
                                     cursor = [[TWTRTimelineCursor alloc] initWithMaxPosition:nil minPosition:minPosition];
                                 }

                                 // if a filter is provided, filter the tweets before completing.
                                 if (timelineFilterManager) {
                                     tweets = [timelineFilterManager filterTweets:tweets];
                                 }

                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     completion(tweets, cursor, error);
                                 });
                             }];
}

- (void)loadTweetsForUserTimeline:(NSString *)screenName userID:(NSString *)userID parameters:(NSDictionary *)params timelineFilterManager:(TWTRTimelineFilterManager *)timelineFilterManager completion:(TWTRLoadTimelineCompletion)completion
{
    TWTRCheckArgumentWithCompletion(screenName || userID, completion);

    NSMutableDictionary *parameters = [[self class] baseTweetQueryParametersByAppendingParameters:params];

    if (userID) {
        parameters[@"user_id"] = userID;
    } else if (screenName) {
        parameters[@"screen_name"] = screenName;
    }

    [self loadJSONArrayFromAPIPath:TWTRAPIConstantsUserTimelinePath
                        parameters:parameters
                        completion:^(NSURLResponse *response, NSArray *responseArray, NSError *error) {
                            NSArray<TWTRTweet *> *tweets = nil;
                            TWTRTimelineCursor *cursor = nil;

                            if (!error) {
                                NSArray<TWTRTweet *> *APITweets = [TWTRTweet tweetsWithJSONArray:responseArray];
                                tweets = [[self class] perspectivalTweets:APITweets userID:self.userID];
                                NSString *minPosition = [TWTRTimelineParser lastTweetIDFromTweets:tweets];
                                cursor = [[TWTRTimelineCursor alloc] initWithMaxPosition:nil minPosition:minPosition];
                            }

                            // if a filter is provided, filter the tweets before completing.
                            if (timelineFilterManager) {
                                tweets = [timelineFilterManager filterTweets:tweets];
                            }

                            dispatch_async(dispatch_get_main_queue(), ^{
                                completion(tweets, cursor, error);
                            });
                        }];
}

- (void)loadTweetsForListID:(NSString *)listID parameters:(NSDictionary *_Nullable)params timelineFilterManager:(TWTRTimelineFilterManager *)timelineFilterManager completion:(TWTRLoadTimelineCompletion)completion
{
    [self loadTweetsForListID:listID listSlug:nil listOwnerScreenName:nil parameters:params timelineFilterManager:timelineFilterManager completion:completion];
}

- (void)loadTweetsForListSlug:(NSString *)listSlug listOwnerScreenName:(NSString *)listOwnerScreenName parameters:(NSDictionary *_Nullable)params timelineFilterManager:(TWTRTimelineFilterManager *)timelineFilterManager completion:(TWTRLoadTimelineCompletion)completion
{
    [self loadTweetsForListID:nil listSlug:listSlug listOwnerScreenName:listOwnerScreenName parameters:params timelineFilterManager:timelineFilterManager completion:completion];
}

#pragma mark - Internal Methods

// This method is not for public consumption
- (void)verifySessionWithCompletion:(TWTRGenericResponseCompletion)completion
{
    NSURL *url = TWTRAPIURLWithPath([[self class] defaultServiceConfig], TWTRAPIConstantsVerifyCredentialsURL);
    NSError *requestError = nil;
    NSURLRequest *request = [self URLRequestWithMethod:@"GET" withURL:url parameters:nil error:&requestError];
    if (requestError) {
        [self callGenericResponseBlock:completion withObject:nil error:requestError];
        return;
    }
    [self sendTwitterRequest:request
                       queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                  completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                      if (connectionError) {
                          [self callGenericResponseBlock:completion withObject:nil error:connectionError];
                          return;
                      };

                      NSError *jsonSerializationErr;
                      NSDictionary *userDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonSerializationErr];
                      if (jsonSerializationErr) {
                          [self callGenericResponseBlock:completion withObject:nil error:jsonSerializationErr];
                          return;
                      }

                      [self callGenericResponseBlock:completion withObject:userDict error:nil];
                  }];
}

/**
 *  Returns Tweets with the `perspectivalUserID` set.
 *  @note assumes that `tweets` was loaded with the same user.
 *
 *  @param tweets Tweets without perspectival user set.
 *  @param userID ID of the perspectival user who loaded these Tweets.
 */
+ (NSArray<TWTRTweet *> *)perspectivalTweets:(NSArray<TWTRTweet *> *)tweets userID:(NSString *)userID
{
    const BOOL shouldSetPerspectivalUserID = [tweets count] > 0 && (tweets[0].perspectivalUserID != userID || ![tweets[0].perspectivalUserID isEqualToString:userID]);
    if (shouldSetPerspectivalUserID) {
        NSMutableArray *perspectivalTweets = [tweets mutableCopy];
        [tweets enumerateObjectsUsingBlock:^(TWTRTweet *tweet, NSUInteger idx, BOOL *stop) {
            perspectivalTweets[idx] = [tweet tweetWithPerspectivalUserID:userID];
        }];
        return perspectivalTweets;
    } else {
        return tweets;
    }
}

#pragma mark - Tweet Actions

- (void)likeTweetWithID:(NSString *)tweetID completion:(TWTRTweetActionCompletion)completion
{
    [self postToAPIPath:TWTRAPIConstantsLikeTweetPath withTweetID:tweetID completion:completion];
}

- (void)unlikeTweetWithID:(NSString *)tweetID completion:(TWTRTweetActionCompletion)completion
{
    [self postToAPIPath:TWTRAPIConstantsUnlikeTweetPath withTweetID:tweetID completion:completion];
}

- (void)retweetTweetWithID:(NSString *)tweetID completion:(TWTRTweetActionCompletion)completion
{
    NSString *path = [NSString stringWithFormat:TWTRAPIConstantsRetweetPath, tweetID];
    [self postToAPIPath:path withTweetID:tweetID completion:completion];
}

- (void)unretweetTweetWithID:(NSString *)tweetID completion:(TWTRTweetActionCompletion)completion
{
    NSString *path = [NSString stringWithFormat:TWTRAPIConstantsUnretweetPath, tweetID];
    [self postToAPIPath:path withTweetID:tweetID completion:completion];
}

- (void)postToAPIPath:(NSString *)path withTweetID:(NSString *)tweetID completion:(TWTRTweetActionCompletion)completion
{
    TWTRParameterAssertOrReturn(path);
    TWTRParameterAssertOrReturn(tweetID);

    [self postToAPIPath:path
             parameters:@{@"id": tweetID}
             completion:^(NSURLResponse *response, NSDictionary *responseDict, NSError *error) {
                 TWTRTweet *tweet = nil;

                 if (responseDict) {
                     TWTRTweet *newTweet = [[TWTRTweet alloc] initWithJSONDictionary:responseDict];
                     tweet = [newTweet tweetWithPerspectivalUserID:self.userID];
                 }

                 [self callGenericResponseBlock:completion withObject:tweet error:error];
             }];
}

- (void)requestEmailForCurrentUser:(TWTRRequestEmailCompletion)completion;
{
    TWTRParameterAssertOrReturn(completion);

    NSURL *URL = TWTRAPIURLWithPath([[self class] defaultServiceConfig], TWTRAPIConstantsVerifyCredentialsURL);
    NSError *requestError = nil;
    NSDictionary *params = @{TWTRAPIConstantsUserParamIncludeEmail: @"true", TWTRAPIConstantsUserParamSkipStatus: @"true"};

    NSURLRequest *request = [self URLRequestWithMethod:@"GET" withURL:URL parameters:params error:&requestError];
    if (requestError) {
        [self callGenericResponseBlock:completion withObject:nil error:requestError];
        return;
    }

    [self sendTwitterRequest:request
                       queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                  completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                      if (connectionError) {
                          [self callGenericResponseBlock:completion withObject:nil error:connectionError];
                          return;
                      };

                      NSError *jsonSerializationErr;
                      NSDictionary *userDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonSerializationErr];
                      if (jsonSerializationErr) {
                          [self callGenericResponseBlock:completion withObject:nil error:jsonSerializationErr];
                          return;
                      }

                      NSString *email = [TWTRDictUtil twtr_stringForKey:@"email" inDict:userDict];
                      NSError *emailUnavailableError;

                      if (email.length == 0 || (id)email == [NSNull null]) {
                          email = nil;

                          emailUnavailableError = [NSError errorWithDomain:TWTRErrorDomain code:TWTRErrorCodeUserHasNoEmailAddress userInfo:@{NSLocalizedDescriptionKey: @"This user does not have an email address."}];
                      }

                      [self callGenericResponseBlock:completion withObject:email error:emailUnavailableError];
                  }];
}

#pragma mark - Media Upload

- (void)uploadMedia:(NSData *)media contentType:(NSString *)contentType completion:(TWTRMediaUploadResponseCompletion)completion
{
    TWTRParameterAssertOrReturn(completion);
    TWTRCheckArgumentWithCompletion2(media && contentType, completion);

    TWTRMultipartFormDocument *doc = [self multipartFormDocumentForMedia:media contentType:contentType];
    NSMutableURLRequest *request = [self partialURLRequestForUploadingMediaWithContentType:doc.contentTypeHeaderField];

    [doc loadBodyDataWithCallbackQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                            completion:^(NSData *data) {
                                request.HTTPBody = data;

                                [self sendTwitterRequest:request
                                                   queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                                              completion:^(NSURLResponse *response, NSData *responseData, NSError *connectionError) {
                                                  NSString *mediaID = nil;
                                                  NSError *error = connectionError;

                                                  if (!connectionError) {
                                                      mediaID = [self mediaIDFromResponseData:responseData error:&error];
                                                  }
                                                  [self callGenericResponseBlock:completion withObject:mediaID error:error];
                                              }];
                            }];
}

- (NSURL *)uploadURL
{
    id<TWTRAPIServiceConfig> config = [[TWTRAPIServiceConfigRegistry defaultRegistry] configForType:TWTRAPIServiceConfigTypeUpload];
    NSURL *URL = TWTRAPIURLWithPath(config, TWTRAPIConstantsUploadMediaPath);

    return URL;
}

- (NSURL *)apiURLWithPath:(NSString *)apiPath
{
    return TWTRAPIURLWithPath([[self class] defaultServiceConfig], apiPath);
}

- (NSMutableURLRequest *)partialURLRequestForUploadingMediaWithContentType:(NSString *)contentType;
{
    NSURL *URL = [self uploadURL];

    NSMutableURLRequest *request = [[self URLRequestWithMethod:@"POST" URLString:[URL absoluteString] parameters:nil error:nil] mutableCopy];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];

    return request;
}

- (TWTRMultipartFormDocument *)multipartFormDocumentForMedia:(NSData *)media contentType:(NSString *)contentType
{
    TWTRMultipartFormElement *mediaElement = [[TWTRMultipartFormElement alloc] initWithName:@"media" contentType:contentType fileName:nil content:media];
    return [[TWTRMultipartFormDocument alloc] initWithFormElements:@[mediaElement]];
}

- (nullable NSString *)mediaIDFromResponseData:(NSData *)data error:(NSError **)error
{
    NSString *mediaID;
    void (^setError)(NSError *) = ^(NSError *errorToSet) {
        if (error) {
            *error = errorToSet;
        }
    };

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
    if (json) {
        if ([json isKindOfClass:[NSDictionary class]]) {
            mediaID = json[TWTRMediaIDStringKey];
            if (!mediaID) {
                NSError *missingKeyError = [NSError errorWithDomain:TWTRErrorDomain code:TWTRErrorCodeMissingParameter userInfo:@{NSLocalizedDescriptionKey: @"API returned dictionary but did not have \"media_id_string\""}];
                setError(missingKeyError);
            }
        } else {
            NSError *invalidTypeError = [NSError errorWithDomain:TWTRErrorDomain code:TWTRErrorCodeMismatchedJSONType userInfo:@{NSLocalizedDescriptionKey: @"API returned invalid JSON type"}];
            setError(invalidTypeError);
        }
    }

    return mediaID;
}

#pragma mark - Public Methods

- (NSURLRequest *)URLRequestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters error:(NSError **)error
{
    NSURLRequest *request = [self.networkingClient URLRequestWithMethod:method URLString:URLString parameters:parameters];

    if ([self isLoggedIn]) {
        TWTRSession *userSession = [self.sessionStore sessionForUserID:self.userID];
        return [TWTRUserAuthRequestSigner signedURLRequest:request authConfig:self.sessionStore.authConfig session:userSession];
    } else {
        if (self.sessionStore.guestSession == nil) {
            return request;
        }
        return [TWTRGuestAuthRequestSigner signedURLRequest:request session:self.sessionStore.guestSession];
    }
}

#pragma mark - Private Methods

- (BOOL)isLoggedIn
{
    const BOOL hasUnsafeCurrentUser = self.userID > 0;
    const BOOL isUserSessionStillValid = hasUnsafeCurrentUser && [self.sessionStore sessionForUserID:self.userID] != nil;

    if (isUserSessionStillValid) {
        return YES;
    } else {
        return NO;
    }
}

- (NSURLRequest *)URLRequestWithMethod:(NSString *)method withURL:(NSURL *)URL parameters:(NSDictionary *)parameters error:(NSError **)error
{
    return [self URLRequestWithMethod:method URLString:URL.absoluteString parameters:parameters error:error];
}

- (void)loadJSONDictionaryFromAPIPath:(nonnull NSString *)apiPath parameters:(NSDictionary *)parameters completion:(TWTRJSONRequestCompletion)completion
{
    [self performHTTPMethod:@"GET" onURL:[self apiURLWithPath:apiPath] expectedType:[NSDictionary class] parameters:parameters completion:completion];
}

- (void)loadJSONArrayFromAPIPath:(nonnull NSString *)apiPath parameters:(NSDictionary *)parameters completion:(TWTRJSONRequestCompletion)completion
{
    [self performHTTPMethod:@"GET" onURL:[self apiURLWithPath:apiPath] expectedType:[NSArray class] parameters:parameters completion:completion];
}

- (void)postToAPIPath:(nonnull NSString *)apiPath parameters:(NSDictionary *)parameters completion:(TWTRJSONRequestCompletion)completion
{
    [self performHTTPMethod:@"POST" onURL:[self apiURLWithPath:apiPath] expectedType:[NSDictionary class] parameters:parameters completion:completion];
}

- (void)uploadWithParameters:(NSDictionary *)parameters completion:(TWTRJSONRequestCompletion)completion
{
    [self performHTTPMethod:@"POST" onURL:[self uploadURL] expectedType:[NSDictionary class] parameters:parameters completion:completion];
}

- (void)performHTTPMethod:(nonnull NSString *)method onURL:(NSURL *)url expectedType:(Class)expectedClass parameters:(NSDictionary *)parameters completion:(TWTRJSONRequestCompletion)completion
{
    TWTRCheckArgumentWithCompletion(url, completion);

    NSError *requestError = nil;
    NSURLRequest *request = [self URLRequestWithMethod:method withURL:url parameters:parameters error:&requestError];
    if (!request) {
        completion(nil, nil, requestError);
        return;
    }

    [self sendTwitterRequest:request
                       queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                  completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                      id responseObject = nil;
                      NSError *errorToReturn = nil;

                      if (data.length > 0) {
                          NSError *jsonParsingError;
                          responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonParsingError];

                          if (responseObject == nil) {
                              errorToReturn = jsonParsingError;
                          } else if (![responseObject isKindOfClass:expectedClass]) {
                              NSString *errorString = [NSString stringWithFormat:@"Invalid type encountered when loading API path: %@. Expected %@ got %@", url.absoluteString, NSStringFromClass(expectedClass), NSStringFromClass([responseObject class])];
                              errorToReturn = [NSError errorWithDomain:TWTRErrorDomain code:TWTRErrorCodeMismatchedJSONType userInfo:@{NSLocalizedDescriptionKey: errorString}];
                              responseObject = nil;
                          }
                      } else {
                          errorToReturn = connectionError;
                      }
                      completion(response, responseObject, errorToReturn);
                  }];
}

- (NSProgress *)sendTwitterRequest:(NSURLRequest *)request completion:(TWTRNetworkCompletion)completion
{
    // still dispatch back to main queue since this is public API
    return [self sendTwitterRequest:request queue:dispatch_get_main_queue() completion:completion];
}

- (NSProgress *)sendTwitterRequest:(NSURLRequest *)request queue:(dispatch_queue_t)queue completion:(TWTRNetworkCompletion)completion
{
    return [[[self class] networkingPipeline] enqueueRequest:request
                                                sessionStore:self.sessionStore
                                              requestingUser:self.userID
                                                  completion:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                      dispatch_async(queue, ^{
                                                          // The networking pipeline matches Apple API's by having the completion be (data, response, error) but the public TWTRNetworkCompletion is (response, data, error) so we add this wrapper to swap the values.
                                                          completion(response, data, error);
                                                      });
                                                  }];
}

- (void)callGenericResponseBlock:(TWTRGenericResponseCompletion)completion withObject:(id)object error:(NSError *)error
{
    if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(object, error);
        });
    } else {
        NSLog(@"[%@] Load method called without a completion. Object: %@, Error: %@", [TWTRAPIClient class], object, error);
    }
}

- (void)loadTweetsForListID:(NSString *)listID listSlug:(NSString *)listSlug listOwnerScreenName:(NSString *)listOwnerScreenName parameters:(NSDictionary *_Nullable)params timelineFilterManager:(TWTRTimelineFilterManager *)timelineFilterManager completion:(TWTRLoadTimelineCompletion)completion
{
    TWTRCheckArgumentWithCompletion(listID || (listSlug && listOwnerScreenName), completion);

    NSMutableDictionary *parameters = [[self class] baseTweetQueryParametersByAppendingParameters:params];

    if (listID) {
        parameters[@"list_id"] = listID;
    } else {
        parameters[@"slug"] = listSlug;
        parameters[@"owner_screen_name"] = listOwnerScreenName;
    }

    [self loadJSONArrayFromAPIPath:TWTRAPIConstantsListsStatusesPath
                        parameters:parameters
                        completion:^(NSURLResponse *response, NSArray *responseArray, NSError *error) {
                            NSArray<TWTRTweet *> *tweets = nil;
                            TWTRTimelineCursor *cursor = nil;

                            if (!error) {
                                NSArray<TWTRTweet *> *APITweets = [TWTRTweet tweetsWithJSONArray:responseArray];
                                tweets = [[self class] perspectivalTweets:APITweets userID:self.userID];
                                NSString *minPosition = [TWTRTimelineParser lastTweetIDFromTweets:tweets];
                                cursor = [[TWTRTimelineCursor alloc] initWithMaxPosition:nil minPosition:minPosition];
                            }

                            // if a filter is provided, filter the tweets before completing.
                            if (timelineFilterManager) {
                                tweets = [timelineFilterManager filterTweets:tweets];
                            }

                            dispatch_async(dispatch_get_main_queue(), ^{
                                completion(tweets, cursor, error);
                            });
                        }];
}

@end
