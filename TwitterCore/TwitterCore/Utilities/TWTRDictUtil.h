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
 This header is private to the Twitter Core SDK and not exposed for public SDK consumption
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TWTRDictUtil : NSObject

/**
 *  Returns an array for the specified key. Returns nil if the value does not exist for the key or the return type is not an array.
 */
+ (NSArray *)twtr_arrayForKey:(NSString *)key inDict:(NSDictionary *)dict;

/**
 *  Returns a CGFloat for the specified key.
 */
+ (CGFloat)twtr_CGFloatForKey:(NSString *)key inDict:(NSDictionary *)dict;

/**
 *  Returns a double for the specified key.
 */
+ (double)twtr_doubleForKey:(NSString *)key inDict:(NSDictionary *)dict;

/**
 *  Returns a bool for the specified key.
 */
+ (BOOL)twtr_boolForKey:(NSString *)key inDict:(NSDictionary *)dict;

/**
 *  Returns an int for the specified key.
 */
+ (NSInteger)twtr_intForKey:(NSString *)key inDict:(NSDictionary *)dict;

/**
 *  Returns a long long for the specified key.
 */
+ (long long)twtr_longlongForKey:(NSString *)key inDict:(NSDictionary *)dict;

/**
 *  Returns an unsigned integer for the specified key.
 */
+ (NSUInteger)twtr_unsignedIntegerForKey:(NSString *)key inDict:(NSDictionary *)dict;

/**
 *  Returns a string from a number for the specified key. Returns nil if the value does not exist for the key or the return type is not a string.
 */
+ (NSString *)twtr_stringFromNumberForKey:(NSString *)key inDict:(NSDictionary *)dict;

/**
 *  Returns a generic object for the specified key. Returns nil if the value does not exist.
 */
+ (id)twtr_objectForKey:(NSString *)key inDict:(NSDictionary *)dict;

/**
 *  Returns a string for the specified key. Returns nil if the value does not exist for the key or the return type is not a string.
 */
+ (NSString *)twtr_stringForKey:(NSString *)key inDict:(NSDictionary *)dict;

/**
 *  Returns a date for the specified key. Returns nil if the value does not exist for the key or the return type is not a date.
 */
+ (NSDate *)twtr_dateForKey:(NSString *)key inDict:(NSDictionary *)dict;

/**
 *  Returns a dictionary for the specified key. Returns nil if the value does not exist for the key or the return type is not a dictionary.
 */
+ (NSDictionary *)twtr_dictForKey:(NSString *)key inDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
