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

/**
 * A class which specifies the constraints to apply to
 * a given key in a dictionary for validation.
 */
@interface TWTRJSONKeyRequirement : NSObject

@property (nonatomic, readonly) Class klass;
@property (nonatomic, readonly, getter=isRequired) BOOL required;
@property (nonatomic, copy, readonly) NSArray<NSString *> *alternateKeys;

+ (instancetype)optionalKeyOfClass:(Class)klass;
+ (instancetype)requiredKeyOfClass:(Class)klass;

/**
 * Specifies that a given key is required.
 * If it is not present but one of the values specified in the alternateKeys
 * is present that key will be used in its place.
 */
+ (instancetype)requiredKeyOfClass:(Class)klass alternateKeys:(NSArray<NSString *> *)alternateKeys;

+ (instancetype)optionalKeyOfAnyClass;

+ (instancetype)optionalString;
+ (instancetype)requiredString;
+ (instancetype)requiredStringWithAlternateKeys:(NSArray<NSString *> *)alternateKeys;

+ (instancetype)optionalNumber;
+ (instancetype)requiredNumber;

+ (instancetype)optionalDate;
+ (instancetype)requiredDate;

+ (instancetype)optionalURL;
+ (instancetype)requiredURL;

@end
