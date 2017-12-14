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

/**
 This header is private to the Twitter Kit SDK and not exposed for public SDK consumption
 */

#import <UIKit/UIKit.h>
#import "TWTRVideoPlaybackState.h"

@class TWTRVideoControlsConfiguration;
@class TWTRVideoControlsView;

NS_ASSUME_NONNULL_BEGIN

@protocol TWTRVideoControlsViewDelegate <NSObject>

@optional
- (void)videoControlsView:(TWTRVideoControlsView *)controlsView didTapControlButton:(UIButton *)controlButton;
- (void)videoControlsView:(TWTRVideoControlsView *)controlsView didTapFullscreenButton:(UIButton *)fullscreenButton;

- (void)videoControlsView:(TWTRVideoControlsView *)controlsView scrubberDidTouchDown:(UISlider *)scrubber;
- (void)videoControlsView:(TWTRVideoControlsView *)controlsView scrubberDidTouchUp:(UISlider *)scrubber;
- (void)videoControlsView:(TWTRVideoControlsView *)controlsView scrubberDidChangeValue:(UISlider *)scrubber;

@end

@interface TWTRVideoControlsView : UIView

@property (nonatomic, weak) id<TWTRVideoControlsViewDelegate> delegate;

- (void)updateForControlState:(TWTRVideoPlaybackState)state;
- (void)updateWithElapsedTime:(NSTimeInterval)elapsed duration:(NSTimeInterval)duration;
- (void)updateScrubberWithValue:(CGFloat)value;

+ (TWTRVideoControlsView *)inlineControls;
+ (TWTRVideoControlsView *)fullscreenControls;

@end

NS_ASSUME_NONNULL_END
