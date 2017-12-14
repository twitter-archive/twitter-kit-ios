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

+ (NSArray *)twtr_arrayForKey:(NSString *)key inDict:(NSDictionary *)dict
{
    return [dict[key] isKindOfClass:[NSArray class]] ? dict[key] : nil;
}

+ (CGFloat)twtr_CGFloatForKey:(NSString *)key inDict:(NSDictionary *)dict
{
    NSNumber *number = [TWTRDictUtil twtr_numberForKey:key inDict:dict];
#if CGFLOAT_IS_DOBULE
    return [number doubleValue];
#else
    return [number floatValue];
#endif
}

+ (double)twtr_doubleForKey:(NSString *)key inDict:(NSDictionary *)dict
{
    return [[TWTRDictUtil twtr_numberForKey:key inDict:dict] doubleValue];
}

+ (BOOL)twtr_boolForKey:(NSString *)key inDict:(NSDictionary *)dict
{
    return [[TWTRDictUtil twtr_numberForKey:key inDict:dict] boolValue];
}

+ (NSInteger)twtr_intForKey:(NSString *)key inDict:(NSDictionary *)dict
{
    return [[TWTRDictUtil twtr_numberForKey:key inDict:dict] integerValue];
}

+ (long long)twtr_longlongForKey:(NSString *)key inDict:(NSDictionary *)dict
{
    return [[TWTRDictUtil twtr_numberForKey:key inDict:dict] longLongValue];
}

+ (NSUInteger)twtr_unsignedIntegerForKey:(NSString *)key inDict:(NSDictionary *)dict
{
    return [[TWTRDictUtil twtr_numberForKey:key inDict:dict] unsignedIntegerValue];
}

+ (NSString *)twtr_stringFromNumberForKey:(NSString *)key inDict:(NSDictionary *)dict
{
    NSNumber *val = [dict[key] isKindOfClass:[NSNumber class]] ? dict[key] : nil;
    return [val stringValue];
}

+ (id)twtr_objectForKey:(NSString *)key inDict:(NSDictionary *)dict
{
    return [dict[key] isKindOfClass:[NSNull class]] ? nil : dict[key];
}

+ (NSString *)twtr_stringForKey:(NSString *)key inDict:(NSDictionary *)dict
{
    return [dict[key] isKindOfClass:[NSString class]] ? dict[key] : nil;
}

+ (NSDate *)twtr_dateForKey:(NSString *)key inDict:(NSDictionary *)dict
{
    return [dict[key] isKindOfClass:[NSDate class]] ? dict[key] : nil;
}

+ (NSDictionary *)twtr_dictForKey:(NSString *)key inDict:(NSDictionary *)dict
{
    return [dict[key] isKindOfClass:[NSDictionary class]] ? dict[key] : nil;
}

#pragma mark - Helper Methods

+ (NSNumber *)twtr_numberForKey:(NSString *)key inDict:(NSDictionary *)dict
{
    NSNumber *number = [dict[key] isKindOfClass:[NSNumber class]] ? dict[key] : nil;
    return number;
}

@end
