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

#import <OCMock/OCMock.h>
#import <TwitterCore/TWTRDateFormatters.h>
#import <TwitterCore/TWTRDateFormatters_Private.h>
#import <XCTest/XCTest.h>

static NSString *const APIDateString = @"Mon Mar 05 22:08:25 +0000 2007";

@interface TWTRDateFormattersTests : XCTestCase

@property (nonatomic, strong) NSDate *apiDate;
@property (nonatomic, strong) NSLocale *spanishLocale;

@end

@implementation TWTRDateFormattersTests

- (void)setUp
{
    [super setUp];

    self.apiDate = [[TWTRDateFormatters serverParsingDateFormatter] dateFromString:APIDateString];
    self.spanishLocale = [NSLocale localeWithLocaleIdentifier:@"es_ES"];
    [TWTRDateFormatters resetCache];
    [TWTRDateFormatters setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
}

+ (void)tearDown
{
    [super tearDown];
    [TWTRDateFormatters resetCache];
    [TWTRDateFormatters setLocale:nil];
}

- (void)testApiParsingFormatter_hasLocale
{
    NSString *formattedDate = [TWTRDateFormatters serverParsingDateFormatter].locale.localeIdentifier;

    XCTAssert([formattedDate isEqualToString:@"en_US_POSIX"]);
}

- (void)testCurrentYearDateFormatter
{
    NSString *formattedDate = [[TWTRDateFormatters dayAndMonthDateFormatter] stringFromDate:self.apiDate];
    XCTAssertTrue([formattedDate isEqualToString:@"Mar 05"]);
}

- (void)testCurrentYearDateFormatter_handlesLocale
{
    [TWTRDateFormatters setLocale:self.spanishLocale];
    NSString *formattedDate = [[TWTRDateFormatters dayAndMonthDateFormatter] stringFromDate:self.apiDate];
    NSString *expectedDate;
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    if ([processInfo respondsToSelector:@selector(operatingSystemVersion)] && processInfo.operatingSystemVersion.majorVersion >= 9) {
        expectedDate = @"05 Mar";
    } else {
        expectedDate = @"05-Mar";
    }
    XCTAssertEqualObjects(formattedDate, expectedDate);
}

- (void)testSystemLongDateFormatter
{
    NSString *formattedDate = [[TWTRDateFormatters systemLongDateFormatter] stringFromDate:self.apiDate];
    XCTAssert([formattedDate isEqualToString:@"March 5, 2007"]);
}

- (void)testSystemLongDateFormatter_handlesLocale
{
    [TWTRDateFormatters setLocale:self.spanishLocale];
    NSString *formattedDate = [[TWTRDateFormatters systemLongDateFormatter] stringFromDate:self.apiDate];

    XCTAssert([formattedDate isEqualToString:@"5 de marzo de 2007"]);
}

- (void)testShortHistoricalDateFormatter
{
    NSString *formattedDate = [[TWTRDateFormatters shortHistoricalDateFormatter] stringFromDate:self.apiDate];
    XCTAssertTrue([formattedDate isEqualToString:@"3/5/07"]);
}

- (void)testHTTPDateHeaderParsingFormatter
{
    NSDate *parsedDate = [[TWTRDateFormatters HTTPDateHeaderParsingFormatter] dateFromString:@"Wed, 25 Nov 2015 02:17:45 GMT"];
    XCTAssertNotNil(parsedDate);
}

@end
