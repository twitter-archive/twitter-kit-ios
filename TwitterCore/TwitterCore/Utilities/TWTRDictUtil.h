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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TWTRDictUtil : NSObject

+ (CGFloat)CGFloatForKey:(NSString *)key fromDict:(NSDictionary *)dict;
+ (double)doubleForKey:(NSString *)key fromDict:(NSDictionary *)dict;
+ (BOOL)boolForKey:(NSString *)key fromDict:(NSDictionary *)dict;
+ (NSInteger)intForKey:(NSString *)key fromDict:(NSDictionary *)dict;
+ (long long)longlongForKey:(NSString *)key fromDict:(NSDictionary *)dict;
+ (NSUInteger)unsignedIntegerForKey:(NSString *)key fromDict:(NSDictionary *)dict;
+ (NSString *)stringFromNumberForKey:(NSString *)key fromDict:(NSDictionary *)dict;
+ (id)objectForKey:(NSString *)key fromDict:(NSDictionary *)dict;
+ (NSString *)stringForKey:(NSString *)key fromDict:(NSDictionary *)dict;
+ (NSDate *)dateForKey:(NSString *)key fromDict:(NSDictionary *)dict;
+ (NSDictionary *)dictForKey:(NSString *)key fromDict:(NSDictionary *)dict;
+ (NSArray *)arrayForKey:(NSString *)key fromDict:(NSDictionary *)dict;

@end

@interface TWTRArrayUtil : NSObject

/**
 * Returns a CGFloat at the given index. This method does not check bounds.
 */
+ (CGFloat)CGFloatAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
