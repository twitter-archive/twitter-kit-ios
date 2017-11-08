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

#import "TWTRFixtureLoader.h"
#import "TWTRTestCase.h"
#import "TWTRURLUtility.h"

@interface TWTRURLUtilityTests : TWTRTestCase

@end

@implementation TWTRURLUtilityTests

- (void)testDeepLinkURL
{
    NSURL *desiredURL = [NSURL URLWithString:@"twitter://status?id=468722941975592960"];
    NSURL *actualURL = [TWTRURLUtility deepLinkURLForTweet:[TWTRFixtureLoader gatesTweet]];
    XCTAssert([desiredURL isEqual:actualURL]);
}

- (void)testPermalinkPath
{
    NSString *desiredPath = @"/BillGates/status/468722941975592960";
    NSString *path = [[TWTRURLUtility permalinkURLForTweet:[TWTRFixtureLoader gatesTweet]] path];

    XCTAssert([path isEqualToString:desiredPath]);
}

- (void)testPermalink
{
    NSURL *desiredURL = [NSURL URLWithString:@"https://www.twitter.com/BillGates/status/468722941975592960"];
    NSURL *url = [TWTRURLUtility permalinkURLForTweet:[TWTRFixtureLoader gatesTweet]];

    XCTAssert([desiredURL isEqual:url]);
}

@end
