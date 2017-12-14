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
#import <TwitterCore/TWTRAuthenticationConstants.h>
#import <TwitterCore/TWTRNetworking.h>
#import "TWTRAPIClient.h"
#import "TWTRAPIClient_Private.h"
#import "TWTRFixtureLoader.h"
#import "TWTRImageTestHelper.h"
#import "TWTRStubTwitterClient.h"
#import "TWTRTestCase.h"
#import "TWTRTestSessionStore.h"
#import "TWTRTimelineCursor.h"
#import "TWTRTwitter.h"

@interface TWTRAPIClient ()

- (void)postAppendWithMediaID:(NSString *)mediaID videoString:(NSString *)videoString completion:(TWTRMediaUploadResponseCompletion)completion;
- (void)postFinalizeWithMediaID:(NSString *)mediaID completion:(TWTRMediaUploadResponseCompletion)completion;

@end

@interface TWTRAPIClientTests : TWTRTestCase

@property (nonatomic) TWTRAPIClient *APIClient;
@property (nonatomic) TWTRStubTwitterClient *collectionClientStub;
@property (nonatomic) TWTRStubTwitterClient *userClientStub;
@property (nonatomic) TWTRStubTwitterClient *searchClientStub;
@property (nonatomic) TWTRStubTwitterClient *listClientStub;
@property (nonatomic) TWTRStubTwitterClient *noNetworkClientStub;
@property (nonatomic) TWTRStubTwitterClient *tweetActionStub;
@property (nonatomic) TWTRTestSessionStore *sessionStore;
@property (nonatomic) TWTRCardConfiguration *appCardConfig;
@property (nonatomic) TWTRStubTwitterClient *clientStub;

@end

@implementation TWTRAPIClientTests

+ (void)setUp
{
    [TWTRTwitter.sharedInstance startWithConsumerKey:@"324" consumerSecret:@"2342"];
}

- (void)setUp
{
    [super setUp];

    NSDictionary *sessionDict = @{
        TWTRAuthOAuthTokenKey: @"authToken",
        TWTRAuthOAuthSecretKey: @"authSecret",
        TWTRAuthAppOAuthUserIDKey: @"123",
        TWTRAuthAppOAuthScreenNameKey: @"screenname",
    };
    TWTRSession *session = [[TWTRSession alloc] initWithSessionDictionary:sessionDict];
    _sessionStore = [[TWTRTestSessionStore alloc] initWithUserSessions:@[session] guestSession:nil];
    _APIClient = [[TWTRAPIClient alloc] initWithSessionStore:_sessionStore userID:nil];

    self.collectionClientStub = [TWTRStubTwitterClient stubTwitterClient];
    self.collectionClientStub.responseData = [TWTRFixtureLoader oauthDancerCollectionData];

    self.userClientStub = [TWTRStubTwitterClient stubTwitterClient];
    self.userClientStub.responseData = [TWTRFixtureLoader jackUserTimelineData];

    self.searchClientStub = [TWTRStubTwitterClient stubTwitterClient];
    self.searchClientStub.responseData = [TWTRFixtureLoader blackLivesMatterSearchResultData];

    self.listClientStub = [TWTRStubTwitterClient stubTwitterClient];
    self.listClientStub.responseData = [TWTRFixtureLoader twitterSyndicationTeamListTimelineData];

    self.noNetworkClientStub = [TWTRStubTwitterClient stubTwitterClient];
    self.noNetworkClientStub.responseData = nil;
    self.noNetworkClientStub.responseError = [NSError errorWithDomain:@"com.twitter.no-connection-domain" code:999 userInfo:nil];

    self.tweetActionStub = [TWTRStubTwitterClient stubTwitterClient];

    self.clientStub = [TWTRStubTwitterClient stubTwitterClient];
}

+ (TWTRAuthConfig *)authConfig
{
    return [[TWTRAuthConfig alloc] initWithConsumerKey:@"consumerKey" consumerSecret:@"consumerSecret"];
}

- (void)testSetupSetsValues
{
    NSString *userID = @"USER";
    TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithSessionStore:self.sessionStore userID:userID];
    XCTAssertEqualObjects(client.sessionStore, self.sessionStore);
    XCTAssertEqualObjects(client.userID, userID);
}

#pragma mark - Collection

- (void)testLoadTweetsFromCollection_queriesCorrectEndpoint
{
    [self.collectionClientStub loadTweetsForCollectionID:@"1"
                                              parameters:@{}
                                   timelineFilterManager:nil
                                              completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                              }];
    XCTAssertEqualObjects([self.collectionClientStub.sentRequest.URL path], @"/1.1/collections/entries.json");
}

- (void)testLoadTweetsFromCollection_addsProperCollectionID
{
    [self.collectionClientStub loadTweetsForCollectionID:@"1"
                                              parameters:@{}
                                   timelineFilterManager:nil
                                              completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                              }];
    XCTAssertTrue([self.collectionClientStub.sentRequest.URL.query containsString:@"id=custom-1"]);
    XCTAssertTrue([self.collectionClientStub.sentRequest.URL.query containsString:@"include_cards=true"]);
}

- (void)testLoadTweetsFromCollection_acceptsNilParams
{
    [self.collectionClientStub loadTweetsForCollectionID:@"1"
                                              parameters:nil
                                   timelineFilterManager:nil
                                              completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                              }];
    XCTAssertTrue([self.collectionClientStub.sentRequest.URL.query containsString:@"id=custom-1"]);
    XCTAssertTrue([self.collectionClientStub.sentRequest.URL.query containsString:@"include_cards=true"]);
}

- (void)testLoadTweetsFromCollection_acceptsParams
{
    [self.collectionClientStub loadTweetsForCollectionID:@"1"
                                              parameters:@{@"max_position": @"123"}
                                   timelineFilterManager:nil
                                              completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                              }];
    XCTAssertTrue([self.collectionClientStub.sentRequest.URL.query containsString:@"max_position=123"]);
    XCTAssertTrue([self.collectionClientStub.sentRequest.URL.query containsString:@"id=custom-1"]);
    XCTAssertTrue([self.collectionClientStub.sentRequest.URL.query containsString:@"include_cards=true"]);
}

- (void)testLoadTweetsFromCollection_returnsTweetsFromCollection
{
    [self.collectionClientStub loadTweetsForCollectionID:@"388061495298244609"
                                              parameters:nil
                                   timelineFilterManager:nil
                                              completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error) {
                                                  XCTAssertEqual([tweets count], 5);
                                              }];
}

- (void)testLadTweetsFromCollection_returnsPerspectivalTweets
{
    [self.collectionClientStub loadTweetsForCollectionID:@"388061495298244609"
                                              parameters:nil
                                   timelineFilterManager:nil
                                              completion:^(NSArray<TWTRTweet *> *tweets, TWTRTimelineCursor *cursor, NSError *error) {
                                                  [tweets enumerateObjectsUsingBlock:^(TWTRTweet *tweet, NSUInteger idx, BOOL *stop) {
                                                      XCTAssertEqualObjects(self.collectionClientStub.userID, tweet.perspectivalUserID);
                                                  }];
                                              }];
}

- (void)testLoadTweetsFromCollection_returnsCorrectTweetIDs
{
    [self.collectionClientStub loadTweetsForCollectionID:@"388061495298244609"
                                              parameters:nil
                                   timelineFilterManager:nil
                                              completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error) {
                                                  XCTAssertEqualObjects(((TWTRTweet *)tweets[0]).tweetID, @"390898463090561024");
                                                  XCTAssertEqualObjects(((TWTRTweet *)tweets[1]).tweetID, @"390892747810295808");
                                                  XCTAssertEqualObjects(((TWTRTweet *)tweets[2]).tweetID, @"390853164611555329");
                                                  XCTAssertEqualObjects(((TWTRTweet *)tweets[3]).tweetID, @"390897780949925889");
                                                  XCTAssertEqualObjects(((TWTRTweet *)tweets[4]).tweetID, @"390890231215292416");
                                              }];
}

- (void)testLoadTweetsFromCollection_returnsCorrectCursor
{
    [self.collectionClientStub loadTweetsForCollectionID:@"388061495298244609"
                                              parameters:nil
                                   timelineFilterManager:nil
                                              completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error) {
                                                  XCTAssertEqualObjects(cursor.minPosition, @"362630905752971520");
                                              }];
}

#pragma mark - Search Query

- (void)testLoadTweetsForSearchQuery_queriesCorrectEndpoint
{
    [self.searchClientStub loadTweetsForSearchQuery:@"twitter"
                                         parameters:nil
                              timelineFilterManager:nil
                                         completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                         }];
    XCTAssertEqualObjects([self.searchClientStub.sentRequest.URL path], @"/1.1/search/tweets.json");
}

- (void)testLoadTweetsForSearchQuery_acceptsNilParams
{
    [self.searchClientStub loadTweetsForSearchQuery:@"twitterapi"
                                         parameters:nil
                              timelineFilterManager:nil
                                         completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                         }];
    XCTAssertTrue([self.searchClientStub.sentRequest.URL.query containsString:@"q=twitterapi"]);
    XCTAssertTrue([self.searchClientStub.sentRequest.URL.query containsString:@"include_cards=true"]);
}

- (void)testLoadTweetsForSearchQuery_acceptsParams
{
    [self.searchClientStub loadTweetsForSearchQuery:@"twitterapi"
                                         parameters:@{@"result_type": @"recent"}
                              timelineFilterManager:nil
                                         completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                         }];
    XCTAssertTrue([self.searchClientStub.sentRequest.URL.query containsString:@"q=twitterapi&result_type=recent"]);
    XCTAssertTrue([self.searchClientStub.sentRequest.URL.query containsString:@"include_cards=true"]);
}

- (void)testLoadTweetsForSearchQuery_returnsTweets
{
    [self.searchClientStub loadTweetsForSearchQuery:@"black lives matter"
                                         parameters:nil
                              timelineFilterManager:nil
                                         completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error) {
                                             XCTAssertEqual([tweets count], 15);
                                         }];
}

- (void)testLadTweetsFromSearchQuery_returnsPerspectivalTweets
{
    [self.searchClientStub loadTweetsForSearchQuery:@"twitterapi"
                                         parameters:nil
                              timelineFilterManager:nil
                                         completion:^(NSArray<TWTRTweet *> *tweets, TWTRTimelineCursor *cursor, NSError *error) {
                                             [tweets enumerateObjectsUsingBlock:^(TWTRTweet *tweet, NSUInteger idx, BOOL *stop) {
                                                 XCTAssertEqualObjects(self.searchClientStub.userID, tweet.perspectivalUserID);
                                             }];
                                         }];
}

#pragma mark - User Timeline

- (void)testLoadTweetsFromUserTimeline_queriesCorrectEndpoint
{
    [self.userClientStub loadTweetsForUserTimeline:@"jack"
                                            userID:nil
                                        parameters:@{}
                             timelineFilterManager:nil
                                        completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                        }];
    XCTAssertEqualObjects([self.userClientStub.sentRequest.URL path], @"/1.1/statuses/user_timeline.json");
}

- (void)testLoadTweetsFromUserTimeline_addUserScreenName
{
    [self.userClientStub loadTweetsForUserTimeline:@"jack"
                                            userID:nil
                                        parameters:@{}
                             timelineFilterManager:nil
                                        completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                        }];
    XCTAssertTrue([self.userClientStub.sentRequest.URL.query containsString:@"screen_name=jack"]);
    XCTAssertTrue([self.userClientStub.sentRequest.URL.query containsString:@"include_cards=true"]);
}

- (void)testLoadTweetsFromUserTimeline_acceptsNilParam
{
    [self.userClientStub loadTweetsForUserTimeline:@"jack"
                                            userID:nil
                                        parameters:nil
                             timelineFilterManager:nil
                                        completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                        }];
    XCTAssertTrue([self.userClientStub.sentRequest.URL.query containsString:@"screen_name=jack"]);
    XCTAssertTrue([self.userClientStub.sentRequest.URL.query containsString:@"include_cards=true"]);
}

- (void)testLoadTweetsFromUserTimeline_acceptsParams
{
    [self.userClientStub loadTweetsForUserTimeline:@"jack"
                                            userID:nil
                                        parameters:@{@"exclude_replies": @"true", @"include_rts": @"true"}
                             timelineFilterManager:nil
                                        completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                        }];
    XCTAssertTrue([self.userClientStub.sentRequest.URL.query containsString:@"exclude_replies=true"]);
    XCTAssertTrue([self.userClientStub.sentRequest.URL.query containsString:@"include_rts=true"]);
    XCTAssertTrue([self.userClientStub.sentRequest.URL.query containsString:@"screen_name=jack"]);
    XCTAssertTrue([self.userClientStub.sentRequest.URL.query containsString:@"include_cards=true"]);
}

- (void)testLadTweetsFromUserTimeline_returnsPerspectivalTweets
{
    [self.userClientStub loadTweetsForUserTimeline:@"jack"
                                            userID:nil
                                        parameters:nil
                             timelineFilterManager:nil
                                        completion:^(NSArray<TWTRTweet *> *tweets, TWTRTimelineCursor *cursor, NSError *error) {
                                            [tweets enumerateObjectsUsingBlock:^(TWTRTweet *tweet, NSUInteger idx, BOOL *stop) {
                                                XCTAssertEqualObjects(self.userClientStub.userID, tweet.perspectivalUserID);
                                            }];
                                        }];
}

#pragma mark - List Timeline

- (void)testLoadTweetsFromListTimeline_listIDQueriesCorrectEndpoint
{
    [self.listClientStub loadTweetsForListID:@"123"
                                  parameters:@{}
                       timelineFilterManager:nil
                                  completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                  }];
    XCTAssertEqualObjects([self.listClientStub.sentRequest.URL path], @"/1.1/lists/statuses.json");
}

- (void)testLoadTweetsFromListTimeline_addListID
{
    [self.listClientStub loadTweetsForListID:@"123"
                                  parameters:@{}
                       timelineFilterManager:nil
                                  completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                  }];
    XCTAssertTrue([self.listClientStub.sentRequest.URL.query containsString:@"list_id=123"]);
    XCTAssertTrue([self.listClientStub.sentRequest.URL.query containsString:@"include_cards=true"]);
}

- (void)testLoadTweetsFromListTimeline_listSlugQueriesCorrectEndpoint
{
    [self.listClientStub loadTweetsForListSlug:@"slug"
                           listOwnerScreenName:@"screenname"
                                    parameters:@{}
                         timelineFilterManager:nil
                                    completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                    }];
    XCTAssertEqualObjects([self.listClientStub.sentRequest.URL path], @"/1.1/lists/statuses.json");
}

- (void)testLoadTweetsFromListTimeline_addListSlugAndScreenname
{
    [self.listClientStub loadTweetsForListSlug:@"slug"
                           listOwnerScreenName:@"screenname"
                                    parameters:@{}
                         timelineFilterManager:nil
                                    completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                    }];
    XCTAssertTrue([self.listClientStub.sentRequest.URL.query containsString:@"owner_screen_name=screenname&slug=slug"]);
    XCTAssertTrue([self.listClientStub.sentRequest.URL.query containsString:@"include_cards=true"]);
}

- (void)testLoadTweetsFromListTimeline_acceptsNilParam
{
    [self.listClientStub loadTweetsForListID:@"123"
                                  parameters:nil
                       timelineFilterManager:nil
                                  completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                  }];
    XCTAssertTrue([self.listClientStub.sentRequest.URL.query containsString:@"list_id=123"]);
    XCTAssertTrue([self.listClientStub.sentRequest.URL.query containsString:@"include_cards=true"]);
}

- (void)testLoadTweetsFromListTimeline_acceptsParams
{
    [self.listClientStub loadTweetsForListID:@"123"
                                  parameters:@{@"include_rts": @"false", @"count": @"1"}
                       timelineFilterManager:nil
                                  completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                  }];
    XCTAssertTrue([self.listClientStub.sentRequest.URL.query containsString:@"count=1"]);
    XCTAssertTrue([self.listClientStub.sentRequest.URL.query containsString:@"include_rts=false"]);
    XCTAssertTrue([self.listClientStub.sentRequest.URL.query containsString:@"list_id=123"]);
    XCTAssertTrue([self.listClientStub.sentRequest.URL.query containsString:@"include_cards=true"]);
}

- (void)testLoadTweetsFromListTimeline_returnsPerspectivalTweets
{
    [self.listClientStub loadTweetsForListID:@"123"
                                  parameters:nil
                       timelineFilterManager:nil
                                  completion:^(NSArray<TWTRTweet *> *tweets, TWTRTimelineCursor *cursor, NSError *error) {
                                      [tweets enumerateObjectsUsingBlock:^(TWTRTweet *tweet, NSUInteger idx, BOOL *stop) {
                                          XCTAssertEqualObjects(self.listClientStub.userID, tweet.perspectivalUserID);
                                      }];
                                  }];
}

#pragma mark - No Network Tests
- (void)testNoNetworkConnection_loadTweetsForCollectionID
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"should return from network request in timeout"];

    [self.noNetworkClientStub loadTweetsForCollectionID:@"123"
                                             parameters:nil
                                  timelineFilterManager:nil
                                             completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error) {
                                                 XCTAssertNil(tweets);
                                                 XCTAssertNil(cursor);
                                                 XCTAssertEqualObjects(error, self.noNetworkClientStub.responseError);
                                                 [expectation fulfill];
                                             }];

    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testNoNetworkConnection_loadTweetsForSearchQuery
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"should return from network request in timeout"];

    [self.noNetworkClientStub loadTweetsForSearchQuery:@"fabric"
                                            parameters:nil
                                 timelineFilterManager:nil
                                            completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error) {
                                                XCTAssertNil(tweets);
                                                XCTAssertNil(cursor);
                                                XCTAssertEqualObjects(error, self.noNetworkClientStub.responseError);
                                                [expectation fulfill];
                                            }];

    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testNoNetworkConnection_loadTweetsForUserTimeline
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"should return from network request in timeout"];

    [self.noNetworkClientStub loadTweetsForUserTimeline:@"jack"
                                                 userID:nil
                                             parameters:nil
                                  timelineFilterManager:nil
                                             completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error) {
                                                 XCTAssertNil(tweets);
                                                 XCTAssertNil(cursor);
                                                 XCTAssertEqualObjects(error, self.noNetworkClientStub.responseError);
                                                 [expectation fulfill];
                                             }];

    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

#pragma mark - JSON loading tests

- (void)testJSONLoading_malformedRequest
{
    TWTRStubTwitterClient *stub = [TWTRStubTwitterClient stubTwitterClient];
    stub.urlRequestError = [NSError errorWithDomain:@"com.twitter.api-tests-domain" code:999 userInfo:nil];

    XCTestExpectation *expectation = [self expectationWithDescription:@"should have returned from loadJSONFromAPIPath:..."];

    [stub loadJSONArrayFromAPIPath:@"/path"
                        parameters:nil
                        completion:^(NSURLResponse *response, id responseObject, NSError *error) {
                            XCTAssertNil(response);
                            XCTAssertNil(responseObject);
                            XCTAssertEqualObjects(error, stub.urlRequestError);
                            [expectation fulfill];
                        }];

    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testJSONDictionaryLoading
{
    NSDictionary *dictionary = @{@"user": @"jack"};
    TWTRStubTwitterClient *stub = [self stubWithObjectResponseData:dictionary];

    XCTestExpectation *expectation = [self expectationWithDescription:@"should have returned from load..."];
    [stub loadJSONDictionaryFromAPIPath:@"/user"
                             parameters:dictionary
                             completion:^(NSURLResponse *response, id responseObject, NSError *error) {
                                 XCTAssertEqualObjects(responseObject, dictionary);
                                 XCTAssertNil(error);
                                 [expectation fulfill];
                             }];

    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testJSONDictionaryLoading_invalidClass
{
    TWTRStubTwitterClient *stub = [self stubWithObjectResponseData:@[]];

    XCTestExpectation *expectation = [self expectationWithDescription:@"should have returned from load..."];
    [stub loadJSONDictionaryFromAPIPath:@"/user"
                             parameters:nil
                             completion:^(NSURLResponse *response, id responseObject, NSError *error) {
                                 XCTAssertNil(responseObject);
                                 XCTAssertEqual(error.code, TWTRErrorCodeMismatchedJSONType);
                                 [expectation fulfill];
                             }];

    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testJSONArrayLoading
{
    NSArray *array = @[@"user_1"];
    TWTRStubTwitterClient *stub = [self stubWithObjectResponseData:array];

    XCTestExpectation *expectation = [self expectationWithDescription:@"should have returned from load..."];
    [stub loadJSONArrayFromAPIPath:@"/user"
                        parameters:nil
                        completion:^(NSURLResponse *response, id responseObject, NSError *error) {
                            XCTAssertEqualObjects(responseObject, array);
                            XCTAssertNil(error);
                            [expectation fulfill];
                        }];

    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testJSONArrayLoading_invalidClass
{
    TWTRStubTwitterClient *stub = [self stubWithObjectResponseData:@{}];

    XCTestExpectation *expectation = [self expectationWithDescription:@"should have returned from load..."];
    [stub loadJSONArrayFromAPIPath:@"/user"
                        parameters:nil
                        completion:^(NSURLResponse *response, id responseObject, NSError *error) {

                            XCTAssertNil(responseObject);
                            XCTAssertEqual(error.code, TWTRErrorCodeMismatchedJSONType);
                            [expectation fulfill];
                        }];

    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testJSONLoading_noNetwork
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"should have returned from load..."];
    [self.noNetworkClientStub loadJSONArrayFromAPIPath:@"/user"
                                            parameters:nil
                                            completion:^(NSURLResponse *response, id responseObject, NSError *error) {
                                                XCTAssertNil(response);
                                                XCTAssertNil(responseObject);
                                                XCTAssertEqualObjects(error, self.noNetworkClientStub.responseError);
                                                [expectation fulfill];
                                            }];

    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

#pragma mark - Like/Unlike

- (void)testLikeTweet_requestsProperURL
{
    [self.tweetActionStub likeTweetWithID:@"1234"
                               completion:^(TWTRTweet *tweet, NSError *error){
                               }];
    XCTAssertEqualObjects([self.tweetActionStub.sentRequest.URL absoluteString], @"https://api.twitter.com/1.1/favorites/create.json");
}

- (void)testLikeTweet_requestsProperID
{
    [self.tweetActionStub likeTweetWithID:@"1234"
                               completion:^(TWTRTweet *tweet, NSError *error){
                               }];
    NSString *requestBody = [[NSString alloc] initWithData:self.tweetActionStub.sentRequest.HTTPBody encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(requestBody, @"id=1234");
}

- (void)testLikeTweet_usesPOST
{
    [self.tweetActionStub likeTweetWithID:@"1234"
                               completion:^(TWTRTweet *tweet, NSError *error){
                               }];
    XCTAssertEqualObjects(self.tweetActionStub.sentRequest.HTTPMethod, @"POST");
}

- (void)testUnlikeTweet_requestsProperURL
{
    [self.tweetActionStub unlikeTweetWithID:@"1234"
                                 completion:^(TWTRTweet *tweet, NSError *error){
                                 }];
    XCTAssertEqualObjects([self.tweetActionStub.sentRequest.URL absoluteString], @"https://api.twitter.com/1.1/favorites/destroy.json");
}

- (void)testUnlikeTweet_requestsProperID
{
    [self.tweetActionStub unlikeTweetWithID:@"1234"
                                 completion:^(TWTRTweet *tweet, NSError *error){
                                 }];
    NSString *requestBody = [[NSString alloc] initWithData:self.tweetActionStub.sentRequest.HTTPBody encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(requestBody, @"id=1234");
}

- (void)testUnlikeTweet_usesPOST
{
    [self.tweetActionStub unlikeTweetWithID:@"1234"
                                 completion:^(TWTRTweet *tweet, NSError *error){
                                 }];
    XCTAssertEqualObjects(self.tweetActionStub.sentRequest.HTTPMethod, @"POST");
}

- (void)testLikeTweet_returnsPerspectivalUser
{
    [self assertPerspectivalUserForActionsWithBlock:^(TWTRAPIClient *APIClient, TWTRTweet *tweet, XCTestExpectation *expectation) {
        [self.tweetActionStub likeTweetWithID:tweet.tweetID
                                   completion:^(TWTRTweet *likedTweet, NSError *error) {
                                       XCTAssertEqualObjects(self.tweetActionStub.userID, likedTweet.perspectivalUserID);
                                       [expectation fulfill];
                                   }];
    }];
}

- (void)testUnlikeTweet_returnsPerspectivalUser
{
    [self assertPerspectivalUserForActionsWithBlock:^(TWTRAPIClient *APIClient, TWTRTweet *tweet, XCTestExpectation *expectation) {
        [self.tweetActionStub unlikeTweetWithID:tweet.tweetID
                                     completion:^(TWTRTweet *unlikedTweet, NSError *error) {
                                         XCTAssertEqualObjects(self.tweetActionStub.userID, unlikedTweet.perspectivalUserID);
                                         [expectation fulfill];
                                     }];
    }];
}

#pragma mark - Retweet/Unretweet

- (void)testRetweetTweet_requestsProperURL
{
    [self.tweetActionStub retweetTweetWithID:@"1234"
                                  completion:^(TWTRTweet *tweet, NSError *error){
                                  }];
    XCTAssertEqualObjects([self.tweetActionStub.sentRequest.URL absoluteString], @"https://api.twitter.com/1.1/statuses/retweet/1234.json");
}

- (void)testUnretweetTweet_requestsProperURL
{
    [self.tweetActionStub unretweetTweetWithID:@"1234"
                                    completion:^(TWTRTweet *tweet, NSError *error){
                                    }];
    XCTAssertEqualObjects([self.tweetActionStub.sentRequest.URL absoluteString], @"https://api.twitter.com/1.1/statuses/unretweet/1234.json");
}

- (void)testRetweetTweet_returnsPerspectivalUser
{
    [self assertPerspectivalUserForActionsWithBlock:^(TWTRAPIClient *APIClient, TWTRTweet *tweet, XCTestExpectation *expectation) {
        [self.tweetActionStub unretweetTweetWithID:tweet.tweetID
                                        completion:^(TWTRTweet *unretweetedTweet, NSError *error) {
                                            XCTAssertEqualObjects(self.tweetActionStub.userID, unretweetedTweet.perspectivalUserID);
                                            [expectation fulfill];
                                        }];
    }];
}

- (void)testUnretweetTweet_returnsPerspectivalUser
{
    [self assertPerspectivalUserForActionsWithBlock:^(TWTRAPIClient *APIClient, TWTRTweet *tweet, XCTestExpectation *expectation) {
        [self.tweetActionStub retweetTweetWithID:tweet.tweetID
                                      completion:^(TWTRTweet *retweetedTweet, NSError *error) {
                                          XCTAssertEqualObjects(self.tweetActionStub.userID, retweetedTweet.perspectivalUserID);
                                          [expectation fulfill];
                                      }];
    }];
}

- (void)assertPerspectivalUserForActionsWithBlock:(void (^)(TWTRAPIClient *APIClient, TWTRTweet *tweet, XCTestExpectation *expectation))actionBlock
{
    TWTRTweet *tweet = [TWTRFixtureLoader obamaTweet];
    self.tweetActionStub.responseData = [TWTRFixtureLoader obamaTweetData];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Tweet should have perspectivalUserID set"];
    actionBlock(self.tweetActionStub, tweet, expectation);
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

#pragma mark - Network Configuration

- (void)testAPIClientHasTwitterKitUserAgent
{
    NSURLSession *URLSession = [TWTRAPIClient URLSession];
    NSURLSessionConfiguration *configuration = URLSession.configuration;
    NSString *const userAgentHeader = configuration.HTTPAdditionalHeaders[@"User-Agent"];
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@".*TwitterKit\\/\\d+\\.\\d+\\.\\d+$" options:0 error:&error];
    NSArray *matches = [regex matchesInString:userAgentHeader options:0 range:NSMakeRange(0, [userAgentHeader length])];
    NSUInteger matchCount = [matches count];

    XCTAssertEqual(matchCount, 1);
}

#pragma mark - Request Email

- (void)testRequestEmail
{
    NSString *expectedEmail = @"user@twitter.com";
    TWTRStubTwitterClient *stub = [self stubWithObjectResponseData:@{@"email": expectedEmail}];

    [stub requestEmailForCurrentUser:^(NSString *_Nullable email, NSError *_Nullable error) {
        XCTAssertEqualObjects(email, expectedEmail);
        XCTAssertNil(error);
    }];
}

- (void)testRequestEmail_missingEmail
{
    TWTRStubTwitterClient *stub = [self stubWithObjectResponseData:@{}];

    [stub requestEmailForCurrentUser:^(NSString *_Nullable email, NSError *_Nullable error) {
        XCTAssertNil(email);
        XCTAssertEqual(error.code, TWTRErrorCodeUserHasNoEmailAddress);
    }];
}

#pragma mark - Sent Tweet

- (void)testSendTweet_requestsProperURL
{
    [self.clientStub sendTweetWithText:@"1234"
                            completion:^(TWTRTweet *tweet, NSError *error){
                            }];
    XCTAssertEqualObjects([self.clientStub.sentRequest.URL absoluteString], @"https://api.twitter.com/1.1/statuses/update.json");
}

- (void)testSendTweet_usesPOST
{
    [self.clientStub sendTweetWithText:@"1234"
                            completion:^(TWTRTweet *tweet, NSError *error){
                            }];
    XCTAssertEqualObjects(self.clientStub.sentRequest.HTTPMethod, @"POST");
}

- (void)testSendTweet_usesCorrectParam
{
    [self.clientStub sendTweetWithText:@"fake text"
                            completion:^(TWTRTweet *tweet, NSError *error){
                            }];
    XCTAssertEqualObjects([self.clientStub sentHTTPBodyString], @"status=fake%20text");
}

- (void)testSendTweet_withSpecialCharacter
{
    [self.clientStub sendTweetWithText:@"fake^text"
                            completion:^(TWTRTweet *tweet, NSError *error){
                            }];
    XCTAssertEqualObjects([self.clientStub sentHTTPBodyString], @"status=fake%5Etext");
}

- (void)testSendTweet
{
    self.clientStub.responseData = [TWTRFixtureLoader obamaTweetData];
    [self.clientStub sendTweetWithText:@"Tweet text"
                            completion:^(TWTRTweet *tweet, NSError *error) {
                                XCTAssertEqualObjects(tweet.text, @"Four more years. http://t.co/bAJE6Vom");
                            }];
}

- (void)testSendTweetWithImage_callsCompletionWithError
{
    NSError *fakeError = [NSError errorWithDomain:TWTRErrorDomain code:0 userInfo:nil];
    self.clientStub.responseError = fakeError;

    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"Completion block called."];
    [self.clientStub sendTweetWithText:@"Text"
                                 image:[UIImage new]
                            completion:^(TWTRTweet *tweet, NSError *uploadError) {
                                XCTAssertEqualObjects(fakeError, uploadError);
                                [completionExpectation fulfill];
                            }];

    [self waitForExpectations:@[completionExpectation] timeout:0.1];
}

- (void)testSendTweetWithImage_sendsMediaId
{
    [self.clientStub sendTweetWithText:@"Text"
                                 image:[UIImage new]
                            completion:^(TWTRTweet *tweet, NSError *uploadError){
                            }];

    XCTAssertEqualObjects([self.clientStub sentHTTPBodyString], @"media_ids=982389&status=Text");
}

- (void)testUploadVideo
{
    // TODO: Get actual videoData from TSE video test patch later
    [self.clientStub uploadVideoWithVideoData:[TWTRFixtureLoader userResponseData]
                                   completion:^(NSString *mediaID, NSError *error){
                                   }];

    XCTAssertEqualObjects([self.clientStub.sentRequest.URL absoluteString], @"https://upload.twitter.com/1.1/media/upload.json");
    XCTAssertEqualObjects(self.clientStub.sentRequest.HTTPMethod, @"POST");
    NSString *expectedHTTPBody = @"command=INIT&media_type=video%2Fmp4&total_bytes=4959";
    XCTAssertEqualObjects([self.clientStub sentHTTPBodyString], expectedHTTPBody);
}

- (void)testSendTweetWithVideo_PostAppend
{
    // TODO: Make a Mock object to test if the APPEND call is made in the process.
    [self.clientStub postAppendWithMediaID:@"fakeID"
                               videoString:@"fakeVideoString"
                                completion:^(NSString *mediaID, NSError *error){
                                }];

    XCTAssertEqualObjects([self.clientStub.sentRequest.URL absoluteString], @"https://upload.twitter.com/1.1/media/upload.json");
    XCTAssertEqualObjects(self.clientStub.sentRequest.HTTPMethod, @"POST");
    //    XCTAssertEqualObjects([self.clientStub sentHTTPBodyString], @"command=APPEND&media=fakeVideoString&media_id=fakeID&segment_index=0");
    XCTAssertEqualObjects([self.clientStub sentHTTPBodyString], @"command=FINALIZE&media_id=fakeID");
}

- (void)testSendTweetWithVideo_PostFinalize
{
    [self.clientStub postFinalizeWithMediaID:@"fakeID"
                                  completion:^(NSString *mediaID, NSError *error){
                                  }];

    XCTAssertEqualObjects([self.clientStub.sentRequest.URL absoluteString], @"https://upload.twitter.com/1.1/media/upload.json");
    XCTAssertEqualObjects(self.clientStub.sentRequest.HTTPMethod, @"POST");
    XCTAssertEqualObjects([self.clientStub sentHTTPBodyString], @"command=FINALIZE&media_id=fakeID");
}

- (void)testSendTweetWithMediaID
{
    [self.clientStub sendTweetWithText:@"tweet"
                               mediaID:@"fakeID"
                            completion:^(TWTRTweet *_Nullable tweet, NSError *_Nullable error){
                            }];
    XCTAssertEqualObjects([self.clientStub.sentRequest.URL absoluteString], @"https://api.twitter.com/1.1/statuses/update.json");
    XCTAssertEqualObjects(self.clientStub.sentRequest.HTTPMethod, @"POST");
    XCTAssertEqualObjects([self.clientStub sentHTTPBodyString], @"media_ids=fakeID&status=tweet");
}
#pragma mark - Helper

- (TWTRStubTwitterClient *)stubWithObjectResponseData:(id)obj
{
    TWTRStubTwitterClient *stub = [TWTRStubTwitterClient stubTwitterClient];
    stub.responseData = [NSJSONSerialization dataWithJSONObject:obj options:0 error:nil];

    return stub;
}

@end
