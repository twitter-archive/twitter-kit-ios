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
#import <TwitterCore/TWTRUtils.h>
#import <XCTest/XCTest.h>
#import "TWTRFixtureLoader.h"
#import "TWTRImageTestHelper.h"
#import "TWTRImageViewController.h"
#import "TWTRTweet.h"
#import "TWTRTweetMediaEntity.h"
#import "TWTRTweet_Private.h"
#import "TWTRTwitter_Private.h"

@interface TWTRImageViewController ()

- (void)shareTapped;
- (BOOL)shouldPresentShareSheetUsingPopover;

@end

@interface UIActivityViewController ()

- (NSArray *)activityItems;

@end

@interface TWTRImageViewControllerTests : XCTestCase

@property (nonatomic) UIImage *landscapeImage;
@property (nonatomic) TWTRImageViewController *imageViewController;
@property (nonatomic) TWTRTweet *mediaTweet;
@property (nonatomic) TWTRTweetMediaEntity *mediaEntity;

@end

@implementation TWTRImageViewControllerTests

- (void)setUp
{
    [super setUp];

    self.landscapeImage = [TWTRImageTestHelper imageWithSize:CGSizeMake(800, 500)];
    self.mediaTweet = [TWTRFixtureLoader obamaTweet];
    self.mediaEntity = self.mediaTweet.media.firstObject;
    self.imageViewController = [[TWTRImageViewController alloc] initWithImage:self.landscapeImage mediaEntity:self.mediaEntity parentTweetID:self.mediaTweet.tweetID];
}

@end
