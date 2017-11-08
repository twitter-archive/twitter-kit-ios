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

#import "TWTRMediaEntityDisplayConfiguration.h"
#import "TWTRCardEntity.h"
#import "TWTRImages.h"
#import "TWTRMediaEntitySize.h"
#import "TWTRMediaType.h"
#import "TWTRPlayerCardEntity.h"
#import "TWTRStringUtil.h"
#import "TWTRTweetMediaEntity.h"
#import "TWTRVideoMetaData.h"
#import "TWTRViewUtil.h"

static NSString *const TWTRPillGIFText = @"GIF";

@implementation TWTRMediaEntityDisplayConfiguration

- (instancetype)initWithMediaEntity:(TWTRTweetMediaEntity *)mediaEntity targetWidth:(CGFloat)targetWidth
{
    TWTRMediaEntitySize *entitySize = [TWTRViewUtil bestMatchSizeFromMediaEntity:mediaEntity fittingWidth:targetWidth];
    NSString *pillText = [[self class] labelTextForMediaEntity:mediaEntity];

    NSString *path = [[[self class] imagePathForMediaEntity:mediaEntity sizeKey:entitySize.name] copy];
    return [self initWithImagePath:path imageSize:entitySize.size pillText:pillText pillImage:nil];
}

- (instancetype)initWithImagePath:(NSString *)imagePath imageSize:(CGSize)imageSize
{
    return [self initWithImagePath:imagePath imageSize:imageSize pillText:nil pillImage:nil];
}

- (instancetype)initWithImagePath:(NSString *)imagePath imageSize:(CGSize)imageSize pillText:(nullable NSString *)pillText pillImage:(nullable UIImage *)pillImage
{
    self = [super init];
    if (self) {
        _imagePath = [imagePath copy];
        _imageSize = imageSize;
        _pillText = [pillText copy];
        _pillImage = pillImage;
    }
    return self;
}

+ (NSString *)imagePathForMediaEntity:(TWTRTweetMediaEntity *)mediaEntity sizeKey:(NSString *)sizeKey;
{
    return [NSString stringWithFormat:@"%@:%@", [mediaEntity mediaUrl], sizeKey];
}

+ (NSString *)labelTextForMediaEntity:(TWTRTweetMediaEntity *)entity
{
    if (entity.mediaType == TWTRMediaTypeGIF) {
        return TWTRPillGIFText;
    } else if (entity.mediaType == TWTRMediaTypeVideo) {
        return [self stringFromDuration:entity.videoMetaData.duration];
    }
    return @"";
}

+ (NSString *)stringFromDuration:(NSTimeInterval)interval
{
    return [TWTRStringUtil displayStringFromTimeInterval:interval] ?: @"";
}

#pragma mark - Card Entity Init
+ (nullable instancetype)mediaEntityDisplayConfigurationWithCardEntity:(TWTRCardEntity *)cardEntity
{
    if (![cardEntity isKindOfClass:[TWTRPlayerCardEntity class]]) {
        return nil;
    }

    TWTRPlayerCardEntity *playerCardEntity = (TWTRPlayerCardEntity *)cardEntity;
    NSString *path = playerCardEntity.bindingValues.playerImageURL;
    CGSize size = playerCardEntity.bindingValues.playerImageSize;

    UIImage *image = nil;
    if (playerCardEntity.playerCardType == TWTRPlayerCardTypeVine) {
        image = [TWTRImages vineBadgeImage];
    }

    return [[TWTRMediaEntityDisplayConfiguration alloc] initWithImagePath:path imageSize:size pillText:nil pillImage:image];
}

@end
