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
#import "TUDelorean+Rollback.h"
#import "TUDelorean.h"
#import "TWTRAuthenticationConstants.h"
#import "TWTRDateUtil.h"
#import "TWTRTestCase.h"
#import "TWTRUserSessionVerifier.h"

@interface TWTRUserSessionVerifier ()

// redefining here to help delayed start verify calls did get triggered
@property (nonatomic, strong) NSDate *lastVerifiedTimestamp;
@property (nonatomic, assign) BOOL alreadyStarted;

- (void)startVerification;
- (void)addHooksForFutureVerifications;
- (void)verifyNowIfNecessary;

@end

@interface TWTRUserSessionVerifierTests : TWTRTestCase

@property (nonatomic, strong) id userSessionVerifierMock;
@property (nonatomic, strong) TWTRUserSessionVerifier *verifier;

@end

@implementation TWTRUserSessionVerifierTests

- (void)setUp
{
    [super setUp];

    self.userSessionVerifierMock = [OCMockObject niceMockForProtocol:@protocol(TWTRUserSessionVerifierDelegate)];
    self.verifier = [[TWTRUserSessionVerifier alloc] initWithDelegate:self.userSessionVerifierMock maxDesiredInterval:TWTRUserSessionVerifierIntervalDaily];
}

// can't seem to be able to verify mock expectations so checking the lastVerifiedTimestamp
// is a good proxy for it has verified on `startVerificationAfterDelay:`
- (void)testStartVerificationAfterDelay_didDelay
{
    [[self.userSessionVerifierMock expect] userSessionVerifierNeedsSessionVerification:OCMOCK_ANY];
    [self.verifier startVerificationAfterDelay:0.1];
    XCTAssertNil(self.verifier.lastVerifiedTimestamp);
    [self waitForCompletionWithTimeout:1.2 check:^BOOL {
        return self.verifier.lastVerifiedTimestamp != nil;
    }];
    [self.userSessionVerifierMock verify];
}

- (void)testStartVerificationAfterDelay_isIdempotent
{
    id verifierMock = [OCMockObject partialMockForObject:self.verifier];
    __block NSUInteger calledCount = 0;
    [[[verifierMock stub] andDo:^(NSInvocation *invocation) {
        calledCount++;
    }] startVerification];

    // call it twice but verifyNowIfNecessary should only be called once
    [verifierMock startVerificationAfterDelay:0];
    [verifierMock startVerificationAfterDelay:0];  // still async, just don't want to increase testing time

    [self waitForDuration:0.1];
    XCTAssertEqual(calledCount, 1);
}

- (void)testVerifyNowIfNecessary_shouldVerifyOnFirstStart
{
    [[self.userSessionVerifierMock expect] userSessionVerifierNeedsSessionVerification:OCMOCK_ANY];
    [self.verifier verifyNowIfNecessary];
    [self.userSessionVerifierMock verify];
}

- (void)testVerifyNowIfNecessary_shouldVerifyIfMoreThanOneDay
{
    NSDate *now = [NSDate date];
    NSDate *moreThanOneDayAgo = [now dateByAddingTimeInterval:(-24 * 60 * 60 - 1)];
    self.verifier.lastVerifiedTimestamp = moreThanOneDayAgo;
    [[self.userSessionVerifierMock expect] userSessionVerifierNeedsSessionVerification:OCMOCK_ANY];
    [self.verifier verifyNowIfNecessary];
    [self.userSessionVerifierMock verify];
}

- (void)testVerifyNowIfNecessary_shouldNotVerifyIfLessThanOneDay
{
    NSDate *now = [TWTRDateUtil UTCDateWithYear:2015 month:2 day:1 hour:0 minute:0 second:0];
    NSDate *almostOneDayAhead = [TWTRDateUtil UTCDateWithYear:2015 month:2 day:1 hour:23 minute:59 second:59];
    self.verifier.lastVerifiedTimestamp = now;

    [TUDelorean temporarilyTimeTravelTo:almostOneDayAhead block:^(NSDate *date) {
        [[self.userSessionVerifierMock reject] userSessionVerifierNeedsSessionVerification:OCMOCK_ANY];
        [self.verifier verifyNowIfNecessary];
        [self.userSessionVerifierMock verify];
    }];
}

- (void)testVerifyNowIfNecessary_shouldCallDelegateIfValid
{
    [[self.userSessionVerifierMock expect] userSessionVerifierNeedsSessionVerification:OCMOCK_ANY];
    [self.verifier verifyNowIfNecessary];

    [self.userSessionVerifierMock verify];
}

- (void)testVerifyNowIfNecessary_shouldUpdateLastVerifiedTimestamp
{
    NSDate *now = [NSDate date];
    NSDate *oneDayAgo = [now dateByAddingTimeInterval:24 * 60 * 60];
    self.verifier.lastVerifiedTimestamp = oneDayAgo;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.verifier verifyNowIfNecessary];
        XCTAssertTrue([self.verifier.lastVerifiedTimestamp timeIntervalSinceDate:oneDayAgo] > 0);
    });
}

@end
