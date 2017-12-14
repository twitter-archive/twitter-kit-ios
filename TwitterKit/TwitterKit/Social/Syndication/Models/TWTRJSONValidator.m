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

#import "TWTRJSONValidator.h"
#import "TWTRJSONKeyRequirement.h"

@interface TWTRJSONValidator ()

@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSValueTransformer *> *transformers;
@property (nonatomic, copy, readonly) NSDictionary<NSString *, TWTRJSONKeyRequirement *> *outputValues;

@end

@implementation TWTRJSONValidator

- (instancetype)initWithValueTransformers:(NSDictionary<NSString *, NSValueTransformer *> *)transformers outputValues:(NSDictionary<NSString *, TWTRJSONKeyRequirement *> *)outputValues
{
    self = [super init];
    if (self) {
        _transformers = [transformers copy];
        _outputValues = [outputValues copy];
    }
    return self;
}

- (nullable NSDictionary<NSString *, id> *)validatedDictionaryFromJSON:(NSDictionary<NSString *, id> *)JSONDictionary
{
    NSMutableDictionary<NSString *, id> *mutableJSON = [JSONDictionary mutableCopy];
    [self transformDictionary:mutableJSON];

    if ([self allRequiredKeysPresent:mutableJSON]) {
        return [self pruneDictionary:mutableJSON];
    } else {
        return nil;
    }
}

- (void)transformDictionary:(NSMutableDictionary<NSString *, id> *)mutableDictionary
{
    [self.transformers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSValueTransformer *transformer, BOOL *stop) {
        id originalObj = mutableDictionary[key];
        id newObj = [transformer transformedValue:originalObj];

        if (newObj != nil) {
            mutableDictionary[key] = newObj;
        } else {
            [mutableDictionary removeObjectForKey:key];
        }
    }];

    /// Remove any keys that are not the correct class or are [NSNull null]
    [self.outputValues enumerateKeysAndObjectsUsingBlock:^(NSString *key, TWTRJSONKeyRequirement *requirement, BOOL *stop) {
        if ([self key:key isValidForClass:requirement.klass inDictionary:mutableDictionary]) {
            return;
        }

        for (NSString *altKey in requirement.alternateKeys) {
            if ([self key:altKey isValidForClass:requirement.klass inDictionary:mutableDictionary]) {
                // update the value
                mutableDictionary[key] = mutableDictionary[altKey];
                return;
            }
        }

        // Not a valid match for the key or it's alternate keys
        [mutableDictionary removeObjectForKey:key];
    }];
}

- (BOOL)key:(NSString *)key isValidForClass:(Class)klass inDictionary:(NSDictionary *)dictionary
{
    id obj = dictionary[key];

    if (![obj isKindOfClass:klass]) {
        return NO;
    }

    return YES;
}

- (BOOL)allRequiredKeysPresent:(NSDictionary<NSString *, id> *)dictionary;
{
    __block BOOL isValid = YES;
    [self.outputValues enumerateKeysAndObjectsUsingBlock:^(NSString *key, TWTRJSONKeyRequirement *requirement, BOOL *stop) {

        if (!requirement.isRequired) {
            return;
        }

        BOOL missingValue = dictionary[key] == nil;

        /// Fail if required key is missing and all aternates are missing or not the correct class
        if (missingValue) {
            *stop = YES;
            isValid = NO;
            NSLog(@"Failed JSON validation because of missing key %@", key);
        }
    }];

    return isValid;
}

- (NSDictionary *)pruneDictionary:(NSDictionary *)input
{
    NSMutableDictionary *output = [NSMutableDictionary dictionaryWithCapacity:self.outputValues.count];

    for (NSString *key in [self.outputValues allKeys]) {
        output[key] = input[key];
    }

    return output;
}

@end
