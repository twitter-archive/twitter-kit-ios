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

#import "TWTRVideoPlayerOutputView.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <TwitterCore/TWTRAssertionMacros.h>
#import "TWTRImages.h"
#import "TWTRNotificationConstants.h"
#import "TWTRVideoPlaybackConfiguration.h"
#import "TWTRViewUtil.h"

NS_ASSUME_NONNULL_BEGIN

// WARNING: Do not for any reason change this value
static const Float64 TWTRStandardTrimAmountInSeconds = 0.05;

static void *TWTRVideoPlayerStatusKVOContext = &TWTRVideoPlayerStatusKVOContext;

NSString *stringForPlaybackState(TWTRVideoPlaybackState state)
{
    switch (state) {
        case TWTRVideoPlaybackStatePaused:
            return TWTRVideoStateValuePaused;
        case TWTRVideoPlaybackStatePlaying:
            return TWTRVideoStateValuePlaying;
        case TWTRVideoPlaybackStateCompleted:
            return TWTRVideoStateValueCompleted;
        default:
            return @"Unknown";
    }
}

NSString *videoGravityForAspectRatio(TWTRVideoPlayerAspectRatio aspectRatio)
{
    switch (aspectRatio) {
        case TWTRVideoPlayerAspectRatioAspect:
            return AVLayerVideoGravityResizeAspect;
        case TWTRVideoPlayerAspectRatioAspectFill:
            return AVLayerVideoGravityResizeAspectFill;
        case TWTRVideoPlayerAspectRatioResize:
            return AVLayerVideoGravityResize;
        default:
            return AVLayerVideoGravityResizeAspect;
    }
}

@interface TWTRVideoPlayerViewLayer : UIView
@property (nonatomic, readonly) AVPlayerLayer *playerLayer;
@end

@implementation TWTRVideoPlayerViewLayer

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (AVPlayerLayer *)playerLayer
{
    return (AVPlayerLayer *)self.layer;
}

@end

@interface TWTRVideoPlayerOutputView ()

@property (nonatomic, readonly) AVPlayerItem *playerItem;
@property (nonatomic, readonly) AVPlayer *player;
@property (nonatomic, readonly) dispatch_queue_t serialConfigurationQueue;
@property (nonatomic, nullable) id playerObserver;
@property (nonatomic, readonly) TWTRVideoPlayerViewLayer *playerLayerView;
@property (nonatomic) TWTRVideoPlaybackState playbackState;

@property (nonatomic, readonly) TWTRVideoPlaybackConfiguration *configuration;

@property (nonatomic, readonly) UIActivityIndicatorView *loadingView;
@property (nonatomic, readonly) UIImageView *previewImageView;

@end

@implementation TWTRVideoPlayerOutputView {
    BOOL _didRegisterForNotifications;
    BOOL _playerHasBecomeReady;
}

- (instancetype)initWithFrame:(CGRect)frame videoPlaybackConfiguration:(TWTRVideoPlaybackConfiguration *)configuration previewImage:(nullable UIImage *)previewImage shouldLoadVideo:(BOOL)shouldLoadVideo
{
    TWTRParameterAssertOrReturnValue(configuration, nil);

    self = [super initWithFrame:frame];
    if (self) {
        _configuration = configuration;
        _shouldAutoPlay = YES;
        _shouldAutoLoop = NO;
        _playbackState = TWTRVideoPlaybackStatePaused;
        _serialConfigurationQueue = dispatch_queue_create("com.twitterkit.videoplayer.configuration-queue", DISPATCH_QUEUE_SERIAL);
        _aspectRatio = TWTRVideoPlayerAspectRatioAspect;

        self.backgroundColor = [UIColor blackColor];
        [self prepareSubviewsWithPreviewImage:previewImage];

        if (shouldLoadVideo) {
            [self configureVideoPlayer];
        }
    }

    return self;
}

- (void)dealloc
{
    [self unregisterObservers];
}

- (void)prepareSubviewsWithPreviewImage:(UIImage *)image
{
    _previewImageView = [[UIImageView alloc] initWithImage:image];
    _previewImageView.frame = self.bounds;
    _previewImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _previewImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_previewImageView];

    _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _loadingView.translatesAutoresizingMaskIntoConstraints = NO;
    [_loadingView startAnimating];
    [self addSubview:_loadingView];
    [TWTRViewUtil centerViewInSuperview:_loadingView];

    _playerLayerView = [[TWTRVideoPlayerViewLayer alloc] init];
    _playerLayerView.frame = self.bounds;
    _playerLayerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _playerLayerView.alpha = 0.0;
    _playerLayerView.playerLayer.videoGravity = videoGravityForAspectRatio(self.aspectRatio);
    [self addSubview:_playerLayerView];
}

- (void)configureVideoPlayer
{
    dispatch_async(self.serialConfigurationQueue, ^{
        [self configureVideoPlayerInSerialQueue];
    });
}

- (void)configureVideoPlayerInSerialQueue
{
    if (self.configuration.videoURL == nil) {
        NSLog(@"Attempting to play a video without a videoURL");
        return;
    }

    if (self.configuration.mediaType == TWTRMediaTypeVine) {
        // TODO: This is pretty slow, need to make it asynchronous.
        _playerItem = [[self class] seamlessLoopingVinePlayerItemFromURL:self.configuration.videoURL];
    } else {
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.configuration.videoURL options:nil];
        _playerItem = [AVPlayerItem playerItemWithAsset:asset];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        self->_player = [AVPlayer playerWithPlayerItem:self.playerItem];
        self.playerLayerView.playerLayer.player = self.player;
        [self registerObservers];
    });
}

- (void)setAspectRatio:(TWTRVideoPlayerAspectRatio)aspectRatio
{
    _aspectRatio = aspectRatio;
    self.playerLayerView.playerLayer.videoGravity = videoGravityForAspectRatio(aspectRatio);
}

- (void)performOnMain:(dispatch_block_t)block
{
    dispatch_async(dispatch_get_main_queue(), block);
}

- (void)loadVideo
{
    if (_playerItem == nil) {
        [self configureVideoPlayer];
    }
}

- (CGRect)videoRect
{
    return self.playerLayerView.playerLayer.videoRect;
}

#pragma mark - KVO

- (void)registerObservers
{
    if (_didRegisterForNotifications) {
        return;
    }

    [self.playerItem addObserver:self forKeyPath:@"status" options:0 context:&TWTRVideoPlayerStatusKVOContext];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePlayerDidReachEndNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];

    _didRegisterForNotifications = YES;
}

- (void)unregisterObservers
{
    if (!_didRegisterForNotifications) {
        return;
    }

    [self.playerItem removeObserver:self forKeyPath:@"status" context:TWTRVideoPlayerStatusKVOContext];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];

    _didRegisterForNotifications = NO;
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString *, id> *)change context:(nullable void *)context
{
    if (context == TWTRVideoPlayerStatusKVOContext) {
        [self handlePlayerStatusChange:change];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)handlePlayerStatusChange:(NSDictionary *)change
{
    [self performOnMain:^{
        [self.loadingView removeFromSuperview];
        if (self.player.status == AVPlayerStatusReadyToPlay) {
            [self playerDidBecomeReady];
        }
    }];
}

- (void)handlePlayerDidReachEndNotification:(NSNotification *)note
{
    if (self.shouldAutoLoop) {
        [self restart];
    } else {
        self.playbackState = TWTRVideoPlaybackStateCompleted;
    }
}

- (void)setPlaybackState:(TWTRVideoPlaybackState)playbackState
{
    if (_playbackState != playbackState) {
        _playbackState = playbackState;
        if ([self.delegate respondsToSelector:@selector(videoPlayer:didChangePlaybackState:)]) {
            [self.delegate videoPlayer:self didChangePlaybackState:playbackState];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:TWTRVideoPlaybackStateChangedNotification object:self userInfo:@{TWTRVideoPlaybackStateKey: stringForPlaybackState(playbackState)}];
    }
}

#pragma mark - Player Management

- (void)playerDidBecomeReady
{
    if (_playerHasBecomeReady) {
        return;
    }

    _playerHasBecomeReady = YES;
    if ([self.delegate respondsToSelector:@selector(videoPlayerDidBecomeReady:)]) {
        [self.delegate videoPlayerDidBecomeReady:self];
    }

    if (self.shouldAutoPlay) {
        [self play];
    }
}

- (BOOL)isVideoReadyToPlay
{
    return self.playerItem.status == AVPlayerStatusReadyToPlay;
}

#pragma mark - Controls

- (void)restart
{
    if (![self isVideoReadyToPlay]) {
        self.shouldAutoPlay = YES;
        return;
    }

    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [self play];
    }];
}

- (void)play
{
    if (![self isVideoReadyToPlay]) {
        self.shouldAutoPlay = YES;
        return;
    }

    self.playerLayerView.alpha = 1.0;
    [self.player setMuted:self.shouldPlayVideoMuted];
    [self.player play];

    self.playbackState = TWTRVideoPlaybackStatePlaying;
}

- (void)pause
{
    if (![self isVideoReadyToPlay]) {
        return;
    }

    [self.player pause];
    self.playbackState = TWTRVideoPlaybackStatePaused;
}

- (void)proceedToNextPlaybackState
{
    switch (self.playbackState) {
        case TWTRVideoPlaybackStatePaused:
            [self play];
            break;
        case TWTRVideoPlaybackStatePlaying:
            [self pause];
            break;
        case TWTRVideoPlaybackStateCompleted:
            [self restart];
            break;
    }
}

- (void)seekToPosition:(NSTimeInterval)position
{
    static const CMTimeScale minimumTimeScale = 90000;

    [self.playerItem cancelPendingSeeks];

    CMTimeScale timeScale = MAX(self.playerItem.currentTime.timescale, minimumTimeScale);
    CMTime time = CMTimeMakeWithSeconds(position, timeScale);

    [self.playerItem seekToTime:time];
}

- (NSTimeInterval)elapsedTime
{
    CMTime time = self.playerItem.currentTime;
    if (CMTIME_IS_INDEFINITE(time) || CMTIME_IS_INVALID(time)) {
        return -1;
    }

    return [self timeIntervalFromTime:time];
}

- (NSTimeInterval)videoDuration
{
    CMTime time = self.playerItem.duration;
    if (CMTIME_IS_INDEFINITE(time) || CMTIME_IS_INVALID(time)) {
        return self.configuration.duration;
    }

    return [self timeIntervalFromTime:time];
}

- (NSTimeInterval)timeIntervalFromTime:(CMTime)time
{
    return (NSTimeInterval)time.value / (NSTimeInterval)time.timescale;
}

#pragma mark - Vine Seemless Looping Player From BlueBird
// https://cgit.twitter.biz/twitter-ios/tree/TwitterPlatform/UI/UI/VineGif/TFNVinePlayer.m#n160
+ (AVPlayerItem *)seamlessLoopingVinePlayerItemFromURL:(NSURL *)url;
{
    BOOL shouldFadeIn = YES;

    AVURLAsset *sourceAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    BOOL hadError = NO;
    NSError *editError = nil;
    AVPlayerItem *item = nil;

    AVMutableCompositionTrack *compositionVideoTrack = nil;
    if (!hadError) {
        if ([sourceAsset tracksWithMediaType:AVMediaTypeVideo].count) {
            AVMutableComposition *composition = [[AVMutableComposition alloc] init];
            int32_t preferredTimeScale = sourceAsset.duration.timescale;
            CMTime duration = sourceAsset.duration;

            BOOL hasAudioTrack = ([sourceAsset tracksWithMediaType:AVMediaTypeAudio].count > 0);

            AVAssetTrack *sourceVideoTrack = [[sourceAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            AVAssetTrack *sourceAudioTrack = (hasAudioTrack ? [[sourceAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] : nil);

            compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            compositionVideoTrack.preferredTransform = sourceVideoTrack.preferredTransform;

            AVMutableCompositionTrack *compositionAudioTracks[2];
            if (hasAudioTrack) {
                compositionAudioTracks[0] = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                compositionAudioTracks[1] = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            }

            NSUInteger numOfCopies = (NSUInteger)(25 * 6 / CMTimeGetSeconds(duration));
            numOfCopies = MAX(25, MIN(numOfCopies, 50));

            NSInteger i = 0, currentAudioTrackIndex = 0;
            NSMutableArray *crossFadeStartPoints = [NSMutableArray array];

            CMTime nextStartTime = kCMTimeZero;

            CMTimeRange editRange = CMTimeRangeMake([self standardTrim], CMTimeSubtract(duration, [self standardTotalTrimAmount]));
            CMTimeRange editAudioRange = CMTimeRangeMake([self standardTrim], CMTimeSubtract(duration, [self standardTrim]));
            duration = editRange.duration;

            BOOL result = [compositionVideoTrack insertTimeRange:editRange ofTrack:sourceVideoTrack atTime:nextStartTime error:&editError];
            if (!result) {
                hadError = YES;
                NSLog(@"An error occured while creating the composition: %@ (video track %@)", editError, compositionVideoTrack);
            } else {
                if (hasAudioTrack) {
                    result = [compositionAudioTracks[0] insertTimeRange:editAudioRange ofTrack:sourceAudioTrack atTime:nextStartTime error:&editError];
                    if (!result) {
                        hadError = YES;
                        NSLog(@"An error occured while creating the composition: %@ (audio track %@)", editError, sourceAudioTrack);
                    }
                }

                nextStartTime = compositionVideoTrack.timeRange.duration;

                for (i = 0; i < numOfCopies; i++) {
                    result = [compositionVideoTrack insertTimeRange:editRange ofTrack:sourceVideoTrack atTime:nextStartTime error:&editError];
                    if (!result) {
                        hadError = YES;
                        NSLog(@"An error occured while creating the composition: %@ (video track %@)", editError, compositionVideoTrack);
                        break;
                    } else if (hasAudioTrack) {
                        currentAudioTrackIndex = ((i + 1) % 2);
                        result = [compositionAudioTracks[currentAudioTrackIndex] insertTimeRange:editAudioRange ofTrack:sourceAudioTrack atTime:nextStartTime error:&editError];
                        if (!result) {
                            hadError = YES;
                            NSLog(@"An error occured while creating the composition: %@ (audio track %@)", editError, sourceAudioTrack);
                            break;
                        }
                    }

                    [crossFadeStartPoints addObject:[NSValue valueWithCMTime:nextStartTime]];
                    nextStartTime = compositionVideoTrack.timeRange.duration;
                }
            }

            AVMutableAudioMix *audioMix = nil;
            // create audio cross fased
            if (!hadError && hasAudioTrack) {
                audioMix = [AVMutableAudioMix audioMix];
                AVMutableAudioMixInputParameters *audioMixParameters[2];
                audioMixParameters[0] = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:compositionAudioTracks[0]];
                audioMixParameters[1] = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:compositionAudioTracks[1]];

                if (shouldFadeIn) {
                    NSTimeInterval overAllFadeDuration = 2.0;
                    CMTime startFadeTime = [crossFadeStartPoints[0] CMTimeValue];
                    if (CMTimeGetSeconds(startFadeTime) < overAllFadeDuration) {
                        overAllFadeDuration = CMTimeGetSeconds(startFadeTime);
                    }

                    [(AVMutableAudioMixInputParameters *)audioMixParameters[0] setVolumeRampFromStartVolume:0 toEndVolume:1.0 timeRange:CMTimeRangeFromTimeToTime(kCMTimeZero, CMTimeMakeWithSeconds(overAllFadeDuration, preferredTimeScale))];
                } else {
                    [(AVMutableAudioMixInputParameters *)audioMixParameters[0] setVolume:1.0 atTime:kCMTimeZero];
                }

                [(AVMutableAudioMixInputParameters *)audioMixParameters[1] setVolume:0.0 atTime:kCMTimeZero];

                for (i = 0; i < numOfCopies; i++) {
                    CMTime startFadeTime = [crossFadeStartPoints[i] CMTimeValue];
                    CMTimeRange crossFadeRange = CMTimeRangeMake(startFadeTime, [self standardTrim]);
                    [(AVMutableAudioMixInputParameters *)audioMixParameters[(i % 2)] setVolumeRampFromStartVolume:1.0 toEndVolume:0.0 timeRange:crossFadeRange];
                    [(AVMutableAudioMixInputParameters *)audioMixParameters[!(i % 2)] setVolumeRampFromStartVolume:0.0 toEndVolume:1.0 timeRange:crossFadeRange];
                }

                audioMix.inputParameters = @[audioMixParameters[0], audioMixParameters[1]];
            }
            item = [AVPlayerItem playerItemWithAsset:composition];

            if (audioMix) {
                [item setAudioMix:audioMix];
            }
        }
    }
    return item;
}

+ (CMTime)standardTrim
{
    return CMTimeMakeWithSeconds(TWTRStandardTrimAmountInSeconds, NSEC_PER_SEC);
}

+ (CMTime)standardTotalTrimAmount
{
    return CMTimeMakeWithSeconds(TWTRStandardTrimAmountInSeconds + TWTRStandardTrimAmountInSeconds, NSEC_PER_SEC);
}

@end

NS_ASSUME_NONNULL_END

/** NOTE FOR LATER
 // This is some sample code that allows for the inline video to play without taking over the playback of audio from something like the music app even when the player is not playing.
 do {
             try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: [.MixWithOthers])
             try AVAudioSession.sharedInstance().setActive(true)
         } catch {
             
         }
 */
