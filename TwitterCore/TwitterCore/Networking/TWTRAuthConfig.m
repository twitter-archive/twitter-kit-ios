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

#import "TWTRAuthConfig.h"

@interface TWTRAuthConfig () <NSCoding>

@property (nonatomic, copy, readwrite) NSString *consumerKey;
@property (nonatomic, copy, readwrite) NSString *consumerSecret;

@end

@implementation TWTRAuthConfig

- (instancetype)initWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret
{
    NSParameterAssert(consumerKey);
    NSParameterAssert(consumerSecret);
    if ((self = [super init])) {
        _consumerKey = [consumerKey copy];
        _consumerSecret = [consumerSecret copy];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    NSString *key = [coder decodeObjectForKey:@"consumerKey"];
    NSString *secret = [coder decodeObjectForKey:@"consumerSecret"];

    return [self initWithConsumerKey:key consumerSecret:secret];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.consumerKey forKey:@"consumerKey"];
    [coder encodeObject:self.consumerSecret forKey:@"consumerSecret"];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[TWTRAuthConfig class]]) {
        return [self isEqualToAuthConfig:object];
    }
    return NO;
}

- (BOOL)isEqualToAuthConfig:(TWTRAuthConfig *)otherAuthConfig
{
    return [self.consumerKey isEqualToString:otherAuthConfig.consumerKey] && [self.consumerSecret isEqualToString:otherAuthConfig.consumerSecret];
}

- (NSUInteger)hash
{
    return [self.consumerKey hash];
}

@end
