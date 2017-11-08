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
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TWTRFixtureLoader.h"
#import "TWTRTweet.h"
#import "TWTRTweetHashtagEntity.h"
#import "TWTRTweetPresenter.h"
#import "TWTRTweetUrlEntity.h"
#import "TWTRUser.h"

@interface TWTRTweetPresenterTests : XCTestCase
@property (nonatomic, strong) TWTRTweetPresenter *regularPresenter;
@property (nonatomic, strong) TWTRTweetPresenter *compactPresenter;

@property (nonatomic) TWTRTweet *googleTweet;
@property (nonatomic) TWTRTweet *obamaTweet;
@property (nonatomic) TWTRTweet *gatesTweet;
@property (nonatomic) TWTRTweet *manyEntitiesTweet;
@property (nonatomic) TWTRTweet *vineTweet;

@end

@implementation TWTRTweetPresenterTests

- (void)setUp
{
    [super setUp];
    self.regularPresenter = [TWTRTweetPresenter presenterForStyle:TWTRTweetViewStyleRegular];
    self.compactPresenter = [TWTRTweetPresenter presenterForStyle:TWTRTweetViewStyleCompact];

    self.googleTweet = [TWTRFixtureLoader googleTweet];
    self.obamaTweet = [TWTRFixtureLoader obamaTweet];
    self.gatesTweet = [TWTRFixtureLoader gatesTweet];
    self.manyEntitiesTweet = [TWTRFixtureLoader manyEntitiesTweet];
    self.vineTweet = [TWTRFixtureLoader vineTweetV13];
}

- (void)testTweetText
{
    NSString *regularText = [self.regularPresenter textForTweet:self.googleTweet];
    NSString *compactText = [self.compactPresenter textForTweet:self.googleTweet];
    NSString *desiredText = @"Mirrors are placed near elevators as a psychological trick to make wait seem more tolerable. People like to look at themselves.";

    XCTAssertEqualObjects(regularText, desiredText);
    XCTAssertEqualObjects(compactText, desiredText);
}

- (void)testImageTweetText
{
    NSString *regularText = [self.regularPresenter textForTweet:self.obamaTweet];
    NSString *compactText = [self.compactPresenter textForTweet:self.obamaTweet];
    NSString *desiredText = @"Four more years.";

    XCTAssertEqualObjects(regularText, desiredText);
    XCTAssertEqualObjects(compactText, desiredText);
}

- (void)testTweetTextWithRenderedURL
{
    NSString *regularText = [self.regularPresenter textForTweet:self.gatesTweet];
    NSString *compactText = [self.compactPresenter textForTweet:self.gatesTweet];
    NSString *desiredText = @"Life-saving innovations don’t have to be high-tech. @MelindaGates explains in the @WSJ: b-gat.es/1jOJ99o";

    XCTAssertEqualObjects(regularText, desiredText);
    XCTAssertEqualObjects(compactText, desiredText);
}

- (void)testHTMLEscapeLabel
{
    id tweet = OCMPartialMock([TWTRFixtureLoader obamaTweet]);
    OCMStub([tweet text]).andReturn(@"weekend of driving SF &lt;-&gt; LA &lt;-&gt; SF");

    NSString *regularText = [self.regularPresenter textForTweet:tweet];
    NSString *compactText = [self.compactPresenter textForTweet:tweet];
    NSString *desiredText = @"weekend of driving SF <-> LA <-> SF";

    XCTAssertEqualObjects(regularText, desiredText);
    XCTAssertEqualObjects(compactText, desiredText);
}

- (void)testRetweetedByTextForRetweet_nilTweetReturnsNil
{
    NSString *retweetedByText = [self.compactPresenter retweetedByTextForRetweet:nil];
    XCTAssertEqualObjects(retweetedByText, nil);
}

- (void)testRetweetedByTextForRetweet_notRetweetReturnsNil
{
    NSString *retweetedByText = [self.compactPresenter retweetedByTextForRetweet:self.gatesTweet];
    XCTAssertEqualObjects(retweetedByText, nil);
}

- (void)testRetweetedByTextForRetweet_retweetReturnsProperAttribution
{
    TWTRTweet *retweet = [TWTRFixtureLoader retweetTweet];
    NSString *retweetedByText = [self.compactPresenter retweetedByTextForRetweet:retweet];
    NSString *retweetedByAttributionString = [NSString stringWithFormat:@"Retweeted by %@", retweet.author.name];
    XCTAssertEqualObjects(retweetedByText, retweetedByAttributionString);
}

#pragma mark - Card Tests
- (void)testCardEntityURLStripped
{
    NSString *expected = @"Andrew Bogut #NBAVote #DubTheVote";
    NSString *tweetText = [self.compactPresenter textForTweet:self.vineTweet];

    XCTAssertEqualObjects(tweetText, expected);
}

#pragma mark - Quote Tweet Tests
- (void)testQuoteTweetStripsURL
{
    TWTRTweet *quoteTweet = [TWTRFixtureLoader quoteTweet];
    NSString *text = [self.compactPresenter textForTweet:quoteTweet];

    NSString *expected = @"test quote tweet.";
    XCTAssertEqualObjects(text, expected);
}

- (void)testQuoteTweetKeepsURLWhenInConversation
{
    TWTRTweet *quoteStripTweet = [TWTRFixtureLoader quoteTweetInConversation];
    NSString *text = [self.compactPresenter textForTweet:quoteStripTweet];
    NSString *expected = @"Test quote tweet twitter.com/katejaiheelee/… without strip";
    XCTAssertEqualObjects(text, expected);
}

#pragma mark - Media tests
- (void)testMediaAspectRatioForNoMediaTweetReturnsZero
{
    CGFloat compactRatio = [self.compactPresenter mediaAspectRatioForTweet:self.googleTweet];
    CGFloat regularRatio = [self.regularPresenter mediaAspectRatioForTweet:self.googleTweet];

    XCTAssertEqualWithAccuracy(compactRatio, 0.0, __FLT_EPSILON__);
    XCTAssertEqualWithAccuracy(regularRatio, 0.0, __FLT_EPSILON__);
}

- (void)testRegularStyleReturnsOriginalAspectRatio
{
    XCTAssertEqualWithAccuracy([self.regularPresenter mediaAspectRatioForTweet:self.obamaTweet], 1.5, 0.1);
}

- (void)testCompactStyleReturnsCorrectAspectRatio
{
    XCTAssertEqualWithAccuracy([self.compactPresenter mediaAspectRatioForTweet:self.obamaTweet], 16.0 / 10.0, 0.1);
}

- (void)testMediaAspectRatioForVineCard
{
    XCTAssertEqualWithAccuracy([self.compactPresenter mediaAspectRatioForTweet:self.vineTweet], 16.0 / 10.0, 0.1);
    XCTAssertEqualWithAccuracy([self.regularPresenter mediaAspectRatioForTweet:self.vineTweet], 1.0, 0.1);
}

#pragma mark - Display Entities
- (void)testLoadingDisplayEntities_urlsAndHashtags
{
    NSArray *entities = [self.regularPresenter entityRangesForTweet:self.manyEntitiesTweet types:TWTRTweetEntityDisplayTypeURL | TWTRTweetEntityDisplayTypeHashtag];
    XCTAssert(entities.count > 0);

    NSString *displayText = [self.regularPresenter textForTweet:self.manyEntitiesTweet];

    // make sure all of the text matches
    for (TWTRTweetEntityRange *displayPosition in entities) {
        NSString *textToFind;
        TWTRTweetEntity *entity = displayPosition.entity;
        if ([entity isKindOfClass:[TWTRTweetUrlEntity class]]) {
            textToFind = [(TWTRTweetUrlEntity *)entity displayUrl];
        } else if ([entity isKindOfClass:[TWTRTweetHashtagEntity class]]) {
            textToFind = [NSString stringWithFormat:@"#%@", [(TWTRTweetHashtagEntity *)entity text]];
        } else {
            XCTFail("Invalid type found");
        }

        NSString *substring = [displayText substringWithRange:displayPosition.textRange];
        XCTAssertEqualObjects(substring, textToFind);
    }
}

- (void)testLoadingDisplayEntities_urls
{
    NSArray *entities = [self.regularPresenter entityRangesForTweet:self.manyEntitiesTweet types:TWTRTweetEntityDisplayTypeURL];
    XCTAssertEqual(entities.count, 10);
}

- (void)testLoadingDisplayEntities_hashtags
{
    NSArray *entities = [self.regularPresenter entityRangesForTweet:self.manyEntitiesTweet types:TWTRTweetEntityDisplayTypeHashtag];
    XCTAssertEqual(entities.count, 5);
}

@end
