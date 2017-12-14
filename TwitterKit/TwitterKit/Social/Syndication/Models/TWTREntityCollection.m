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

#import "TWTREntityCollection.h"
#import <TwitterCore/TWTRAPIConstants.h>
#import <TwitterCore/TWTRDictUtil.h>
#import "TWTRAPIConstantsStatus.h"
#import "TWTRJSONKeyRequirement.h"
#import "TWTRJSONValidator.h"
#import "TWTRNSCodingUtil.h"
#import "TWTRTweetCashtagEntity.h"
#import "TWTRTweetHashtagEntity.h"
#import "TWTRTweetMediaEntity.h"
#import "TWTRTweetUrlEntity.h"
#import "TWTRTweetUserMentionEntity.h"
#import "TWTRValueTransformers.h"

@interface TWTREntityCollection ()

@property (nonatomic, copy) NSDictionary<NSString *, id> *validatedDictionary;

@end

@implementation TWTREntityCollection

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
    self = [super init];

    if (self) {
        _validatedDictionary = [validatedDictionary copy];
        [self setPropertiesFromValidatedDictionary:validatedDictionary];
    }

    return self;
}

- (void)setPropertiesFromValidatedDictionary:(NSDictionary *)dict
{
    _hashtags = [dict[TWTRAPIConstantsStatusFieldEntitiesHashtags] copy];
    _cashtags = [dict[TWTRAPIConstantsStatusFieldEntitiesCashTags] copy];
    _media = [dict[TWTRAPIConstantsStatusFieldEntitiesMedia] copy];
    _urls = [dict[TWTRAPIConstantsStatusFieldEntitiesUrls] copy];
    _userMentions = [dict[TWTRAPIConstantsStatusFieldEntitiesUserMentions] copy];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    NSDictionary *validatedDictionary = [decoder decodeObjectOfClass:[NSDictionary class] forKey:TWTRValidatedDictionaryEncoderKey];

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

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (NSUInteger)hash
{
    return [self.validatedDictionary hash];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[TWTREntityCollection class]]) {
        return [self.validatedDictionary isEqualToDictionary:((TWTREntityCollection *)object).validatedDictionary];
    } else {
        return NO;
    }
}

#pragma mark - JSON Validation
+ (TWTRJSONValidator *)JSONValidator
{
    static TWTRJSONValidator *validator = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary *transformers = @{
            TWTRAPIConstantsStatusFieldEntitiesHashtags: [TWTRJSONConvertibleTransformer transformerWithTargetClass:[TWTRTweetHashtagEntity class]],
            TWTRAPIConstantsStatusFieldEntitiesCashTags: [TWTRJSONConvertibleTransformer transformerWithTargetClass:[TWTRTweetCashtagEntity class]],
            TWTRAPIConstantsStatusFieldEntitiesMedia: [TWTRJSONConvertibleTransformer transformerWithTargetClass:[TWTRTweetMediaEntity class]],
            TWTRAPIConstantsStatusFieldEntitiesUrls: [TWTRJSONConvertibleTransformer transformerWithTargetClass:[TWTRTweetUrlEntity class]],
            TWTRAPIConstantsStatusFieldEntitiesUserMentions: [TWTRJSONConvertibleTransformer transformerWithTargetClass:[TWTRTweetUserMentionEntity class]]
        };

        NSDictionary *outputValues = @{
            /// Optional
            TWTRAPIConstantsStatusFieldEntitiesHashtags: [TWTRJSONKeyRequirement optionalKeyOfClass:[NSArray class]],
            TWTRAPIConstantsStatusFieldEntitiesCashTags: [TWTRJSONKeyRequirement optionalKeyOfClass:[NSArray class]],
            TWTRAPIConstantsStatusFieldEntitiesMedia: [TWTRJSONKeyRequirement optionalKeyOfClass:[NSArray class]],
            TWTRAPIConstantsStatusFieldEntitiesUrls: [TWTRJSONKeyRequirement optionalKeyOfClass:[NSArray class]],
            TWTRAPIConstantsStatusFieldEntitiesUserMentions: [TWTRJSONKeyRequirement optionalKeyOfClass:[NSArray class]]
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
