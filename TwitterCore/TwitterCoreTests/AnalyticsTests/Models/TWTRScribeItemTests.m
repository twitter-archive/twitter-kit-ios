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

#import "TWTRScribeCardEvent.h"
#import "TWTRScribeItem.h"
#import "TWTRTestCase.h"

@interface TWTRScribeItemTests : TWTRTestCase

@end

@implementation TWTRScribeItemTests

- (void)testScribeKey
{
    NSString *key = [TWTRScribeItem scribeKey];
    XCTAssertEqualObjects(key, @"items");
}

- (void)testDictionaryRepresentation_withItemID
{
    TWTRScribeItem *item = [[TWTRScribeItem alloc] initWithItemType:TWTRScribeItemTypeTweet itemID:@"1"];
    NSDictionary *dictionaryRepresentation = [item dictionaryRepresentation];
    XCTAssertEqualObjects(dictionaryRepresentation[@"item_type"], [NSNumber numberWithUnsignedInteger:TWTRScribeItemTypeTweet]);
    XCTAssertEqualObjects(dictionaryRepresentation[@"id"], @"1");
}

- (void)testDictionaryRepresentation_withCardEvent
{
    TWTRScribeCardEvent *cardEvent = [[TWTRScribeCardEvent alloc] initWithPromotionCardType:TWTRScribePromotionCardTypeImageAppDownload];
    TWTRScribeItem *item = [[TWTRScribeItem alloc] initWithItemType:TWTRScribeItemTypeTweet itemID:nil cardEvent:cardEvent mediaDetails:nil];
    NSDictionary *dictionaryRepresentation = [item dictionaryRepresentation];
    XCTAssertEqualObjects(dictionaryRepresentation[@"item_type"], [NSNumber numberWithUnsignedInteger:TWTRScribeItemTypeTweet]);
    XCTAssertEqualObjects(dictionaryRepresentation[@"card_event"][@"promotion_card_type"], @8);
    XCTAssertNil(dictionaryRepresentation[@"id"]);
}

@end
