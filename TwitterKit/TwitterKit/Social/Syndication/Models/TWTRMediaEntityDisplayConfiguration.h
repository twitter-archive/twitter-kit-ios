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

@class TWTRTweetMediaEntity;
@class TWTRCardEntity;

NS_ASSUME_NONNULL_BEGIN

@interface TWTRMediaEntityDisplayConfiguration : NSObject

/**
 * Returns the fully qualified url for the image based on the
 * image size and location.
 */
@property (nonatomic, copy, readonly) NSString *imagePath;

/**
 * Returns the size of the image.
 */
@property (nonatomic, readonly) CGSize imageSize;

/**
 * Returns a short description of playable media if there is playable media.
 */
@property (nonatomic, readonly, copy, nullable) NSString *pillText;
@property (nonatomic, readonly, nullable) UIImage *pillImage;

- (instancetype)init NS_UNAVAILABLE;

/**
 * Creates an instance of the media entity display configuration object
 * with the given media entity object and the width that you are targeting.
 *
 * @param mediaEntity the TWTRTweetMediaEntity object
 * @param targetWidth the width that the view will target.
 */
- (instancetype)initWithMediaEntity:(TWTRTweetMediaEntity *)mediaEntity targetWidth:(CGFloat)targetWidth;

/**
 * Initializes the receiver with the given card entity or nil if the card has no associated media.
 */
+ (nullable instancetype)mediaEntityDisplayConfigurationWithCardEntity:(TWTRCardEntity *)cardEntity;

- (instancetype)initWithImagePath:(NSString *)imagePath imageSize:(CGSize)imageSize;
- (instancetype)initWithImagePath:(NSString *)imagePath imageSize:(CGSize)imageSize pillText:(nullable NSString *)pillText pillImage:(nullable UIImage *)pillImage NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
