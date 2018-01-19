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

#import <TwitterCore/TWTRDateFormatters.h>
#import <TwitterCore/TWTRDateFormatters_Private.h>
#import <XCTest/XCTest.h>
#import "TUDelorean+Rollback.h"
#import "TUDelorean.h"
#import "TWTRFixtureLoader.h"
#import "TWTRTimestampLabel.h"
#import "TWTRTweet.h"

@interface TWTRTimestampLabelTests : XCTestCase

@property (nonatomic) TWTRTimestampLabel *timestamp;
@property (nonatomic, strong) NSDate *november2014;
@property (nonatomic, strong) NSTimeZone *userTimeZone;
@property (nonatomic, strong) TWTRTweet *googleTweet;
@property (nonatomic, strong) TWTRTweet *obamaTweet;

@end

@implementation TWTRTimestampLabelTests

- (void)setUp
{
    [super setUp];

    [TWTRDateFormatters resetCache];
    [TWTRDateFormatters setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];

    self.timestamp = [[TWTRTimestampLabel alloc] init];

    // Tweet setup
    self.googleTweet = [TWTRFixtureLoader googleTweet];
    self.obamaTweet = [TWTRFixtureLoader obamaTweet];

    // Date setup
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"MMMM dd, yyyy";
    self.november2014 = [dateFormat dateFromString:@"November 12, 2014"];
    self.userTimeZone = [NSTimeZone defaultTimeZone];
    NSTimeZone *easternTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"EST"];
    [NSTimeZone setDefaultTimeZone:easternTimeZone];
}

- (void)tearDown
{
    [NSTimeZone setDefaultTimeZone:self.userTimeZone];  // Return to timezone before tests were run
}

- (void)testNotNil
{
    self.timestamp.date = [NSDate date];
    XCTAssertNotNil(self.timestamp.text);
    XCTAssertNotNil(self.timestamp.accessibilityLabel);
}

- (void)testNilDate_EmptyStrings
{
    self.timestamp.date = nil;
    XCTAssertEqual(self.timestamp.text, @"");
    XCTAssertEqual(self.timestamp.accessibilityLabel, @"");
}

- (void)testRegularFormattedDate
{
    [TUDelorean temporarilyTimeTravelTo:self.november2014
                                  block:^(NSDate *date) {
                                      self.timestamp.date = self.obamaTweet.createdAt;
                                      XCTAssertEqualObjects(self.timestamp.text, @" • 11/6/12");

                                      self.timestamp.date = self.googleTweet.createdAt;
                                      XCTAssertEqualObjects(self.timestamp.text, @" • May 23");
                                  }];
}

@end
