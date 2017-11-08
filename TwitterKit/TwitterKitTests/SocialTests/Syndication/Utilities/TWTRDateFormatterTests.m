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
#import "TWTRDateFormatter.h"
#import "TWTRTestCase.h"

@interface TWTRDateFormatterTests : TWTRTestCase

@end

@implementation TWTRDateFormatterTests

- (void)testElapsedTimeStringSinceDatePreviousYear
{
    NSDate *now = [NSDate date];
    NSDate *aYearAgo = [now dateByAddingTimeInterval:-366 * 24 * 60 * 60];  // 366 to make sure this works in leap years
    NSString *elapsedString = [TWTRDateFormatter elapsedTimeStringSinceDate:aYearAgo];
    NSString *formattedString = [[TWTRDateFormatters shortHistoricalDateFormatter] stringFromDate:aYearAgo];
    XCTAssertTrue([elapsedString isEqualToString:formattedString]);
}

- (void)testElapsedTimeStringSinceDateWithin24HourDiffYear
{
    NSDate *within24HoursDiffYear = [[NSDate date] dateByAddingTimeInterval:-70];  // 70 sec instead of 60 just so tests aren't flakey
    NSString *elapsedString = [TWTRDateFormatter elapsedTimeStringSinceDate:within24HoursDiffYear];
    XCTAssertTrue([@"1m" isEqualToString:elapsedString], @"Time elapsed should only be 1 minute");
}

- (void)testElapsedTimeStringSinceDateSameYear
{
    NSDate *now = [NSDate date];
    // TODO (kang): support boundary cases
    // Will need to mock out [NSDate date] to really test this properly
    NSDate *aDayAgo = [now dateByAddingTimeInterval:-1 * 24 * 60 * 60];
    NSString *elapsedString = [TWTRDateFormatter elapsedTimeStringSinceDate:aDayAgo];
    NSString *formattedString = [[TWTRDateFormatters dayAndMonthDateFormatter] stringFromDate:aDayAgo];
    XCTAssertTrue([elapsedString isEqualToString:formattedString]);
}

- (void)testElapsedTimeStringSinceDateOneHourAgo
{
    NSDate *now = [NSDate date];
    NSDate *anHourAgo = [now dateByAddingTimeInterval:-1 * 60 * 60];
    NSString *elapsedString = [TWTRDateFormatter elapsedTimeStringSinceDate:anHourAgo];
    XCTAssertTrue([elapsedString isEqualToString:@"1h"]);
}

- (void)testElapsedTimeStringSinceDateOneMinuteAgo
{
    NSDate *now = [NSDate date];
    NSDate *aMinuteAgo = [now dateByAddingTimeInterval:-1 * 60];
    NSString *elapsedString = [TWTRDateFormatter elapsedTimeStringSinceDate:aMinuteAgo];
    XCTAssertTrue([elapsedString isEqualToString:@"1m"]);
}

- (void)testElapsedTimeStringSinceDateOneSecondAgo
{
    NSDate *now = [NSDate date];
    NSDate *aSecondAgo = [now dateByAddingTimeInterval:-1];
    NSString *elapsedString = [TWTRDateFormatter elapsedTimeStringSinceDate:aSecondAgo];
    XCTAssertTrue([elapsedString isEqualToString:@"1s"]);
}

@end
