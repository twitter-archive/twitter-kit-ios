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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TWTRFixtureLoader.h"
#import "TWTRJSONSerialization.h"
#import "TWTRTestCase.h"

@interface TWTRJSONSerializationTests : TWTRTestCase

@property (nonatomic, strong) NSData *searchResultData;  // JSON dictionary
@property (nonatomic, strong) NSData *timelineData;      // JSON array
@property (nonatomic, strong) NSError *error;

@end

@implementation TWTRJSONSerializationTests

- (void)setUp
{
    [super setUp];
    self.searchResultData = [TWTRFixtureLoader blackLivesMatterSearchResultData];
    self.timelineData = [TWTRFixtureLoader jackUserTimelineData];
}

#pragma mark - Dictionary Parsing

- (void)testJSONDictionary_IsCorrectClass
{
    NSError *error;
    id hopefullyDict = [TWTRJSONSerialization dictionaryFromData:self.searchResultData error:&error];

    XCTAssert([hopefullyDict isKindOfClass:[NSDictionary class]]);
}

- (void)testJSONDictionary_NestedResultsCorrect
{
    NSError *error;
    NSDictionary *dict = [TWTRJSONSerialization dictionaryFromData:self.searchResultData error:&error];

    XCTAssertEqual([[dict allKeys] count], 2);
    XCTAssertEqualObjects(dict[@"search_metadata"][@"max_id_str"], @"564948898058223616");
}

- (void)testJSONDictionary_NestedArray
{
    NSError *error;
    NSDictionary *dict = [TWTRJSONSerialization dictionaryFromData:self.searchResultData error:&error];
    id tweets = dict[@"statuses"];

    XCTAssert([tweets isKindOfClass:[NSArray class]]);
    XCTAssertEqual([tweets count], 15);
}

- (void)testJSONDictionary_MismatchTypeFails
{
    NSError *error;
    NSDictionary *actuallyArray = [TWTRJSONSerialization dictionaryFromData:self.timelineData error:&error];

    XCTAssertNil(actuallyArray);
}

#pragma mark - Array Parsing

- (void)testJSONArray_IsCorrectClass
{
    NSError *error;
    id hopefullyArray = [TWTRJSONSerialization arrayFromData:self.timelineData error:&error];

    XCTAssert([hopefullyArray isKindOfClass:[NSArray class]]);
}

- (void)testJSONArray_CountIsCorrect
{
    NSError *error;
    NSArray *array = [TWTRJSONSerialization arrayFromData:self.timelineData error:&error];

    XCTAssertEqual([array count], 20);
}

- (void)testJSONArray_CorrectTopLevelDetails
{
    NSError *error;
    NSArray *array = [TWTRJSONSerialization arrayFromData:self.timelineData error:&error];

    XCTAssertEqualObjects(array[3][@"id_str"], @"564573512309161984");
}

- (void)testJSONArray_CorrectNestedDetails
{
    NSError *error;
    NSArray *array = [TWTRJSONSerialization arrayFromData:self.timelineData error:&error];

    XCTAssertEqualObjects(array[3][@"user"][@"followers_count"], @2842989);
}

- (void)testJSONArray_MismatchTypeFails
{
    NSError *error;
    NSArray *actuallyDictionary = [TWTRJSONSerialization arrayFromData:self.searchResultData error:&error];

    XCTAssertNil(actuallyDictionary);
}

@end
