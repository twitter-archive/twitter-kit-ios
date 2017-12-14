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

@interface TWTRDateFormatters : NSObject

/**
 *  For use in parsing the Twitter API only.
 *
 *  @return formatter that handles Twitter's API format.
 */
+ (NSDateFormatter *)serverParsingDateFormatter;

/**
 *  For use in parsing the HTTP `date` header only
 *
 *  @return formatter that handles HTTP `date` header format
 */
+ (NSDateFormatter *)HTTPDateHeaderParsingFormatter;

/**
 *  For use in compact Tweet view when 24 hours < createdAt < current year.
 *
 *  @return formatter that emits abbreviated month and day e.g. Aug 5.
 */
+ (NSDateFormatter *)dayAndMonthDateFormatter;

/**
 *  For use in timestamp accessibility labels
 *
 *  @return formatter with NSDateFormatterLongStyle e.g. November 23, 1937
 */
+ (NSDateFormatter *)systemLongDateFormatter;

/**
 *  For use in compact Tweet view when current year < createdAt.
 *
 *  @return formatter that emits just the date without time e.g. MM/DD/YY
 */
+ (NSDateFormatter *)shortHistoricalDateFormatter;

@end
