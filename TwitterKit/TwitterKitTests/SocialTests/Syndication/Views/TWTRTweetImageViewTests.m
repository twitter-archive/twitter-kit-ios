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
#import <TwitterKit/TWTRKit.h>
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TWTRFixtureLoader.h"
#import "TWTRMediaEntityDisplayConfiguration.h"
#import "TWTRPlayIcon.h"
#import "TWTRTweet.h"
#import "TWTRTweetImageView.h"
#import "TWTRTweetMediaEntity.h"
#import "TWTRTweetMediaView.h"
#import "TWTRTweetPresenter.h"
#import "TWTRTweet_Private.h"
#import "TWTRViewUtil.h"

@interface TWTRTweetImageViewTests : XCTestCase

@property (nonatomic) TWTRTweetMediaView *compactImage;
@property (nonatomic) TWTRTweetMediaView *regularImage;
@property (nonatomic) TWTRTweet *tweet;
@property (nonatomic) TWTRTweet *tweetWithVideo;

@end

@interface TWTRTweetImageView ()
@property (nonatomic, readonly) TWTRMediaEntityDisplayConfiguration *mediaConfiguration;
@end

@interface TWTRTweetMediaView ()

@property (nonatomic, assign) TWTRTweetViewStyle style;
@property (nonatomic) NSMutableArray<TWTRTweetImageView *> *imageViews;
- (TWTRTweetImageView *)videoThumbnail;

@end

@implementation TWTRTweetImageViewTests

- (void)setUp
{
    [super setUp];

    TWTRTweetPresenter *compactPresenter = [TWTRTweetPresenter presenterForStyle:TWTRTweetViewStyleCompact];
    TWTRTweetPresenter *regularPresenter = [TWTRTweetPresenter presenterForStyle:TWTRTweetViewStyleRegular];

    self.compactImage = [[TWTRTweetMediaView alloc] init];
    self.regularImage = [[TWTRTweetMediaView alloc] init];

    self.tweet = [TWTRFixtureLoader obamaTweet];
    self.tweetWithVideo = [TWTRFixtureLoader videoTweet];

    [self.compactImage configureWithTweet:self.tweet style:TWTRTweetViewStyleCompact];
    [self.regularImage configureWithTweet:self.tweet style:TWTRTweetViewStyleRegular];

    self.compactImage.aspectRatio = [compactPresenter mediaAspectRatioForTweet:self.tweet];
    self.regularImage.aspectRatio = [regularPresenter mediaAspectRatioForTweet:self.tweet];

    [self.compactImage updateConstraints];
}

- (void)testStyleSet
{
    XCTAssert(self.compactImage.style == TWTRTweetViewStyleCompact);
    XCTAssert(self.regularImage.style == TWTRTweetViewStyleRegular);
}

- (void)testCompressedSize
{
    // make sure the obamaTweet fixture's dimensions don't change,
    // since we have to manually generate an image with the same
    // dimensions to do the actual test
    XCTAssertEqualWithAccuracy(self.regularImage.imageViews[0].mediaConfiguration.imageSize.width, 340, 0.01);
    XCTAssertEqualWithAccuracy(self.regularImage.imageViews[0].mediaConfiguration.imageSize.height, 226, 0.01);

    // at the moment, we don't stub network requests, so we have to manually set the image
    // after calling configureWithMediaEntity.
    // WARNING: this is also a potential race condition. The alternatives to this aren't great.
    self.regularImage.imageViews[0].image = [[self class] blankImageWithSize:CGSizeMake(340, 226)];

    // and here's what we actually want to test!
    CGSize size = [self.regularImage systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    CGSize imageViewSize = [self.regularImage systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];

    XCTAssertEqualWithAccuracy(size.width, 340, 0.01);
    XCTAssertEqualWithAccuracy(size.height, 226, 0.01);
    XCTAssertEqualWithAccuracy(imageViewSize.width, 340, 0.01);
    XCTAssertEqualWithAccuracy(imageViewSize.height, 226, 0.01);
}

- (void)testRegularAspectRatio
{
    XCTAssertEqualWithAccuracy([self.regularImage aspectRatio], 340.0 / (226.0 + 12), 0.1, @"Regular should have the same aspect ratio as the image (plus padding).");
}

#pragma mark - Video

- (void)testPlayIcon_showsForVideo
{
    [self.compactImage configureWithTweet:self.tweetWithVideo style:TWTRTweetViewStyleCompact];
    UIView *playIcon;
    for (UIView *subview in [self.regularImage.videoThumbnail subviews]) {
        if ([subview isKindOfClass:NSClassFromString(@"TWTRPlayIcon")]) {
            playIcon = subview;
        }
    }

    XCTAssert(CGPointEqualToPoint(playIcon.center, self.compactImage.center));
}

- (void)testPlayIcon_hiddenForNonVideo
{
    [self.compactImage configureWithTweet:self.tweet style:TWTRTweetViewStyleCompact];

    UIView *playIcon;
    for (UIView *subview in [self.regularImage.videoThumbnail subviews]) {
        if ([subview isKindOfClass:NSClassFromString(@"TWTRPlayIcon")]) {
            playIcon = subview;
        }
    }

    XCTAssertNil(playIcon);
}

#pragma mark - Test helpers

+ (UIImage *)blankImageWithSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
