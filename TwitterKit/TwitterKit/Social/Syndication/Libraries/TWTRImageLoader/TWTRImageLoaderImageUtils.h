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

NS_ASSUME_NONNULL_BEGIN

@interface TWTRImageLoaderImageUtils : NSObject

/**
 *  Determines if the given image has an alpha channel.
 *
 *  @param image image to check.
 *
 *  @return YES if image has alpha channel e.g. PNG and JPEG2000
 */
+ (BOOL)imageHasAlphaChannel:(UIImage *)image;

/**
 *  Extracts the underlying image data from the given image.
 *
 *  @param image              the image to extract data from. Supported formats: PNG/JPEG
 *  @param compressionQuality whether to compress the image data in the output.
 *                            0 (most) <= compressionQuality <= 1 (least). This is no-op for formats
 *                            that do not support compression.
 *
 *  @return underlying image data.
 */
+ (NSData *)imageDataFromImage:(UIImage *)image compressionQuality:(CGFloat)compressionQuality;

@end

NS_ASSUME_NONNULL_END
