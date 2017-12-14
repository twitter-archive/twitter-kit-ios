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

#import "TWTRTweetEntity.h"

#import <TwitterCore/TWTRDictUtil.h>
#import "TWTRAPIConstantsStatus.h"

@implementation TWTRTweetEntity

#pragma mark - Init

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary
{
    self = [super init];

    NSInteger startIndex = 0;
    NSInteger endIndex = 0;

    if (self) {
        NSArray *indices = [TWTRDictUtil twtr_arrayForKey:TWTRAPIConstantsStatusFieldIndices inDict:dictionary];

        startIndex = [indices[0] isKindOfClass:[NSNumber class]] ? [indices[0] integerValue] : 0;
        endIndex = [indices[1] isKindOfClass:[NSNumber class]] ? [indices[1] integerValue] : 0;
    }

    return [self initWithStartIndex:startIndex endIndex:endIndex];
}

- (instancetype)initWithStartIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex
{
    self = [super init];
    if (self) {
        _startIndex = startIndex;
        _endIndex = endIndex;
    }
    return self;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super init];

    if (self) {
        _startIndex = [decoder decodeIntegerForKey:@"startIndex"];
        _endIndex = [decoder decodeIntegerForKey:@"endIndex"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInteger:[self startIndex] forKey:@"startIndex"];
    [encoder encodeInteger:[self endIndex] forKey:@"endIndex"];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[TWTRTweetEntity class]]) {
        return [self isEqualToTweetEntity:object];
    } else {
        return NO;
    }
}

- (NSUInteger)hash
{
    return self.startIndex;
}

- (BOOL)isEqualToTweetEntity:(TWTRTweetEntity *)other
{
    return self.startIndex == other.startIndex && self.endIndex == other.endIndex;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    return self;
}

- (NSString *)accessibilityValue
{
    return @"";
}

@end
