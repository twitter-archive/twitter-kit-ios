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
#import "TWTRDateFormatters.h"
#import "TWTRDateUtil.h"
#import "TWTRTestCase.h"

static NSString *const APIDateString = @"Mon Mar 05 22:08:25 +0000 2007";

@interface TWTRDateUtilTests : TWTRTestCase

@property (nonatomic, strong) NSDate *apiDate;

@end

@implementation TWTRDateUtilTests

- (void)setUp
{
    [super setUp];

    self.apiDate = [[TWTRDateFormatters serverParsingDateFormatter] dateFromString:APIDateString];
}

- (void)testIsDateInCurrentYearFalse
{
    XCTAssertFalse([TWTRDateUtil isDateInCurrentYear:self.apiDate]);
}

- (void)testIsDateInCurrentYearTrue
{
    NSDate *currentDate = [NSDate date];
    XCTAssertTrue([TWTRDateUtil isDateInCurrentYear:currentDate]);
}

- (void)testAccessibilityText
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterLongStyle;

    NSString *desired = [formatter stringFromDate:self.apiDate];
    NSString *actual = [TWTRDateUtil accessibilityTextForDate:self.apiDate];
    XCTAssert([desired isEqualToString:actual]);
}

- (void)testIsDateWithinIntervalOfDate_true_futureDateIsInThePast
{
    NSDate *now = [NSDate date];
    NSDate *oneMinuteAgo = [now dateByAddingTimeInterval:-1 * 60];
    XCTAssertTrue([TWTRDateUtil isDate:oneMinuteAgo withinInterval:1 fromDate:now]);
}

- (void)testIsDateWithinIntervalOfDate_true_sameDates
{
    NSDate *now = [NSDate date];
    XCTAssertTrue([TWTRDateUtil isDate:now withinInterval:1 fromDate:now]);
}

- (void)testIsDateWithinIntervalOfDate_true_withinInterval
{
    NSDate *now = [NSDate date];
    NSDate *oneMinuteFromNow = [now dateByAddingTimeInterval:1 * 60];
    XCTAssertTrue([TWTRDateUtil isDate:oneMinuteFromNow withinInterval:3600 fromDate:now]);
}

- (void)testIsDateWithinIntervalOfDate_true_atInterval
{
    NSDate *now = [NSDate date];
    NSDate *oneMinuteFromNow = [now dateByAddingTimeInterval:1 * 60];
    XCTAssertTrue([TWTRDateUtil isDate:oneMinuteFromNow withinInterval:60 fromDate:now]);
}

- (void)testIsDateWithinIntervalOfDate_false_outSideInterval
{
    NSDate *now = [NSDate date];
    NSDate *oneMinuteFromNow = [now dateByAddingTimeInterval:1 * 60];
    XCTAssertFalse([TWTRDateUtil isDate:oneMinuteFromNow withinInterval:59 fromDate:now]);
}

- (void)testDayIsWithinSameUTCDayAsDate_false_futureDateIsInPast
{
    NSDate *now = [NSDate date];
    NSDate *futureDateReallyADayAgo = [now dateByAddingTimeInterval:-24 * 60 * 60];
    XCTAssertFalse([TWTRDateUtil date:futureDateReallyADayAgo isWithinSameUTCDayAsDate:now]);
}

- (void)testDayIsWithinSameUTCDayAsDate_false_futureDateIsLessThanOneDayInThePast
{
    NSDate *now = [NSDate date];
    NSDate *aboutADayAgo = [now dateByAddingTimeInterval:(-24 * 60 * 60 + 1)];
    XCTAssertFalse([TWTRDateUtil date:aboutADayAgo isWithinSameUTCDayAsDate:now]);
}

- (void)testDayIsWithinSameUTCDayAsDate_false_futureDateIsPastADay
{
    NSDate *now = [NSDate date];
    NSDate *aboutOneDayFromNow = [now dateByAddingTimeInterval:(24 * 60 * 60 + 1)];
    XCTAssertFalse([TWTRDateUtil date:aboutOneDayFromNow isWithinSameUTCDayAsDate:now]);
}

- (void)testDayIsWithinSameUTCDayAsDate_true_futureDateIsADay
{
    NSDate *date = [TWTRDateUtil UTCDateWithYear:2007 month:3 day:5 hour:0 minute:0 second:0];
    NSDate *sameDay = [TWTRDateUtil UTCDateWithYear:2007 month:3 day:5 hour:23 minute:59 second:59];
    XCTAssertTrue([TWTRDateUtil date:sameDay isWithinSameUTCDayAsDate:date]);
}

- (void)testDayIsWithinSameUTCDayAsDate_true_futureDateIsWithinADay
{
    NSDate *date = [TWTRDateUtil UTCDateWithYear:2007 month:3 day:5 hour:0 minute:0 second:0];
    NSDate *oneMinuteFromDate = [TWTRDateUtil UTCDateWithYear:2007 month:3 day:5 hour:0 minute:1 second:0];
    XCTAssertTrue([TWTRDateUtil date:oneMinuteFromDate isWithinSameUTCDayAsDate:date]);
}

@end
