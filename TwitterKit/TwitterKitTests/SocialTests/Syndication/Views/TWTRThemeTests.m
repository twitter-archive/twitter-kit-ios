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

#import <TwitterCore/TWTRColorUtil.h>
#import <XCTest/XCTest.h>
#import "TWTRFixtureLoader.h"
#import "TWTRTweetContentView+Layout.h"
#import "TWTRTweetLabel.h"
#import "TWTRTweetView.h"
#import "TWTRTweetView_Private.h"

/**
 *  Removes all the recorded invocations in the provided UIAppearance proxy for TWTRTweetView.
 *  UIApperance relies on global state, this allows you to reset that state to keep testing from a clean state.
 */
void resetTweetViewAppearance()
{
    [[[TWTRTweetView appearance] valueForKey:@"_appearanceInvocations"] removeAllObjects];
    [[TWTRTweetView appearance] setTheme:TWTRTweetViewThemeLight];
}

@interface TWTRTweetThemeTests : XCTestCase

@property (nonatomic, strong) TWTRTweetView *tweetView;
@property (nonatomic, readonly, strong) UIWindow *window;

@end

@interface TWTRTweetLabel ()
- (TWTRTweetEntityRange *)entityAtCharacterIndex:(CFIndex)idx;
@end

@implementation TWTRTweetThemeTests

- (void)setUp
{
    [super setUp];

    resetTweetViewAppearance();
    _window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 200, 300)];
    self.tweetView = [[TWTRTweetView alloc] initWithTweet:nil];
}

- (void)verifyThemeIsLight
{
    XCTAssertEqualObjects(self.tweetView.primaryTextColor, [TWTRColorUtil textColor]);
    XCTAssertEqualObjects(self.tweetView.backgroundColor, [TWTRColorUtil whiteColor]);
    XCTAssertEqualObjects(self.tweetView.linkTextColor, [TWTRColorUtil blueColor]);
}

- (void)verifyThemeIsDark
{
    XCTAssertEqualObjects(self.tweetView.primaryTextColor, [TWTRColorUtil faintGrayColor]);
    XCTAssertEqualObjects(self.tweetView.backgroundColor, [TWTRColorUtil textColor]);
    XCTAssertEqualObjects(self.tweetView.linkTextColor, [TWTRColorUtil lightBlueColor]);
}

#pragma mark - Theme

- (void)testTheme_setsColorsToLight
{
    [self.window addSubview:self.tweetView];
    [self verifyThemeIsLight];
}

- (void)testTheme_isLightWhenSetDirectly
{
    self.tweetView.theme = TWTRTweetViewThemeLight;

    [self verifyThemeIsLight];
}

- (void)testTheme_isLightByDefault
{
    XCTAssertEqual(self.tweetView.theme, TWTRTweetViewThemeLight);
}

- (void)testTheme_isDarkWHenSetDirectly
{
    [self.tweetView setTheme:TWTRTweetViewThemeDark];

    [self verifyThemeIsDark];
}

- (void)testTheme_isDarkWhenSetOnAppearance
{
    [TWTRTweetView appearance].theme = TWTRTweetViewThemeDark;

    TWTRTweetView *tweetView = [[TWTRTweetView alloc] init];
    // UIAppearance performs the appearance invocations when the view is added to a window
    [self.window addSubview:tweetView];

    XCTAssertEqual(tweetView.theme, TWTRTweetViewThemeDark);
}

#pragma mark - Other Properties

- (void)testUIAppearance_setsTextColor
{
    UIColor *textColor = [UIColor greenColor];
    [[TWTRTweetView appearance] setPrimaryTextColor:textColor];

    self.tweetView = [[TWTRTweetView alloc] initWithTweet:nil];
    [self.window addSubview:self.tweetView];

    XCTAssertEqualObjects(self.tweetView.primaryTextColor, textColor);
}

- (void)testUIAppearance_setsLinkColor
{
    UIColor *linkColor = [UIColor redColor];

    [[TWTRTweetView appearance] setLinkTextColor:linkColor];

    self.tweetView = [[TWTRTweetView alloc] initWithTweet:nil];
    [self.window addSubview:self.tweetView];

    XCTAssertEqualObjects(self.tweetView.linkTextColor, linkColor);
}

- (void)testUIAppearance_setsBackgroundColor
{
    UIColor *backgroundColor = [UIColor purpleColor];

    [[TWTRTweetView appearance] setBackgroundColor:backgroundColor];

    self.tweetView = [[TWTRTweetView alloc] initWithTweet:nil];
    [self.window addSubview:self.tweetView];

    XCTAssertEqualObjects(self.tweetView.backgroundColor, backgroundColor);
}

#pragma mark - Links

- (void)testLink_isLinkedByDefault
{
    TWTRTweet *tweetWithLink = [TWTRFixtureLoader gatesTweet];
    TWTRTweetView *tweetView = [[TWTRTweetView alloc] initWithTweet:tweetWithLink];
    [self.window addSubview:tweetView];

    id result = [tweetView.contentView.tweetLabel entityAtCharacterIndex:100];

    XCTAssertNotNil(result);
}

- (void)testLink_isDefaultColor
{
    TWTRTweet *tweetWithLink = [TWTRFixtureLoader gatesTweet];
    TWTRTweetView *tweetView = [[TWTRTweetView alloc] initWithTweet:tweetWithLink];
    [self.window addSubview:tweetView];

    UIColor *expectedColor = [TWTRColorUtil blueColor];
    UIColor *actualLinkColor = [self linkColorForTweetView:tweetView];

    XCTAssertEqualObjects(actualLinkColor, expectedColor);
}

- (void)testLink_isAppearanceColor
{
    UIColor *linkColor = [UIColor greenColor];
    [TWTRTweetView appearance].linkTextColor = linkColor;

    TWTRTweet *tweetWithLink = [TWTRFixtureLoader gatesTweet];
    TWTRTweetView *tweetView = [[TWTRTweetView alloc] initWithTweet:tweetWithLink];
    [self.window addSubview:tweetView];

    UIColor *actualLinkColor = [self linkColorForTweetView:tweetView];

    XCTAssertEqualObjects(actualLinkColor, linkColor);
}

- (void)testLink_isStillLinkedWithCustomColor
{
    [TWTRTweetView appearance].linkTextColor = [UIColor orangeColor];
    TWTRTweet *tweetWithLink = [TWTRFixtureLoader gatesTweet];
    TWTRTweetView *tweetView = [[TWTRTweetView alloc] initWithTweet:tweetWithLink];
    [self.window addSubview:tweetView];

    id result = [tweetView.contentView.tweetLabel entityAtCharacterIndex:100];

    XCTAssertNotNil(result);
}

- (void)testLink_changesColorOnThemeChange
{
    TWTRTweet *tweetWithLink = [TWTRFixtureLoader gatesTweet];
    TWTRTweetView *tweetView = [[TWTRTweetView alloc] initWithTweet:tweetWithLink];
    [self.window addSubview:tweetView];
    tweetView.theme = TWTRTweetViewThemeDark;

    UIColor *expectedColor = [TWTRColorUtil lightBlueColor];
    UIColor *actualLinkColor = [self linkColorForTweetView:tweetView];

    XCTAssertEqualObjects(actualLinkColor, expectedColor);
}

- (void)testLink_isStillLinkedOnThemeChange
{
    TWTRTweet *tweetWithLink = [TWTRFixtureLoader gatesTweet];
    TWTRTweetView *tweetView = [[TWTRTweetView alloc] initWithTweet:tweetWithLink];
    [self.window addSubview:tweetView];
    tweetView.theme = TWTRTweetViewThemeDark;

    id result = [tweetView.contentView.tweetLabel entityAtCharacterIndex:100];

    XCTAssertNotNil(result);
}

#pragma mark - Utilities

- (UIColor *)linkColorForTweetView:(TWTRTweetView *)tweetView
{
    NSDictionary *linkAttributes = [self linkAttributes:tweetView];
    UIColor *actualLinkColor = linkAttributes[NSForegroundColorAttributeName];

    return actualLinkColor;
}

- (NSDictionary *)linkAttributes:(TWTRTweetView *)tweetView
{
    return [tweetView.contentView.tweetLabel.attributedText attributesAtIndex:100 effectiveRange:NULL];
}

@end
