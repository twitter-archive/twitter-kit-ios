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
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "TWTRGuestSession.h"
#import "TWTRNetworkingPipeline.h"
#import "TWTRNetworkingPipelinePackage.h"
#import "TWTRNetworkingPipelineQueue.h"
#import "TWTRPipelineSessionMock.h"

@interface TWTRNetworkingPipeline (Testing)
// Declared here for testing
- (TWTRNetworkingPipelineQueue *)userQueueForUser:(NSString *)userID;
@property (nonatomic, readonly) TWTRNetworkingPipelineQueue *guestQueue;

@end

@interface TWTRNetworkingPipelineTests : XCTestCase

@property (nonatomic) TWTRNetworkingPipeline *pipeline;
@property (nonatomic) NSURLRequest *twitterRequest;
@property (nonatomic) TWTRPipelineSessionMock *sessionStoreMock;
@property (nonatomic) NSURLSession *URLSession;

@property (nonatomic, copy) NSString *userID;
@property (nonatomic) id userQueueMock;

@end

@implementation TWTRNetworkingPipelineTests

- (void)setUp
{
    self.URLSession = OCMClassMock([NSURLSession class]);
    self.sessionStoreMock = [[TWTRPipelineSessionMock alloc] init];
    self.twitterRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.twitter.com"]];

    // TODO: Test response validator
    self.pipeline = [[TWTRNetworkingPipeline alloc] initWithURLSession:self.URLSession responseValidator:nil];

    self.userID = @"1234";
    TWTRNetworkingPipelineQueue *queue = [self.pipeline userQueueForUser:self.userID];
    self.userQueueMock = OCMPartialMock(queue);

    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
    self.pipeline = nil;
    [self.userQueueMock stopMocking];
}

- (void)testEnqueueConvenienceCallsWithCorrectDefaults
{
    id mock = OCMPartialMock(self.pipeline);

    [mock enqueueRequest:self.twitterRequest sessionStore:self.sessionStoreMock];

    OCMVerify([mock enqueueRequest:OCMOCK_ANY sessionStore:OCMOCK_ANY requestingUser:nil completion:nil]);

    [mock stopMocking];
}

- (void)testEnqueueGuestEnqueuesCorrectPackage
{
    id mock = OCMPartialMock(self.pipeline.guestQueue);
    OCMExpect([mock enqueuePipelinePackage:[OCMArg checkWithBlock:^BOOL(TWTRNetworkingPipelinePackage *package) {
                        XCTAssertNil(package.userID);
                        XCTAssertNil(package.callback);
                        return [package.request isEqual:self.twitterRequest] && [package.sessionStore isEqual:self.sessionStoreMock];
                    }]]);

    [self.pipeline enqueueRequest:self.twitterRequest sessionStore:self.sessionStoreMock];

    OCMVerifyAll(mock);
    [mock stopMocking];
}

- (void)testEnqueueUserEnqueuesCorrectPackage
{
    OCMExpect([self.userQueueMock enqueuePipelinePackage:[OCMArg checkWithBlock:^BOOL(TWTRNetworkingPipelinePackage *package) {
                                      XCTAssertNil(package.callback);
                                      return [package.request isEqual:self.twitterRequest] && [package.sessionStore isEqual:self.sessionStoreMock] && [package.userID isEqualToString:self.userID];
                                  }]]);

    [self.pipeline enqueueRequest:self.twitterRequest sessionStore:self.sessionStoreMock requestingUser:self.userID];

    OCMVerifyAll(self.userQueueMock);
}

- (void)testEnqueueCreatesCorrectPackage
{
    OCMExpect([self.userQueueMock enqueuePipelinePackage:[OCMArg checkWithBlock:^BOOL(TWTRNetworkingPipelinePackage *package) {
                                      XCTAssertNotNil(package.callback);
                                      XCTAssertEqualObjects(package.request, self.twitterRequest);
                                      XCTAssertEqualObjects(package.sessionStore, self.sessionStoreMock);
                                      XCTAssertEqualObjects(package.userID, self.userID);
                                      return YES;
                                  }]]);

    [self.pipeline enqueueRequest:self.twitterRequest sessionStore:self.sessionStoreMock requestingUser:self.userID completion:^(NSData *d, NSURLResponse *r, NSError *e){
    }];

    OCMVerifyAll(self.userQueueMock);
}

- (void)testGuestQueueIsCorrectType
{
    XCTAssertNotNil(self.pipeline.guestQueue);
    XCTAssert(self.pipeline.guestQueue.queueType == TWTRNetworkingPipelineQueueTypeGuest);
}

- (void)testGuestQueueReturnsSameQueueForSubsequentCalls
{
    TWTRNetworkingPipelineQueue *first = self.pipeline.guestQueue;
    TWTRNetworkingPipelineQueue *second = self.pipeline.guestQueue;

    XCTAssertEqual(first, second);
}

- (void)testUserQueueIsCorrectType
{
    TWTRNetworkingPipelineQueue *queue = [self.pipeline userQueueForUser:@"user"];
    XCTAssert(queue.queueType == TWTRNetworkingPipelineQueueTypeUser);
}

- (void)testUserQueueReturnsSameQueueForSameUser
{
    NSString *user = @"user";
    TWTRNetworkingPipelineQueue *first = [self.pipeline userQueueForUser:user];
    TWTRNetworkingPipelineQueue *second = [self.pipeline userQueueForUser:user];

    XCTAssertEqual(first, second);
}

- (void)testUserQueueReturnsUniqueQueueForDifferentUsers
{
    NSString *user1 = @"user1";
    NSString *user2 = @"user2";
    TWTRNetworkingPipelineQueue *first = [self.pipeline userQueueForUser:user1];
    TWTRNetworkingPipelineQueue *second = [self.pipeline userQueueForUser:user2];

    XCTAssertNotEqual(first, second);
}

- (void)testCancelInvokesCallbackWithCorrectError
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"wait for cancel"];

    // We want a live request
    TWTRNetworkingPipeline *pipeline = [[TWTRNetworkingPipeline alloc] initWithURLSession:[NSURLSession sharedSession] responseValidator:nil];
    self.sessionStoreMock.guestSession = [[TWTRGuestSession alloc] initWithAccessToken:@"a" guestToken:@"b"];

    NSProgress *progress = [pipeline enqueueRequest:self.twitterRequest sessionStore:self.sessionStoreMock requestingUser:nil completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        XCTAssertEqualObjects(error.domain, NSURLErrorDomain);
        XCTAssertEqual(error.code, NSURLErrorCancelled);
        XCTAssertNotNil(error.userInfo);
        [expectation fulfill];
    }];

    [progress cancel];

    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

@end
