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

#import "TWTRDateFormatters.h"

static NSString *const TWTRDateFormatterLock = @"TWTRDateFormatterLock";
static NSString *const TWTRDateFormatterShortHistorical = @"TWTRDateFormatterShortHistorical";
static NSString *const TWTRDateFormatterSystemLong = @"TWTRDateFormatterSystemLong";
static NSString *const TWTRDateFormatterCurrentYear = @"TWTRDateFormatterCurrentYear";
static NSString *const TWTRDateFormatterAPIParsing = @"TWTRDateFormatterAPIParsing";
static NSString *const TWTRDateHTTPHeaderParsing = @"TWTRDateHTTPHeaderParsing";

static NSMutableDictionary *internalCache;
static NSLocale *internalLocale;

@implementation TWTRDateFormatters

+ (NSDateFormatter *)serverParsingDateFormatter
{
    NSString *key = TWTRDateFormatterAPIParsing;

    __block NSDateFormatter *formatter;
    @synchronized(TWTRDateFormatterLock)
    {
        formatter = self.cache[key];
        if (formatter == nil) {
            formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"EEE MMM d HH:mm:ss Z y";
            formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
            self.cache[key] = formatter;
        }
    }

    return formatter;
}

+ (NSDateFormatter *)HTTPDateHeaderParsingFormatter
{
    NSString *key = TWTRDateHTTPHeaderParsing;

    __block NSDateFormatter *formatter;
    @synchronized(TWTRDateFormatterLock)
    {
        formatter = self.cache[key];
        if (formatter == nil) {
            formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"EEE',' dd' 'MMM' 'yyyy HH':'mm':'ss zzz";
            self.cache[key] = formatter;
        }
    }

    return formatter;
}

+ (NSDateFormatter *)dayAndMonthDateFormatter
{
    NSString *key = TWTRDateFormatterCurrentYear;

    __block NSDateFormatter *formatter;
    @synchronized(TWTRDateFormatterLock)
    {
        formatter = self.cache[key];
        if (formatter == nil) {
            formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"MMM dd" options:0 locale:self.locale];
            self.cache[key] = formatter;
        }
    }

    return formatter;
}

+ (NSDateFormatter *)systemLongDateFormatter
{
    NSString *key = TWTRDateFormatterSystemLong;

    __block NSDateFormatter *formatter;
    @synchronized(TWTRDateFormatterLock)
    {
        formatter = self.cache[key];
        if (formatter == nil) {
            formatter = [[NSDateFormatter alloc] init];
            formatter.locale = self.locale;
            formatter.dateStyle = NSDateFormatterLongStyle;
            self.cache[key] = formatter;
        }
    }

    return formatter;
}

+ (NSDateFormatter *)shortHistoricalDateFormatter
{
    NSString *key = TWTRDateFormatterShortHistorical;

    __block NSDateFormatter *formatter;
    @synchronized(TWTRDateFormatterLock)
    {
        formatter = self.cache[key];
        if (formatter == nil) {
            formatter = [[NSDateFormatter alloc] init];
            formatter.locale = self.locale;
            formatter.dateStyle = NSDateFormatterShortStyle;  // e.g. 8/15/14
            self.cache[key] = formatter;
        }
    }

    return formatter;
}

#pragma mark - Caching

+ (NSMutableDictionary *)cache
{
    @synchronized(TWTRDateFormatterLock)
    {
        if (!internalCache) {
            internalCache = [NSMutableDictionary dictionary];
        }
    }

    return internalCache;
}

+ (void)resetCache
{
    @synchronized(TWTRDateFormatterLock)
    {
        [internalCache removeAllObjects];
    }
}

+ (void)setLocale:(NSLocale *)locale
{
    @synchronized(TWTRDateFormatterLock)
    {
        if (locale != internalLocale) {
            internalLocale = locale;
            [self resetCache];
        }
    }
}

+ (NSLocale *)locale
{
    @synchronized(TWTRDateFormatterLock)
    {
        if (!internalLocale) {
            internalLocale = [NSLocale currentLocale];
        }
    }

    return internalLocale;
}

@end
