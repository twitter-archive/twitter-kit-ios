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

#import "TWTRDateUtil.h"
#import "TWTRDateFormatters.h"

@implementation TWTRDateUtil

+ (BOOL)isDateInCurrentYear:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *currentDate = [NSDate date];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear fromDate:date];
    NSDateComponents *currentDateComponents = [calendar components:NSCalendarUnitYear fromDate:currentDate];
    return currentDateComponents.year == dateComponents.year;
}

+ (NSString *)accessibilityTextForDate:(NSDate *)date
{
    return [[TWTRDateFormatters systemLongDateFormatter] stringFromDate:date];
}

+ (BOOL)isDate:(NSDate *)date withinInterval:(NSTimeInterval)interval fromDate:(NSDate *)fromDate
{
    NSParameterAssert(date);
    NSParameterAssert(fromDate);

    return [date timeIntervalSinceDate:fromDate] <= interval;
}

+ (BOOL)date:(NSDate *)date isWithinSameUTCDayAsDate:(NSDate *)date2
{
    NSParameterAssert(date);
    NSParameterAssert(date2);

    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    NSDateComponents *dateComponents2 = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date2];

    return (dateComponents.year == dateComponents2.year) && (dateComponents.month == dateComponents2.month) && (dateComponents.day == dateComponents2.day);
}

+ (NSDate *)UTCDateWithYear:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day hour:(NSUInteger)hour minute:(NSUInteger)minute second:(NSUInteger)second
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:year];
    [components setMonth:month];
    [components setDay:day];
    [components setHour:hour];
    [components setMinute:minute];
    [components setSecond:second];

    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    return [calendar dateFromComponents:components];
}

@end
