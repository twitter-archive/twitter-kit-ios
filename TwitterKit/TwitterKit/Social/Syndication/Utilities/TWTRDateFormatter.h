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
 This header is private to the Twitter Kit SDK and not exposed for public SDK consumption
 */

#import <Foundation/Foundation.h>

@interface TWTRDateFormatter : NSObject

/**
 *  Returns the formatted elapsed time string base on the given date.
 *
 *  Logic:
 *      - Relative timestamp for anything less than 24 hours
 *      - Abbreviated month and day format (Aug 5), and no year for anything within the current year
 *      - MM/DD/YY (10/5/14) for anything beyond the current year
 *
 *  @param date The date object to calculate elapsed time against.
 *
 *  @return Formatted string of the elapsed time from the given date.
 */
+ (NSString *)elapsedTimeStringSinceDate:(NSDate *)date;

@end
