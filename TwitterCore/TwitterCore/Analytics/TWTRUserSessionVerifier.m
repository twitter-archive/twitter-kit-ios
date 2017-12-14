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

#if IS_UIKIT_AVAILABLE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif
#import "TWTRDateUtil.h"
#import "TWTRUserSessionVerifier.h"

NSTimeInterval const TWTRUserSessionVerifierIntervalDaily = 86400;
NSTimeInterval const TWTRUserSessionVerifierDefaultDelay = 3;

@interface TWTRUserSessionVerifier ()

@property (nonatomic, weak) id<TWTRUserSessionVerifierDelegate> delegate;
@property (nonatomic, assign, readonly) NSTimeInterval maxDesiredInterval;
@property (nonatomic, strong) NSDate *lastVerifiedTimestamp;
@property (nonatomic, assign) BOOL alreadyStarted;

@end

@implementation TWTRUserSessionVerifier

- (instancetype)initWithDelegate:(id<TWTRUserSessionVerifierDelegate>)delegate maxDesiredInterval:(NSTimeInterval)maxDesiredInterval
{
    NSParameterAssert(delegate);

    if (self = [super init]) {
        _delegate = delegate;
        _maxDesiredInterval = maxDesiredInterval;
        _alreadyStarted = NO;
    }

    return self;
}

- (void)startVerificationAfterDelay:(NSTimeInterval)delay
{
    NSParameterAssert(delay >= 0);

    if (!self.alreadyStarted) {
        self.alreadyStarted = YES;

        @weakify(self);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self);
            [self startVerification];
        });
    }
}

- (void)startVerification
{
    [self verifyNowIfNecessary];
    [self addHooksForFutureVerifications];
}

#pragma mark - NotificationCenter

- (void)addHooksForFutureVerifications
{
#if IS_UIKIT_AVAILABLE
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(verifyNowIfNecessary) name:UIApplicationWillEnterForegroundNotification object:nil];
#else
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(verifyNowIfNecessary) name:NSApplicationWillBecomeActiveNotification object:nil];
#endif
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Helpers

- (void)verifyNowIfNecessary
{
    BOOL isTimeToVerifyAgain = [self isPastMaxDesiredInterval];

    if (isTimeToVerifyAgain) {
        [self.delegate userSessionVerifierNeedsSessionVerification:self];

        self.lastVerifiedTimestamp = [NSDate date];
    }
}

- (BOOL)isPastMaxDesiredInterval
{
    if (self.lastVerifiedTimestamp) {
        NSDate *currentDate = [NSDate date];
        const BOOL hasExceededMaxDesiredInterval = ![TWTRDateUtil isDate:currentDate withinInterval:self.maxDesiredInterval fromDate:self.lastVerifiedTimestamp];
        const BOOL isDifferentDay = ![TWTRDateUtil date:currentDate isWithinSameUTCDayAsDate:self.lastVerifiedTimestamp];
        return hasExceededMaxDesiredInterval || isDifferentDay;
    } else {
        return YES;
    }
}

@end
