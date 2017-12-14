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

NS_ASSUME_NONNULL_BEGIN

extern NSString *const TWTRServerDateValueTransformerName;
extern NSString *const TWTRMyRetweetIDValueTransformerName;
extern NSString *const TWTRNSURLValueTransformerName;
extern NSString *const TWTRCardEntityJSONValueTransformerName;

/// converts an array [16, 9] -> 1.77777
extern NSString *const TWTRAspectRatioArrayTransformerName;

/**
 * Converts a dictionary to the targetClass or if a collection of dictionaries
 * returns a collection of targetClass objects.
 */
@interface TWTRJSONConvertibleTransformer : NSValueTransformer

@property (nonatomic) Class targetClass;

/**
 * Initializes the receiver with the given target class.
 * This class must conform to the TWTRJSONConvertible protocol.
 */
- (instancetype)initWithTargetClass:(Class)targetClass;
+ (instancetype)transformerWithTargetClass:(Class)targetClass;

@end

NS_ASSUME_NONNULL_END
