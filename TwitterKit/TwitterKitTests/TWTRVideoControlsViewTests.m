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

#import <XCTest/XCTest.h>
#import "TWTRImages.h"
#import "TWTRVideoControlsView.h"

@interface TWTRVideoControlsView ()

@property (nonatomic, readonly) UILabel *timeLabel;
@property (nonatomic, readonly) UISlider *scrubber;
@property (nonatomic, readonly) UIButton *controlButton;
@property (nonatomic, readonly) UIButton *fullScreenButton;
@property (nonatomic, readonly) UILabel *timeRemainingLabel;

@end

@interface TWTRVideoControlsViewTests : XCTestCase
@end

@implementation TWTRVideoControlsViewTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInlineControls
{
    TWTRVideoControlsView *controlsView = [TWTRVideoControlsView inlineControls];
    XCTAssertNotNil(controlsView.timeRemainingLabel);
    XCTAssertNotNil(controlsView.fullScreenButton);
    XCTAssertNil(controlsView.timeLabel);
    XCTAssertNil(controlsView.scrubber);
    XCTAssertNil(controlsView.controlButton);
}

- (void)testFullscreenControls
{
    TWTRVideoControlsView *controlsView = [TWTRVideoControlsView fullscreenControls];
    XCTAssertNil(controlsView.timeRemainingLabel);
    XCTAssertNil(controlsView.fullScreenButton);
    XCTAssertNotNil(controlsView.timeLabel);
    XCTAssertNotNil(controlsView.scrubber);
    XCTAssertNotNil(controlsView.controlButton);
}

- (void)testUpdateForControlState_paused
{
    TWTRVideoControlsView *controlsView = [TWTRVideoControlsView fullscreenControls];
    [controlsView updateForControlState:TWTRVideoPlaybackStatePaused];
    UIImage *expectedImage = [TWTRImages mediaPlayTemplateImage];
    UIImage *actualImage = controlsView.controlButton.imageView.image;
    XCTAssertTrue([[self class] isImage:expectedImage equalToImage:actualImage]);
}

- (void)testUpdateForControlState_playing
{
    TWTRVideoControlsView *controlsView = [TWTRVideoControlsView fullscreenControls];
    [controlsView updateForControlState:TWTRVideoPlaybackStatePlaying];
    UIImage *expectedImage = [TWTRImages mediaPauseTemplateImage];
    UIImage *actualImage = controlsView.controlButton.imageView.image;
    XCTAssertTrue([[self class] isImage:expectedImage equalToImage:actualImage]);
}

- (void)testUpdateForControlState_completed
{
    TWTRVideoControlsView *controlsView = [TWTRVideoControlsView fullscreenControls];
    [controlsView updateForControlState:TWTRVideoPlaybackStateCompleted];
    UIImage *expectedImage = [TWTRImages mediaReplayTemplateImage];
    UIImage *actualImage = controlsView.controlButton.imageView.image;
    XCTAssertTrue([[self class] isImage:expectedImage equalToImage:actualImage]);
}

- (void)testUpdateWithElapsedTimeAndDuration_fullscreen
{
    TWTRVideoControlsView *controlsView = [TWTRVideoControlsView fullscreenControls];
    NSTimeInterval elapsed = 100.0;
    NSTimeInterval duration = 1000.0;
    [controlsView updateWithElapsedTime:elapsed duration:duration];
    XCTAssertNotNil(controlsView.timeLabel.text);
    XCTAssertTrue([controlsView.timeLabel.text isEqualToString:@"1:40 / 16:40"]);
}

- (void)testUpdateWithElapsedTimeAndDuration_inline
{
    TWTRVideoControlsView *controlsView = [TWTRVideoControlsView inlineControls];
    NSTimeInterval elapsed = 100.0;
    NSTimeInterval duration = 1000.0;
    [controlsView updateWithElapsedTime:elapsed duration:duration];
    XCTAssertNotNil(controlsView.timeRemainingLabel.text);
    XCTAssertTrue([controlsView.timeRemainingLabel.text isEqualToString:@"15:00"]);
}

#pragma mark - Helpers

+ (BOOL)isImage:(UIImage *)image1 equalToImage:(UIImage *)image2
{
    return [UIImagePNGRepresentation(image1) isEqual:UIImagePNGRepresentation(image2)];
}

@end
