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

#import <TwitterCore/TWTRSession.h>
#import <XCTest/XCTest.h>
#import "TWTRComposerUser.h"
#import "TWTRFixtureLoader.h"
#import "TWTRUser.h"

@interface TWTRComposerUserTests : XCTestCase

@end

@implementation TWTRComposerUserTests

- (void)testUserFromUser_setsCorrectProperties
{
    TWTRUser *twitterUser = [TWTRFixtureLoader obamaUser];
    TWTRComposerUser *user = userFromUser(twitterUser);

    XCTAssertEqualObjects(user.fullName, @"Barack Obama");
    XCTAssertEqual(user.userID, 813286);
    XCTAssertEqualObjects(user.avatarURL.absoluteString, @"https://pbs.twimg.com/profile_images/451007105391022080/iu1f7brY_normal.png");
    XCTAssertEqualObjects(user.username, @"BarackObama");
}

@end
