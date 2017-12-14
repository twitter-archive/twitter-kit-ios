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

/**
 This header is private to the Twitter Kit SDK and not exposed for public SDK consumption
 */

#import <Foundation/Foundation.h>
@class TWTRJSONKeyRequirement;

NS_ASSUME_NONNULL_BEGIN

/**
 * This class provides a mechanism for converting a JSON Dictionary
 * into a dictionary that contains non-JSON objects.
 */
@interface TWTRJSONValidator : NSObject

/**
 * Initializes the receiver with the required transformers and output values.
 *
 * @param transformers a mapping of keys in the dictionary to a value transformer to apply to that mapping. If the transformer returns nil the key will be removed.
 * @param outputValues a mapping of keys and requirement constraints that will be output in the final object.
 */
- (instancetype)initWithValueTransformers:(NSDictionary<NSString *, NSValueTransformer *> *)transformers outputValues:(NSDictionary<NSString *, TWTRJSONKeyRequirement *> *)outputValues;

/**
 * Convert the given JSONDictionary object to the representation described by the transformers and outputValues.
 * The resulting dictionary will only contain the objects that are specified in the outputValues array after
 * they have been transformed.
 *
 * @param JSONDictionary the JSON dictionary to convert.
 * @return the transformed dictionary or nil if the constraints cannot be satisfied.
 * Failure occurs if any of the required keys are missing or are the wrong class. If an optional key is the wrong class it is removed.
 */
- (nullable NSDictionary<NSString *, id> *)validatedDictionaryFromJSON:(NSDictionary<NSString *, id> *)JSONDictionary;

@end

NS_ASSUME_NONNULL_END
