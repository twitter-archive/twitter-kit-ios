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
#import "TWTRMediaType.h"

@class TWTRCardEntity;
@class TWTRTweetMediaEntity;
@class TWTRTweetUrlEntity;
@class TWTRVideoDeeplinkConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface TWTRVideoPlaybackConfiguration : NSObject

/**
 * The URL for the video.
 */
@property (nonatomic, readonly) NSURL *videoURL;

/**
 * The aspect ratio for the video.
 */
@property (nonatomic, readonly) CGFloat aspectRatio;

/**
 * The duration of the video return from the videoURL.
 */
@property (nonatomic, readonly) NSTimeInterval duration;

/**
 * The type of Twitter media this video represents.
 */
@property (nonatomic, readonly) TWTRMediaType mediaType;

/**
 * An ID that represents this media on Twitter's backend. Not all
 * playback configurations will have this value.
 */
@property (nonatomic, copy, readonly) NSString *mediaID;

/**
 * An object which describes how to deep link to an external application.
 */
@property (nonatomic, readonly, nullable) TWTRVideoDeeplinkConfiguration *deeplinkConfiguration;

/**
 * Initializes the receiver with the given values.
 */
- (instancetype)initWithVideoURL:(NSURL *)URL aspectRatio:(CGFloat)aspectRatio duration:(NSTimeInterval)duration mediaType:(TWTRMediaType)mediaType mediaID:(NSString *)mediaID deeplinkConfiguration:(nullable TWTRVideoDeeplinkConfiguration *)deeplinkConfiguration;

/**
 * Returns a playback configuration object for the given meta data object.
 */
+ (nullable instancetype)playbackConfigurationForTweetMediaEntity:(TWTRTweetMediaEntity *)mediaEntity;
+ (nullable instancetype)playbackConfigurationForCardEntity:(TWTRCardEntity *)cardEntity URLEntities:(NSArray<TWTRTweetUrlEntity *> *)URLEntities;

@end

NS_ASSUME_NONNULL_END
