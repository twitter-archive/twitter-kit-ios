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
#import "TWTRAuthenticationConstants.h"
#import "TWTRGuestSession.h"
#import "TWTRGuestSession_Private.h"

@interface TWTRGuestSessionTests : XCTestCase
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *guestToken;

@end

@implementation TWTRGuestSessionTests

- (void)setUp
{
    [super setUp];
    self.accessToken = @"accessToken";
    self.guestToken = @"guestToken";
}

- (void)testInitSessionDictionary
{
    NSDictionary *dictionary = @{TWTRAuthAppOAuthTokenKey: self.accessToken, TWTRGuestAuthOAuthTokenKey: self.guestToken};
    TWTRGuestSession *session = [[TWTRGuestSession alloc] initWithSessionDictionary:dictionary];
    XCTAssertEqualObjects(session.accessToken, self.accessToken);
    XCTAssertEqualObjects(session.guestToken, self.guestToken);
}

- (void)testInit
{
    TWTRGuestSession *session = [[TWTRGuestSession alloc] initWithAccessToken:self.accessToken guestToken:self.guestToken];
    XCTAssertEqualObjects(session.accessToken, self.accessToken);
    XCTAssertEqualObjects(session.guestToken, self.guestToken);
}

- (void)testNSCoding
{
    TWTRGuestSession *session = [[TWTRGuestSession alloc] initWithAccessToken:self.accessToken guestToken:self.guestToken];

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:session];
    TWTRGuestSession *encodedSession = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    XCTAssertEqualObjects(session.accessToken, encodedSession.accessToken);
    XCTAssertEqualObjects(session.guestToken, encodedSession.guestToken);
}

- (void)testProbablyNeedsRefreshing_NO_DefaultInitializer
{
    TWTRGuestSession *session = [[TWTRGuestSession alloc] initWithAccessToken:@"A" guestToken:@"G"];
    XCTAssertFalse(session.probablyNeedsRefreshing);
}

- (void)testProbablyNeedsRefreshing_YES_GreaterThan1Hour
{
    NSTimeInterval interval = 60 * 60 + 1;  // three hours +1 second
    NSDate *creationDate = [NSDate dateWithTimeIntervalSinceNow:-interval];

    TWTRGuestSession *session = [[TWTRGuestSession alloc] initWithAccessToken:@"A" guestToken:@"B" creationDate:creationDate];
    XCTAssertTrue(session.probablyNeedsRefreshing);
}

- (void)testProbablyNeedsRefreshing_NO_30Minutes
{
    NSTimeInterval interval = 30 * 60;
    NSDate *creationDate = [NSDate dateWithTimeIntervalSinceNow:-interval];

    TWTRGuestSession *session = [[TWTRGuestSession alloc] initWithAccessToken:@"A" guestToken:@"B" creationDate:creationDate];
    XCTAssertFalse(session.probablyNeedsRefreshing);
}

@end
