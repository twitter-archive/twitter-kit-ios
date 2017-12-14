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
#import "TWTRBirdView.h"
#import "TWTRFixtureLoader.h"
#import "TWTRProfileHeaderView.h"
#import "TWTRRetweetView.h"
#import "TWTRTimestampLabel.h"
#import "TWTRTweet.h"
#import "TWTRTwitter_Private.h"
#import "TWTRUser.h"
#import "TWTRVerifiedView.h"

@interface TWTRProfileHeaderView ()

@property (nonatomic) TWTRBirdView *twitterLogo;
@property (nonatomic) TWTRRetweetView *retweetView;
@property (nonatomic) TWTRVerifiedView *verified;
@property (nonatomic) UILabel *userName;
- (void)loadProfileThumbnail;
- (void)profileTapped;

@end

@interface TWTRProfileHeaderViewMockDelegate : NSObject <TWTRProfileHeaderViewDelegate>
@property (nonatomic, nullable) TWTRUser *tappedUser;
@end

@interface TWTRProfileHeaderViewTests : XCTestCase

@property (nonatomic) TWTRProfileHeaderView *compactHeader;
@property (nonatomic) TWTRProfileHeaderView *regularHeader;
@property (nonatomic) TWTRTweet *retweet;
@property (nonatomic) TWTRTweet *verifiedTweet;
@property (nonatomic) TWTRTweet *standardTweet;
@property (nonatomic) TWTRProfileHeaderViewMockDelegate *mockDelegate;

@end

@implementation TWTRProfileHeaderViewTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.compactHeader = [[TWTRProfileHeaderView alloc] initWithStyle:TWTRTweetViewStyleCompact];
    self.regularHeader = [[TWTRProfileHeaderView alloc] initWithStyle:TWTRTweetViewStyleRegular];

    self.retweet = [TWTRFixtureLoader retweetTweet];
    self.verifiedTweet = [TWTRFixtureLoader obamaTweet];
    self.standardTweet = [TWTRFixtureLoader googleTweet];

    self.mockDelegate = [[TWTRProfileHeaderViewMockDelegate alloc] init];

    self.compactHeader.delegate = self.mockDelegate;
    self.regularHeader.delegate = self.mockDelegate;
}

#pragma mark - Verified

- (void)testRegularTimestampText
{
    XCTAssertNotNil(self.regularHeader.timestamp.text);
    XCTAssertNotNil(self.regularHeader.timestamp.accessibilityLabel);
}

- (void)testVerified_showsForVerifiedRegular
{
    [self.regularHeader configureWithTweet:self.retweet];

    XCTAssert(self.regularHeader.verified.hidden == NO);
}

- (void)testVerified_hidesForUnverifiedRegular
{
    [self.regularHeader configureWithTweet:[TWTRFixtureLoader googleTweet]];

    XCTAssert(self.regularHeader.verified.hidden == YES);
}

- (void)testVerified_hidesForCompact
{
    XCTAssert(self.compactHeader.verified.hidden == YES);
}

- (void)testVerified_hidesForEmptyTweet
{
    [self.regularHeader configureWithTweet:nil];

    XCTAssert(self.regularHeader.verified.hidden == YES);
}

#pragma mark - Retweet

- (void)testRetweetView_showsIcon
{
    [self.regularHeader configureWithTweet:self.retweet];

    XCTAssertNotNil(self.regularHeader.retweetView.imageView.image);
}

- (void)testRetweetView_notShownIfRegularTweet
{
    XCTAssert(self.regularHeader.retweetView.hidden == YES);
}

- (void)testRetweetView_shownIfRetweet
{
    [self.compactHeader configureWithTweet:self.retweet];

    XCTAssert(self.compactHeader.retweetView.hidden == NO);
}

- (void)testRetweetIcon_showsIfConfiguredWithRetweet
{
    XCTAssert(self.compactHeader.retweetView.hidden == YES);
    [self.compactHeader configureWithTweet:self.retweet];
    XCTAssert(self.compactHeader.retweetView.hidden == NO);
}

- (void)testRetweetIcon_hidesIfConfiguredWithRegularTweet
{
    [self.compactHeader configureWithTweet:self.retweet];
    XCTAssert(self.compactHeader.retweetView.hidden == NO);
    [self.compactHeader configureWithTweet:self.verifiedTweet];
    XCTAssert(self.compactHeader.retweetView.hidden == YES);
}

- (void)testRetweetedByText
{
    [self.compactHeader configureWithTweet:self.retweet];
    XCTAssertEqualObjects(self.compactHeader.retweetView.textLabel.text, @"Retweeted by Fabric");
}

#pragma mark - Username

- (void)testUsername_NilTweet
{
    XCTAssertEqualObjects(self.regularHeader.fullname.text, @"");
}

- (void)testUsername
{
    [self.regularHeader configureWithTweet:self.standardTweet];
    [self.compactHeader configureWithTweet:self.retweet];

    XCTAssertEqualObjects(self.regularHeader.userName.text, @"@GoogleFacts");
    XCTAssertEqualObjects(self.compactHeader.userName.text, @"@digits");
}

- (void)testFullNameForNilTweet
{
    XCTAssertEqualObjects(self.regularHeader.fullname.text, @"");
}

- (void)testFullNameForTweet
{
    [self.regularHeader configureWithTweet:self.standardTweet];
    [self.compactHeader configureWithTweet:self.retweet];

    XCTAssertEqualObjects(self.regularHeader.fullname.text, @"Google Facts");
    XCTAssertEqualObjects(self.compactHeader.fullname.text, self.retweet.retweetedTweet.author.name);
}

#pragma mark - Images

- (void)testLogo
{
    XCTAssertNotNil(self.regularHeader.twitterLogo.birdColor);
    XCTAssertNotNil(self.compactHeader.twitterLogo.birdColor);
}

#pragma mark - Colors

- (void)testSetPrimaryTextColor
{
    UIColor *green = [UIColor greenColor];
    self.compactHeader.primaryTextColor = green;

    XCTAssert(self.compactHeader.fullname.textColor == green);
}

- (void)testSecondaryTextColor
{
    UIColor *secondaryColor = [UIColor greenColor];
    self.regularHeader.secondaryTextColor = secondaryColor;
    XCTAssertEqualObjects(self.regularHeader.timestamp.textColor, secondaryColor);
    XCTAssertEqualObjects(self.regularHeader.userName.textColor, secondaryColor);
    XCTAssertEqualObjects(self.regularHeader.retweetView.textLabel.textColor, secondaryColor);

    secondaryColor = [UIColor yellowColor];
    self.regularHeader.secondaryTextColor = secondaryColor;
    XCTAssertEqualObjects(self.regularHeader.timestamp.textColor, secondaryColor);
    XCTAssertEqualObjects(self.regularHeader.userName.textColor, secondaryColor);
    XCTAssertEqualObjects(self.regularHeader.retweetView.textLabel.textColor, secondaryColor);
}

- (void)testSetBackgroundColor
{
    UIColor *green = [UIColor greenColor];
    self.compactHeader.backgroundColor = green;

    XCTAssert(self.compactHeader.fullname.backgroundColor == green);
    XCTAssert(self.compactHeader.userName.backgroundColor == green);
    XCTAssert(self.compactHeader.timestamp.backgroundColor == green);
    XCTAssert(self.compactHeader.retweetView.backgroundColor == green);
}

- (void)testEmptyTweetLabelBackgrounds
{
    [self.compactHeader configureWithTweet:nil];

    XCTAssert(self.compactHeader.fullname.backgroundColor != self.compactHeader.backgroundColor, @"If the tweet view is configured with an empty tweet, the text label backgrounds should stand out.");
}

#pragma mark - Profile Image

- (void)testLoadsProfileImage
{
    id mockHeader = [OCMockObject partialMockForObject:self.regularHeader];
    [[mockHeader expect] loadProfileThumbnail];

    [mockHeader configureWithTweet:self.verifiedTweet];
    [mockHeader verify];
}

- (void)testLoadsProfileImage_withProperURL
{
    // Make sure we load the Retweeted tweet's author profile
    NSURL *expectedURL = [NSURL URLWithString:self.retweet.retweetedTweet.author.profileImageLargeURL];
    [[TWTRTwitter sharedInstance] startWithConsumerKey:@"sdflkjfd" consumerSecret:@"sdflkfd"];
    id mockImageLoader = OCMPartialMock([[TWTRTwitter sharedInstance] imageLoader]);
    OCMExpect([mockImageLoader fetchImageWithURL:expectedURL completion:OCMOCK_ANY]);

    [self.compactHeader configureWithTweet:self.retweet];
    [mockImageLoader verify];
    [mockImageLoader stopMocking];
}

- (void)testLoadsProfileImage_onlyOnce
{
    [self.regularHeader configureWithTweet:self.verifiedTweet];
    id mockHeader = [OCMockObject partialMockForObject:self.regularHeader];
    [[mockHeader reject] loadProfileThumbnail];

    [mockHeader configureWithTweet:self.verifiedTweet];
    [mockHeader verify];
}

- (void)testLoadsProfileImage_notWhenCalculationOnly
{
    self.regularHeader.calculationOnly = YES;

    [[TWTRTwitter sharedInstance] startWithConsumerKey:@"sdflkjfd" consumerSecret:@"sdflkfd"];
    id mockImageLoader = OCMPartialMock([[TWTRTwitter sharedInstance] imageLoader]);
    [[mockImageLoader reject] fetchImageWithURL:OCMOCK_ANY completion:OCMOCK_ANY];

    [self.regularHeader configureWithTweet:self.verifiedTweet];
    OCMVerifyAll(mockImageLoader);
    [mockImageLoader stopMocking];
}

#pragma mark - Delegate tests

- (void)testProfileDelegateTapCallsTweetAuthor
{
    [self.regularHeader configureWithTweet:self.standardTweet];
    [self.regularHeader profileTapped];
    XCTAssertEqualObjects(self.mockDelegate.tappedUser, self.standardTweet.author);
}

- (void)testProfileDelegateTapCallsRetweetAuthorForRetweet
{
    [self.regularHeader configureWithTweet:self.retweet];
    [self.regularHeader profileTapped];
    XCTAssertEqualObjects(self.mockDelegate.tappedUser, self.retweet.retweetedTweet.author);
}

@end

@implementation TWTRProfileHeaderViewMockDelegate

- (void)profileHeaderView:(TWTRProfileHeaderView *)headerView didTapProfileForUser:(TWTRUser *)user
{
    self.tappedUser = user;
}

@end
