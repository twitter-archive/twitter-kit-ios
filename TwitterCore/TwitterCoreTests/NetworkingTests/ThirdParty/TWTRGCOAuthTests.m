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
#import <XCTest/XCTest.h>
#import "TWTRGCOAuth.h"

static time_t TWTRGCOAuthTimeStampOffset;

@interface TWTRGCOAuth ()

+ (NSString *)timeStamp;

@end

@interface TWTRGCOAuthTests : XCTestCase

@end

@implementation TWTRGCOAuthTests

- (void)testTimeStamp_mustBeGMT
{
    NSTimeZone *cachedTimeZone = [NSTimeZone defaultTimeZone];
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithName:@"Australia/Melbourne"]];

    NSString *oAuthTimeStamp = [TWTRGCOAuth timeStamp];
    NSTimeInterval gmtTimeStamp = [NSDate date].timeIntervalSince1970;

    XCTAssertEqualWithAccuracy([oAuthTimeStamp doubleValue], gmtTimeStamp, 1);

    [NSTimeZone setDefaultTimeZone:cachedTimeZone];
}

- (void)testSetTimeStampOffset
{
    time_t currentOffset = TWTRGCOAuthTimeStampOffset;
    [TWTRGCOAuth setTimestampOffset:300];

    NSString *oAuthTimeStamp = [TWTRGCOAuth timeStamp];
    NSTimeInterval gmtTimeStamp = [NSDate date].timeIntervalSince1970 + 300;

    XCTAssertEqualWithAccuracy([oAuthTimeStamp doubleValue], gmtTimeStamp, 1);

    [TWTRGCOAuth setTimestampOffset:currentOffset];
}

@end
