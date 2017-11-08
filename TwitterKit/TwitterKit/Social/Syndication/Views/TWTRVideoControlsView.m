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

#import "TWTRVideoControlsView.h"
#import <AVFoundation/AVFoundation.h>
#import "TWTRImages.h"
#import "TWTRStringUtil.h"
#import "TWTRViewUtil.h"

static const CGFloat TWTRControlsMinimumTappableSizeInPoints = 44.0;

/**
 * Helper class for making it easier to interact with the slider.
 */
@interface TWTRVideoControlsResponsiveSlider : UISlider
@end

@implementation TWTRVideoControlsResponsiveSlider

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{
    CGRect thumbRect = [super thumbRectForBounds:bounds trackRect:rect value:value];

    CGFloat extraWidth = MAX(0, (TWTRControlsMinimumTappableSizeInPoints - thumbRect.size.width) / 2.0);
    CGFloat extraHeight = MAX(0, (TWTRControlsMinimumTappableSizeInPoints - thumbRect.size.height) / 2.0);

    return CGRectInset(thumbRect, extraWidth, extraHeight);
}

@end

@interface TWTRVideoControlsView ()

@property (nonatomic, readonly, nullable) UILabel *timeLabel;
@property (nonatomic, readonly, nullable) UISlider *scrubber;
@property (nonatomic, readonly, nullable) UIButton *controlButton;
@property (nonatomic, readonly, nullable) UIButton *fullScreenButton;
@property (nonatomic, readonly, nullable) UILabel *timeRemainingLabel;

@end

@implementation TWTRVideoControlsView

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    [self updateTintColorForSubviews];
}

- (void)updateTintColorForSubviews
{
    self.timeLabel.textColor = self.tintColor;
    self.scrubber.tintColor = self.tintColor;
    self.controlButton.tintColor = self.tintColor;
    self.fullScreenButton.tintColor = self.tintColor;
    self.timeRemainingLabel.tintColor = self.tintColor;
    self.timeRemainingLabel.textColor = self.tintColor;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, 60.0);
}

- (void)updateForControlState:(TWTRVideoPlaybackState)state
{
    if (self.controlButton) {
        UIImage *image;
        switch (state) {
            case TWTRVideoPlaybackStatePaused:
                image = [TWTRImages mediaPlayTemplateImage];
                break;
            case TWTRVideoPlaybackStatePlaying:
                image = [TWTRImages mediaPauseTemplateImage];
                break;
            case TWTRVideoPlaybackStateCompleted:
                image = [TWTRImages mediaReplayTemplateImage];
                break;
        }

        [self.controlButton setImage:image forState:UIControlStateNormal];
    }
}

- (void)updateWithElapsedTime:(NSTimeInterval)elapsed duration:(NSTimeInterval)duration
{
    NSString *timeString = [self displayStringForTimeInterval:elapsed];
    NSString *durationString = [self displayStringForTimeInterval:duration];

    if (self.timeLabel) {
        self.timeLabel.text = [NSString stringWithFormat:@"%@ / %@", timeString, durationString];
    }

    if (self.timeRemainingLabel) {
        self.timeRemainingLabel.text = [self displayStringForTimeInterval:duration - elapsed];
    }
}

- (void)updateScrubberWithValue:(CGFloat)value
{
    self.scrubber.value = value;
}

+ (TWTRVideoControlsView *)inlineControls
{
    TWTRVideoControlsView *controlsView = [[TWTRVideoControlsView alloc] init];

    [controlsView prepareInlineSubviews];
    return controlsView;
}

+ (TWTRVideoControlsView *)fullscreenControls
{
    TWTRVideoControlsView *controlsView = [[TWTRVideoControlsView alloc] init];

    [controlsView prepareFullscreenSubviews];
    return controlsView;
}

#pragma mark - Actions

- (void)handleScrubberTouchDown
{
    if ([self.delegate respondsToSelector:@selector(videoControlsView:scrubberDidTouchDown:)]) {
        [self.delegate videoControlsView:self scrubberDidTouchDown:self.scrubber];
    }
}

- (void)handleScrubberTouchUp
{
    if ([self.delegate respondsToSelector:@selector(videoControlsView:scrubberDidTouchUp:)]) {
        [self.delegate videoControlsView:self scrubberDidTouchUp:self.scrubber];
    }
}

- (void)handleScrubberValueChange
{
    if ([self.delegate respondsToSelector:@selector(videoControlsView:scrubberDidChangeValue:)]) {
        [self.delegate videoControlsView:self scrubberDidChangeValue:self.scrubber];
    }
}

- (void)didTapControlButton
{
    if ([self.delegate respondsToSelector:@selector(videoControlsView:didTapControlButton:)]) {
        [self.delegate videoControlsView:self didTapControlButton:self.controlButton];
    }
}

- (void)didTapFullscreenButton
{
    if ([self.delegate respondsToSelector:@selector(videoControlsView:didTapFullscreenButton:)]) {
        [self.delegate videoControlsView:self didTapFullscreenButton:self.fullScreenButton];
    }
}

#pragma mark - Private methods

- (CGFloat)desirableWidthForTimeLabel
{
    return [@"88:88 / 88:88" sizeWithAttributes:@{NSFontAttributeName: self.timeLabel.font}].width;
}

- (CGFloat)desirableWidthForTimeRemainingLabel
{
    return [@"88:88" sizeWithAttributes:@{NSFontAttributeName: self.timeRemainingLabel.font}].width;
}

- (NSString *)displayStringForTimeInterval:(NSTimeInterval)interval
{
    return [TWTRStringUtil displayStringFromTimeInterval:interval] ?: @"--";
}

#pragma mark - View Creation

- (void)prepareInlineSubviews
{
    _fullScreenButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _timeRemainingLabel = [[UILabel alloc] init];

    [_fullScreenButton addTarget:self action:@selector(didTapFullscreenButton) forControlEvents:UIControlEventTouchUpInside];
    [_fullScreenButton setImage:[TWTRImages mediaExpandTemplateImage] forState:UIControlStateNormal];

    _timeRemainingLabel.font = [UIFont boldSystemFontOfSize:14.0];
    _timeRemainingLabel.textAlignment = NSTextAlignmentCenter;
    _timeRemainingLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    _timeRemainingLabel.layer.cornerRadius = 4.0;
    _timeRemainingLabel.clipsToBounds = YES;

    for (UIView *subview in @[_fullScreenButton, _timeRemainingLabel]) {
        subview.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:subview];
    }

    NSDictionary *metrics = @{ @"labelwidth": @([self desirableWidthForTimeRemainingLabel]) };
    NSDictionary *views = @{@"button": self.fullScreenButton, @"label": self.timeRemainingLabel};
    [TWTRViewUtil addVisualConstraints:@"V:[button(24)]-|" metrics:metrics views:views];
    [TWTRViewUtil addVisualConstraints:@"V:[label(16)]-|" metrics:metrics views:views];
    [TWTRViewUtil addVisualConstraints:@"H:|-[label(labelwidth)]-(>=10)-[button(24)]-|" metrics:metrics views:views];

    [self updateForControlState:TWTRVideoPlaybackStatePaused];
    [self updateTintColorForSubviews];
}

- (void)prepareFullscreenSubviews
{
    _timeLabel = [[UILabel alloc] init];
    _scrubber = [[TWTRVideoControlsResponsiveSlider alloc] init];
    _controlButton = [UIButton buttonWithType:UIButtonTypeSystem];

    [_controlButton addTarget:self action:@selector(didTapControlButton) forControlEvents:UIControlEventTouchUpInside];

    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textAlignment = NSTextAlignmentRight;

    _scrubber.minimumValue = 0.0;
    _scrubber.maximumValue = 1.0;
    _scrubber.continuous = YES;

    [_scrubber setThumbImage:[TWTRImages mediaScrubberThumb] forState:UIControlStateNormal];
    [_scrubber addTarget:self action:@selector(handleScrubberValueChange) forControlEvents:UIControlEventValueChanged];
    [_scrubber addTarget:self action:@selector(handleScrubberTouchDown) forControlEvents:UIControlEventTouchDown];
    [_scrubber addTarget:self action:@selector(handleScrubberTouchUp) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];

    for (UIView *subview in @[_timeLabel, _scrubber, _controlButton]) {
        subview.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:subview];
    }

    NSDictionary *metrics = @{ @"labelwidth": @([self desirableWidthForTimeLabel]) };
    NSDictionary *views = @{@"button": self.controlButton, @"scrubber": self.scrubber, @"label": self.timeLabel};
    [TWTRViewUtil addVisualConstraints:@"H:|-[button(30)]-10-[scrubber]-2-[label(labelwidth)]-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views];
    [TWTRViewUtil equateAttribute:NSLayoutAttributeCenterY onView:self.controlButton toView:self];
    [TWTRViewUtil constraintForAttribute:NSLayoutAttributeHeight onView:_controlButton value:TWTRControlsMinimumTappableSizeInPoints].active = YES;

    [self updateForControlState:TWTRVideoPlaybackStatePaused];
    [self updateTintColorForSubviews];
}

@end
