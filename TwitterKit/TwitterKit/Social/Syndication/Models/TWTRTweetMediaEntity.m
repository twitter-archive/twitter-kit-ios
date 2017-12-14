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

#import "TWTRTweetMediaEntity.h"
#import <TwitterCore/TWTRDictUtil.h>
#import <TwitterCore/TWTRUtils.h>
#import "TWTRAPIConstantsStatus.h"
#import "TWTRMediaEntitySize.h"
#import "TWTRMediaType.h"
#import "TWTRVideoMetaData.h"
#import "TWTRVideoPlaybackConfiguration.h"

@implementation TWTRTweetMediaEntity

#pragma mark - Init

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary
{
    self = [super initWithJSONDictionary:dictionary];

    if (self) {
        [self setPropertiesFromDict:dictionary];
    }

    return self;
}

#pragma mark - Init Helpers

- (void)setPropertiesFromDict:(NSDictionary *)dict
{
    _mediaUrl = [TWTRDictUtil twtr_stringForKey:TWTRAPIConstantsStatusFieldMediaEntityMediaUrlHttps inDict:dict];
    NSDictionary *sizesDict = [TWTRDictUtil twtr_dictForKey:TWTRAPIConstantsStatusFieldMediaEntitySizes inDict:dict];
    _sizes = [TWTRMediaEntitySize mediaEntitySizesWithJSONDictionary:sizesDict];
    _displayURL = [TWTRDictUtil twtr_stringForKey:TWTRAPIConstantsStatusFieldUrlEntityDisplayUrl inDict:dict];
    _tweetTextURL = [TWTRDictUtil twtr_stringForKey:TWTRAPIConstantsStatusFieldUrlEntitiyUrl inDict:dict];
    _mediaID = [TWTRDictUtil twtr_stringFromNumberForKey:TWTRAPIConstantsStatusFieldMediaEntityMediaID inDict:dict];
    _mediaType = TWTRMediaTypeFromStringContentType([TWTRDictUtil twtr_stringForKey:TWTRAPIConstantsStatusFieldMediaEntityType inDict:dict]);

    NSDictionary *additionalInfo = [TWTRDictUtil twtr_dictForKey:TWTRAPIConstantsStatusFieldMediaEntityAdditionalMediaInfo inDict:dict];
    _embeddable = [TWTRDictUtil twtr_boolForKey:TWTRAPIConstantsStatusFieldMediaEntityEmbeddable inDict:additionalInfo];
    _isEmbeddableDefined = [additionalInfo objectForKey:TWTRAPIConstantsStatusFieldMediaEntityEmbeddable] != nil;

    NSDictionary *videoInfo = [TWTRDictUtil twtr_dictForKey:TWTRAPIConstantsStatusFieldMediaEntityVideoInfo inDict:dict];
    if (videoInfo) {
        _videoMetaData = [[TWTRVideoMetaData alloc] initWithJSONDictionary:videoInfo];
    }
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];

    if (self) {
        _mediaUrl = [decoder decodeObjectForKey:@"mediaUrl"];
        _displayURL = [decoder decodeObjectForKey:@"displayURL"];
        _tweetTextURL = [decoder decodeObjectForKey:@"tweetTextURL"];
        _sizes = [decoder decodeObjectForKey:@"sizes"];
        _mediaID = [decoder decodeObjectForKey:@"id"];
        _mediaType = TWTRMediaTypeFromStringContentType([decoder decodeObjectForKey:@"type"]);
        _videoMetaData = [decoder decodeObjectForKey:@"videoMetaData"];
        _embeddable = [decoder decodeBoolForKey:@"embeddable"];
        _isEmbeddableDefined = [decoder decodeBoolForKey:@"isEmbeddableDefined"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];

    [encoder encodeObject:self.mediaUrl forKey:@"mediaUrl"];
    [encoder encodeObject:self.displayURL forKey:@"displayURL"];
    [encoder encodeObject:self.tweetTextURL forKey:@"tweetTextURL"];
    [encoder encodeObject:self.sizes forKey:@"sizes"];
    [encoder encodeObject:self.mediaID forKey:@"id"];
    [encoder encodeObject:NSStringFromTWTRMediaType(self.mediaType) forKey:@"type"];
    [encoder encodeObject:self.videoMetaData forKey:@"videoMetaData"];
    [encoder encodeBool:self.embeddable forKey:@"embeddable"];
    [encoder encodeBool:self.isEmbeddableDefined forKey:@"isEmbeddableDefined"];
}

- (NSUInteger)hash
{
    return [self.mediaID hash];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[TWTRTweetMediaEntity class]]) {
        return [self isEqualToMediaEntity:object];
    } else {
        return NO;
    }
}

- (BOOL)isEqualToMediaEntity:(TWTRTweetMediaEntity *)other
{
    return [super isEqual:other] && [self.mediaUrl isEqual:other.mediaUrl] && [self.displayURL isEqual:other.displayURL] && [self.tweetTextURL isEqual:other.tweetTextURL] && [self.sizes isEqual:other.sizes] && [self.mediaID isEqual:other.mediaID] && [TWTRUtils isEqualOrBothNil:self.videoMetaData other:other.videoMetaData] && self.mediaType == other.mediaType && self.embeddable == other.embeddable;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    return self;
}

@end
