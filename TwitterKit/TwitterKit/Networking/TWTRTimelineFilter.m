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

#import "TWTRTimelineFilter.h"
#import <TwitterCore/TWTRDictUtil.h>

@implementation TWTRTimelineFilter

- (nullable instancetype)initWithJSONDictionary:(nonnull NSDictionary *)dictionary
{
    if ((self = [super init])) {
        self.keywords = [NSSet setWithArray:[TWTRDictUtil twtr_arrayForKey:@"keywords" inDict:dictionary]];
        self.hashtags = [NSSet setWithArray:[TWTRDictUtil twtr_arrayForKey:@"hashtags" inDict:dictionary]];
        self.handles = [NSSet setWithArray:[TWTRDictUtil twtr_arrayForKey:@"handles" inDict:dictionary]];
        self.urls = [NSSet setWithArray:[TWTRDictUtil twtr_arrayForKey:@"urls" inDict:dictionary]];
    }
    return self;
}

- (NSUInteger)filterCount
{
    return self.keywords.count + self.hashtags.count + self.handles.count + self.urls.count;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    typeof(self) copy = [[[self class] alloc] init];

    copy.keywords = [self.keywords copy];
    copy.hashtags = [self.hashtags copy];
    copy.handles = [self.handles copy];
    copy.urls = [self.urls copy];

    return copy;
}

@end
