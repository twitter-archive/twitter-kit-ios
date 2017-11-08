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
#import "TWTRComposerAccount.h"

@interface TWTRComposerAccountTests : XCTestCase

@end

@implementation TWTRComposerAccountTests

- (void)testExample
{
    TWTRComposerAccount *account = [[TWTRComposerAccount alloc] init];
    account.userID = 383294;
    account.username = @"stevenhepting";

    XCTAssertEqualObjects(account.userIDString, @"383294");
}

- (void)testAccountFromSession_setsCorrectProperties
{
    TWTRSession *session = [[TWTRSession alloc] initWithSessionDictionary:@{ @"screen_name": @"fakename", @"user_id": @"38927309", @"oauth_token": @"fake_token", @"oauth_token_secret": @"secret" }];
    TWTRComposerAccount *account = accountFromSession(session);

    XCTAssertEqual(account.userID, 38927309);
    XCTAssertEqualObjects(account.username, @"fakename");
}

@end
