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

#import <TwitterKit/TWTRJSONConvertible.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString *const TWTRMediaTypeMP4;
FOUNDATION_EXTERN NSString *const TWTRMediaTypeM3u8;

@interface TWTRVideoMetaDataVariant : NSObject <NSCoding, NSCopying, TWTRJSONConvertible>

/**
 * The bitrate of the entitity
 */
@property (nonatomic, readonly) NSInteger bitrate;

/**
 * The content type of the video entity.
 */
@property (nonatomic, copy, readonly) NSString *contentType;

/**
 * The URL for the entity.
 */
@property (nonatomic, readonly) NSURL *URL;

@end

@interface TWTRVideoMetaData : NSObject <NSCoding, NSCopying, TWTRJSONConvertible>

/**
 * The URL of the video if the video is an mp4. This value is provided as a convenience
 * method but user's should query the `variants` property to have finer grained control
 * over which video they play.
 */
@property (nonatomic, readonly, nullable) NSURL *videoURL;

/**
 * Returns the array of variants.
 */
@property (nonatomic, readonly) NSArray *variants;

/**
 * The video's aspect ratio.
 */
@property (nonatomic, readonly) CGFloat aspectRatio;

/**
 * The video's duration in seconds.
 */
@property (nonatomic, readonly) NSTimeInterval duration;

@end

NS_ASSUME_NONNULL_END
