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

/**
 This header is private to the Twitter Core SDK and not exposed for public SDK consumption
 */

#import <Foundation/Foundation.h>

@interface TWTRDateUtil : NSObject

/**
 *  Determines whether the given date is in the current year.
 *
 *  @param date the date to determine whether this is in the current year
 *
 *  @return whether the date is in the current year
 */
+ (BOOL)isDateInCurrentYear:(NSDate *)date;

/**
 *  String suitable for reading out in accessibility label of timestamp.
 *
 *  @param date The date to be read out
 *
 *  @return The string suitable for reading by VoiceOver
 */
+ (NSString *)accessibilityTextForDate:(NSDate *)date;

/**
 *  Checks if two dates are within a certain interval of each other.
 *
 *  @param date     the future date
 *  @param interval time interval to check for
 *  @param fromDate the older date to check against
 *
 *  @return true if date - fromDate is <= interval
 */
+ (BOOL)isDate:(NSDate *)date withinInterval:(NSTimeInterval)interval fromDate:(NSDate *)fromDate;

/**
 *  Checks if two dates are within the same calendar day in UTC.
 *
 *  @param date  a date
 *  @param date2 another date
 *
 *  @return true if two dates are within the same calendar day
 */
+ (BOOL)date:(NSDate *)date isWithinSameUTCDayAsDate:(NSDate *)date2;

/**
 *  Returns a new date of the specified time in UTC.
 *
 *  @param year   the 4-digit year e.g. YYYY
 *  @param month  the month within the year e.g. 1 for Jan, 11 for Nov
 *  @param day    the day within the month
 *  @param hour   the hour in 24-hour format e.g. 23 for 11PM
 *  @param minute the minute
 *  @param second the second
 *
 *  @return a new date in the specified UTC time.
 */
+ (NSDate *)UTCDateWithYear:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day hour:(NSUInteger)hour minute:(NSUInteger)minute second:(NSUInteger)second;
@end
