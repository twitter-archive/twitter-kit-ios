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

#import <OCMock/OCMock.h>
#import <TwitterCore/TWTRConstants.h>
#import <TwitterCore/TWTRSession.h>
#import <TwitterCore/TWTRSessionStore.h>
#import "TWTRAPIClient.h"
#import "TWTRAPIClient_Private.h"
#import "TWTRFixtureLoader.h"
#import "TWTRStubTweetCache.h"
#import "TWTRStubTwitterClient.h"
#import "TWTRTestCase.h"
#import "TWTRTestSessionStore.h"
#import "TWTRTweet.h"
#import "TWTRTweetCache.h"
#import "TWTRTweetRepository.h"

static NSArray *TWTRTweetRepositoryTestsTweetsJSON;
static NSArray *TWTRTweetRepositoryTestsTweets;
static NSMutableArray *TWTRTweetRepositoryTestsTweetsIDs;

@interface TWTRTweetRepositoryTests : TWTRTestCase

@property (nonatomic, strong) id mockAPIClient;
@property (nonatomic, strong) id mockTweetCache;
@property (nonatomic, strong) TWTRAPIClient *APIClient;
@property (nonatomic, strong) TWTRTweetRepository *repository;
@property (nonatomic, strong) TWTRStubTwitterClient *stubAPIClient;
@property (nonatomic, strong) TWTRStubTweetCache *stubTweetCache;
@property (nonatomic, strong) TWTRTestSessionStore *sessionStore;
@end

@interface TWTRTweetRepository ()
- (instancetype)initWithCache:(id<TWTRTweetCache>)cache;
@end

@implementation TWTRTweetRepositoryTests

+ (void)setUp
{
    NSData *manyTweetsData = [TWTRFixtureLoader manyTweetsData];
    TWTRTweetRepositoryTestsTweetsJSON = [NSJSONSerialization JSONObjectWithData:manyTweetsData options:0 error:nil];
    TWTRTweetRepositoryTestsTweets = [TWTRTweet tweetsWithJSONArray:TWTRTweetRepositoryTestsTweetsJSON];
    TWTRTweetRepositoryTestsTweetsIDs = [NSMutableArray array];
    for (TWTRTweet *tweet in TWTRTweetRepositoryTestsTweets) {
        [TWTRTweetRepositoryTestsTweetsIDs addObject:tweet.tweetID];
    }
}

- (void)setUp
{
    [super setUp];

    //    TWTRAuthConfig *authConfig = [[TWTRAuthConfig alloc] initWithConsumerKey:@"consumerKey" consumerSecret:@"consumerSecret"];
    self.sessionStore = [[TWTRTestSessionStore alloc] initWithUserSessions:@[] guestSession:nil];
    self.APIClient = [[TWTRAPIClient alloc] initWithSessionStore:self.sessionStore userID:nil];
    self.mockAPIClient = [OCMockObject partialMockForObject:self.APIClient];
    self.mockTweetCache = [OCMockObject mockForClass:[TWTRTweetCache class]];
    self.stubAPIClient = [TWTRStubTwitterClient stubTwitterClient];
    self.stubTweetCache = [[TWTRStubTweetCache alloc] init];
    self.repository = [[TWTRTweetRepository alloc] initWithCache:self.stubTweetCache];
}

- (void)tearDown
{
    [self.mockAPIClient stopMocking];
    [self.mockTweetCache stopMocking];

    [super tearDown];
}

- (void)testSharedInstanceSame
{
    TWTRTweetRepository *firstRepo = [TWTRTweetRepository sharedInstance];
    TWTRTweetRepository *secondRepo = [TWTRTweetRepository sharedInstance];
    XCTAssertEqual(firstRepo, secondRepo, @"Should return the same instance");
}

- (void)testLoadTweetsWithIDsEmpty
{
    [self.repository loadTweetsWithIDs:@[] APIClient:self.stubAPIClient additionalParameters:nil completion:^(NSArray *tweets, NSError *error) {
        XCTAssert([tweets count] == 0);
        [self setAsyncComplete:YES];
    }];
    [self waitForCompletion];
}

- (void)testLoadTweetsWithIDsEmptyNoNetworkOrCacheInvocations
{
    [self.mockTweetCache reject];
    [self.mockAPIClient reject];

    [self.repository loadTweetsWithIDs:@[] APIClient:self.stubAPIClient additionalParameters:nil completion:^(NSArray *tweets, NSError *error) {
        [self.mockTweetCache verify];
        [self.mockAPIClient verify];

        [self setAsyncComplete:YES];
    }];
    [self waitForCompletion];
}

- (void)testLoadTweetsAllValidAndCached
{
    [self.stubTweetCache cacheTweets:TWTRTweetRepositoryTestsTweets];

    XCTestExpectation *loadExpectation = [self expectationWithDescription:@"Async load expectation"];
    [self.repository loadTweetsWithIDs:@[@"483693675445100546"] APIClient:self.stubAPIClient additionalParameters:nil completion:^(NSArray *tweets, NSError *error) {
        XCTAssert([tweets count] == 1);
        XCTAssert(error == nil);
        [loadExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testLoadTweetsFromNetwork
{
    self.stubAPIClient.responseData = [TWTRFixtureLoader manyTweetsData];

    [self.repository loadTweetsWithIDs:@[@"483693675445100546", @"484071743238066176"] APIClient:self.stubAPIClient additionalParameters:nil completion:^(NSArray *tweets, NSError *error) {
        XCTAssert([tweets count] == 2);
        XCTAssert(error == nil);
    }];
}

- (void)testLoadTweetsFromNetworkCorrectOrder
{
    self.stubAPIClient.responseData = [TWTRFixtureLoader manyTweetsData];

    [self.repository loadTweetsWithIDs:@[@"483693675445100546", @"484071743238066176"] APIClient:self.stubAPIClient additionalParameters:nil completion:^(NSArray *tweets, NSError *error) {
        TWTRTweet *tweet1 = tweets[0];
        TWTRTweet *tweet2 = tweets[1];
        XCTAssert([tweet1.tweetID isEqual:@"483693675445100546"]);
        XCTAssert([tweet2.tweetID isEqual:@"484071743238066176"]);
    }];
}

- (void)testLoadTweetsOneValidOneInvalid
{
    self.stubAPIClient.responseData = [TWTRFixtureLoader singleTweetData];

    [self.repository loadTweetsWithIDs:@[@"469961733323653120", @"meow"] APIClient:self.stubAPIClient additionalParameters:nil completion:^(NSArray *tweets, NSError *error) {
        XCTAssert([tweets count] == 1);
        XCTAssert(error != nil);
        XCTAssert([error.userInfo[TWTRTweetsNotLoadedKey] isKindOfClass:[NSArray class]]);
        XCTAssert([error.userInfo[TWTRTweetsNotLoadedKey] count] == 1);
    }];
}

- (void)testLoadTweetsOneInvalid
{
    self.stubAPIClient.responseData = [@"[]" dataUsingEncoding:NSUTF8StringEncoding];

    [self.repository loadTweetsWithIDs:@[@"meow"] APIClient:self.stubAPIClient additionalParameters:nil completion:^(NSArray *tweets, NSError *error) {
        XCTAssert([tweets isKindOfClass:[NSArray class]]);
        XCTAssert([tweets count] == 0);
        XCTAssert(error != nil);
        XCTAssert([error.userInfo[TWTRTweetsNotLoadedKey] isKindOfClass:[NSArray class]]);
        XCTAssert([error.userInfo[TWTRTweetsNotLoadedKey] count] == 1);
    }];
}

- (void)testLoadTweetsWithIDsAllCacheHitNoNetwork
{
    [self.stubTweetCache cacheTweets:TWTRTweetRepositoryTestsTweets];

    [self.mockAPIClient reject];  // should not call network if all cached

    XCTestExpectation *loadExpectation = [self expectationWithDescription:@"Load tweets expectation"];
    [self.repository loadTweetsWithIDs:TWTRTweetRepositoryTestsTweetsIDs APIClient:self.stubAPIClient additionalParameters:nil completion:^(NSArray *tweets, NSError *error) {
        [self.mockAPIClient verify];
        [loadExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testLoadTweetsWithIDsAllCacheHitCorrectTweets
{
    [self.stubTweetCache cacheTweets:TWTRTweetRepositoryTestsTweets];

    XCTestExpectation *loadExpectation = [self expectationWithDescription:@"Load tweets expectation"];

    // Should return all the correct tweets
    [self.repository loadTweetsWithIDs:TWTRTweetRepositoryTestsTweetsIDs APIClient:self.stubAPIClient additionalParameters:nil completion:^(NSArray *tweets, NSError *error) {
        NSArray *returnedIDs = [tweets valueForKey:@"tweetID"];
        XCTAssert([returnedIDs isEqual:TWTRTweetRepositoryTestsTweetsIDs]);

        [loadExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testLoadTweetsWithIDsMixedCacheAndNetworkReturnsBothCorrectly
{
    // Cache one tweet, network response other make sure they make it through correctly
    self.stubAPIClient.responseData = [TWTRFixtureLoader singleTweetData];
    [self.stubTweetCache cacheTweets:@[[TWTRFixtureLoader gatesTweet]]];

    NSArray *tweetIDs = @[
        @"469961733323653120",  // Google Tweet
        @"468722941975592960"
    ];  // Gates Tweet

    XCTestExpectation *loadExpectation = [self expectationWithDescription:@"Load tweets expectation"];
    [self.repository loadTweetsWithIDs:tweetIDs APIClient:self.stubAPIClient additionalParameters:nil completion:^(NSArray *tweets, NSError *error) {
        TWTRTweet *tweet1 = tweets[0];
        TWTRTweet *tweet2 = tweets[1];

        XCTAssert([tweet1.tweetID isEqualToString:@"469961733323653120"]);
        XCTAssert([tweet2.tweetID isEqualToString:@"468722941975592960"]);
        [loadExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testLoadTweetsWithIDsRequestCorrectIDsFromCache
{
    TWTRTweet *obamaTweet = [TWTRFixtureLoader obamaTweet];

    [self.repository loadTweetsWithIDs:@[obamaTweet.tweetID] APIClient:self.stubAPIClient additionalParameters:nil completion:^(NSArray *tweets, NSError *error) {
        XCTAssert([self.stubTweetCache.lastRequestedID isEqualToString:obamaTweet.tweetID]);
    }];
}

- (void)testLoadTweetsWithIDsCachesTweets
{
    // Set the Google tweet data as the network response
    TWTRTweet *networkTweet = [TWTRFixtureLoader googleTweet];
    self.stubAPIClient.responseData = [TWTRFixtureLoader singleTweetData];

    [self.repository loadTweetsWithIDs:@[networkTweet.tweetID] APIClient:self.stubAPIClient additionalParameters:nil completion:^(NSArray *tweets, NSError *error) {
        // Hopefully the Google tweet has been put in the cache
        TWTRTweet *newlyCachedTweet = self.stubTweetCache.cachedTweets[networkTweet.tweetID];
        XCTAssert([newlyCachedTweet.description isEqual:networkTweet.description]);
    }];
}

#pragma mark - Error handling

- (void)testLoadTweetsWithIDsNetworkError
{
    self.stubAPIClient.responseError = [[NSError alloc] initWithDomain:TWTRAPIErrorDomain code:0 userInfo:nil];

    [self.repository loadTweetsWithIDs:@[@"tweetID"] APIClient:self.stubAPIClient additionalParameters:nil completion:^(NSArray *tweets, NSError *error) {
        XCTAssert([error.domain isEqualToString:TWTRAPIErrorDomain]);
        XCTAssert(error.code == 0);
    }];
}

- (void)testLoadTweetsWithIDsURLRequestError
{
    self.stubAPIClient.urlRequestError = [[NSError alloc] initWithDomain:@"fakeDomain" code:123 userInfo:nil];

    [self.repository loadTweetsWithIDs:@[@"tweetID"] APIClient:self.stubAPIClient additionalParameters:nil completion:^(NSArray *tweets, NSError *error) {
        XCTAssert([error.domain isEqualToString:@"fakeDomain"]);
        XCTAssert(error.code == 123);
    }];
}

- (void)testLoadTweetsWithIDsSerializationError
{
    uint8_t *bytes = malloc(sizeof(*bytes) * 1);
    // bad data length
    self.stubAPIClient.responseData = [NSData dataWithBytes:bytes length:1];

    [self.repository loadTweetsWithIDs:@[@"unusedTweetID"] APIClient:self.stubAPIClient additionalParameters:nil completion:^(NSArray *tweets, NSError *error) {
        // check for json serialization error
        XCTAssert([error.domain isEqualToString:NSCocoaErrorDomain]);
        XCTAssert(error.code == 3840);
    }];
}

// TODO: this test requires loads of setup (auth headers, etc)
//- (void)testLoadTweetsWithIDsUsesProperHeader {
//    NSArray *networkTweetIDs = [TWTRTweetRepositoryTestsTweetsIDs subarrayWithRange:NSMakeRange(0, 3)];
//
//    // Check the parameters of the network request
//    [[self.mockAPIClient expect] sendTwitterRequest:[OCMArg checkWithBlock:^BOOL(NSURLRequest *request) {
//        NSDictionary *parameters = @{@"id" : [networkTweetIDs componentsJoinedByString:@","]};
//        NSString *query = [TWTRNetworkingUtil queryStringFromParameters:parameters];
//        return [request.URL.query rangeOfString:query].location != NSNotFound;
//    }] completion:OCMOCK_ANY];
//
//    // Use the mockAPIClient
//    self.repository = [[TWTRTweetRepository alloc] initWithTwitterClient:self.mockAPIClient cache:self.stubTweetCache];
//
//    [self.repository loadTweetsWithIDs:TWTRTweetRepositoryTestsTweetsIDs completion:^(NSArray *tweets, NSError *error) {
//        [self.mockAPIClient verify];
//    }];
//}

@end
