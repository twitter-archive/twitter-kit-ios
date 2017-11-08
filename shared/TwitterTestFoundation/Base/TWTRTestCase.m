//
//  TWTRTestCase.m
//  TwitterTestFoundation
//
//  Created by Alden Keefe Sampson on 5/13/14.
//  Copyright (c) 2014 Twitter. All rights reserved.
//

#import "TWTRTestCase.h"

#define SDK_ASYNC_TEST_TIMEOUT 3.0

@implementation TWTRTestCase

#pragma mark - Setup / Tear Down

- (void)setUp {
    [super setUp];
    [self setAsyncComplete:NO];
}

#pragma mark - Async Testing

- (BOOL)waitForCompletion {
    return [self waitForCompletion:SDK_ASYNC_TEST_TIMEOUT];
}

- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs {
    return [self waitForCompletionWithTimeout:timeoutSecs check:^BOOL{
        return [self isAsyncComplete];
    }];
}

- (BOOL)waitForCompletionWithTimeout:(NSTimeInterval)timeout check:(BOOL(^)(void))checkBlock {
    NSParameterAssert(checkBlock);

    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeout];

    __block BOOL checkPassed = NO;

    while (!(checkPassed = checkBlock())) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        if ([timeoutDate timeIntervalSinceNow] < 0.0) {
            break;
        }
    }

    XCTAssertTrue(checkPassed, @"Test has timed out : %s", __PRETTY_FUNCTION__);
    return checkPassed;
}

- (void)waitForDuration:(NSTimeInterval)duration {
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:duration];
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
}

@end
