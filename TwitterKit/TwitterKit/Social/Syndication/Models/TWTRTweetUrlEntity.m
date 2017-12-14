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

#import "TWTRTweetUrlEntity.h"

#import <TwitterCore/TWTRDictUtil.h>
#import "TWTRAPIConstantsStatus.h"

@implementation TWTRTweetUrlEntity

#pragma mark - Init

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    self = [super initWithJSONDictionary:dict];

    if (self) {
        _displayUrl = [[TWTRDictUtil twtr_stringForKey:TWTRAPIConstantsStatusFieldUrlEntityDisplayUrl inDict:dict] copy];
        _expandedUrl = [[TWTRDictUtil twtr_stringForKey:TWTRAPIConstantsStatusFieldUrlEntityExpandedUrl inDict:dict] copy];
        _url = [[TWTRDictUtil twtr_stringForKey:TWTRAPIConstantsStatusFieldUrlEntitiyUrl inDict:dict] copy];
    }

    return self;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];

    if (self) {
        _displayUrl = [[decoder decodeObjectForKey:@"displayUrl"] copy];
        _expandedUrl = [[decoder decodeObjectForKey:@"expandedUrl"] copy];
        _url = [[decoder decodeObjectForKey:@"url"] copy];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];

    [encoder encodeObject:self.displayUrl forKey:@"displayUrl"];
    [encoder encodeObject:self.expandedUrl forKey:@"expandedUrl"];
    [encoder encodeObject:self.url forKey:@"url"];
}

- (NSString *)accessibilityValue
{
    return self.displayUrl;
}

@end
