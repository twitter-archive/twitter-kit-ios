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

#import "TWTRSEScribe.h"
#import "TWTRSEUIScribeEvent+Private.h"

@implementation TWTRSEUIScribeEvent

- (instancetype)initWithUser:(NSNumber *)userID
                     element:(NSString *)element
                      action:(NSString *)action
{
    if ((self = [super init])) {
        _userID = userID;
        _element = [element copy];
        _action = [action copy];
    }

    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"user_id = %@, {share_ext:composer:share_sheet:%@:%@}", _userID, _element, _action];
}

@end
