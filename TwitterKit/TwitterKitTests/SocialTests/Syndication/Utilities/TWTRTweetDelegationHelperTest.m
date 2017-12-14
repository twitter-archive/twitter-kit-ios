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

#import <XCTest/XCTest.h>
#import "TWTRTweetDelegationHelper.h"

@interface TWTRTweetDelegationHelperTest : XCTestCase

@end

@implementation TWTRTweetDelegationHelperTest

// TODO: Add more test for other methods in TWTRTwetDelegationHelper

- (void)testURLWithReferral
{
    NSURL *originalURL = [NSURL URLWithString:@"http://www.twitter.com"];
    NSString *expected = @"http://www.twitter.com?ref_src=twsrc%5Etwitterkit";
    XCTAssertEqualObjects(expected, [[TWTRTweetDelegationHelper URLWithReferral:originalURL] absoluteString]);
}

@end
