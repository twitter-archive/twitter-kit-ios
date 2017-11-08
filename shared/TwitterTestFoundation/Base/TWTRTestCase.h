//
//  TWTRTestCase.h
//  TwitterTestFoundation
//
//  Created by Alden Keefe Sampson on 5/13/14.
//  Copyright (c) 2014 Twitter. All rights reserved.
//

#import <XCTest/XCTest.h>

// A base test case class with common functionality useful to SDK foundation and kit developers.
@interface TWTRTestCase : XCTestCase

#pragma mark - Setup / Tear Down

- (void)setUp NS_REQUIRES_SUPER;

#pragma mark - Async Testing

// Async tests must set self.asyncComplete = YES to signal the test is complete.
// The implementation of setUp ensures it is always set to NO before each test.
@property (atomic, assign, getter=isAsyncComplete) BOOL asyncComplete;

// Wait until an async test is complete or timeout after 3 seconds.
- (BOOL)waitForCompletion;

// Wait until an async test is complete or timeout after timeoutSecs.
- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs;

// Wait `timeout` or until the check block returns YES.
- (BOOL)waitForCompletionWithTimeout:(NSTimeInterval)timeout check:(BOOL(^)(void))check;

// Waits for the duration and returns. This is useful for tests that we cannot be certain a condition
// will never appear until the time is up.
- (void)waitForDuration:(NSTimeInterval)duration;

@end
