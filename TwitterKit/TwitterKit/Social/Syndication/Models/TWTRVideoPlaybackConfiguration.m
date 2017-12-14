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

#import "TWTRVideoPlaybackConfiguration.h"
#import "TWTRCardEntity.h"
#import "TWTRPlayerCardEntity.h"
#import "TWTRTranslationsUtil.h"
#import "TWTRTweetMediaEntity.h"
#import "TWTRTweetUrlEntity.h"
#import "TWTRVideoDeeplinkConfiguration.h"
#import "TWTRVideoMetaData.h"
#import "TWTRViewUtil.h"

@implementation TWTRVideoPlaybackConfiguration

- (instancetype)initWithVideoURL:(NSURL *)URL aspectRatio:(CGFloat)aspectRatio duration:(NSTimeInterval)duration mediaType:(TWTRMediaType)mediaType mediaID:(NSString *)mediaID deeplinkConfiguration:(nullable TWTRVideoDeeplinkConfiguration *)deeplinkConfiguration
{
    self = [super init];
    if (self) {
        _videoURL = URL;
        _duration = duration;
        _mediaType = mediaType;
        _mediaID = [mediaID copy];
        _aspectRatio = aspectRatio;
        _deeplinkConfiguration = deeplinkConfiguration;
    }
    return self;
}

+ (nullable instancetype)playbackConfigurationForTweetMediaEntity:(TWTRTweetMediaEntity *)mediaEntity
{
    TWTRVideoMetaData *videoMetaData = mediaEntity.videoMetaData;
    if (!videoMetaData) {
        return nil;
    }

    TWTRVideoMetaDataVariant *variant = [[self class] bestVariantFromMetaData:videoMetaData];
    NSURL *URL = variant.URL;

    return [[TWTRVideoPlaybackConfiguration alloc] initWithVideoURL:URL aspectRatio:videoMetaData.aspectRatio duration:videoMetaData.duration mediaType:mediaEntity.mediaType mediaID:mediaEntity.mediaID deeplinkConfiguration:nil];
}

+ (TWTRVideoMetaDataVariant *)bestVariantFromMetaData:(TWTRVideoMetaData *)videoMetaData
{
    NSInteger index = [[videoMetaData variants] indexOfObjectPassingTest:^BOOL(TWTRVideoMetaDataVariant *obj, NSUInteger idx, BOOL *stop) {
        return [TWTRMediaTypeM3u8 isEqualToString:obj.contentType];
    }];

    if (index != NSNotFound) {
        TWTRVideoMetaDataVariant *variant = [videoMetaData variants][index];
        return variant;
    } else {
        return [self lowestBitrateVariant:videoMetaData];
    }
}

+ (TWTRVideoMetaDataVariant *)lowestBitrateVariant:(TWTRVideoMetaData *)videoMetaData
{
    NSIndexSet *mp4Indexes = [[videoMetaData variants] indexesOfObjectsPassingTest:^BOOL(TWTRVideoMetaDataVariant *obj, NSUInteger idx, BOOL *stop) {
        return [TWTRMediaTypeMP4 isEqualToString:obj.contentType];
    }];

    return [[[[videoMetaData variants] objectsAtIndexes:mp4Indexes] sortedArrayUsingComparator:^NSComparisonResult(TWTRVideoMetaDataVariant *obj1, TWTRVideoMetaDataVariant *obj2) {
        return [@(obj1.bitrate) compare:@(obj2.bitrate)];
    }] firstObject];
}

#pragma mark - Card Entity
+ (nullable instancetype)playbackConfigurationForCardEntity:(TWTRCardEntity *)cardEntity URLEntities:(NSArray<TWTRTweetUrlEntity *> *)URLEntities
{
    if (![cardEntity isKindOfClass:[TWTRPlayerCardEntity class]]) {
        return nil;
    }

    TWTRPlayerCardEntity *playerCardEntity = (TWTRPlayerCardEntity *)cardEntity;
    if (playerCardEntity.playerCardType != TWTRPlayerCardTypeVine) {
        return nil;
    }

    NSURL *deeplinkURL = [self expandedURLFromEntities:URLEntities matchingURLString:playerCardEntity.URLString];
    if (!deeplinkURL) {
        return nil;
    }

    NSURL *metricsURL = [NSURL URLWithString:playerCardEntity.URLString];
    NSURL *videoURL = [NSURL URLWithString:playerCardEntity.bindingValues.playerStreamURL];
    CGFloat aspectRatio = [TWTRViewUtil aspectRatioForSize:playerCardEntity.bindingValues.playerImageSize];

    NSString *displayText = [NSString stringWithFormat:TWTRLocalizedString(@"tw__open_in_text"), playerCardEntity.bindingValues.appName];
    TWTRVideoDeeplinkConfiguration *deeplinkConfig = [[TWTRVideoDeeplinkConfiguration alloc] initWithDisplayText:displayText targetURL:deeplinkURL metricsURL:metricsURL];

    // TODO: Vine's don't have a media id
    return [[TWTRVideoPlaybackConfiguration alloc] initWithVideoURL:videoURL aspectRatio:aspectRatio duration:6 mediaType:TWTRMediaTypeVine mediaID:@"" deeplinkConfiguration:deeplinkConfig];
}

+ (nullable NSURL *)expandedURLFromEntities:(NSArray<TWTRTweetUrlEntity *> *)entities matchingURLString:(NSString *)URLString
{
    for (TWTRTweetUrlEntity *entity in entities) {
        if ([entity.url isEqual:URLString]) {
            return [NSURL URLWithString:entity.expandedUrl];
        }
    }
    return nil;
}

@end
