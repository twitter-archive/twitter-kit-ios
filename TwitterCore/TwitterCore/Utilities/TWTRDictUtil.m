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

#import "TWTRDictUtil.h"

@implementation TWTRDictUtil

+ (CGFloat)CGFloatForKey:(NSString *)key fromDict:(NSDictionary *)dict
{
    NSNumber *number = [self numberForKey:key fromDict:dict];
#if CGFLOAT_IS_DOUBLE
    return [number doubleValue];
#else
    return [number floatValue];
#endif
}

+ (double)doubleForKey:(NSString *)key fromDict:(NSDictionary *)dict
{
    return [[self numberForKey:key fromDict:dict] doubleValue];
}

+ (BOOL)boolForKey:(NSString *)key fromDict:(NSDictionary *)dict
{
    return [[self numberForKey:key fromDict:dict] boolValue];
}

+ (NSInteger)intForKey:(NSString *)key fromDict:(NSDictionary *)dict
{
    return [[self numberForKey:key fromDict:dict] integerValue];
}

+ (long long)longlongForKey:(NSString *)key fromDict:(NSDictionary *)dict
{
    return [[self numberForKey:key fromDict:dict] longLongValue];
}

+ (NSUInteger)unsignedIntegerForKey:(NSString *)key fromDict:(NSDictionary *)dict
{
    return [[self numberForKey:key fromDict:dict] unsignedIntegerValue];
}

+ (NSString *)stringFromNumberForKey:(NSString *)key fromDict:(NSDictionary *)dict
{
    NSNumber *val = [dict[key] isKindOfClass:[NSNumber class]] ? dict[key] : nil;
    return [val stringValue];
}

+ (id)objectForKey:(NSString *)key fromDict:(NSDictionary *)dict
{
    return [dict[key] isKindOfClass:[NSNull class]] ? nil : dict[key];
}

+ (NSString *)stringForKey:(NSString *)key fromDict:(NSDictionary *)dict
{
    return [dict[key] isKindOfClass:[NSString class]] ? dict[key] : nil;
}

+ (NSDate *)dateForKey:(NSString *)key fromDict:(NSDictionary *)dict
{
    return [dict[key] isKindOfClass:[NSDate class]] ? dict[key] : nil;
}

+ (NSDictionary *)dictForKey:(NSString *)key fromDict:(NSDictionary *)dict
{
    return [dict[key] isKindOfClass:[NSDictionary class]] ? dict[key] : nil;
}

+ (NSArray *)arrayForKey:(NSString *)key fromDict:(NSDictionary *)dict
{
    return [dict[key] isKindOfClass:[NSArray class]] ? dict[key] : nil;
}

#pragma mark - Helper
+ (NSNumber *)numberForKey:(NSString *)key fromDict:(NSDictionary *)dict
{
    NSNumber *number = [dict[key] isKindOfClass:[NSNumber class]] ? dict[key] : nil;
    return number;
}

@end
