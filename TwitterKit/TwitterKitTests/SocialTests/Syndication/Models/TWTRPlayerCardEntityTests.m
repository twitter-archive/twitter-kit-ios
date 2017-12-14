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

#import <XCTest/XCTest.h>
#import "TWTRCardEntity+Subclasses.h"
#import "TWTRFixtureLoader.h"
#import "TWTRMediaEntityDisplayConfiguration.h"
#import "TWTRPlayerCardEntity.h"
#import "TWTRVideoPlaybackConfiguration.h"

@interface TWTRPlayerCardEntityTests : XCTestCase

@property (nonatomic, readonly) NSDictionary *vineCardDictionary;

@end

@implementation TWTRPlayerCardEntityTests

- (void)setUp
{
    [super setUp];
    _vineCardDictionary = [TWTRFixtureLoader vineCard];
}

- (void)testCanInitWithJSONDictionary
{
    NSDictionary *dict = @{@"name": @"player"};
    XCTAssertTrue([TWTRPlayerCardEntity canInitWithJSONDictionary:dict]);
}

- (void)testParsingVineCard_validDictionary
{
    TWTRPlayerCardEntity *card = (TWTRPlayerCardEntity *)[TWTRCardEntity cardEntityFromJSONDictionary:self.vineCardDictionary];
    XCTAssertTrue([card isKindOfClass:[TWTRPlayerCardEntity class]]);

    XCTAssertEqualObjects(card.URLString, @"https://t.co/KcqVd4U4AB");
    XCTAssertEqual(card.playerCardType, TWTRPlayerCardTypeVine);
    XCTAssertEqualObjects(card.bindingValues.appName, @"Vine");
    XCTAssertEqualObjects(card.bindingValues.playerStreamURL, @"https://v.cdn.vine.co/r/videos_h264high/3FFE1E20071282608868568055808_486f3351bcd.4.0.6244909849912429457.mp4?versionId=HdRqgNrs8rQN70K9wqYgQLhaVKrMxgTb");
    XCTAssertEqualObjects(card.bindingValues.playerURL, @"https://t.co/KcqVd4U4AB");
    XCTAssertEqualObjects(card.bindingValues.cardDescription, @"Vine by warriors");
}

- (void)testParsingVineCard_invalidDictionary
{
    NSDictionary *dict = @{@"name": @"player"};
    TWTRPlayerCardEntity *card = (TWTRPlayerCardEntity *)[TWTRCardEntity cardEntityFromJSONDictionary:dict];
    XCTAssertNil(card);
}

- (void)testParsingPlayerCard_UnknownType
{
    NSMutableDictionary *dict = [self.vineCardDictionary mutableCopy];
    NSMutableDictionary *bindingValues = [dict[@"binding_values"] mutableCopy];
    bindingValues[@"site"] = @{ @"user_value": @{@"id_str": @""} };
    dict[@"binding_values"] = bindingValues;

    TWTRPlayerCardEntity *card = (TWTRPlayerCardEntity *)[TWTRCardEntity cardEntityFromJSONDictionary:dict];
    XCTAssertTrue([card isKindOfClass:[TWTRPlayerCardEntity class]]);

    XCTAssertEqual(card.playerCardType, TWTRPlayerCardTypeUnknown);
}

@end
