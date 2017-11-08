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

#import "TWTRImages.h"
#import <TwitterCore/TWTRColorUtil.h>
#import "TWTRConstants_Private.h"
#import "TWTROSVersionInfo.h"
#import "TWTRRuntime.h"

@implementation TWTRImages

#pragma mark - Favorite

+ (UIImage *)likeOn
{
    return [self resourcesImageNamed:@"twtr-icn-heart-on"];
}

+ (UIImage *)likeOff
{
    return [self resourcesImageNamed:@"twtr-icn-heart-off"];
}

+ (UIImage *)likeImageSheet
{
    return [self resourcesImageNamed:@"twtr-heart-animation-sheet"];
}

+ (UIImage *)likeOnLarge
{
    return [self resourcesImageNamed:@"twtr-icon-heart-on-large"];
}

+ (UIImage *)likeOffLarge
{
    return [self resourcesImageNamed:@"twtr-icn-heart-off-large"];
}

+ (UIImage *)likeImageSheetLarge
{
    return [self resourcesImageNamed:@"twtr-heart-animation-sheet-large"];
}

+ (UIImage *)retweetImage
{
    return [self resourcesImageNamed:@"twtr-retweet"];
}

+ (UIImage *)shareImage
{
    return [self resourcesImageNamed:@"twtr-share"];
}

+ (UIImage *)shareImageLarge
{
    return [self resourcesImageNamed:@"twtr-share-large"];
}

#pragma mark - Retweet

+ (UIImage *)retweetImageForBackgroundColor:(UIColor *)backgroundColor
{
    if (backgroundColor && [TWTRColorUtil isLightColor:backgroundColor]) {
        return [self darkRetweet];
    } else {
        return [self lightRetweet];
    }
}

+ (UIImage *)lightRetweet
{
    return [self resourcesImageNamed:@"twtr-icn-tweet-retweeted-by-light"];
}

+ (UIImage *)darkRetweet
{
    return [self resourcesImageNamed:@"twtr-icn-tweet-retweeted-by-dark"];
}

#pragma mark - Verified

+ (UIImage *)verifiedIcon
{
    return [self resourcesImageNamed:@"twtr-icn-tweet-verified"];
}

#pragma mark - Play

+ (UIImage *)playIcon
{
    return [self resourcesImageNamed:@"twtr-play"];
}

#pragma mark - Video Player

+ (UIImage *)mediaPauseTemplateImage
{
    return [[self resourcesImageNamed:@"twtr-icn-media-pause"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

+ (UIImage *)mediaPlayTemplateImage
{
    return [[self resourcesImageNamed:@"twtr-icn-media-play"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

+ (UIImage *)mediaReplayTemplateImage
{
    return [[self resourcesImageNamed:@"twtr-icn-media-replay"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

+ (UIImage *)mediaExpandTemplateImage
{
    return [[self resourcesImageNamed:@"twtr-media-expand"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

+ (UIImage *)mediaScrubberThumb
{
    return [self resourcesImageNamed:@"twtr-icn-media-scrubber"];
}

+ (UIImage *)vineBadgeImage
{
    return [self resourcesImageNamed:@"icn_vine_badge"];
}

#pragma mark - Button images

+ (UIImage *)closeButtonTemplateImage
{
    UIImage *baseImage = [self resourcesImageNamed:@"twtr-icn_close"];
    return [baseImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

+ (UIImage *)buttonImageWithCornerRadius:(CGFloat)radius backgroundColor:(UIColor *)backgroundColor;
{
    return [self buttonImageWithCornerRadius:radius backgroundColor:backgroundColor borderColor:nil];
}

+ (UIImage *)buttonImageWithCornerRadius:(CGFloat)radius backgroundColor:(UIColor *)backgroundColor borderColor:(nullable UIColor *)borderColor
{
    CGFloat imageSize = radius * 2.0 + 1;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageSize, imageSize), NO, 0.0);

    CGRect rect = CGRectMake(0, 0, imageSize, imageSize);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
    [backgroundColor set];
    [path fill];

    if (borderColor) {
        CGRect insetRect = CGRectInset(rect, 1.0, 1.0);
        UIBezierPath *insetPath = [UIBezierPath bezierPathWithRoundedRect:insetRect cornerRadius:radius];
        insetPath.lineWidth = 2.0;
        [borderColor set];
        [insetPath stroke];
    }

    UIImage *baseImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return [baseImage resizableImageWithCapInsets:UIEdgeInsetsMake(radius, radius, radius, radius)];
}

#pragma mark -

#pragma mark - Internal

+ (NSString *)resourcePathForImageName:(NSString *)imageName
{
    NSString *fullPath = [NSString pathWithComponents:@[TWTRResourceBundleLocation, imageName]];

    // When running tests, imageNamed: needs to know which bundle to look inside
    if ([TWTRRuntime isRunningUnitTests]) {
        NSString *currentBundlePath = [NSBundle bundleForClass:self].bundlePath;
        fullPath = [NSString pathWithComponents:@[currentBundlePath, fullPath]];
    }

    return fullPath;
}

+ (UIImage *)resourcesImageNamed:(NSString *)imageName
{
    NSString *imagePath = [self resourcePathForImageName:imageName];
    return [UIImage imageNamed:imagePath];
}

@end
