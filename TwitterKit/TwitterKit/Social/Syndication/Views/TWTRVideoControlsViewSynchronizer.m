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

#import "TWTRVideoControlsViewSynchronizer.h"
#import <TwitterCore/TWTRAssertionMacros.h>
#import "TWTRStringUtil.h"
#import "TWTRVideoControlsView.h"
#import "TWTRVideoPlaybackState.h"

/**
 * This object provides a mechanism for breaking the retain cycle
 * that occurs when using a display link. Instead of requiring the
 * users of the TWTRVideoControlsViewSynchronizer to invalidate the
 * display link we can hide it in the implementation details.
 */
@interface TWTRSynchronizerDisplayLinkWrapper : NSObject

@property (nonatomic, readonly) CADisplayLink *displayLink;
@property (nonatomic, copy) dispatch_block_t actionBlock;

@end

@implementation TWTRSynchronizerDisplayLinkWrapper

- (instancetype)init
{
    self = [super init];
    if (self) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkDidFire:)];
        _displayLink.frameInterval = 20;
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
    return self;
}

- (void)displayLinkDidFire:(CADisplayLink *)link
{
    if (self.actionBlock) {
        self.actionBlock();
    }
}

- (void)invalidate
{
    [self.displayLink invalidate];
    _displayLink = nil;
}

@end

@interface TWTRVideoControlsViewSynchronizer ()

@property (nonatomic, readonly) TWTRSynchronizerDisplayLinkWrapper *displayLinkWrapper;

/**
 * A mechanism to remember what the playback state was when we started scubbing so we can return to that value.
 */
@property (nonatomic) TWTRVideoPlaybackState playbackStateBeforeScrubbing;

@end

@implementation TWTRVideoControlsViewSynchronizer {
    BOOL _disableSynchronization;
}

- (instancetype)initWithVideoPlayer:(TWTRVideoPlayerOutputView *)player controls:(TWTRVideoControlsView *)controls
{
    TWTRParameterAssertOrReturnValue(player, nil);
    TWTRParameterAssertOrReturnValue(controls, nil);

    self = [super init];
    if (self) {
        _videoPlayerView = player;
        _controlsView = controls;

        self.presentsVideoControlsOnReady = YES;

        _displayLinkWrapper = [[TWTRSynchronizerDisplayLinkWrapper alloc] init];
        _displayLinkWrapper.actionBlock = [self displayLinkDidFireBlock];

        _videoPlayerView.delegate = self;
        _controlsView.delegate = self;

        [self synchronizeUI];
    }
    return self;
}

- (void)dealloc
{
    [_displayLinkWrapper invalidate];
}

- (void)setPresentsVideoControlsOnReady:(BOOL)presentsVideoControlsOnReady
{
    if (_presentsVideoControlsOnReady != presentsVideoControlsOnReady) {
        self.controlsView.alpha = presentsVideoControlsOnReady ? 0.0 : 1.0;
        _presentsVideoControlsOnReady = presentsVideoControlsOnReady;
    }
}

- (void)setControlsView:(TWTRVideoControlsView * _Nullable)controlsView
{
    _controlsView = controlsView;
    _controlsView.delegate = self;
    [self synchronizeUI];
}

- (dispatch_block_t)displayLinkDidFireBlock
{
    @weakify(self) return ^{
        @strongify(self) if (self->_disableSynchronization || !self.videoPlayerView || !self.controlsView)
        {
            return;  // no need to update
        }
        [self synchronizeUI];
    };
}

- (void)synchronizeUI
{
    NSTimeInterval elapsed;
    NSTimeInterval duration;

    if (self.videoPlayerView) {
        elapsed = [self.videoPlayerView elapsedTime];
        duration = [self.videoPlayerView videoDuration];
    } else {
        elapsed = -1;
        duration = -1;
    }

    [self updateTimeLabelWithElapsedTime:elapsed duration:duration];
    [self.controlsView updateScrubberWithValue:elapsed / duration];
}

- (void)updateTimeLabelWithElapsedTime:(NSTimeInterval)elapsed duration:(NSTimeInterval)duration
{
    [self.controlsView updateWithElapsedTime:elapsed duration:duration];
}

- (void)handleActionButton
{
    [self.videoPlayerView proceedToNextPlaybackState];
}

#pragma mark - Controls View Delegate

- (void)videoControlsView:(TWTRVideoControlsView *)controlsView didTapControlButton:(UIButton *)controlButton
{
    [self.videoPlayerView proceedToNextPlaybackState];
}

- (void)videoControlsView:(TWTRVideoControlsView *)controlsView scrubberDidTouchDown:(UISlider *)scrubber
{
    _disableSynchronization = YES;
    self.playbackStateBeforeScrubbing = self.videoPlayerView.playbackState;
    [self.videoPlayerView pause];
}

- (void)videoControlsView:(TWTRVideoControlsView *)controlsView scrubberDidTouchUp:(UISlider *)scrubber
{
    _disableSynchronization = NO;
    if (self.playbackStateBeforeScrubbing == TWTRVideoPlaybackStatePlaying) {
        [self.videoPlayerView play];
    }
}

- (void)videoControlsView:(TWTRVideoControlsView *)controlsView scrubberDidChangeValue:(UISlider *)scrubber
{
    NSTimeInterval duration = self.videoPlayerView.videoDuration;
    NSTimeInterval position = scrubber.value * duration;
    [self.videoPlayerView seekToPosition:position];
    [self updateTimeLabelWithElapsedTime:position duration:duration];
}

- (void)videoControlsView:(TWTRVideoControlsView *)controlsView didTapFullscreenButton:(UIButton *)fullscreenButton
{
    if ([self.delegate respondsToSelector:@selector(controlsViewSynchronizerDidTapFullscreen:)]) {
        [self.delegate controlsViewSynchronizerDidTapFullscreen:self];
    }
}

#pragma mark - Video Player Delegate

- (void)videoPlayer:(TWTRVideoPlayerOutputView *)player didChangePlaybackState:(TWTRVideoPlaybackState)newState;
{
    [self.controlsView updateForControlState:newState];

    if ([self.delegate respondsToSelector:@selector(controlsViewSynchronizer:didChangePlaybackState:)]) {
        [self.delegate controlsViewSynchronizer:self didChangePlaybackState:newState];
    }

}

- (void)videoPlayerDidBecomeReady:(TWTRVideoPlayerOutputView *)player
{
    if (!self.presentsVideoControlsOnReady) {
        return;
    }

    if ([self.delegate respondsToSelector:@selector(controlsViewSynchronizerVideoPlayerDidBecomeReady:)]) {
        [self.delegate controlsViewSynchronizerVideoPlayerDidBecomeReady:self];
    }

    [UIView animateWithDuration:0.3
                     animations:^{
                         self.controlsView.alpha = 1.0;
                     }];
}

@end
