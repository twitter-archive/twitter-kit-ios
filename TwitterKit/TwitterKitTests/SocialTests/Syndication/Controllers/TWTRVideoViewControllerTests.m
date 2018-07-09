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

#import <TwitterCore/TWTRUtils.h>
#import <XCTest/XCTest.h>
#import "TWTRFixtureLoader.h"
#import "TWTRMediaContainerViewController.h"
#import "TWTRNotificationConstants.h"
#import "TWTRVideoControlsView.h"
#import "TWTRVideoPlaybackConfiguration.h"
#import "TWTRVideoPlayerView.h"
#import "TWTRVideoPlayerView_Private.h"
#import "TWTRVideoViewController.h"
#import "TWTRVideoViewController_Private.h"

@interface TWTRVideoViewController ()

- (void)handleCloseButton;

@end

@interface TWTRVideoViewControllerTests : XCTestCase

@property (nonatomic) UIViewController *parentController;
@property (nonatomic) TWTRVideoViewController *videoController;
@property (nonatomic) TWTRVideoPlaybackConfiguration *playbackConfig;
@property (nonatomic) TWTRTweet *videoTweet;

@end

@implementation TWTRVideoViewControllerTests

- (void)setUp
{
    [super setUp];

    self.playbackConfig = [[TWTRVideoPlaybackConfiguration alloc] initWithVideoURL:[NSURL URLWithString:@"https://video.twimg.com/ext_tw_video/675887965726515200/pu/pl/fb6bgw1oy5Gko69h.m3u8"] aspectRatio:1 duration:6.532 mediaType:TWTRMediaTypeVideo mediaID:@"23424" deeplinkConfiguration:nil];
    self.videoTweet = [TWTRFixtureLoader videoTweet];
    self.videoController = [[TWTRVideoViewController alloc] initWithTweet:self.videoTweet playbackConfiguration:self.playbackConfig previewImage:nil playerView:nil];
    self.parentController = [[UIViewController alloc] init];
}

#pragma mark - TWTRVideoPlayerView Configuration Tests

// Tests that the video player that is presented when nil is passed in the playerView parameter
// has the expected configurations.
- (void)testInit_videoPlayerInitalizedAsExpected
{
    TWTRVideoViewController *viewController = [[TWTRVideoViewController alloc] initWithTweet:self.videoTweet playbackConfiguration:self.playbackConfig previewImage:nil playerView:nil];

    XCTAssertEqual(viewController.playerView.aspectRatio, TWTRVideoPlayerAspectRatioAspect);
}

- (void)testInit_videoPlayerPassedInConfiguredAsExpected
{
    TWTRVideoPlayerView *customPlayer = [[TWTRVideoPlayerView alloc] initWithTweet:self.videoTweet playbackConfiguration:self.playbackConfig controlsView:[TWTRVideoControlsView inlineControls] previewImage:nil];
    customPlayer.aspectRatio = TWTRVideoPlayerAspectRatioAspectFill;

    TWTRVideoViewController *viewController = [[TWTRVideoViewController alloc] initWithTweet:self.videoTweet playbackConfiguration:self.playbackConfig previewImage:nil playerView:customPlayer];

    XCTAssertEqual(viewController.playerView.aspectRatio, TWTRVideoPlayerAspectRatioAspect);
}

#pragma mark - Notification Tests

- (void)testPresent_emitsNotification
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"async"];
    [[NSNotificationCenter defaultCenter] addObserverForName:TWTRWillPresentVideoNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *_Nonnull note) {
        XCTAssert([note.userInfo[TWTRVideoTypeKey] isEqualToString:TWTRVideoTypeStandard]);
        [expectation fulfill];
    }];

    [self.videoController willShowInMediaContainer];

    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testDismiss_emitsNotification
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"async"];
    [[NSNotificationCenter defaultCenter] addObserverForName:TWTRDidDismissVideoNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *_Nonnull note) {
        [expectation fulfill];
    }];

    [self.videoController didDismissInMediaContainer];

    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

@end
