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

#import "TWTRAPIDateSync.h"
#import "TWTRDateFormatters.h"
#import "TWTRGCOAuth.h"

NSString *const TWTRAPIDateHeader = @"date";
NSTimeInterval const TWTRAPIDateAccuracy = 600;  // 10 minutes in seconds

@interface TWTRAPIDateSync ()

@property (nonatomic) NSHTTPURLResponse *response;

@end

@implementation TWTRAPIDateSync

- (instancetype)initWithHTTPResponse:(NSHTTPURLResponse *)response
{
    if (!response) {
        return nil;
    }

    if (self = [super init]) {
        _response = response;
    }

    return self;
}

/**
 * Parses http response header and syncs OAuth offsets if necessary
 */
- (BOOL)sync
{
    NSDictionary *headers = [self.response allHeaderFields];
    NSString *dateString = [headers valueForKey:TWTRAPIDateHeader];
    if (!dateString || !dateString.length) {
        return NO;
    }

    NSDate *serverDate = [[TWTRDateFormatters HTTPDateHeaderParsingFormatter] dateFromString:dateString];
    if (!serverDate) {
        return NO;
    }

    NSDate *localDate = [NSDate date];

    NSTimeInterval localTime = [localDate timeIntervalSince1970];
    NSTimeInterval serverTime = [serverDate timeIntervalSince1970];
    NSTimeInterval delta = serverTime - localTime;

    if (ABS(delta) > TWTRAPIDateAccuracy) {
        NSLog(@"Local time is off from UTC by %f seconds", delta);
        [TWTRGCOAuth setTimestampOffset:delta];
        return YES;
    }

    // if the delta is not large enough, just reset to 0
    [TWTRGCOAuth setTimestampOffset:0];

    return NO;
}

@end
