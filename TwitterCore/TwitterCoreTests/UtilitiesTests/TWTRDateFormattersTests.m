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
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMM dd";
    NSString *desired = [dateFormatter stringFromDate:self.apiDate];
    NSString *actual = [[TWTRDateFormatters dayAndMonthDateFormatter] stringFromDate:self.apiDate];
    XCTAssertTrue([desired isEqualToString:actual]);
}

- (void)testCurrentYearDateFormatter_handlesLocale
{
    [TWTRDateFormatters setLocale:self.spanishLocale];
    NSString *formattedDate = [[TWTRDateFormatters dayAndMonthDateFormatter] stringFromDate:self.apiDate];
    NSString *expectedDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"MMM dd" options:0 locale:self.spanishLocale];

    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    if ([processInfo respondsToSelector:@selector(operatingSystemVersion)] && processInfo.operatingSystemVersion.majorVersion >= 9) {
        expectedDate = [dateFormatter stringFromDate:self.apiDate];
    } else {
        expectedDate = [dateFormatter stringFromDate:self.apiDate];
    }
    XCTAssertEqualObjects(formattedDate, expectedDate);
}

- (void)testSystemLongDateFormatter
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    NSString *desired = [dateFormatter stringFromDate:self.apiDate];
    NSString *actual = [[TWTRDateFormatters systemLongDateFormatter] stringFromDate:self.apiDate];
    XCTAssert([actual isEqualToString:desired]);
}

- (void)testSystemLongDateFormatter_handlesLocale
{
    [TWTRDateFormatters setLocale:self.spanishLocale];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    dateFormatter.locale = self.spanishLocale;
    NSString *desired = [dateFormatter stringFromDate:self.apiDate];
    NSString *actual = [[TWTRDateFormatters systemLongDateFormatter] stringFromDate:self.apiDate];

    XCTAssert([actual isEqualToString:desired]);
}

- (void)testShortHistoricalDateFormatter
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    NSString *desired = [dateFormatter stringFromDate:self.apiDate];
    NSString *actual = [[TWTRDateFormatters shortHistoricalDateFormatter] stringFromDate:self.apiDate];
    XCTAssert([desired isEqualToString:actual]);
}

- (void)testHTTPDateHeaderParsingFormatter
{
    NSDate *parsedDate = [[TWTRDateFormatters HTTPDateHeaderParsingFormatter] dateFromString:@"Wed, 25 Nov 2015 02:17:45 GMT"];
    XCTAssertNotNil(parsedDate);
}

@end
