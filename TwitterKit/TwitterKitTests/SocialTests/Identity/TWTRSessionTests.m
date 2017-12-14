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

#import <TwitterCore/TWTRAuthenticationConstants.h>
#import <TwitterCore/TWTRSession.h>
#import <TwitterCore/TWTRSession_Private.h>
#import "TWTRTestCase.h"

@interface TWTRSessionTests : TWTRTestCase

@property (nonatomic, strong, readonly) NSDictionary *authResponseDict;

@end

@implementation TWTRSessionTests

- (void)setUp
{
    [super setUp];

    _authResponseDict = @{ @"oauth_token": @"token", @"oauth_token_secret": @"secret", @"screen_name": @"screenname", @"user_id": @"123" };
}

- (void)testInitWithDictionary_propertiesAreSetAsExpected
{
    TWTRSession *session = [[TWTRSession alloc] initWithSessionDictionary:self.authResponseDict];
    XCTAssertEqualObjects(session.authToken, @"token");
    XCTAssertEqualObjects(session.authTokenSecret, @"secret");
    XCTAssertEqualObjects(session.userName, @"screenname");
    XCTAssertEqualObjects(session.userID, @"123");
}

- (void)testInitWithSSOResponse_correct
{
    NSDictionary *parameters = @{ @"token": @"23698-mzYEJHqJ", @"secret": @"RVfziSc", @"username": @"fabric_tester" };
    TWTRSession *session = [[TWTRSession alloc] initWithSSOResponse:parameters];
    XCTAssertEqualObjects(session.authToken, @"23698-mzYEJHqJ");
    XCTAssertEqualObjects(session.authTokenSecret, @"RVfziSc");
    XCTAssertEqualObjects(session.userName, @"fabric_tester");
    XCTAssertEqualObjects(session.userID, @"23698");
}

- (void)testNSCoder
{
    TWTRSession *session = [[TWTRSession alloc] initWithSessionDictionary:self.authResponseDict];

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:session];
    TWTRSession *encodedSession = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    XCTAssertEqualObjects(session.authToken, encodedSession.authToken);
    XCTAssertEqualObjects(session.authTokenSecret, encodedSession.authTokenSecret);
    XCTAssertEqualObjects(session.userName, encodedSession.userName);
    XCTAssertEqualObjects(session.userID, encodedSession.userID);
}

- (void)testEquality_EqualObjects
{
    TWTRSession *first = [[TWTRSession alloc] initWithSessionDictionary:self.authResponseDict];
    TWTRSession *second = [[TWTRSession alloc] initWithSessionDictionary:self.authResponseDict];

    XCTAssertEqualObjects(first, second);
}

- (void)testEquality_DifferentClasses
{
    TWTRSession *first = [[TWTRSession alloc] initWithSessionDictionary:self.authResponseDict];
    XCTAssertNotEqualObjects(first, @"first");
}

- (void)testEquality_NotEqualObjectsDifferentToken
{
    NSMutableDictionary *otherDict = [self.authResponseDict mutableCopy];
    otherDict[@"oauth_token"] = @"other_token";

    TWTRSession *first = [[TWTRSession alloc] initWithSessionDictionary:self.authResponseDict];
    TWTRSession *second = [[TWTRSession alloc] initWithSessionDictionary:otherDict];

    XCTAssertNotEqualObjects(first, second);
}

- (void)testEquality_NotEqualObjectsDifferentSecret
{
    NSMutableDictionary *otherDict = [self.authResponseDict mutableCopy];
    otherDict[@"oauth_token_secret"] = @"other_secret";

    TWTRSession *first = [[TWTRSession alloc] initWithSessionDictionary:self.authResponseDict];
    TWTRSession *second = [[TWTRSession alloc] initWithSessionDictionary:otherDict];

    XCTAssertNotEqualObjects(first, second);
}

- (void)testEquality_NotEqualObjectsDifferentUserName
{
    NSMutableDictionary *otherDict = [self.authResponseDict mutableCopy];
    otherDict[@"screen_name"] = @"other_screen_name";

    TWTRSession *first = [[TWTRSession alloc] initWithSessionDictionary:self.authResponseDict];
    TWTRSession *second = [[TWTRSession alloc] initWithSessionDictionary:otherDict];

    XCTAssertNotEqualObjects(first, second);
}

- (void)testEquality_NotEqualObjectsDifferentUserID
{
    NSMutableDictionary *otherDict = [self.authResponseDict mutableCopy];
    otherDict[@"user_id"] = @"other_user_id";

    TWTRSession *first = [[TWTRSession alloc] initWithSessionDictionary:self.authResponseDict];
    TWTRSession *second = [[TWTRSession alloc] initWithSessionDictionary:otherDict];

    XCTAssertNotEqualObjects(first, second);
}

- (void)testIsValidSessionDictionary_allKeys
{
    NSDictionary *validDictionary = @{ TWTRAuthOAuthTokenKey: @"token", TWTRAuthOAuthSecretKey: @"secret", TWTRAuthAppOAuthScreenNameKey: @"user-name", TWTRAuthAppOAuthUserIDKey: @"1234" };
    XCTAssertTrue([TWTRSession isValidSessionDictionary:validDictionary]);
}

- (void)testIsValidSessionDictionary_failsMissingToken
{
    NSDictionary *validDictionary = @{ TWTRAuthOAuthSecretKey: @"secret", TWTRAuthAppOAuthScreenNameKey: @"user-name", TWTRAuthAppOAuthUserIDKey: @"1234" };
    XCTAssertFalse([TWTRSession isValidSessionDictionary:validDictionary]);
}

- (void)testIsValidSessionDictionary_failsMissingSecret
{
    NSDictionary *validDictionary = @{ TWTRAuthOAuthTokenKey: @"token", TWTRAuthAppOAuthScreenNameKey: @"user-name", TWTRAuthAppOAuthUserIDKey: @"1234" };
    XCTAssertFalse([TWTRSession isValidSessionDictionary:validDictionary]);
}

- (void)testIsValidSessionDictionary_failsMissingScreenName
{
    NSDictionary *validDictionary = @{ TWTRAuthOAuthTokenKey: @"token", TWTRAuthOAuthSecretKey: @"secret", TWTRAuthAppOAuthUserIDKey: @"1234" };
    XCTAssertFalse([TWTRSession isValidSessionDictionary:validDictionary]);
}

- (void)testIsValidSessionDictionary_failsMissingUserID
{
    NSDictionary *validDictionary = @{ TWTRAuthOAuthTokenKey: @"token", TWTRAuthOAuthSecretKey: @"secret", TWTRAuthAppOAuthScreenNameKey: @"user-name" };
    XCTAssertFalse([TWTRSession isValidSessionDictionary:validDictionary]);
}

- (void)testDictionary_correctlySerializesToDictionary
{
    TWTRSession *session = [[TWTRSession alloc] initWithSessionDictionary:self.authResponseDict];
    NSDictionary *sessionDictionary = [session dictionaryRepresentation];
    XCTAssertEqualObjects(self.authResponseDict[TWTRAuthOAuthTokenKey], sessionDictionary[TWTRAuthOAuthTokenKey]);
    XCTAssertEqualObjects(self.authResponseDict[TWTRAuthOAuthSecretKey], sessionDictionary[TWTRAuthOAuthSecretKey]);
    XCTAssertEqualObjects(self.authResponseDict[TWTRAuthAppOAuthScreenNameKey], sessionDictionary[TWTRAuthAppOAuthScreenNameKey]);
    XCTAssertEqualObjects(self.authResponseDict[TWTRAuthAppOAuthUserIDKey], sessionDictionary[TWTRAuthAppOAuthUserIDKey]);
}

@end
