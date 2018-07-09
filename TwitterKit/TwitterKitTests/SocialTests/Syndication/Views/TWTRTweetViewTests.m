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
#import <TwitterCore/TWTRColorUtil.h>
#import <XCTest/XCTest.h>
#import "TWTRAttributedLabel.h"
#import "TWTRFixtureLoader.h"
#import "TWTRFontUtil.h"
#import "TWTRLikeButton.h"
#import "TWTRMultiImageViewController.h"
#import "TWTRNotificationCenter.h"
#import "TWTRProfileHeaderView.h"
#import "TWTRShareButton.h"
#import "TWTRTweet.h"
#import "TWTRTweetCashtagEntity.h"
#import "TWTRTweetContentView+Layout.h"
#import "TWTRTweetDelegationHelper.h"
#import "TWTRTweetHashtagEntity.h"
#import "TWTRTweetLabel.h"
#import "TWTRTweetMediaEntity.h"
#import "TWTRTweetMediaView.h"
#import "TWTRTweetUrlEntity.h"
#import "TWTRTweetUserMentionEntity.h"
#import "TWTRTweetView_Private.h"
#import "TWTRTweet_Private.h"
#import "TWTRTwitter_Private.h"
#import "TWTRUser.h"
#import "TWTRVideoViewController.h"
#import "TWTRViewUtil.h"

@interface TWTRTweetView () <TWTRProfileHeaderViewDelegate, TWTRAttributedLabelDelegate>

// Exposing this just for testing purposes
- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize;
- (void)shareButtonTapped;
- (void)backgroundTapped;

@end

@interface TWTRTweetViewTests : XCTestCase

@property (nonatomic) TWTRTweetView *compactTweetView;
@property (nonatomic) TWTRTweetView *regularTweetView;
@property (nonatomic) TWTRTweetPresenter *compactPresenter;
@property (nonatomic) TWTRTweetPresenter *regularPresenter;
@property (nonatomic) TWTRTweet *obamaTweet;
@property (nonatomic) TWTRTweet *retweet;
@property (nonatomic) TWTRTweet *videoTweet;
@property (nonatomic) TWTRTweet *quoteTweetWithPlayableVideo;
@property (nonatomic) TWTRTweet *quoteTweetWithoutMedia;
@property (nonatomic) id mockDelegate;
@property (nonatomic) NSTimeZone *userTimeZone;
@property (nonatomic) id mockNotificationCenter;

@end

@implementation TWTRTweetViewTests

- (void)setUp
{
    [super setUp];

    self.userTimeZone = [NSTimeZone defaultTimeZone];

    NSTimeZone *easternTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"EST"];
    [NSTimeZone setDefaultTimeZone:easternTimeZone];

    self.obamaTweet = [TWTRFixtureLoader obamaTweet];
    self.retweet = [TWTRFixtureLoader retweetTweet];
    self.videoTweet = [TWTRFixtureLoader videoTweet];
    self.quoteTweetWithoutMedia = [TWTRFixtureLoader quoteTweet];
    self.quoteTweetWithPlayableVideo = [TWTRFixtureLoader quoteTweetWithPlayableVideo];
    self.mockDelegate = [OCMockObject niceMockForProtocol:@protocol(TWTRTweetViewDelegate)];

    self.regularTweetView = [[TWTRTweetView alloc] initWithTweet:self.obamaTweet style:TWTRTweetViewStyleRegular];
    self.regularTweetView.delegate = self.mockDelegate;
    self.compactTweetView = [[TWTRTweetView alloc] initWithTweet:self.obamaTweet style:TWTRTweetViewStyleCompact];
    self.compactTweetView.delegate = self.mockDelegate;

    self.regularPresenter = [TWTRTweetPresenter presenterForStyle:TWTRTweetViewStyleRegular];
    self.compactPresenter = [TWTRTweetPresenter presenterForStyle:TWTRTweetViewStyleCompact];

    _mockNotificationCenter = OCMClassMock([TWTRNotificationCenter class]);
}

- (void)tearDown
{
    self.mockDelegate = nil;
    [self.mockNotificationCenter stopMocking];
    [NSTimeZone setDefaultTimeZone:self.userTimeZone];  // Return to timezone before tests were run
}

- (void)testDefaultInit
{
    TWTRTweetView *tweetView = [[TWTRTweetView alloc] init];

    XCTAssert(tweetView.tweet == nil);
    XCTAssert(tweetView.style == TWTRTweetViewStyleCompact);
    XCTAssert(tweetView.contentView.mediaView != nil);
}

#pragma mark - Text

- (void)testRegularTweetText
{
    XCTAssert([self.regularTweetView.contentView.tweetLabel.text isEqualToString:@"Four more years."]);
}

- (void)testCompactTweetText
{
    XCTAssert([self.compactTweetView.contentView.tweetLabel.text isEqualToString:@"Four more years."]);
}

- (void)testSetBackgroundColor
{
    UIColor *green = [UIColor greenColor];
    self.compactTweetView.backgroundColor = green;

    XCTAssert(self.compactTweetView.backgroundColor == green);
    XCTAssert(self.compactTweetView.contentView.tweetLabel.backgroundColor == green);
}

- (void)testEmptyTweetLabelBackgrounds
{
    [self.compactTweetView configureWithTweet:nil];

    XCTAssert(self.compactTweetView.contentView.tweetLabel.backgroundColor != self.compactTweetView.backgroundColor, @"If the tweet view is configured with an empty tweet, the text label backgrounds should stand out.");
}

- (void)testSetPrimaryTextColor
{
    UIColor *green = [UIColor greenColor];
    self.compactTweetView.primaryTextColor = green;

    XCTAssert(self.compactTweetView.contentView.tweetLabel.textColor == green);
}

- (void)testRegularMediaEntity
{
    XCTAssert(self.regularTweetView.contentView.mediaView);
    XCTAssert(self.regularTweetView.contentView.mediaView.hidden == NO);
}

- (void)testCompactMediaEntity
{
    XCTAssert(self.compactTweetView.contentView.mediaView);
    XCTAssert(self.compactTweetView.contentView.mediaView.hidden == NO);
}

- (void)testRegularAddingConstraints
{
    XCTAssertNoThrow([self.regularTweetView updateConstraints]);
}

- (void)testCompactAddingConstraints
{
    XCTAssertNoThrow([self.compactTweetView updateConstraints]);
}

- (void)testRegularDefaultSize
{
    CGSize desiredSize = [self.regularTweetView sizeThatFits:CGSizeMake(300, CGFLOAT_MAX)];
    XCTAssert(desiredSize.height > 80);
}

- (void)testManualSizeThatFitsForCompact
{
    for (int width = TWTRTweetViewMinWidth; width <= TWTRTweetViewMaxWidth; width += 10) {
        CGFloat autolayoutHeight = [self autolayoutHeightForTweetView:self.compactTweetView width:width];
        CGFloat calculatorHeight = [self calculatorHeightForTweetView:self.compactTweetView width:width];

        XCTAssertEqualWithAccuracy(calculatorHeight, autolayoutHeight, 1.5f);
    }
}

#pragma mark - Media

- (void)testMediaViewDelegateSetup
{
    XCTAssertTrue([self.compactTweetView conformsToProtocol:@protocol(TWTRTweetMediaViewDelegate)]);
    XCTAssertEqualObjects(self.compactTweetView.contentView.mediaView.delegate, self.compactTweetView);
    XCTAssertEqualObjects(self.regularTweetView.contentView.mediaView.delegate, self.regularTweetView);
}

- (void)testTapImage_usesPresenterViewController
{
    id mockPresenter = OCMPartialMock([[UIViewController alloc] init]);

    TWTRImagePresentationContext *context = [TWTRImagePresentationContext contextWithImage:[[UIImage alloc] init] mediaEntity:[[TWTRTweetMediaEntity alloc] init] parentTweetID:@""];
    id mockPresentationContext = OCMClassMock([TWTRImagePresentationContext class]);
    [[[mockPresentationContext stub] andReturn:context] contextWithImage:OCMOCK_ANY mediaEntity:OCMOCK_ANY parentTweetID:OCMOCK_ANY];

    OCMExpect([mockPresenter presentViewController:OCMOCK_ANY animated:YES completion:OCMOCK_ANY]);
    self.regularTweetView.presenterViewController = mockPresenter;
    [self.regularTweetView configureWithTweet:self.obamaTweet];

    self.regularTweetView.delegate = nil;
    [self invokeMediaTapOnTweetView:self.regularTweetView forEntity:self.obamaTweet.media.firstObject];
    self.regularTweetView.delegate = self.mockDelegate;

    OCMVerifyAll(mockPresenter);
}

#pragma mark - Delegate Method Tests

- (void)testTapImage_CallsDelegateWithProperParameters
{
    [self.regularTweetView configureWithTweet:self.obamaTweet];

    TWTRTweetMediaEntity *mediaEnity = self.obamaTweet.media.firstObject;
    UIImage *image = [self.regularTweetView.contentView.mediaView imageForMediaEntity:mediaEnity];
    NSURL *URL = [NSURL URLWithString:mediaEnity.mediaUrl];

    OCMExpect([self.mockDelegate tweetView:self.regularTweetView didTapImage:image withURL:URL]);

    [self invokeMediaTapOnTweetView:self.regularTweetView forEntity:mediaEnity];
    OCMVerifyAll(self.mockDelegate);
}

- (void)testTapImage_HasGestureRecognizerConnected
{
    XCTAssert([[[self.regularTweetView.contentView.mediaView gestureRecognizers] firstObject] isKindOfClass:[UITapGestureRecognizer class]]);
}

- (void)testSelectURL_notifiesDelegate
{
    TWTRTweetUrlEntity *entity = [TWTRFixtureLoader tweetURLEntity];

    [[self.mockDelegate expect] tweetView:self.regularTweetView didTapURL:[NSURL URLWithString:entity.url]];

    [self.regularTweetView attributedLabel:self.regularTweetView.contentView.tweetLabel didTapTweetURLEntity:entity];
    [self.mockDelegate verify];
}

- (void)testSelectURL_opensURL
{
    TWTRTweetUrlEntity *entity = [TWTRFixtureLoader tweetURLEntity];
    self.regularTweetView.delegate = nil;

    id mockApplication = [OCMockObject niceMockForClass:[UIApplication class]];
    [[[mockApplication stub] andReturn:mockApplication] sharedApplication];
    [[mockApplication expect] openURL:[NSURL URLWithString:entity.url]];

    [self.regularTweetView attributedLabel:nil didTapTweetURLEntity:entity];
    [mockApplication verify];
}

- (void)testGestureRecognizer_failsIfLinkAtPoint
{
    id mockTweetLabel = [OCMockObject partialMockForObject:self.regularTweetView.contentView.tweetLabel];
    [[[[mockTweetLabel stub] ignoringNonObjectArgs] andReturn:[TWTRTweetEntity new]] entityAtPoint:CGPointZero];

    BOOL shouldBegin = [self.regularTweetView gestureRecognizerShouldBegin:[[UITapGestureRecognizer alloc] init]];
    XCTAssert(shouldBegin == NO);
}

- (void)testGestureRecognizer_succeedsIfNoLinkAtPoint
{
    id mockTweetLabel = [OCMockObject partialMockForObject:self.regularTweetView.contentView.tweetLabel];
    [[[[mockTweetLabel stub] ignoringNonObjectArgs] andReturn:nil] entityAtPoint:CGPointZero];

    BOOL shouldBegin = [self.regularTweetView gestureRecognizerShouldBegin:[[UITapGestureRecognizer alloc] init]];
    XCTAssertTrue(shouldBegin);
}

- (void)testTapProfile_callsDelegateMethod
{
    [self.regularTweetView configureWithTweet:self.videoTweet];
    [[self.mockDelegate expect] tweetView:self.regularTweetView didTapProfileImageForUser:self.videoTweet.author];
    [self.regularTweetView profileHeaderView:self.regularTweetView.contentView.profileHeaderView didTapProfileForUser:self.videoTweet.author];

    [self.mockDelegate verify];
}

- (void)testTapBackground_callsDelegateMethod
{
    [self.regularTweetView configureWithTweet:self.videoTweet];
    [[self.mockDelegate expect] tweetView:self.regularTweetView didTapTweet:OCMOCK_ANY];

    [self.regularTweetView backgroundTapped];

    [self.mockDelegate verify];
}

- (void)testTapBackground_doesNotCallOpenURL
{
    [self.regularTweetView configureWithTweet:self.videoTweet];

    id appMock = OCMClassMock([UIApplication class]);
    [[[[appMock stub] classMethod] andReturn:appMock] sharedApplication];
    [[appMock reject] openURL:OCMOCK_ANY];

    [self.regularTweetView backgroundTapped];
    [appMock verify];

    [appMock stopMocking];
}

- (void)testTweetLabelLinkifiesCorrectLabels
{
    self.regularTweetView.contentView.tweetLabel.entityDisplayTypes = TWTRTweetEntityDisplayTypeURL;
    self.compactTweetView.contentView.tweetLabel.entityDisplayTypes = TWTRTweetEntityDisplayTypeURL;
}

#pragma mark - Notifications

- (void)testTapBackground_postsDidSelectNotification
{
    [self.regularTweetView configureWithTweet:self.videoTweet];
    OCMExpect([self.mockNotificationCenter postNotificationName:@"TWTRDidSelectTweetNotification" tweet:self.videoTweet userInfo:nil]);
    [self.regularTweetView backgroundTapped];
    OCMVerifyAll(self.mockNotificationCenter);
}

#pragma mark - Action Buttons

- (void)testShowActions_falseByDefault
{
    XCTAssert(self.regularTweetView.showActionButtons == NO);
}

- (void)testShareButton_hiddenForCompact
{
    XCTAssert(self.compactTweetView.shareButton.hidden == YES);
}

- (void)testShareButton_hiddenForRegular
{
    XCTAssert(self.regularTweetView.shareButton.hidden == YES);
}

- (void)testFavoriteButton_hiddenForCompact
{
    XCTAssert(self.compactTweetView.likeButton.hidden == YES);
}

- (void)testFavoriteButton_hiddenForRegular
{
    XCTAssert(self.regularTweetView.likeButton.hidden == YES);
}

#pragma mark - Border

- (void)testTweetView_ShouldHaveBorder
{
    XCTAssertEqual(self.compactTweetView.layer.borderWidth, 0.5);
}

- (void)testTweetView_ShouldHaveRoundedCorners
{
    XCTAssertEqual(self.compactTweetView.layer.cornerRadius, 4);
}

- (void)testTweetView_ShowsBorder
{
    XCTAssertEqual(self.compactTweetView.showBorder, YES);
}

- (void)testTweetView_LightBorderColor
{
    UIColor *borderColor = [UIColor colorWithCGColor:self.regularTweetView.layer.borderColor];
    CGFloat white, alpha;
    [borderColor getWhite:&white alpha:&alpha];

    XCTAssertEqualWithAccuracy(white, 0.0, 0.001);
    XCTAssertEqualWithAccuracy(alpha, 0.1, 0.001);
}

- (void)testTweetView_DarkBorderColor
{
    self.regularTweetView.theme = TWTRTweetViewThemeDark;
    UIColor *borderColor = [UIColor colorWithCGColor:self.regularTweetView.layer.borderColor];
    CGFloat white, alpha;
    [borderColor getWhite:&white alpha:&alpha];

    XCTAssertEqualWithAccuracy(white, 0.0, 0.001);
    XCTAssertEqualWithAccuracy(alpha, 0.5, 0.001);
}

#pragma mark - Performance Tests
// TODO: @kang These tests seem to be really flakey when run on CI box. Graph them instead of asserting
- (void)DISABLE_testTweetViewSizeThatFitsPerformance
{
    size_t iterations = 100;
    uint64_t averageTime = dispatch_benchmark(iterations, ^{
        @autoreleasepool {
            [self.regularTweetView sizeThatFits:CGSizeMake(300, CGFLOAT_MAX)];
        }
    });
    XCTAssert(averageTime <= 3200000);  // ns
}

- (void)DISABLE_testTweetViewAutolayoutSizingPerformance
{
    size_t iterations = 100;
    uint64_t averageTime = dispatch_benchmark(iterations, ^{
        uint32_t tweetViewWidthRange = TWTRTweetViewMaxWidth - TWTRTweetViewMinWidth;
        @autoreleasepool {
            CGFloat randomWidth = TWTRTweetViewMinWidth + arc4random_uniform(tweetViewWidthRange) + 1;
            NSLayoutConstraint *widthConstraint = [TWTRViewUtil constraintForAttribute:NSLayoutAttributeWidth onView:self.compactTweetView value:randomWidth];
            widthConstraint.active = YES;

            [self.compactTweetView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
            widthConstraint.active = NO;
        }
    });
    XCTAssert(averageTime <= 4200000);  // ns
}

#pragma mark - Play/Pause Video Methods

- (void)testPlayVideo_contentViewSetsShouldPlayVideoMuted
{
    id mockTweetView = OCMPartialMock(self.regularTweetView);
    id mockContentView = OCMPartialMock([mockTweetView contentView]);
    OCMStub([mockContentView playVideo]).andDo(nil);
    OCMStub([mockTweetView shouldPlayVideoMuted]).andReturn(YES);

    [mockTweetView configureWithTweet:self.videoTweet];
    [mockTweetView playVideo];

    XCTAssertEqual([mockTweetView shouldPlayVideoMuted], [mockContentView shouldPlayVideoMuted]);
}

- (void)testPlayVideo_attachmentContentViewSetsShouldPlayVideoMuted
{
    id mockTweetView = OCMPartialMock(self.regularTweetView);
    [mockTweetView configureWithTweet:self.quoteTweetWithPlayableVideo];
    OCMStub([mockTweetView shouldPlayVideoMuted]).andReturn(YES);

    id mockAttachmentContentView = OCMPartialMock([mockTweetView attachmentContentView]);
    OCMStub([mockAttachmentContentView playVideo]).andDo(nil);

    [mockTweetView playVideo];

    XCTAssertEqual([mockTweetView shouldPlayVideoMuted], [mockAttachmentContentView shouldPlayVideoMuted]);
}

- (void)testPlayVideo_quoteTweetWithPlayableMedia
{
    id mockTweetView = OCMPartialMock(self.regularTweetView);
    [mockTweetView configureWithTweet:self.quoteTweetWithPlayableVideo];

    id mockAttachmentContentView = OCMPartialMock([mockTweetView attachmentContentView]);
    OCMStub([mockAttachmentContentView playVideo]).andDo(nil);

    [mockTweetView playVideo];

    OCMVerify([mockAttachmentContentView playVideo]);
}

- (void)testPlayVideo_quoteTweetWithoutPlayableMedia
{
    id mockTweetView = OCMPartialMock(self.regularTweetView);
    [mockTweetView configureWithTweet:self.quoteTweetWithoutMedia];

    id mockAttachmentContentView = OCMPartialMock([mockTweetView attachmentContentView]);
    OCMReject([mockAttachmentContentView playVideo]);

    [mockTweetView playVideo];

    OCMVerifyAll(mockAttachmentContentView);
}

- (void)testPlayVideo_tweetWithPlayableMedia
{
    id mockTweetView = OCMPartialMock(self.regularTweetView);
    id mockContentView = OCMPartialMock([mockTweetView contentView]);
    OCMStub([mockContentView playVideo]).andDo(nil);

    [mockTweetView configureWithTweet:self.videoTweet];
    [mockTweetView playVideo];

    OCMVerify([mockContentView playVideo]);
}

- (void)testPlayVideo_tweetWithoutPlaybleMedia
{
    id mockTweetView = OCMPartialMock(self.regularTweetView);
    id mockContentView = OCMPartialMock([mockTweetView contentView]);
    OCMReject([mockContentView playVideo]);

    [mockTweetView configureWithTweet:self.obamaTweet];
    [mockTweetView playVideo];

    OCMVerifyAll(mockContentView);
}

- (void)testPauseVideo_quoteTweetWithPlayableMedia
{
    id mockTweetView = OCMPartialMock(self.regularTweetView);
    [mockTweetView configureWithTweet:self.quoteTweetWithPlayableVideo];

    id mockAttachmentContentView = OCMPartialMock([mockTweetView attachmentContentView]);
    OCMStub([mockAttachmentContentView pauseVideo]).andDo(nil);

    [mockTweetView pauseVideo];

    OCMVerify([mockAttachmentContentView pauseVideo]);
}

- (void)testPauseVideo_quoteTweetWithoutPlayableMedia
{
    id mockTweetView = OCMPartialMock(self.regularTweetView);
    [mockTweetView configureWithTweet:self.quoteTweetWithoutMedia];

    id mockAttachmentContentView = OCMPartialMock([mockTweetView attachmentContentView]);
    OCMReject([mockAttachmentContentView pauseVideo]);

    [mockTweetView pauseVideo];

    OCMVerifyAll(mockAttachmentContentView);
}

- (void)testPauseVideo_tweetWithPlayableMedia
{
    id mockTweetView = OCMPartialMock(self.regularTweetView);
    id mockContentView = OCMPartialMock([mockTweetView contentView]);

    OCMStub([mockContentView pauseVideo]).andDo(nil);

    [mockTweetView configureWithTweet:self.videoTweet];
    [mockTweetView pauseVideo];

    OCMVerify([mockContentView pauseVideo]);
}

- (void)testPauseVideo_tweetWithoutPlaybleMedia
{
    id mockTweetView = OCMPartialMock(self.regularTweetView);
    id mockContentView = OCMPartialMock([mockTweetView contentView]);

    OCMReject([mockContentView pauseVideo]);

    [mockTweetView configureWithTweet:self.obamaTweet];
    [mockTweetView pauseVideo];

    OCMVerifyAll(mockTweetView);
}

#pragma mark - TWTRTweetLabelDelegate Methods

- (void)testTapURL_notifiesDelegateWhenSet
{
    NSURL *url = [NSURL URLWithString:@"http://test.com"];
    OCMExpect([self.mockDelegate tweetView:OCMOCK_ANY didTapURL:url]);

    TWTRTweetUrlEntity *urlEntity = [[TWTRTweetUrlEntity alloc] initWithJSONDictionary:@{@"expanded_url": @"", @"display_url": @"", @"url": @"http://test.com"}];
    [self.compactTweetView attributedLabel:nil didTapTweetURLEntity:urlEntity];

    OCMVerifyAll(self.mockDelegate);
}

- (void)testTapURL_performDefaultAction
{
    self.compactTweetView.delegate = nil;
    id mockDelegationHelper = OCMClassMock([TWTRTweetDelegationHelper class]);
    OCMExpect([mockDelegationHelper performDefaultActionForTappingURL:OCMOCK_ANY]);

    TWTRTweetUrlEntity *urlEntity = [[TWTRTweetUrlEntity alloc] initWithJSONDictionary:@{@"expanded_url": @"", @"display_url": @"", @"url": @"http://test.com"}];
    [self.compactTweetView attributedLabel:nil didTapTweetURLEntity:urlEntity];

    OCMVerifyAll(mockDelegationHelper);
}

- (void)testTapHashtag_performDefaultAction
{
    TWTRTweetHashtagEntity *hashtagEntity = [[TWTRTweetHashtagEntity alloc] initWithJSONDictionary:@{@"text": @"#hashtag"}];

    id mockDelegationHelper = OCMClassMock([TWTRTweetDelegationHelper class]);
    OCMExpect([mockDelegationHelper performDefaultActionForTappingHashtag:hashtagEntity]);

    [self.compactTweetView attributedLabel:nil didTapTweetHashtagEntity:hashtagEntity];

    OCMVerifyAll(mockDelegationHelper);
}

- (void)testTapCashtag_performDefaultAction
{
    TWTRTweetCashtagEntity *cashtagEntity = [[TWTRTweetCashtagEntity alloc] initWithJSONDictionary:@{@"text": @"$twtr"}];

    id mockDelegationHelper = OCMClassMock([TWTRTweetDelegationHelper class]);
    OCMExpect([mockDelegationHelper performDefaultActionForTappingCashtag:cashtagEntity]);

    [self.compactTweetView attributedLabel:nil didTapTweetCashtagEntity:cashtagEntity];

    OCMVerifyAll(mockDelegationHelper);
}

- (void)testTapUserMention_performDefaultAction
{
    TWTRTweetUserMentionEntity *userEntity = [[TWTRTweetUserMentionEntity alloc] initWithJSONDictionary:@{@"id": @"5", @"name": @"Jim", @"screen_name": @"jim23"}];
    id mockDelegationHelper = OCMClassMock([TWTRTweetDelegationHelper class]);
    OCMExpect([mockDelegationHelper performDefaultActionForTappingUserMention:userEntity]);

    [self.compactTweetView attributedLabel:nil didTapTweetUserMentionEntity:userEntity];

    OCMVerifyAll(mockDelegationHelper);
}

#pragma mark - Helpers

- (CGFloat)autolayoutHeightForTweetView:(TWTRTweetView *)tweetView width:(CGFloat)width
{
    NSLayoutConstraint *widthConstraint = [TWTRViewUtil constraintForAttribute:NSLayoutAttributeWidth onView:tweetView value:width];
    widthConstraint.active = YES;

    CGSize autolayoutSize = [tweetView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];

    widthConstraint.active = NO;
    CGFloat autolayoutHeight = autolayoutSize.height;

    return autolayoutHeight;
}

- (CGFloat)calculatorHeightForTweetView:(TWTRTweetView *)tweetView width:(CGFloat)width
{
    CGSize calculatorSize = [tweetView sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    CGFloat calculatorHeight = calculatorSize.height;

    return calculatorHeight;
}

- (void)invokeMediaTapOnTweetView:(TWTRTweetView *)tweetView forEntity:(TWTRTweetMediaEntity *)mediaEntity
{
    [tweetView.contentView.mediaView presentDetailedMediaViewForMediaEntity:mediaEntity];
}

@end
