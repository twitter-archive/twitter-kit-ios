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

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "TWTRAuthenticationConstants.h"
#import "TWTRGuestSession.h"
#import "TWTRMockURLSessionProtocol.h"
#import "TWTRNetworkingPipeline.h"
#import "TWTRNetworkingPipelinePackage.h"
#import "TWTRNetworkingPipelineQueue.h"
#import "TWTRPipelineSessionMock.h"
#import "TWTRSession.h"
#import "TWTRSessionFixtureLoader.h"
#import "TWTRSessionStore.h"

@interface TWTRNetworkingPipelineQueueTests : XCTestCase <TWTRNetworkingResponseValidating>

@property (nonatomic) TWTRNetworkingPipelineQueue *guestQueue;
@property (nonatomic) TWTRNetworkingPipelineQueue *userQueue;
@property (nonatomic) TWTRNetworkingPipelineQueue *noValidatorQueue;
@property (nonatomic) TWTRPipelineSessionMock *sessionStoreMock;
@property (nonatomic) NSURLRequest *twitterRequest;
@property (nonatomic) TWTRSession *session;
@property (nonatomic) NSError *responseValidatorError;

@end

@implementation TWTRNetworkingPipelineQueueTests

- (void)setUp
{
    [NSURLProtocol registerClass:[TWTRMockURLSessionProtocol class]];

    self.guestQueue = [TWTRNetworkingPipelineQueue guestPipelineQueueWithURLSession:[NSURLSession sharedSession] responseValidator:self];
    self.userQueue = [TWTRNetworkingPipelineQueue userPipelineQueueWithURLSession:[NSURLSession sharedSession] responseValidator:self];
    self.noValidatorQueue = [TWTRNetworkingPipelineQueue guestPipelineQueueWithURLSession:[NSURLSession sharedSession] responseValidator:nil];
    self.sessionStoreMock = [[TWTRPipelineSessionMock alloc] init];
    self.twitterRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.twitter.com"]];
    self.session = [[TWTRSession alloc] initWithSessionDictionary:@{ TWTRAuthOAuthTokenKey: @"token", TWTRAuthOAuthSecretKey: @"secret", TWTRAuthAppOAuthScreenNameKey: @"screenname", TWTRAuthAppOAuthUserIDKey: @"userID" }];
    self.responseValidatorError = nil;

    [super setUp];
}

- (void)tearDown
{
    self.sessionStoreMock = nil;
    self.userQueue = nil;
    self.guestQueue = nil;

    XCTAssertTrue([TWTRMockURLSessionProtocol isEmpty]);
    [NSURLProtocol unregisterClass:[TWTRMockURLSessionProtocol class]];
    [super tearDown];
}

#pragma mark - Initializer tests
- (void)testDesignatedInitializerSetsType
{
    TWTRNetworkingPipelineQueue *queue = [[TWTRNetworkingPipelineQueue alloc] initWithType:TWTRNetworkingPipelineQueueTypeUser URLSession:[NSURLSession sharedSession] responseValidator:nil];
    XCTAssertEqual(queue.queueType, TWTRNetworkingPipelineQueueTypeUser);
}

- (void)testGuestConvenienceInitializer
{
    TWTRNetworkingPipelineQueue *queue = [TWTRNetworkingPipelineQueue guestPipelineQueueWithURLSession:[NSURLSession sharedSession] responseValidator:nil];
    XCTAssertEqual(queue.queueType, TWTRNetworkingPipelineQueueTypeGuest);
}

- (void)testAuthenticatedConvenienceInitializer
{
    TWTRNetworkingPipelineQueue *queue = [TWTRNetworkingPipelineQueue userPipelineQueueWithURLSession:[NSURLSession sharedSession] responseValidator:nil];
    XCTAssertEqual(queue.queueType, TWTRNetworkingPipelineQueueTypeUser);
}

#pragma mark Guest Session Tests
- (void)testQueueFetchesGuestSession
{
    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithString:@"Success"]];

    XCTestExpectation *expectation = [self expectationWithDescription:@"waiting for guest session request"];
    self.sessionStoreMock.guestSession = [self guestSession];

    TWTRNetworkingPipelinePackage *package = [self guestPackageWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        [expectation fulfill];
    }];

    [self.guestQueue enqueuePipelinePackage:package];

    [self waitForExpectationsWithTimeout:1 handler:nil];

    XCTAssertTrue(self.sessionStoreMock.guestSessionFetchCount == 1, @"should never fetch a guest session for an authenticated queue");
}

- (void)testQueueDoesNotFetchGuestSessionForAuthenticatedReqeust
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"should execute request"];

    self.sessionStoreMock.userSession = self.session;
    TWTRNetworkingPipelinePackage *package = [self userPackageWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        XCTAssertNotNil(error);
        [expectation fulfill];
    }];

    [self.userQueue enqueuePipelinePackage:package];

    [self waitForExpectationsWithTimeout:1 handler:nil];
    XCTAssertTrue(self.sessionStoreMock.guestSessionFetchCount == 0, @"should never fetch a guest session for an authenticated queue");
}

- (void)testGuestSessionFetchIdempotent
{
    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithString:@"first"]];
    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithString:@"second"]];

    XCTestExpectation *firstExpectation = [self expectationWithDescription:@"first request"];
    XCTestExpectation *secondExpectation = [self expectationWithDescription:@"second request"];

    self.sessionStoreMock.guestSession = [self guestSession];

    TWTRNetworkingPipelinePackage *firstPackage = [self guestPackageWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        [firstExpectation fulfill];
    }];

    TWTRNetworkingPipelinePackage *secondPackage = [self guestPackageWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        [secondExpectation fulfill];
    }];

    [self.guestQueue enqueuePipelinePackage:firstPackage];
    [self.guestQueue enqueuePipelinePackage:secondPackage];

    [self waitForExpectationsWithTimeout:1 handler:nil];

    XCTAssert(self.sessionStoreMock.guestSessionFetchCount == 1, @"should only be called once");
}

#pragma mark - User Session Fetching
- (void)testQueueFetchesUserSession
{
    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithString:@"uccess"]];

    XCTestExpectation *expectation = [self expectationWithDescription:@"waiting for user session request"];
    self.sessionStoreMock.userSession = [self userSession];

    TWTRNetworkingPipelinePackage *package = [self userPackageWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        [expectation fulfill];
    }];

    [self.userQueue enqueuePipelinePackage:package];

    [self waitForExpectationsWithTimeout:1 handler:nil];

    XCTAssertTrue(self.sessionStoreMock.userSessionFetchCount == 1, @"should never fetch a guest session for an authenticated queue");
}

- (void)testQueueDoesNotFetchUserSessionForGuestRequest
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"should execute request"];

    TWTRNetworkingPipelinePackage *package = [self guestPackageWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        XCTAssertNotNil(error);
        [expectation fulfill];
    }];

    [self.guestQueue enqueuePipelinePackage:package];

    [self waitForExpectationsWithTimeout:1 handler:nil];
    XCTAssertTrue(self.sessionStoreMock.userSessionFetchCount == 0, @"should never fetch a user session for a user queue");
}

- (void)testUserSessionFetchIdempotent
{
    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithString:@"first"]];
    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithString:@"second"]];

    XCTestExpectation *firstExpectation = [self expectationWithDescription:@"first request"];
    XCTestExpectation *secondExpectation = [self expectationWithDescription:@"second request"];

    self.sessionStoreMock.userSession = [self userSession];

    TWTRNetworkingPipelinePackage *firstPackage = [self userPackageWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        [firstExpectation fulfill];
    }];

    TWTRNetworkingPipelinePackage *secondPackage = [self userPackageWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        [secondExpectation fulfill];
    }];

    [self.userQueue enqueuePipelinePackage:firstPackage];
    [self.userQueue enqueuePipelinePackage:secondPackage];

    [self waitForExpectationsWithTimeout:1 handler:nil];

    XCTAssert(self.sessionStoreMock.userSessionFetchCount == 1, @"should only be called once");
}

#pragma mark - Networking Tests
- (void)testQueueExecutesRequestIfSessionIsNonNil
{
    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithString:@"Success"]];

    XCTestExpectation *expectation = [self expectationWithDescription:@"should execute request"];
    self.sessionStoreMock.guestSession = [self guestSession];

    TWTRNetworkingPipelinePackage *package = [self guestPackageWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        XCTAssertNotNil(data);
        XCTAssertNotNil(response);
        XCTAssertNil(error);
        [expectation fulfill];
    }];

    [self.guestQueue enqueuePipelinePackage:package];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testQueueCancelsRequestsIfSessionFetchFails
{
    self.sessionStoreMock.error = [NSError errorWithDomain:@"com.twitterkit-tests" code:1001 userInfo:nil];
    self.sessionStoreMock.guestSession = nil;

    XCTestExpectation *expectation = [self expectationWithDescription:@"fail request"];

    TWTRNetworkingPipelinePackage *package = [self guestPackageWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        XCTAssertNotNil(error);
        [expectation fulfill];
    }];

    [self.guestQueue enqueuePipelinePackage:package];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testNetworkRespondedWithErrorInvokesCallback
{
    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithError:[NSError errorWithDomain:@"com.twitterkit-tests" code:1001 userInfo:nil]]];

    XCTestExpectation *expectation = [self expectationWithDescription:@"should execute request"];
    self.sessionStoreMock.guestSession = [self guestSession];

    TWTRNetworkingPipelinePackage *package = [self guestPackageWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        XCTAssertNil(data);
        XCTAssertNil(response);
        XCTAssertNotNil(error);
        [expectation fulfill];
    }];

    [self.guestQueue enqueuePipelinePackage:package];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testEnqueueAfterFailureRetries
{
    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithString:@"SUCCESS"]];

    self.sessionStoreMock.error = [NSError errorWithDomain:@"com.twitterkit-tests" code:1001 userInfo:nil];
    self.sessionStoreMock.guestSession = nil;

    XCTestExpectation *expectation = [self expectationWithDescription:@"should execute request"];

    TWTRNetworkingPipelinePackage *second = [self guestPackageWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        XCTAssertNil(error);
        [expectation fulfill];
    }];

    TWTRNetworkingPipelinePackage *first = [self guestPackageWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        XCTAssertNotNil(error);

        self.sessionStoreMock.guestSession = [self guestSession];
        self.sessionStoreMock.error = nil;
        [self.guestQueue enqueuePipelinePackage:second];
    }];

    [self.guestQueue enqueuePipelinePackage:first];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

#pragma mark - Request Cancellation
- (void)testCancelInvokesCallbackWithCorrectError
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"wait for cancel"];
    self.sessionStoreMock.guestSession = [[TWTRGuestSession alloc] initWithAccessToken:@"a" guestToken:@"b"];

    TWTRNetworkingPipelinePackage *package = [self guestPackageWithCompletion:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        XCTAssertEqualObjects(error.domain, NSURLErrorDomain);
        XCTAssertEqual(error.code, NSURLErrorCancelled);
        XCTAssertNotNil(error.userInfo);
        [expectation fulfill];
    }];

    NSProgress *progress = [self.guestQueue enqueuePipelinePackage:package];
    [progress cancel];

    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testProgressIsIndeterminate
{
    TWTRNetworkingPipelinePackage *package = [self guestPackageWithCompletion:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error){
    }];

    NSProgress *progress = [self.guestQueue enqueuePipelinePackage:package];
    XCTAssertTrue(progress.isIndeterminate);
}

- (void)testProgressIsCancellable
{
    TWTRNetworkingPipelinePackage *package = [self guestPackageWithCompletion:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error){
    }];

    NSProgress *progress = [self.guestQueue enqueuePipelinePackage:package];
    XCTAssertTrue(progress.isCancellable);
}

- (void)testProgressIsNotPausable
{
    TWTRNetworkingPipelinePackage *package = [self guestPackageWithCompletion:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error){
    }];

    NSProgress *progress = [self.guestQueue enqueuePipelinePackage:package];
    XCTAssertFalse(progress.isPausable);
}

#pragma mark - Refresh Testing
- (void)testRequestSucceedsAfterRefreshOfGuestToken
{
    NSString *responseString = @"SUCCESS";

    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithString:@"refresh" statusCode:209]];
    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithString:responseString statusCode:200]];

    self.sessionStoreMock.guestSession = [self guestSession];
    self.sessionStoreMock.refreshSession = [self guestSession];

    XCTestExpectation *expectation = [self expectationWithDescription:@"should execute request"];

    TWTRNetworkingPipelinePackage *package = [self guestPackageWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {

        NSString *receivedText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

        XCTAssertEqualObjects(responseString, receivedText);
        XCTAssertNotNil(response);
        XCTAssertNil(error);

        [expectation fulfill];
    }];

    [self.guestQueue enqueuePipelinePackage:package];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testRequestFailsAfterRefreshOfGuestTokenFails
{
    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithString:@"refresh" statusCode:209]];

    self.sessionStoreMock.guestSession = [self guestSession];
    self.sessionStoreMock.refreshSession = nil;
    self.sessionStoreMock.refreshError = [NSError errorWithDomain:@"com.twitterkit-tests" code:1001 userInfo:nil];

    XCTestExpectation *expectation = [self expectationWithDescription:@"should execute request"];

    TWTRNetworkingPipelinePackage *package = [self guestPackageWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {

        XCTAssertNil(data);
        XCTAssertNil(response);
        XCTAssertNotNil(error);

        [expectation fulfill];
    }];

    [self.guestQueue enqueuePipelinePackage:package];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testRequestFailsAfterReachingAttemptCapOnBadGuestTokenResponse
{
    // networking pipeline will find out that the response indicates session-expiration 3 times in a row
    NSString *responseString1 = @"response string 1";
    NSString *responseString2 = @"response string 2";
    NSString *responseString3 = @"response string 3";

    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithString:responseString1 statusCode:209]];
    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithString:responseString2 statusCode:209]];
    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithString:responseString3 statusCode:209]];

    self.sessionStoreMock.guestSession = [self guestSession];
    self.sessionStoreMock.refreshSession = [self guestSession];
    self.sessionStoreMock.refreshError = [NSError errorWithDomain:@"com.twitterkit-tests" code:1001 userInfo:nil];

    XCTestExpectation *expectation = [self expectationWithDescription:@"should execute request"];

    TWTRNetworkingPipelinePackage *package = [self guestPackageWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {

        // after seeing the session expiration 3 times on attempting the request, it will give up and
        // report whatever being received from last attempt.

        XCTAssertNotNil(data);
        NSString *receivedText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

        XCTAssertEqualObjects(responseString3, receivedText);

        XCTAssertNotNil(response);
        [expectation fulfill];
    }];

    [self.guestQueue enqueuePipelinePackage:package];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testRequestSucceedsAfterRefreshOfUserToken
{
    NSString *responseString = @"SUCCESS";

    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithString:@"refresh" statusCode:209]];
    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithString:responseString statusCode:200]];

    self.sessionStoreMock.userSession = [self userSession];
    self.sessionStoreMock.refreshSession = [self userSession];

    XCTestExpectation *expectation = [self expectationWithDescription:@"should execute request"];

    TWTRNetworkingPipelinePackage *package = [self userPackageWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {

        NSString *receivedText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

        XCTAssertEqualObjects(responseString, receivedText);
        XCTAssertNotNil(response);
        XCTAssertNil(error);

        [expectation fulfill];
    }];

    [self.userQueue enqueuePipelinePackage:package];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testRequestFailsAfterRefreshOfUserTokenFails
{
    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithString:@"refresh" statusCode:209]];

    self.sessionStoreMock.userSession = [self userSession];
    self.sessionStoreMock.refreshSession = nil;
    self.sessionStoreMock.refreshError = [NSError errorWithDomain:@"com.twitterkit-tests" code:1001 userInfo:nil];

    XCTestExpectation *expectation = [self expectationWithDescription:@"should execute request"];

    TWTRNetworkingPipelinePackage *package = [self userPackageWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {

        XCTAssertNil(data);
        XCTAssertNil(response);
        XCTAssertNotNil(error);

        [expectation fulfill];
    }];

    [self.userQueue enqueuePipelinePackage:package];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

#pragma mark - Error Tests
- (void)testCorrectErrorReturnedWhenFetchFails
{
    NSError *error = [NSError errorWithDomain:@"com.twittertests" code:-9999 userInfo:nil];

    self.sessionStoreMock.error = error;
    self.responseValidatorError = [NSError errorWithDomain:@"should-not-be-called" code:101 userInfo:nil];

    XCTestExpectation *expectation = [self expectationWithDescription:@"should execute request"];

    TWTRNetworkingPipelinePackage *package = [self guestPackageWithCompletion:^(NSData *data, NSURLResponse *response, NSError *responseError) {

        XCTAssertNil(data);
        XCTAssertNil(response);
        XCTAssertEqualObjects(error, responseError);

        [expectation fulfill];
    }];

    [self.guestQueue enqueuePipelinePackage:package];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testValidatorErrorReturnedWhenResponseSuccess
{
    self.sessionStoreMock.guestSession = [self guestSession];
    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithString:@"{}" statusCode:200]];
    self.responseValidatorError = [NSError errorWithDomain:@"com.validatorerror" code:101 userInfo:nil];

    XCTestExpectation *expectation = [self expectationWithDescription:@"should execute request"];

    TWTRNetworkingPipelinePackage *package = [self guestPackageWithCompletion:^(NSData *data, NSURLResponse *response, NSError *responseError) {

        XCTAssertNil(data);
        XCTAssertNil(response);
        XCTAssertEqualObjects(self.responseValidatorError, responseError);

        [expectation fulfill];
    }];

    [self.guestQueue enqueuePipelinePackage:package];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testLackOfValidatorReturnsSuccess
{
    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithString:@"Success"]];

    XCTestExpectation *expectation = [self expectationWithDescription:@"should execute request"];
    self.sessionStoreMock.guestSession = [self guestSession];

    TWTRNetworkingPipelinePackage *package = [self guestPackageWithCompletion:^(NSData *data, NSURLResponse *response, NSError *error) {
        XCTAssertNotNil(data);
        XCTAssertNotNil(response);
        XCTAssertNil(error);
        [expectation fulfill];
    }];

    [self.noValidatorQueue enqueuePipelinePackage:package];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

#pragma mark - Utitlities
- (TWTRNetworkingPipelinePackage *)guestPackageWithCompletion:(TWTRNetworkingPipelineCallback)completion
{
    TWTRNetworkingPipelinePackage *package = [TWTRNetworkingPipelinePackage packageWithRequest:self.twitterRequest sessionStore:self.sessionStoreMock userID:nil completion:completion];
    return package;
}

- (TWTRNetworkingPipelinePackage *)userPackageWithCompletion:(TWTRNetworkingPipelineCallback)completion
{
    TWTRNetworkingPipelinePackage *package = [TWTRNetworkingPipelinePackage packageWithRequest:self.twitterRequest sessionStore:self.sessionStoreMock userID:@"user_id" completion:completion];
    return package;
}

- (TWTRSession *)userSession
{
    return [TWTRSessionFixtureLoader twitterSession];
}

- (TWTRGuestSession *)guestSession
{
    return [TWTRSessionFixtureLoader twitterGuestSession];
}

#pragma mark - Response Validating
- (BOOL)validateResponse:(NSHTTPURLResponse *)response data:(NSData *)data error:(NSError **)error
{
    if (!self.responseValidatorError) {
        return YES;
    }

    if (error) {
        *error = self.responseValidatorError;
    }
    return NO;
}

@end
