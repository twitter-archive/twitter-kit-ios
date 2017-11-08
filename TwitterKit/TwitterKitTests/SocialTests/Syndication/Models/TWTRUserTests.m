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
#import "TWTRUser.h"

@interface TWTRUserTests : TWTRTestCase

@property (nonatomic, strong) TWTRUser *user;
@property (nonatomic, strong) NSDictionary *userDict;

@end

@implementation TWTRUserTests

- (void)setUp
{
    [super setUp];

    self.userDict = [TWTRFixtureLoader dictFromJSONFile:@"ObamaUser.json"];
    self.user = [TWTRFixtureLoader obamaUser];
}

- (void)tearDown
{
    [super tearDown];
}

#pragma mark - Init

- (void)testInit
{
    TWTRUser *user = [self user];

    XCTAssertTrue([@"813286" isEqualToString:user.userID], @"User ID not set properly");
    XCTAssertTrue([[user name] isEqualToString:@"Barack Obama"], @"User name not set properly");
    XCTAssertTrue([[user screenName] isEqualToString:@"BarackObama"], @"User screen name not set properly");
    XCTAssertTrue([user isVerified], @"User should be verified");

    XCTAssertTrue([[user profileImageURL] isEqualToString:@"https://pbs.twimg.com/profile_images/451007105391022080/iu1f7brY_normal.png"], @"User profileImageURL not set properly");
}

- (void)testUserIsProtectedFalse
{
    XCTAssertFalse(self.user.isProtected, @"Obama user should have isProtected = false");
}

- (void)testUserIsProtectedTrue
{
    NSDictionary *protectedUserDictionary = [TWTRFixtureLoader dictFromJSONFile:@"ProtectedUser.json"];
    TWTRUser *protectedUser = [[TWTRUser alloc] initWithJSONDictionary:protectedUserDictionary];
    XCTAssertTrue(protectedUser.isProtected, @"Protected user should have isProtected = true");
}

- (void)testUserEncoding
{
    TWTRUser *user = self.user;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:user];
    XCTAssertTrue([data length] > 0, @"Encoded User invalid.");
}

- (void)testUserDecoding
{
    TWTRUser *user = self.user;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:user];
    TWTRUser *decodedUser = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    XCTAssertTrue([user.userID isEqualToString:decodedUser.userID], @"Decoded User id should match");
    XCTAssertTrue([user.name isEqualToString:decodedUser.name], @"Decoded User name should match");
    XCTAssertTrue([user.screenName isEqualToString:decodedUser.screenName], @"Decoded User screenName should match");
    XCTAssertTrue(user.isVerified == decodedUser.isVerified, @"Decoded User isVerified should match");
    XCTAssertTrue(user.isProtected == decodedUser.isProtected, @"Decoded User isProtected should match");
    XCTAssertTrue([user.profileImageURL isEqualToString:decodedUser.profileImageURL], @"Decoded User profileImageURL should match");
    XCTAssertTrue([user.profileImageMiniURL isEqualToString:decodedUser.profileImageMiniURL], @"Decoded User profileImageMiniURL should match");
    XCTAssertTrue([user.profileImageLargeURL isEqualToString:decodedUser.profileImageLargeURL], @"Decoded User profileImageLargeURL should match");
    XCTAssertTrue([user.formattedScreenName isEqualToString:decodedUser.formattedScreenName], @"Decoded User formattedScreenName should match");
}

- (void)testUserFormattedScreenName
{
    NSString *formattedScreenName = [NSString stringWithFormat:@"@%@", self.user.screenName];
    XCTAssertTrue([self.user.formattedScreenName isEqualToString:formattedScreenName], @"User formatted screenName should be prefixed with @");
}

- (void)testProfileImageMiniUrlSimple
{
    NSString *miniUrl = [self.user.profileImageURL stringByReplacingOccurrencesOfString:@"_normal" withString:@"_mini"];
    XCTAssertTrue([self.user.profileImageMiniURL isEqualToString:miniUrl], @"User profile mini URL does not match");
}

- (void)testProfileImageMiniUrlRepeated
{
    NSString *repeatedUrl = @"https://foo.com/image_normal_normal.jpg";
    [self.user setValue:repeatedUrl forKey:NSStringFromSelector(@selector(profileImageURL))];
    XCTAssertTrue([self.user.profileImageMiniURL isEqualToString:@"https://foo.com/image_normal_mini.jpg"], @"User profile mini URL does not match");
}

- (void)testProfileImageLargeUrlSimple
{
    NSString *largeUrl = [self.user.profileImageURL stringByReplacingOccurrencesOfString:@"_normal" withString:@"_reasonably_small"];
    XCTAssertTrue([self.user.profileImageLargeURL isEqualToString:largeUrl], @"User profile large URL does not match");
}

- (void)testProfileImageLargeUrlRepeated
{
    NSString *repeatedUrl = @"https://foo.com/image_normal_normal.jpg";
    [self.user setValue:repeatedUrl forKey:NSStringFromSelector(@selector(profileImageURL))];
    XCTAssertTrue([self.user.profileImageLargeURL isEqualToString:@"https://foo.com/image_normal_reasonably_small.jpg"], @"User profile mini URL does not match");
}

- (void)testProfileImageURL
{
    NSURL *expected = [NSURL URLWithString:@"https://www.twitter.com/BarackObama"];
    XCTAssertEqualObjects(expected, self.user.profileURL);
}

@end
