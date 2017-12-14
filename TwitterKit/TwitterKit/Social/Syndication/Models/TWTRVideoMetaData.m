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

#import "TWTRVideoMetaData.h"
#import <TwitterCore/TWTRAssertionMacros.h>
#import <TwitterCore/TWTRDictUtil.h>
#import "TWTRAPIConstantsStatus.h"
#import "TWTRJSONKeyRequirement.h"
#import "TWTRJSONValidator.h"
#import "TWTRNSCodingUtil.h"
#import "TWTRValueTransformers.h"
#import "TWTRViewUtil.h"

static NSString *const TWTRDurationKey = @"duration";
static NSString *const TWTRVideoURLKey = @"videoURL";
static NSString *const TWTRVariantsKey = @"variants";
static NSString *const TWTRContentTypeKey = @"content_type";
static NSString *const TWTRVideoDurationMillisKey = @"duration_millis";
static NSString *const TWTRAspectRatioKey = @"aspect_ratio";
static NSString *const TWTRURLKey = @"url";

static NSString *const TWTRVideoVariantBitrateKey = @"bitrate";

NSString *const TWTRMediaTypeMP4 = @"video/mp4";
NSString *const TWTRMediaTypeM3u8 = @"application/x-mpegURL";

@interface TWTRVideoMetaDataVariant ()

@property (nonatomic, copy) NSDictionary<NSString *, id> *validatedDictionary;

@end

@implementation TWTRVideoMetaDataVariant

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

#pragma mark - Init Helpers

- (void)setPropertiesFromValidatedDictionary:(NSDictionary *)dict
{
    _bitrate = [dict[TWTRVideoVariantBitrateKey] integerValue];
    _contentType = [dict[TWTRContentTypeKey] copy];
    _URL = [dict[TWTRURLKey] copy];
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
    if ([object isKindOfClass:[TWTRVideoMetaDataVariant class]]) {
        return [self isEqualToVariant:object];
    } else {
        return NO;
    }
}

- (BOOL)isEqualToVariant:(TWTRVideoMetaDataVariant *)other
{
    return [self.validatedDictionary isEqualToDictionary:other.validatedDictionary];
}

#pragma mark - JSON Validation
+ (TWTRJSONValidator *)JSONValidator
{
    static TWTRJSONValidator *validator = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary *transformers = @{TWTRURLKey: [NSValueTransformer valueTransformerForName:TWTRNSURLValueTransformerName]};

        NSDictionary *outputValues = @{
            /// Required Values
            TWTRContentTypeKey: [TWTRJSONKeyRequirement requiredString],
            TWTRURLKey: [TWTRJSONKeyRequirement requiredURL],

            /// Optional Values
            TWTRVideoVariantBitrateKey: [TWTRJSONKeyRequirement optionalNumber]
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

@interface TWTRVideoMetaData ()

@property (nonatomic, copy) NSDictionary<NSString *, id> *validatedDictionary;

@end

@implementation TWTRVideoMetaData

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

#pragma mark - Init Helpers

- (void)setPropertiesFromValidatedDictionary:(NSDictionary *)dict
{
    _variants = dict[TWTRVariantsKey];
    _aspectRatio = [dict[TWTRAspectRatioKey] floatValue];
    _duration = [dict[TWTRVideoDurationMillisKey] doubleValue] / 1000.0;

    for (TWTRVideoMetaDataVariant *variant in _variants) {
        /// Keep this to support older versions that use the videoURL property.
        if ([variant.contentType isEqualToString:TWTRMediaTypeMP4]) {
            _videoURL = variant.URL;
        }
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
    if ([object isKindOfClass:[TWTRVideoMetaData class]]) {
        return [self isEqualToVideoMetaData:object];
    } else {
        return NO;
    }
}

- (BOOL)isEqualToVideoMetaData:(TWTRVideoMetaData *)other
{
    return [self.validatedDictionary isEqualToDictionary:other.validatedDictionary];
}

#pragma mark - JSON Validation
+ (TWTRJSONValidator *)JSONValidator
{
    static TWTRJSONValidator *validator = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary *transformers = @{TWTRVariantsKey: [TWTRJSONConvertibleTransformer transformerWithTargetClass:[TWTRVideoMetaDataVariant class]], TWTRAspectRatioKey: [NSValueTransformer valueTransformerForName:TWTRAspectRatioArrayTransformerName]};

        NSDictionary *outputValues = @{
            /// Required Values
            TWTRVariantsKey: [TWTRJSONKeyRequirement requiredKeyOfClass:[NSArray class]],
            TWTRAspectRatioKey: [TWTRJSONKeyRequirement requiredNumber],
            TWTRVideoDurationMillisKey: [TWTRJSONKeyRequirement optionalNumber]
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
