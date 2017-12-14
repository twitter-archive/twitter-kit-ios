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

#import "TWTRImageLoaderImageUtils.h"
#import <TwitterCore/TWTRAssertionMacros.h>

@implementation TWTRImageLoaderImageUtils

+ (BOOL)imageHasAlphaChannel:(UIImage *)image
{
    TWTRParameterAssertOrReturnValue(image, NO);

    const CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image.CGImage);
    return !(alpha == kCGImageAlphaNone || alpha == kCGImageAlphaNoneSkipFirst || alpha == kCGImageAlphaNoneSkipLast);
}

+ (NSData *)imageDataFromImage:(UIImage *)image compressionQuality:(CGFloat)compressionQuality
{
    TWTRParameterAssertOrReturnValue(image, nil);

    CGFloat clampedCompressionQuality = MIN(MAX(0, compressionQuality), 1);
    const BOOL imageHasAlpha = [TWTRImageLoaderImageUtils imageHasAlphaChannel:image];
    return imageHasAlpha ? UIImagePNGRepresentation(image) : UIImageJPEGRepresentation(image, clampedCompressionQuality);
}

@end
