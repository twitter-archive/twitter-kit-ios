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

#import "TWTRJSONKeyRequirement.h"

@implementation TWTRJSONKeyRequirement

+ (instancetype)optionalKeyOfClass:(Class)klass
{
    return [[self alloc] initWithClass:klass alternateKeys:@[] isRequired:NO];
}

+ (instancetype)requiredKeyOfClass:(Class)klass
{
    return [self requiredKeyOfClass:klass alternateKeys:@[]];
}

+ (instancetype)requiredKeyOfClass:(Class)klass alternateKeys:(NSArray<NSString *> *)alternateKeys
{
    return [[self alloc] initWithClass:klass alternateKeys:alternateKeys isRequired:YES];
}

+ (instancetype)optionalKeyOfAnyClass
{
    return [[self alloc] initWithClass:[NSObject class] alternateKeys:@[] isRequired:NO];
}

+ (instancetype)optionalString
{
    return [self optionalKeyOfClass:[NSString class]];
}

+ (instancetype)requiredString
{
    return [self requiredStringWithAlternateKeys:@[]];
}

+ (instancetype)requiredStringWithAlternateKeys:(NSArray<NSString *> *)alternateKeys
{
    return [self requiredKeyOfClass:[NSString class] alternateKeys:alternateKeys];
}

+ (instancetype)optionalNumber
{
    return [self optionalKeyOfClass:[NSNumber class]];
}

+ (instancetype)requiredNumber
{
    return [self requiredKeyOfClass:[NSNumber class]];
}

+ (instancetype)optionalDate
{
    return [self optionalKeyOfClass:[NSDate class]];
}

+ (instancetype)requiredDate
{
    return [self requiredKeyOfClass:[NSDate class]];
}

+ (instancetype)optionalURL
{
    return [self optionalKeyOfClass:[NSURL class]];
}

+ (instancetype)requiredURL
{
    return [self requiredKeyOfClass:[NSURL class]];
}

- (instancetype)initWithClass:(Class)klass alternateKeys:(NSArray<NSString *> *)alternateKeys isRequired:(BOOL)isRequired
{
    self = [super init];
    if (self) {
        _klass = klass;
        _alternateKeys = [alternateKeys copy];
        _required = isRequired;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@", self.isRequired ? @"Required" : @"Optional", NSStringFromClass(self.klass)];
}

@end
