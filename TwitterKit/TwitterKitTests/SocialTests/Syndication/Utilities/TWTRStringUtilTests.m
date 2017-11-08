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
#import "TWTRStringUtil.h"
#import "limits.h"

@interface TWTRStringUtilTests : XCTestCase

@end

@implementation TWTRStringUtilTests

- (void)testStringReplacesJPG
{
    NSString *testString = @"http://twitter.com/images/2348732_normal.jpg";
    NSString *desiredString = @"http://twitter.com/images/2348732_small.jpg";

    XCTAssert([[TWTRStringUtil stringByReplacingLastOccurrenceOfString:@"_normal" withString:@"_small" inStringIgnoringExtension:testString] isEqualToString:desiredString]);
}

- (void)testStringReplacesPNG
{
    NSString *testString = @"http://twitter.com/images/2348732_normal.png";
    NSString *desiredString = @"http://twitter.com/images/2348732_small.png";

    XCTAssert([[TWTRStringUtil stringByReplacingLastOccurrenceOfString:@"_normal" withString:@"_small" inStringIgnoringExtension:testString] isEqualToString:desiredString]);
}

- (void)testStringReplacesOnlyLast
{
    NSString *testString = @"http://twitter.com/images/234_normal8732_normal.png";
    NSString *desiredString = @"http://twitter.com/images/234_normal8732_small.png";

    XCTAssert([[TWTRStringUtil stringByReplacingLastOccurrenceOfString:@"_normal" withString:@"_small" inStringIgnoringExtension:testString] isEqualToString:desiredString]);
}

- (void)testStringWithNumbers
{
    XCTAssert([TWTRStringUtil stringContainsOnlyNumbers:@"23498"]);
}

- (void)testStringNoNumbers
{
    XCTAssert([TWTRStringUtil stringContainsOnlyNumbers:@"32423a"] == NO);
}

- (void)testStringHexNumbers
{
    XCTAssert([TWTRStringUtil stringContainsOnlyHexNumbers:@"ab8c"]);
}

- (void)testStringNotHexNumbers
{
    XCTAssert([TWTRStringUtil stringContainsOnlyNumbers:@"23z"] == NO);
}

- (void)testStringHexValue
{
    XCTAssert([TWTRStringUtil hexIntegerValueWithString:@"123abc"] == 1194684);
}

- (void)testDisplayStringFromTimeInterval_negative
{
    XCTAssertNil([TWTRStringUtil displayStringFromTimeInterval:-1]);
}

- (void)testDisplayStringFromTimeInterval_lessThanMinute
{
    NSTimeInterval interval = 59;
    NSString *expected = @"0:59";
    XCTAssertEqualObjects(expected, [TWTRStringUtil displayStringFromTimeInterval:interval]);
}

- (void)testDisplayStringFromTimeInterval_moreThanMinute
{
    NSTimeInterval interval = 80;
    NSString *expected = @"1:20";
    XCTAssertEqualObjects(expected, [TWTRStringUtil displayStringFromTimeInterval:interval]);
}

- (void)testDisplayStringFromTimeInterval_twoDigitsForSeconds
{
    NSTimeInterval interval = 3;
    NSString *expected = @"0:03";
    XCTAssertEqualObjects(expected, [TWTRStringUtil displayStringFromTimeInterval:interval]);
}

- (void)testDisplayStringFromTimeInterval_twoDigitsForMinutes
{
    NSTimeInterval interval = 633;
    NSString *expected = @"10:33";
    XCTAssertEqualObjects(expected, [TWTRStringUtil displayStringFromTimeInterval:interval]);
}

@end
