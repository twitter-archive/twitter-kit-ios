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
#import "TWTRServerTrustEvaluator.h"
#import "TWTRURLSessionDelegate.h"

@interface TWTRURLSessionDelegate ()
// Exposed for mocking
@property (nonatomic, readonly) TWTRServerTrustEvaluator *trustEvaluator;

@end

@interface TWTRURLSessionDelegateTests : XCTestCase

@property (nonatomic) NSURLSession *URLSession;
@property (nonatomic, copy) NSString *twitterHost;
@property (nonatomic) NSURLSessionTask *task;
@property (nonatomic) TWTRURLSessionDelegate *sessionDelegate;
@property (nonatomic) id evaluatorMock;

@end

@implementation TWTRURLSessionDelegateTests

- (void)setUp
{
    [super setUp];
    self.URLSession = [NSURLSession sharedSession];
    self.twitterHost = @"api.twitter.com";

    self.task = [self taskWithHost:self.twitterHost];

    self.sessionDelegate = [[TWTRURLSessionDelegate alloc] init];
    self.evaluatorMock = OCMPartialMock(self.sessionDelegate.trustEvaluator);
}

- (void)tearDown
{
    [self.evaluatorMock stopMocking];
    [super tearDown];
}

- (NSURLSessionTask *)taskWithHost:(NSString *)host
{
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = @"https";
    components.host = host;

    return [self.URLSession dataTaskWithURL:components.URL];
}

- (void)testCertPinning_SkipsProtectionSpaceWithInvalidAuthenticationMethod
{
    NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc] initWithHost:self.twitterHost port:443 protocol:@"https" realm:nil authenticationMethod:NSURLAuthenticationMethodClientCertificate];
    NSURLAuthenticationChallenge *authChallenge = [[NSURLAuthenticationChallenge alloc] initWithProtectionSpace:protectionSpace proposedCredential:nil previousFailureCount:0 failureResponse:nil error:nil sender:OCMProtocolMock(@protocol(NSURLAuthenticationChallengeSender))];

    XCTestExpectation *expectation = [self expectationWithDescription:@"wait for callback"];
    [self.sessionDelegate URLSession:self.URLSession task:self.task didReceiveChallenge:authChallenge completionHandler:^(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential) {
        XCTAssertTrue(NSURLSessionAuthChallengeRejectProtectionSpace == disposition);
        XCTAssertNil(credential);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testCertPinning_CancelsChallengeIfEvaluatorRejectsServerTrust
{
    NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc] initWithHost:self.twitterHost port:443 protocol:@"https" realm:nil authenticationMethod:NSURLAuthenticationMethodServerTrust];
    NSURLAuthenticationChallenge *authChallenge = [[NSURLAuthenticationChallenge alloc] initWithProtectionSpace:protectionSpace proposedCredential:nil previousFailureCount:0 failureResponse:nil error:nil sender:OCMProtocolMock(@protocol(NSURLAuthenticationChallengeSender))];

    OCMStub([self.evaluatorMock evaluateServerTrust:[OCMArg anyPointer] forDomain:OCMOCK_ANY]).andReturn(NO);

    XCTestExpectation *expectation = [self expectationWithDescription:@"wait for callback"];
    [self.sessionDelegate URLSession:self.URLSession task:self.task didReceiveChallenge:authChallenge completionHandler:^(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential) {
        XCTAssertTrue(NSURLSessionAuthChallengeCancelAuthenticationChallenge == disposition);
        XCTAssertNil(credential);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testCertPinning_SucceedsIfEvaluatorAcceptsServerTrust
{
    NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc] initWithHost:self.twitterHost port:443 protocol:@"https" realm:nil authenticationMethod:NSURLAuthenticationMethodServerTrust];
    NSURLAuthenticationChallenge *authChallenge = [[NSURLAuthenticationChallenge alloc] initWithProtectionSpace:protectionSpace proposedCredential:nil previousFailureCount:0 failureResponse:nil error:nil sender:OCMProtocolMock(@protocol(NSURLAuthenticationChallengeSender))];

    OCMStub([self.evaluatorMock evaluateServerTrust:[OCMArg anyPointer] forDomain:OCMOCK_ANY]).andReturn(YES);

    XCTestExpectation *expectation = [self expectationWithDescription:@"wait for callback"];
    [self.sessionDelegate URLSession:self.URLSession task:self.task didReceiveChallenge:authChallenge completionHandler:^(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential) {
        XCTAssertTrue(NSURLSessionAuthChallengeUseCredential == disposition);
        XCTAssertNotNil(credential);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
