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
#import "TWTRFixtureLoader.h"
#import "TWTRImageTestHelper.h"
#import "TWTRTweet.h"
#import "TWTRTweetImageView.h"
#import "TWTRTweetMediaView.h"
#import "TWTRTweetMediaView_Private.h"
#import "TWTRTweet_Private.h"

@interface TWTRTweetMediaViewDelegateStub : NSObject <TWTRTweetMediaViewDelegate>
@property (nonatomic) BOOL shouldPresent;
@property (nonatomic, readonly) BOOL didAskToPresent;

@property (nonatomic, readonly) BOOL didAskForViewController;
@property (nonatomic, readonly) BOOL didPresentImageViewer;
@property (nonatomic, readonly) BOOL didPresentVideoPlayer;

@end

@interface TWTRTweetMediaViewTests : XCTestCase
@property (nonatomic) TWTRTweetMediaView *emptyMediaView;
@property (nonatomic) TWTRTweetMediaView *imageMediaView;
@property (nonatomic) TWTRTweetMediaView *videoMediaView;

@property (nonatomic) TWTRTweet *imageTweet;
@property (nonatomic) TWTRTweet *videoTweet;

@property (nonatomic) TWTRTweetMediaViewDelegateStub *delegateStub;

@end

@interface TWTRTweetMediaView ()
@property (nonatomic) NSMutableArray<TWTRTweetImageView *> *imageViews;
@end

@implementation TWTRTweetMediaViewTests

- (void)setUp
{
    [super setUp];
    self.emptyMediaView = [[TWTRTweetMediaView alloc] init];
    self.imageMediaView = [[TWTRTweetMediaView alloc] init];
    self.videoMediaView = [[TWTRTweetMediaView alloc] init];

    self.imageTweet = [TWTRFixtureLoader obamaTweet];
    self.videoTweet = [TWTRFixtureLoader videoTweet];

    [self.emptyMediaView configureWithTweet:[TWTRFixtureLoader gatesTweet] style:TWTRTweetViewStyleRegular];
    [self.imageMediaView configureWithTweet:self.imageTweet style:TWTRTweetViewStyleRegular];
    self.imageMediaView.imageViews[0].image = [TWTRImageTestHelper imageWithSize:CGSizeMake(100, 60)];
    [self.videoMediaView configureWithTweet:self.videoTweet style:TWTRTweetViewStyleRegular];

    self.delegateStub = [[TWTRTweetMediaViewDelegateStub alloc] init];
    self.delegateStub.shouldPresent = YES;
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testAspectRatio
{
    self.imageMediaView.aspectRatio = 2;
    self.imageMediaView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint constraintWithItem:self.imageMediaView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:100].active = YES;
    [self.imageMediaView layoutIfNeeded];

    CGRect bounds = self.imageMediaView.bounds;
    XCTAssertTrue(bounds.size.width > 0);
    XCTAssertTrue((bounds.size.height * 2) == bounds.size.width);
}

- (void)testCornerRadius_regular
{
    XCTAssert(self.imageMediaView.layer.cornerRadius == 0.0);
    XCTAssert(self.videoMediaView.layer.cornerRadius == 0.0);
}

- (void)testCornerRadius_compact
{
    [self.imageMediaView configureWithTweet:[TWTRFixtureLoader obamaTweet] style:TWTRTweetViewStyleCompact];
    [self.videoMediaView configureWithTweet:[TWTRFixtureLoader videoTweet] style:TWTRTweetViewStyleCompact];

    XCTAssert(self.imageMediaView.layer.cornerRadius == 4.0);
    XCTAssert(self.videoMediaView.layer.cornerRadius == 4.0);
}

#pragma mark - Delegate Methods

- (void)testDoesNotPresent_IfDelegateDeclines
{
    self.delegateStub.shouldPresent = NO;
    self.imageMediaView.delegate = self.delegateStub;

    XCTAssertFalse([self.imageMediaView presentDetailedMediaViewForMediaEntity:self.imageTweet.media.firstObject]);
    XCTAssertTrue(self.delegateStub.didAskToPresent);
}

- (void)testDoesPresentForImage
{
    XCTAssertTrue([self.imageMediaView presentDetailedMediaViewForMediaEntity:self.imageTweet.media.firstObject]);
}

- (void)testDoesPresentForVideo
{
    XCTAssertTrue([self.videoMediaView presentDetailedMediaViewForMediaEntity:self.videoTweet.media.firstObject]);
}

- (void)testPresentingAsksDelegateForViewController
{
    self.imageMediaView.delegate = self.delegateStub;
    [self.imageMediaView presentDetailedMediaViewForMediaEntity:self.imageTweet.media.firstObject];
    XCTAssertTrue(self.delegateStub.didAskForViewController);
}

- (void)testImagePresentationNotifiesDelegate
{
    self.imageMediaView.delegate = self.delegateStub;
    [self.imageMediaView presentDetailedMediaViewForMediaEntity:self.imageTweet.media.firstObject];
    XCTAssertTrue(self.delegateStub.didPresentImageViewer);
}

- (void)testVideoPresentationNotifiesDelegate
{
    self.videoMediaView.delegate = self.delegateStub;
    [self.videoMediaView presentDetailedVideoView];
    XCTAssertTrue(self.delegateStub.didPresentVideoPlayer);
}

- (void)testTapGestureRecognizerSetupCorrectly
{
    XCTAssertNotNil(self.imageMediaView.tapGestureRecognizer);
}

#pragma mark - imageAtIndex Tests

- (void)testImageAtIndex_emptyMedia
{
    UIImage *image = [self.emptyMediaView imageAtIndex:0];
    XCTAssertNil(image);
}

- (void)testImageAtIndex_singleArray
{
    UIImage *image = [self.imageMediaView imageAtIndex:0];
    XCTAssertNotNil(image);
}

- (void)testImageAtIndex_video
{
    UIImage *image = [self.videoMediaView imageAtIndex:0];
    XCTAssertNil(image);
}

- (void)testImageAtIndex_notFoundIndex
{
    UIImage *image = [self.imageMediaView imageAtIndex:NSNotFound];
    XCTAssertNil(image);
}

- (void)testImageAtIndex_indexHigherThanMaxIndex
{
    UIImage *image = [self.imageMediaView imageAtIndex:100];
    XCTAssertNil(image);
}

- (void)testImageAtIndex_negativeIndex
{
    UIImage *image = [self.imageMediaView imageAtIndex:-10];
    XCTAssertNil(image);
}

#pragma mark - Accessibility

- (void)testAccessibilityLabel
{
    XCTAssertTrue(self.emptyMediaView.isAccessibilityElement);
}

- (void)testAccessibilityLabel_noMedia
{
    XCTAssertEqualObjects(self.emptyMediaView.accessibilityLabel, @"");
}

- (void)testAccessibilityLabel_image
{
    XCTAssertEqualObjects(self.imageMediaView.accessibilityLabel, @"Image Attachment");
}

- (void)testAccessibilityLabel_video
{
    XCTAssertEqualObjects(self.videoMediaView.accessibilityLabel, @"Video Attachment");
}

@end

@implementation TWTRTweetMediaViewDelegateStub

- (BOOL)tweetMediaView:(TWTRTweetMediaView *)mediaView shouldPresentImageForMediaEntity:(TWTRTweetMediaEntity *)mediaEntity;
{
    _didAskToPresent = YES;
    return self.shouldPresent;
}

- (BOOL)tweetMediaView:(TWTRTweetMediaView *)mediaView shouldPresentVideoForConfiguration:(TWTRVideoPlaybackConfiguration *)videoConfiguration
{
    _didAskToPresent = YES;
    return self.shouldPresent;
}

- (UIViewController *)viewControllerToPresentFromTweetMediaView:(TWTRTweetMediaView *)mediaView
{
    _didAskForViewController = YES;
    return nil;
}

- (void)tweetMediaView:(TWTRTweetMediaView *)mediaView didPresentImageViewerForMediaEntity:(TWTRTweetMediaEntity *)mediaEntity
{
    _didPresentImageViewer = YES;
}

- (void)tweetMediaView:(TWTRTweetMediaView *)mediaView didPresentVideoPlayerForMediaEntity:(TWTRTweetMediaEntity *)mediaEntity
{
    _didPresentVideoPlayer = YES;
}

@end
