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

#import "TWTRTweetUserMentionEntity.h"

#import <TwitterCore/TWTRDictUtil.h>
#import "TWTRAPIConstantsStatus.h"

@implementation TWTRTweetUserMentionEntity

#pragma mark - Init

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    self = [super initWithJSONDictionary:dict];

    if (self) {
        _userID = [[TWTRDictUtil twtr_stringFromNumberForKey:TWTRAPIConstantsStatusFieldUserMentionEntityUserID inDict:dict] copy];
        _name = [[TWTRDictUtil twtr_stringForKey:TWTRAPIConstantsStatusFieldUserMentionEntityName inDict:dict] copy];
        _screenName = [[TWTRDictUtil twtr_stringForKey:TWTRAPIConstantsStatusFieldUserMentionEntityScreenName inDict:dict] copy];
    }

    return self;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];

    if (self) {
        _userID = [[decoder decodeObjectForKey:TWTRAPIConstantsStatusFieldUserMentionEntityUserID] copy];
        _name = [[decoder decodeObjectForKey:TWTRAPIConstantsStatusFieldUserMentionEntityName] copy];
        _screenName = [[decoder decodeObjectForKey:TWTRAPIConstantsStatusFieldUserMentionEntityScreenName] copy];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];

    [encoder encodeObject:self.userID forKey:TWTRAPIConstantsStatusFieldUserMentionEntityUserID];
    [encoder encodeObject:self.name forKey:TWTRAPIConstantsStatusFieldUserMentionEntityName];
    [encoder encodeObject:self.screenName forKey:TWTRAPIConstantsStatusFieldUserMentionEntityScreenName];
}

- (NSString *)accessibilityValue
{
    return self.screenName;
}

@end
