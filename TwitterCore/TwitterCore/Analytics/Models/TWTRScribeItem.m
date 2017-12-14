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

#import "TWTRScribeItem.h"
#import "TWTRAssertionMacros.h"
#import "TWTRScribeCardEvent.h"
#import "TWTRScribeFilterDetails.h"
#import "TWTRScribeMediaDetails.h"

@implementation TWTRScribeItem

- (instancetype)initWithItemType:(TWTRScribeItemType)itemType itemID:(NSString *)itemID
{
    TWTRParameterAssertOrReturnValue(itemID, nil);

    return [self initWithItemType:itemType itemID:itemID cardEvent:nil mediaDetails:nil];
}

- (instancetype)initWithItemType:(TWTRScribeItemType)itemType itemID:(NSString *)itemID cardEvent:(TWTRScribeCardEvent *)cardEvent mediaDetails:(TWTRScribeMediaDetails *)mediaDetails
{
    return [self initWithItemType:itemType itemID:itemID cardEvent:cardEvent mediaDetails:mediaDetails filterDetails:nil];
}

- (instancetype)initWithItemType:(TWTRScribeItemType)itemType itemID:(NSString *)itemID cardEvent:(TWTRScribeCardEvent *)cardEvent mediaDetails:(TWTRScribeMediaDetails *)mediaDetails filterDetails:(TWTRScribeFilterDetails *)filterDetails
{
    if (self = [super init]) {
        _itemType = itemType;
        _cardEvent = cardEvent;
        _itemID = itemID;
        _mediaDetails = mediaDetails;
        _filterDetails = filterDetails;
    }

    return self;
}

#pragma mark - TWTRScribeSerializable
+ (NSString *)scribeKey
{
    return @"items";
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    dictionary[@"item_type"] = @(self.itemType);

    if (self.itemID) {
        dictionary[@"id"] = self.itemID;
    }

    if (self.cardEvent) {
        dictionary[[TWTRScribeCardEvent scribeKey]] = [self.cardEvent dictionaryRepresentation];
    }

    if (self.mediaDetails) {
        dictionary[[TWTRScribeMediaDetails scribeKey]] = [self.mediaDetails dictionaryRepresentation];
    }

    if (self.filterDetails) {
        dictionary[[TWTRScribeFilterDetails scribeKey]] = [NSString stringWithFormat:@"%@", [self.filterDetails stringRepresentation]];
    }

    return dictionary;
}

@end
