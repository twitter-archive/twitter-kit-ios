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

#import "TWTRUser.h"
#import <TwitterCore/TWTRAPIConstants.h>
#import <TwitterCore/TWTRDictUtil.h>
#import "TWTRAPIConstantsStatus.h"
#import "TWTRJSONKeyRequirement.h"
#import "TWTRJSONValidator.h"
#import "TWTRNSCodingUtil.h"
#import "TWTRStringUtil.h"

@interface TWTRUser ()

@property (nonatomic, copy) NSDictionary<NSString *, id> *validatedDictionary;

@end

@implementation TWTRUser

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
    _userID = [dict[TWTRAPIConstantsFieldIDString] copy];
    _name = [dict[TWTRAPIConstantsStatusFieldName] copy];
    _screenName = [dict[TWTRAPIConstantsStatusFieldScreenName] copy];
    _isVerified = [dict[TWTRAPIConstantsStatusFieldVerified] boolValue];
    _isProtected = [dict[TWTRAPIConstantsStatusFieldProtected] boolValue];
    _profileImageURL = [dict[TWTRAPIConstantsStatusFieldProfileImageUrl] copy];
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
    if ([object isKindOfClass:[TWTRUser class]]) {
        return [self.validatedDictionary isEqualToDictionary:((TWTRUser *)object).validatedDictionary];
    } else {
        return NO;
    }
}

#pragma mark - Getters and Setters

- (NSString *)formattedScreenName
{
    return [NSString stringWithFormat:@"@%@", self.screenName];
}

- (NSString *)profileImageMiniURL
{
    return [TWTRStringUtil stringByReplacingLastOccurrenceOfString:@"_normal" withString:@"_mini" inStringIgnoringExtension:self.profileImageURL];
}

- (NSString *)profileImageLargeURL
{
    // This isn't a typo, reasonably_small is indeed "large" i.e. 128x128 pixels.
    return [TWTRStringUtil stringByReplacingLastOccurrenceOfString:@"_normal" withString:@"_reasonably_small" inStringIgnoringExtension:self.profileImageURL];
}

- (NSURL *)profileURL
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://www.twitter.com/%@", self.screenName]];
}

#pragma mark - NSObject

- (NSString *)description
{
    return self.formattedScreenName;
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"<%@ %p; userID = %@; name = \"%@\"; screenName = \"%@\">", NSStringFromClass([self class]), self, self.userID, self.name, self.screenName];
}

#pragma mark - JSON Validation
+ (TWTRJSONValidator *)JSONValidator
{
    static TWTRJSONValidator *validator = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary *transformers = @{};

        NSDictionary *outputValues = @{
            /// Required Values
            TWTRAPIConstantsFieldIDString: [TWTRJSONKeyRequirement requiredString],
            TWTRAPIConstantsStatusFieldName: [TWTRJSONKeyRequirement requiredString],
            TWTRAPIConstantsStatusFieldScreenName: [TWTRJSONKeyRequirement requiredString],
            TWTRAPIConstantsStatusFieldVerified: [TWTRJSONKeyRequirement requiredNumber],
            TWTRAPIConstantsStatusFieldProtected: [TWTRJSONKeyRequirement requiredNumber],
            TWTRAPIConstantsStatusFieldProfileImageUrl: [TWTRJSONKeyRequirement requiredString]
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
