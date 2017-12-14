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

#import "TWTRDateFormatter.h"
#import <TwitterCore/TWTRDateFormatters.h>
#import <TwitterCore/TWTRDateUtil.h>
#import "TWTRTranslationsUtil.h"

@implementation TWTRDateFormatter

+ (NSString *)elapsedTimeStringSinceDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *currentDate = [NSDate date];

    NSCalendarUnit units = NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *components = [calendar components:units fromDate:date toDate:currentDate options:0];
    NSInteger dayDiff = components.day;

    if (dayDiff < 1) {  // within 24 hours
        return [self _tinyRelativeTimeAgoStringForDate:date];
    } else if ([TWTRDateUtil isDateInCurrentYear:date]) {
        return [[TWTRDateFormatters dayAndMonthDateFormatter] stringFromDate:date];
    } else {
        return [[TWTRDateFormatters shortHistoricalDateFormatter] stringFromDate:date];
    }
}

// Borrowed from twitter-ios NSDate+TFNAdditions
// Original method signature: -[NSDate _relativeTimeAgoStringWithFormatForSeconds:second:minutes:minute:hours:hour:days:day:]
// TODO: At some point, use TFNUtilities directly instead of copy+pasta'd code
+ (NSString *)_tinyRelativeTimeAgoStringForDate:(NSDate *)date
{
    static NSString *seconds;
    static NSString *second;
    static NSString *minutes;
    static NSString *minute;
    static NSString *hours;
    static NSString *hour;
    static NSString *days;
    static NSString *day;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        seconds = TWTRLocalizedString(@"TIME_SHORT_SECONDS_FORMAT");
        second = TWTRLocalizedString(@"TIME_SHORT_SECOND_FORMAT");
        minutes = TWTRLocalizedString(@"TIME_SHORT_MINUTES_FORMAT");
        minute = TWTRLocalizedString(@"TIME_SHORT_MINUTE_FORMAT");
        hours = TWTRLocalizedString(@"TIME_SHORT_HOURS_FORMAT");
        hour = TWTRLocalizedString(@"TIME_SHORT_HOUR_FORMAT");
        days = TWTRLocalizedString(@"TIME_SHORT_DAYS_FORMAT");
        day = TWTRLocalizedString(@"TIME_SHORT_DAY_FORMAT");
    });
    return [self _relativeTimeAgoStringForDate:date withFormatForSeconds:seconds second:second minutes:minutes minute:minute hours:hours hour:hour days:days day:day];
}

// Borrowed from twitter-ios NSDate+TFNAdditions
// Original method signature: -[NSDate tinyRelativeTimeAgoString]
// TODO: At some point, use TFNUtilities directly instead of copy+pasta'd code
+ (NSString *)_relativeTimeAgoStringForDate:(NSDate *)date withFormatForSeconds:(NSString *)seconds second:(NSString *)second minutes:(NSString *)minutes minute:(NSString *)minute hours:(NSString *)hours hour:(NSString *)hour days:(NSString *)days day:(NSString *)day
{
    // use long instead of NSInteger because
    // a) more easily localizable to %1$d (vs long long which would require changes to localizable.strings files)
    // b) shouldn't need more than 4 billion of any of the following units (days being the only real consideration)
    long i = -[date timeIntervalSinceNow];
    if (i < 0) {
        i = 0;
    }
    if (i < 60) {
        return [NSString stringWithFormat:i == 1 ? second : seconds, i];
    }
    i = i / 60;
    if (i < 60) {
        return [NSString stringWithFormat:i == 1 ? minute : minutes, i];
    }
    i = i / 60;
    if (i < 24) {
        return [NSString stringWithFormat:i == 1 ? hour : hours, i];
    }
    i = i / 24;
    return [NSString stringWithFormat:i == 1 ? day : days, i];
}

@end
