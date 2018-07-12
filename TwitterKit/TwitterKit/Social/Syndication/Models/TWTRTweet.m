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

#import "TWTRTweet.h"
#import <TwitterCore/TWTRAPIConstants.h>
#import <TwitterCore/TWTRAssertionMacros.h>
#import <TwitterCore/TWTRDateFormatters.h>
#import <TwitterCore/TWTRDictUtil.h>
#import "TWTRAPIConstantsStatus.h"
#import "TWTRCardEntity.h"
#import "TWTREntityCollection.h"
#import "TWTRJSONKeyRequirement.h"
#import "TWTRJSONValidator.h"
#import "TWTRNSCodingUtil.h"
#import "TWTRPlayerCardEntity.h"
#import "TWTRStringUtil.h"
#import "TWTRTweetHashtagEntity.h"
#import "TWTRTweetMediaEntity.h"
#import "TWTRTweetUrlEntity.h"
#import "TWTRTweet_Constants.h"
#import "TWTRTweet_Private.h"
#import "TWTRURLUtility.h"
#import "TWTRUser.h"
#import "TWTRValueTransformers.h"
#import "TWTRVideoMetaData.h"

NSString *const TWTRTweetPerspectivalUserID = @"perspectival_user_id";

@interface TWTRTweet ()
@property (nonatomic, copy) NSDictionary<NSString *, id> *validatedDictionary;

@end

@implementation TWTRTweet
@synthesize permalink = _permalink;

#pragma mark - Init

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary
{
    NSDictionary<NSString *, id> *validatedDictionary = [[self class] validateJSONDictionary:dictionary];

    if (validatedDictionary == nil) {
        return nil;
    }

    return [self initWithValidatedDictionary:validatedDictionary];
}

- (instancetype)initWithValidatedDictionary:(NSDictionary<NSString *, id> *)validatedDictionary
{
    if (self = [super init]) {
        _validatedDictionary = [validatedDictionary copy];
        [self setPropertiesFromValidatedDictiontary:validatedDictionary];
    }

    return self;
}

+ (NSArray *)tweetsWithJSONArray:(NSArray *)array
{
    NSMutableArray *tweets = [NSMutableArray array];

    for (NSDictionary *tweetJson in array) {
        TWTRTweet *tweet = [[TWTRTweet alloc] initWithJSONDictionary:tweetJson];
        if (tweet) {
            [tweets addObject:tweet];
        }
    }

    return tweets;
}

- (TWTRTweet *)tweetWithLikeToggled
{
    NSMutableDictionary *validatedCopy = [self.validatedDictionary mutableCopy];
    validatedCopy[TWTRAPIConstantsStatusFieldFavorited] = @(!self.isLiked);

    return [[TWTRTweet alloc] initWithValidatedDictionary:validatedCopy];
}

- (TWTRTweet *)tweetWithPerspectivalUserID:(NSString *)userID
{
    NSMutableDictionary *validatedCopy = [self.validatedDictionary mutableCopy];
    validatedCopy[TWTRTweetPerspectivalUserID] = userID;
    return [[TWTRTweet alloc] initWithValidatedDictionary:validatedCopy];
}

#pragma mark - Init Helpers

- (void)setPropertiesFromValidatedDictiontary:(NSDictionary<NSString *, id> *)dict
{
    _text = [self tweetTextFromDictionary:dict];
    _author = dict[TWTRAPIConstantsStatusFieldUser];
    _createdAt = dict[TWTRAPIConstantsStatusFieldCreatedAt];
    _tweetID = [dict[TWTRAPIConstantsFieldIDString] copy];
    _likeCount = [dict[TWTRAPIConstantsStatusFieldFavoriteCount] longLongValue];
    _retweetCount = [dict[TWTRAPIConstantsStatusFieldRetweetCount] longLongValue];
    _isLiked = [dict[TWTRAPIConstantsStatusFieldFavorited] boolValue];
    _isRetweeted = [dict[TWTRAPIConstantsStatusFieldRetweeted] boolValue];
    _languageCode = [dict[TWTRAPIConstantsStatusFieldLang] copy];
    _retweetID = [dict[TWTRAPIConstantsStatusFieldCurrentUserRetweet] copy];
    _retweetedTweet = dict[TWTRAPIConstantsStatusFieldRetweetedStatus];
    _inReplyToTweetID = [dict[TWTRAPIConstantsStatusFieldInReplyToStatusIDString] copy];
    _inReplyToUserID = [dict[TWTRAPIConstantsStatusFieldInReplyToUserIDString] copy];
    _inReplyToScreenName = [dict[TWTRAPIConstantsStatusFieldInReplyToScreenName] copy];
    _cardEntity = dict[TWTRAPIConstantsStatusFieldCardCurrent];

    /// This is not part of the API response but something that the API client would set
    _perspectivalUserID = [dict[TWTRTweetPerspectivalUserID] copy];

    TWTREntityCollection *entities = dict[TWTRAPIConstantsStatusFieldEntities];
    TWTREntityCollection *extendedEntities = dict[TWTRAPIConstantsStatusFieldEntitiesExtended];

    if (extendedEntities.media.count > 0) {
        _media = extendedEntities.media;
    } else {
        _media = entities.media;
    }

    _hashtags = entities.hashtags;
    _urls = entities.urls;
    _userMentions = entities.userMentions;
    _cashtags = entities.cashtags;

    _quotedTweet = dict[TWTRAPIConstantsStatusFieldQuotedStatus];
}

- (NSString *)tweetTextFromDictionary:(NSDictionary<NSString *, id> *)dict
{
    // We prefer the full_text value over the text value
    return dict[TWTRAPIConstantsStatusFieldFullText] ?: dict[TWTRAPIConstantsStatusFieldText];
}

#pragma mark - Properties

- (BOOL)isRetweet
{
    return self.retweetedTweet != nil;
}

- (BOOL)isQuoteTweet
{
    return self.quotedTweet != nil;
}

#pragma mark - NSCoding Protocol

- (instancetype)initWithCoder:(NSCoder *)coder
{
    NSDictionary *validatedDictionary = [coder decodeObjectOfClass:[NSDictionary class] forKey:TWTRValidatedDictionaryEncoderKey];

    if (validatedDictionary) {
        return [self initWithValidatedDictionary:validatedDictionary];
    } else {
        return nil;
    }
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.validatedDictionary forKey:TWTRValidatedDictionaryEncoderKey];
}

#pragma mark - Getters and Setters

- (BOOL)hasMedia
{
    return [self.media count] > 0 || [self.cardEntity isKindOfClass:[TWTRPlayerCardEntity class]];
}

- (BOOL)hasPlayableVideo
{
    const BOOL isDisplayingVideoEntity = self.videoMetaData != nil;
    const BOOL isDisplayingVineCard = [self hasVineCard];

    return isDisplayingVideoEntity || isDisplayingVineCard;
}

- (BOOL)hasVineCard
{
    return self.cardEntity && ([self.cardEntity isKindOfClass:[TWTRPlayerCardEntity class]] && [(TWTRPlayerCardEntity *)self.cardEntity playerCardType] == TWTRPlayerCardTypeVine);
}

- (TWTRVideoMetaData *)videoMetaData
{
    return self.media.firstObject.videoMetaData;
}

- (NSURL *)permalink
{
    if (!_permalink) {
        _permalink = [TWTRURLUtility permalinkURLForTweet:self];
    }

    return _permalink;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    return self;
}

- (NSUInteger)hash
{
    return [self.tweetID hash];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[TWTRTweet class]]) {
        return [self.validatedDictionary isEqualToDictionary:((TWTRTweet *)object).validatedDictionary];
    } else {
        return NO;
    }
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: %@", self.author, self.text];
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"<%@: %p; tweetID = %@; createdAt = %@; text = \"%@\"; author = %@>", NSStringFromClass([self class]), self, self.tweetID, self.createdAt, self.text, self.author.debugDescription];
}

#pragma mark - Caching

+ (NSInteger)version
{
    return 12;
}

+ (NSString *)versionedCacheKeyWithID:(NSString *)IDString perspective:(NSString *)perspective
{
    TWTRParameterAssertOrReturnValue([IDString length] > 0, nil);

    return [NSString stringWithFormat:@"%@:%zd:%@:%@", NSStringFromClass([self class]), (long)[[self class] version], perspective ?: @"", IDString];
}

#pragma mark - JSON Validating
+ (TWTRJSONValidator *)JSONValidator
{
    static TWTRJSONValidator *validator = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary *transformers = @{
            TWTRAPIConstantsStatusFieldCreatedAt: [NSValueTransformer valueTransformerForName:TWTRServerDateValueTransformerName],
            TWTRAPIConstantsStatusFieldCurrentUserRetweet: [NSValueTransformer valueTransformerForName:TWTRMyRetweetIDValueTransformerName],
            TWTRAPIConstantsStatusFieldUser: [TWTRJSONConvertibleTransformer transformerWithTargetClass:[TWTRUser class]],
            TWTRAPIConstantsStatusFieldRetweetedStatus: [TWTRJSONConvertibleTransformer transformerWithTargetClass:[TWTRTweet class]],
            TWTRAPIConstantsStatusFieldQuotedStatus: [TWTRJSONConvertibleTransformer transformerWithTargetClass:[TWTRTweet class]],
            TWTRAPIConstantsStatusFieldEntities: [TWTRJSONConvertibleTransformer transformerWithTargetClass:[TWTREntityCollection class]],
            TWTRAPIConstantsStatusFieldEntitiesExtended: [TWTRJSONConvertibleTransformer transformerWithTargetClass:[TWTREntityCollection class]],
            TWTRAPIConstantsStatusFieldCardCurrent: [NSValueTransformer valueTransformerForName:TWTRCardEntityJSONValueTransformerName],
        };

        NSDictionary *outputValues = @{
            /// Required Values
            TWTRAPIConstantsStatusFieldCreatedAt: [TWTRJSONKeyRequirement requiredDate],

            /*
             The API will return a "text" field for the old version of Tweets but the new
             extended_mode tweets will return a "full_text" field. The value transformer will
             place the value of the full_text field in place of the text field if it is present.
             */
            TWTRAPIConstantsStatusFieldText: [TWTRJSONKeyRequirement requiredStringWithAlternateKeys:@[TWTRAPIConstantsStatusFieldFullText]],

            TWTRAPIConstantsFieldIDString: [TWTRJSONKeyRequirement requiredString],
            TWTRAPIConstantsStatusFieldFavoriteCount: [TWTRJSONKeyRequirement requiredNumber],
            TWTRAPIConstantsStatusFieldRetweetCount: [TWTRJSONKeyRequirement requiredNumber],
            TWTRAPIConstantsStatusFieldFavorited: [TWTRJSONKeyRequirement requiredNumber],
            TWTRAPIConstantsStatusFieldRetweeted: [TWTRJSONKeyRequirement requiredNumber],
            TWTRAPIConstantsStatusFieldLang: [TWTRJSONKeyRequirement requiredString],
            TWTRAPIConstantsStatusFieldUser: [TWTRJSONKeyRequirement requiredKeyOfClass:[TWTRUser class]],

            /// Optional Values
            TWTRAPIConstantsStatusFieldInReplyToStatusIDString: [TWTRJSONKeyRequirement optionalString],
            TWTRAPIConstantsStatusFieldInReplyToUserIDString: [TWTRJSONKeyRequirement optionalString],
            TWTRAPIConstantsStatusFieldInReplyToScreenName: [TWTRJSONKeyRequirement optionalString],
            TWTRAPIConstantsStatusFieldCurrentUserRetweet: [TWTRJSONKeyRequirement optionalString],
            TWTRAPIConstantsStatusFieldRetweetedStatus: [TWTRJSONKeyRequirement optionalKeyOfClass:[TWTRTweet class]],
            TWTRAPIConstantsStatusFieldEntities: [TWTRJSONKeyRequirement optionalKeyOfClass:[TWTREntityCollection class]],
            TWTRAPIConstantsStatusFieldEntitiesExtended: [TWTRJSONKeyRequirement optionalKeyOfClass:[TWTREntityCollection class]],
            TWTRTweetPerspectivalUserID: [TWTRJSONKeyRequirement optionalString],
            TWTRAPIConstantsStatusFieldCardCurrent: [TWTRJSONKeyRequirement optionalKeyOfClass:[TWTRCardEntity class]],
            TWTRAPIConstantsStatusFieldQuotedStatus: [TWTRJSONKeyRequirement optionalKeyOfClass:[TWTRTweet class]],

            // Versions of the Tweets requested in extended_mode will have a full_text property instead of a text property.
            TWTRAPIConstantsStatusFieldFullText: [TWTRJSONKeyRequirement optionalString],
        };

        validator = [[TWTRJSONValidator alloc] initWithValueTransformers:transformers outputValues:outputValues];
    });

    return validator;
}

+ (NSDictionary<NSString *, id> *)validateJSONDictionary:(NSDictionary<NSString *, id> *)JSON
{
    return [[self JSONValidator] validatedDictionaryFromJSON:JSON];
}

@end
