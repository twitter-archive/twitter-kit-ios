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

#import "TWTRPlayerCardEntity.h"
#import <TwitterCore/TWTRDictUtil.h>
#import "TWTRCardEntity+Subclasses.h"
#import "TWTRImages.h"
#import "TWTRJSONKeyRequirement.h"
#import "TWTRJSONValidator.h"
#import "TWTRMediaEntityDisplayConfiguration.h"
#import "TWTRNSCodingUtil.h"
#import "TWTRValueTransformers.h"
#import "TWTRViewUtil.h"

static NSString *const TWTRVineUserIDString = @"586671909";

static NSString *const TWTRPlayerCardSiteBindingValueKey = @"site";
static NSString *const TWTRPlayerCardAppNameBindingValueKey = @"app_name";
static NSString *const TWTRPlayerCardPlayerStreamURLBindingValueKey = @"player_stream_url";
static NSString *const TWTRPlayerCardPlayerURLBindingValueKey = @"card_url";
static NSString *const TWTRPlayerCardPlayerImageBindingValueKey = @"player_image";
static NSString *const TWTRPlayerCardDescriptionBindingValueKey = @"description";

static NSString *const TWTRPlayerCardURLKey = @"url";
static NSString *const TWTRPlayerCardBindingValuesKey = @"binding_values";
static NSString *const TWTRPlayerCardNameKey = @"name";
static NSString *const TWTRPlayerCardPlayerTypeName = @"player";

@interface TWTRPlayerCardEntityBindingValues ()

@property (nonatomic, readonly) NSString *IDString;
@property (nonatomic, copy) NSDictionary<NSString *, id> *validatedDictionary;

@end

@implementation TWTRPlayerCardEntityBindingValues

- (nullable instancetype)initWithJSONDictionary:(NSDictionary *)dictionary
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
        _validatedDictionary = validatedDictionary;
        [self setPropertiesFromValidatedDictionary:validatedDictionary];
    }

    return self;
}

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
    if ([object isKindOfClass:[TWTRPlayerCardEntityBindingValues class]]) {
        return [self isEqualToPlayerCardEntityBindingValues:object];
    } else {
        return NO;
    }
}

- (BOOL)isEqualToPlayerCardEntityBindingValues:(TWTRPlayerCardEntityBindingValues *)other
{
    return [self.validatedDictionary isEqualToDictionary:other.validatedDictionary];
}

- (void)setPropertiesFromValidatedDictionary:(NSDictionary *)dict
{
    _IDString = [dict[TWTRPlayerCardSiteBindingValueKey] copy];
    _appName = [dict[TWTRPlayerCardAppNameBindingValueKey] copy];
    _playerStreamURL = [dict[TWTRPlayerCardPlayerStreamURLBindingValueKey] copy];
    _playerURL = [dict[TWTRPlayerCardPlayerURLBindingValueKey] copy];
    _cardDescription = [dict[TWTRPlayerCardDescriptionBindingValueKey] copy];

    TWTRCardEntityImageValue *imageValue = dict[TWTRPlayerCardPlayerImageBindingValueKey];
    _playerImageURL = [imageValue.imageURLString copy];
    _playerImageSize = imageValue.imageSize;
}

+ (TWTRJSONValidator *)JSONValidator
{
    static TWTRJSONValidator *validator = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary *transformers = @{
            TWTRPlayerCardSiteBindingValueKey: [NSValueTransformer valueTransformerForName:TWTRCardSiteValueToUserIDStringTransformerName],
            TWTRPlayerCardAppNameBindingValueKey: [NSValueTransformer valueTransformerForName:TWTRCardEntityBindingValueStringTransformerName],
            TWTRPlayerCardPlayerStreamURLBindingValueKey: [NSValueTransformer valueTransformerForName:TWTRCardEntityBindingValueStringTransformerName],
            TWTRPlayerCardPlayerURLBindingValueKey: [NSValueTransformer valueTransformerForName:TWTRCardEntityBindingValueStringTransformerName],
            TWTRPlayerCardDescriptionBindingValueKey: [NSValueTransformer valueTransformerForName:TWTRCardEntityBindingValueStringTransformerName],
            TWTRPlayerCardPlayerImageBindingValueKey: [NSValueTransformer valueTransformerForName:TWTRCardEntityBindingValueImageTransformerName],
        };

        NSDictionary *outputValues = @{
            TWTRPlayerCardSiteBindingValueKey: [TWTRJSONKeyRequirement requiredString],
            TWTRPlayerCardAppNameBindingValueKey: [TWTRJSONKeyRequirement requiredString],
            TWTRPlayerCardPlayerStreamURLBindingValueKey: [TWTRJSONKeyRequirement requiredString],
            TWTRPlayerCardPlayerURLBindingValueKey: [TWTRJSONKeyRequirement requiredString],
            TWTRPlayerCardDescriptionBindingValueKey: [TWTRJSONKeyRequirement requiredString],
            TWTRPlayerCardPlayerImageBindingValueKey: [TWTRJSONKeyRequirement requiredKeyOfClass:[TWTRCardEntityImageValue class]],
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

#pragma mark - TWTRPlayerCardEntity

@interface TWTRPlayerCardEntity ()

@property (nonatomic, copy) NSDictionary<NSString *, id> *validatedDictionary;

@end

@implementation TWTRPlayerCardEntity

+ (BOOL)canInitWithJSONDictionary:(NSDictionary<NSString *, id> *)JSONDictionary
{
    NSString *name = [TWTRDictUtil twtr_stringForKey:TWTRPlayerCardNameKey inDict:JSONDictionary];
    return [name isEqualToString:TWTRPlayerCardPlayerTypeName];
}

- (nullable instancetype)initWithJSONDictionary:(NSDictionary *)dictionary
{
    NSDictionary<NSString *, id> *validatedDictionary = [[self class] validateJSONDictionary:dictionary];
    if (validatedDictionary == nil) {
        return nil;
    }

    return [self initWithValidatedDictionary:validatedDictionary];
}

- (instancetype)initWithValidatedDictionary:(NSDictionary<NSString *, id> *)validatedDictionary
{
    self = [super initWithURLString:validatedDictionary[TWTRPlayerCardURLKey]];

    if (self) {
        _validatedDictionary = [validatedDictionary copy];
        [self setPropertiesFromValidatedDictionary:validatedDictionary];
    }

    return self;
}

#pragma mark - Init Helpers

- (void)setPropertiesFromValidatedDictionary:(NSDictionary *)dict
{
    _bindingValues = dict[TWTRPlayerCardBindingValuesKey];

    // The card schema doesn't have a good way of defining what type of player card
    // this is. We are copying what bluebird is doing by looking at the user id of
    // the owning application. The card schema will be changing shortly to give a better
    // indication of the type of card, when that is released we will update this logic.
    if ([self.bindingValues.IDString isEqualToString:TWTRVineUserIDString]) {
        _playerCardType = TWTRPlayerCardTypeVine;
    } else {
        _playerCardType = TWTRPlayerCardTypeUnknown;
    }
}

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
    if ([object isKindOfClass:[TWTRPlayerCardEntity class]]) {
        return [self isEqualToPlayerCardEntity:object];
    } else {
        return NO;
    }
}

- (BOOL)isEqualToPlayerCardEntity:(TWTRPlayerCardEntity *)other
{
    return [self.validatedDictionary isEqualToDictionary:other.validatedDictionary];
}

#pragma mark - JSON Validation
+ (TWTRJSONValidator *)JSONValidator
{
    static TWTRJSONValidator *validator = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary *transformers = @{
            TWTRPlayerCardBindingValuesKey: [TWTRJSONConvertibleTransformer transformerWithTargetClass:[TWTRPlayerCardEntityBindingValues class]],
        };

        NSDictionary *outputValues = @{TWTRPlayerCardURLKey: [TWTRJSONKeyRequirement requiredKeyOfClass:[NSString class]], TWTRPlayerCardBindingValuesKey: [TWTRJSONKeyRequirement requiredKeyOfClass:[TWTRPlayerCardEntityBindingValues class]]};

        validator = [[TWTRJSONValidator alloc] initWithValueTransformers:transformers outputValues:outputValues];
    });

    return validator;
}

+ (NSDictionary<NSString *, id> *)validateJSONDictionary:(NSDictionary<NSString *, id> *)JSON
{
    return [[self JSONValidator] validatedDictionaryFromJSON:JSON];
}

@end
