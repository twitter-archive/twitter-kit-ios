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
#import "TWTRAuthConfig.h"
#import "TWTRAuthenticationConstants.h"
#import "TWTRFakeAPIServiceConfig.h"
#import "TWTRGuestSession.h"
#import "TWTRIdentifier.h"
#import "TWTRNetworking.h"
#import "TWTRNetworkingPipeline.h"
#import "TWTRScribeClientEventNamespace.h"
#import "TWTRScribeClientEventNamespace_Private.h"
#import "TWTRScribeEvent.h"
#import "TWTRScribeService.h"
#import "TWTRSession.h"
#import "TWTRSessionStore.h"
#import "TWTRTestCase.h"

@interface TWTRScribeServiceTests : TWTRTestCase

@property (nonatomic) TWTRScribeClientEventNamespace *loadTweet;
@property (nonatomic) id invalidSubject;
@property (nonatomic) id subject;

@property (nonatomic) id storeMock;
@property (nonatomic) id pipelineMock;
@property (nonatomic) id scribeMock;

@property (nonatomic) NSURL *scribeURL;

@end

@interface TWTRScribeService ()

@property (nonatomic, strong) TFSScribe *scribe;

- (void)handleScribeOutgoingEvents:(NSString *)outgoingEvents userID:(NSString *)userID completionHandler:(TFSScribeRequestCompletionBlock)completionHandler;
- (void)mainThreadHandleScribeOutgoingEvents:(NSString *)outgoingEvents userID:(NSString *)userID completionHandler:(TFSScribeRequestCompletionBlock)completionHandler;

- (void)sendGuestRequestWithAPIClient:(TWTRNetworking *)apiClient params:(NSDictionary *)requestBodyParams completion:(TWTRTwitterNetworkCompletion)completionHandler;

- (NSURLRequest *)scribeServiceRequestParameters:(NSDictionary *)parameters;

- (void)scribePendingEvents;
- (NSArray *)existingUserIDs;

@end

@interface TFSScribe ()

- (void)_setupManagedObjectContext;

@end

@implementation TWTRScribeServiceTests

- (void)setUp
{
    [super setUp];

    self.loadTweet = [[TWTRScribeClientEventNamespace alloc] initWithClient:TWTRScribeEventImpressionClient page:TWTRScribeEventImpressionPage section:TWTRScribeEventImpressionSectionTweet component:TWTRScribeEventImpressionComponent element:TWTRScribeEmptyKey action:TWTRScribeEventImpressionTypeLoad];

    TWTRFakeAPIServiceConfig *apiServiceConfig = [[TWTRFakeAPIServiceConfig alloc] init];

    TFSScribe *scribe = [[TFSScribe alloc] initWithStoreURL:nil];
    _scribeMock = [OCMockObject partialMockForObject:scribe];
    [[self.scribeMock stub] _setupManagedObjectContext];

    TWTRScribeService *service = [[TWTRScribeService alloc] initWithScribe:self.scribeMock scribeAPIServiceConfig:apiServiceConfig];
    self.subject = OCMPartialMock(service);

    self.storeMock = OCMClassMock([TWTRSessionStore class]);
    self.pipelineMock = OCMClassMock([TWTRNetworkingPipeline class]);
    [self.subject setSessionStore:self.storeMock networkingPipeline:self.pipelineMock];

    self.invalidSubject = [[TWTRScribeService alloc] initWithScribe:self.scribeMock scribeAPIServiceConfig:apiServiceConfig];

    self.scribeURL = TWTRAPIURLWithPath(apiServiceConfig, @"/i/jot/sdk");
}

- (void)tearDown
{
    [self.storeMock stopMocking];
    [self.pipelineMock stopMocking];
    [super tearDown];
}

- (void)testScribeEventUserIDOnlyChangesIfNil
{
    TWTRScribeEvent *scribeEvent = [[TWTRScribeEvent alloc] initWithUserID:@"1" tweetID:@"1" category:TWTRScribeEventCategoryImpressions eventNamespace:self.loadTweet items:@[]];
    XCTAssertEqual(@"1", scribeEvent.userID, @"User ID should be 1");
}

- (void)testScribeEventNilUserIDResultsInGuestID
{
    TWTRScribeEvent *scribeEvent = [[TWTRScribeEvent alloc] initWithUserID:nil tweetID:@"1" category:TWTRScribeEventCategoryImpressions eventNamespace:self.loadTweet items:@[]];
    XCTAssertEqual(@"0", scribeEvent.userID, @"User ID shouldn't be nil");
}

- (void)testScribeEventDescription
{
    TWTRScribeEvent *scribeEvent = [[TWTRScribeEvent alloc] initWithUserID:@"0" tweetID:@"1" category:TWTRScribeEventCategoryImpressions eventNamespace:self.loadTweet items:@[]];
    XCTAssertNotNil([scribeEvent description]);
}

- (void)testEnqueueNilEvent
{
    id scribe = [OCMockObject mockForClass:[TFSScribe class]];

    [[[self.subject stub] andReturn:scribe] scribe];

    XCTAssertNoThrow([self.subject enqueueEvent:nil], @"Enqueuing a nil event should not throw an exception or call enqueueEvent:");
    [scribe verify];
}

- (void)testEnqueueNilEvents
{
    id scribe = [OCMockObject mockForClass:[TFSScribe class]];

    [[[self.subject stub] andReturn:scribe] scribe];

    XCTAssertNoThrow([self.subject enqueueEvents:nil], @"Enqueuing nil events should not throw an exception or call enqueueEvent:");
    [scribe verify];
}

- (void)testEnqueueNonEventsShouldNotThrowOrEnqueue
{
    id scribe = [OCMockObject mockForClass:[TFSScribe class]];

    [[[self.subject stub] andReturn:scribe] scribe];

    TWTRScribeEvent *scribeEvent = [[TWTRScribeEvent alloc] initWithUserID:@"0" tweetID:@"1" category:TWTRScribeEventCategoryImpressions eventNamespace:self.loadTweet items:@[]];
    NSArray *events = @[scribeEvent, @"1"];
    XCTAssertNoThrow([self.subject enqueueEvents:events], @"Attempting to enqueue a non-TFSScribeEventParameters should not throw or call enqueueEvent:");
    [scribe verify];
}

- (void)testEnqueueEventsShouldEnqueue
{
    id scribe = [OCMockObject mockForClass:[TFSScribe class]];
    [[scribe expect] enqueueEvent:OCMOCK_ANY];

    [[[self.subject stub] andReturn:scribe] scribe];

    TWTRScribeEvent *scribeEvent = [[TWTRScribeEvent alloc] initWithUserID:@"0" tweetID:@"1" category:TWTRScribeEventCategoryImpressions eventNamespace:self.loadTweet items:@[]];
    NSArray *events = @[scribeEvent];
    XCTAssertNoThrow([self.subject enqueueEvents:events], @"Attempting to enqueue a non-TFSScribeEventParameters should not throw or call enqueueEvent:");
    [scribe verify];
}

- (void)testPollingHeadersInScribeRequests
{
    NSURLRequest *request = [self.subject scribeServiceRequestParameters:@{}];

    NSDictionary *headers = request.allHTTPHeaderFields;
    NSString *pollingHeaderValue = headers[@"X-Twitter-Polling"];

    XCTAssertEqualObjects(pollingHeaderValue, @"true");
}

- (void)testEnqueuePipelineEvents_withNilSession
{
    [self.subject setSessionStore:self.storeMock networkingPipeline:self.pipelineMock];

    OCMStub([self.storeMock session]).andReturn(nil);
    OCMExpect([self.pipelineMock enqueueRequest:OCMOCK_ANY sessionStore:self.storeMock requestingUser:nil completion:OCMOCK_ANY]);

    [self.subject mainThreadHandleScribeOutgoingEvents:@"events"
                                                userID:nil
                                     completionHandler:^(TFSScribeServiceRequestDisposition disposition){
                                     }];
    OCMVerifyAll(self.pipelineMock);
}

- (void)testSendEvents_checkDispositionSuccess
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"callback"];

    OCMStub([self.pipelineMock enqueueRequest:OCMOCK_ANY sessionStore:self.storeMock requestingUser:OCMOCK_ANY completion:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
        TWTRNetworkingPipelineCallback callback;
        [invocation getArgument:&callback atIndex:invocation.methodSignature.numberOfArguments - 1];
        NSData *data = [@"" dataUsingEncoding:NSUTF8StringEncoding];
        NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@""] statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:nil];
        callback(data, response, nil);
    });

    [self.subject handleScribeOutgoingEvents:@"events"
                                      userID:@"1"
                           completionHandler:^(TFSScribeServiceRequestDisposition disposition) {
                               XCTAssertEqual(disposition, TFSScribeServiceRequestDispositionSuccess);
                               [expectation fulfill];
                           }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testSendEvents_checkDispositionServerErrorOverCapacity
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"callback"];

    OCMStub([self.pipelineMock enqueueRequest:OCMOCK_ANY sessionStore:self.storeMock requestingUser:OCMOCK_ANY completion:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
        TWTRNetworkingPipelineCallback callback;
        [invocation getArgument:&callback atIndex:invocation.methodSignature.numberOfArguments - 1];
        NSData *data = [@"" dataUsingEncoding:NSUTF8StringEncoding];
        NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@""] statusCode:503 HTTPVersion:@"HTTP/1.1" headerFields:nil];
        callback(data, response, nil);
    });

    [self.subject handleScribeOutgoingEvents:@"events"
                                      userID:@"1"
                           completionHandler:^(TFSScribeServiceRequestDisposition disposition) {
                               XCTAssertEqual(disposition, TFSScribeServiceRequestDispositionSuccess);
                               [expectation fulfill];
                           }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testSendEvents_checkDispositionServerErrorDelay
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"callback"];

    OCMStub([self.pipelineMock enqueueRequest:OCMOCK_ANY sessionStore:self.storeMock requestingUser:OCMOCK_ANY completion:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
        TWTRNetworkingPipelineCallback callback;
        [invocation getArgument:&callback atIndex:invocation.methodSignature.numberOfArguments - 1];
        NSData *data = [@"" dataUsingEncoding:NSUTF8StringEncoding];
        NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@""] statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:@{@"X-CLIENT-EVENT-ENABLED": @"YES"}];
        NSError *error = [NSError errorWithDomain:@"test" code:1 userInfo:nil];
        callback(data, response, error);
    });

    [self.subject handleScribeOutgoingEvents:@"events"
                                      userID:@"1"
                           completionHandler:^(TFSScribeServiceRequestDisposition disposition) {
                               XCTAssertEqual(disposition, TFSScribeServiceRequestDispositionServerError);
                               [expectation fulfill];
                           }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testSendEvents_checkDispositionClientError
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"callback"];

    OCMStub([self.pipelineMock enqueueRequest:OCMOCK_ANY sessionStore:self.storeMock requestingUser:OCMOCK_ANY completion:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
        TWTRNetworkingPipelineCallback callback;
        [invocation getArgument:&callback atIndex:invocation.methodSignature.numberOfArguments - 1];
        NSError *error = [NSError errorWithDomain:@"test" code:1 userInfo:nil];
        callback(nil, nil, error);
    });

    [self.subject handleScribeOutgoingEvents:@"events"
                                      userID:@"1"
                           completionHandler:^(TFSScribeServiceRequestDisposition disposition) {
                               XCTAssertEqual(disposition, TFSScribeServiceRequestDispositionClientError);
                               [expectation fulfill];
                           }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)xtestEnqueueEventWithInvalidJson
{
    //    [[TWTRScribeService sharedInstance] enqueueEvent:@{ @"test" : [[NSObject alloc] init] }];
}

- (void)xtestEnqueueEventWithInvalidJsonNestedDictionary
{
    //    NSDictionary* invalidDict = @{ @"test" : @{ @"test" : [[NSObject alloc] init] }};
    //    [[TWTRScribeService sharedInstance] enqueueEvent:invalidDict];
}

- (void)xtestEnqueueEventWithEmptyDictionary
{
    //    [[TWTRScribeService sharedInstance] enqueueEvent:@{}];
}

- (void)testNamespaceDictionary
{
    TWTRScribeEvent *scribeEvent = [[TWTRScribeEvent alloc] initWithUserID:@"0" tweetID:@"1" category:TWTRScribeEventCategoryImpressions eventNamespace:self.loadTweet items:@[]];

    NSDictionary *expectedDictionary = @{TWTRScribeClientEventNamespaceClientKey: @"tfw", TWTRScribeClientEventNamespacePageKey: @"iOS", TWTRScribeClientEventNamespaceSectionKey: @"tweet", TWTRScribeClientEventNamespaceComponentKey: @"default", TWTRScribeClientEventNamespaceElementKey: @"", TWTRScribeClientEventNamespaceActionKey: @"load_tweet"};
    XCTAssertEqualObjects(scribeEvent.dictionaryRepresentation[@"event_namespace"], expectedDictionary);
}

- (void)testScribeToTfwClientEventCategory
{
    TWTRScribeEvent *scribeEvent = [[TWTRScribeEvent alloc] initWithUserID:@"0" tweetID:@"1" category:TWTRScribeEventCategoryImpressions eventNamespace:self.loadTweet items:@[]];
    NSDictionary *dictionary = [scribeEvent dictionaryRepresentation];
    XCTAssertTrue([dictionary[@"_category_"] isEqualToString:@"tfw_client_event"]);
}

- (void)testScribeToSyndicatedSDKImpressionCategory
{
    TWTRScribeEvent *scribeEvent = [[TWTRScribeEvent alloc] initWithUserID:@"0" tweetID:@"1" category:TWTRScribeEventCategoryUniques eventNamespace:self.loadTweet items:@[]];
    NSDictionary *dictionary = [scribeEvent dictionaryRepresentation];
    XCTAssertTrue([dictionary[@"_category_"] isEqualToString:@"syndicated_sdk_impression"]);
}

- (void)testScribePendingEvents_guestSession
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"flushUserID"];

    [[[self.scribeMock expect] andDo:^(NSInvocation *invocation) {
        [expectation fulfill];
    }] flushUserID:@"0"
        requestHandler:OCMOCK_ANY];

    [[[self.subject stub] andReturn:@[@"0"]] existingUserIDs];

    [self.subject scribePendingEvents];

    [self waitForExpectationsWithTimeout:1 handler:nil];
    [self.scribeMock verify];
}

- (void)testScribePendingEvents_userSession
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"flushUserID"];

    [[self.scribeMock expect] flushUserID:@"0" requestHandler:OCMOCK_ANY];

    [[[self.scribeMock expect] andDo:^(NSInvocation *invocation) {
        [expectation fulfill];
    }] flushUserID:@"1234"
        requestHandler:OCMOCK_ANY];

    [[[self.subject stub] andReturn:@[@"0", @"1234"]] existingUserIDs];

    [self.subject scribePendingEvents];

    [self waitForExpectationsWithTimeout:1 handler:nil];
    [self.scribeMock verify];
}

- (void)testExistingUserIDs_noSessions
{
    NSArray *userIDs = [self.subject existingUserIDs];
    XCTAssert([userIDs count] == 1, @"Missing Guest ID");
    XCTAssertEqualObjects([userIDs lastObject], @"0", @"Missing Guest ID");
}

- (void)testExistingUserIDs_userSession
{
    NSDictionary *sessionDictionary = @{TWTRAuthOAuthTokenKey: @"some_token", TWTRAuthOAuthSecretKey: @"some_secret", TWTRAuthAppOAuthScreenNameKey: @"other_screen_name", TWTRAuthAppOAuthUserIDKey: @"1234"};
    TWTRSession *session = [[TWTRSession alloc] initWithSessionDictionary:sessionDictionary];

    [[[self.storeMock expect] andReturn:@[session]] existingUserSessions];

    NSArray *userIDs = [self.subject existingUserIDs];

    [self.storeMock verify];
    XCTAssert([userIDs count] == 2, @"Missing IDs");
    XCTAssertEqualObjects([userIDs firstObject], @"0", @"Missing Guest ID");
    XCTAssertEqualObjects([userIDs lastObject], @"1234", @"Missing User ID");
}

#pragma mark - Mock methods

- (NSURLRequest *)mockURLRequestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters error:(NSError **)error
{
    return [NSURLRequest requestWithURL:[NSURL URLWithString:@""]];
}

- (NSURLRequest *)mockURLRequestWithMethodError:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters error:(NSError **)error
{
    if (error) {
        *error = [NSError errorWithDomain:@"" code:2 userInfo:nil];
    }
    [self setAsyncComplete:YES];
    return nil;
}

@end
