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
#import <XCTest/XCTest.h>
#import "TWTRNotificationConstants.h"
#import "TWTRVideoPlaybackConfiguration.h"
#import "TWTRVideoPlaybackState.h"
#import "TWTRVideoPlayerOutputView.h"

@interface TWTRVideoPlayerOutputView ()

- (void)setPlaybackState:(TWTRVideoPlaybackState)state;

@end

@interface TWTRVideoPlayerOutputViewTests : XCTestCase

@property (nonatomic) TWTRVideoPlayerOutputView *videoView;
@property (nonatomic) id mockNotificationCenter;

@end

@implementation TWTRVideoPlayerOutputViewTests

- (void)setUp
{
    [super setUp];

    self.videoView = [[TWTRVideoPlayerOutputView alloc] init];
    self.mockNotificationCenter = OCMPartialMock([NSNotificationCenter defaultCenter]);
}

- (void)tearDown
{
    [super tearDown];

    self.mockNotificationCenter = nil;
}

#pragma mark - Tests

- (void)testPlayerNotification_onStart
{
    OCMExpect([self.mockNotificationCenter postNotificationName:TWTRVideoPlaybackStateChangedNotification object:OCMOCK_ANY userInfo:[OCMArg checkWithBlock:^BOOL(NSDictionary *userInfo) {
                                                                                                                                return [userInfo[TWTRVideoPlaybackStateKey] isEqualToString:@"TWTRVideoStateValuePlaying"];
                                                                                                                            }]]);

    [self.videoView setPlaybackState:TWTRVideoPlaybackStatePlaying];

    OCMVerifyAll(self.mockNotificationCenter);
}

- (void)testPlayerNotification_onPause
{
    // Set to state other than paused to ensure the set happens
    [self.videoView setPlaybackState:TWTRVideoPlaybackStatePlaying];

    OCMExpect([self.mockNotificationCenter postNotificationName:TWTRVideoPlaybackStateChangedNotification object:OCMOCK_ANY userInfo:[OCMArg checkWithBlock:^BOOL(NSDictionary *userInfo) {
                                                                                                                                return [userInfo[TWTRVideoPlaybackStateKey] isEqualToString:@"TWTRVideoStateValuePaused"];
                                                                                                                            }]]);

    [self.videoView setPlaybackState:TWTRVideoPlaybackStatePaused];

    OCMVerifyAll(self.mockNotificationCenter);
}

- (void)testPlayerNotification_onComplete
{
    OCMExpect([self.mockNotificationCenter postNotificationName:TWTRVideoPlaybackStateChangedNotification object:OCMOCK_ANY userInfo:[OCMArg checkWithBlock:^BOOL(NSDictionary *userInfo) {
                                                                                                                                return [userInfo[TWTRVideoPlaybackStateKey] isEqualToString:@"TWTRVideoStateValueCompleted"];
                                                                                                                            }]]);

    [self.videoView setPlaybackState:TWTRVideoPlaybackStateCompleted];

    OCMVerifyAll(self.mockNotificationCenter);
}

@end
