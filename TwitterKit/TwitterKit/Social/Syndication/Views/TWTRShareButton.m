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

#import "TWTRShareButton.h"
#import <TwitterCore/TWTRColorUtil.h>
#import <TwitterCore/TWTRUtils.h>
#import "TWTRFontUtil.h"
#import "TWTRImages.h"
#import "TWTRNotificationCenter.h"
#import "TWTRNotificationConstants.h"
#import "TWTRTranslationsUtil.h"
#import "TWTRTweet.h"
#import "TWTRTweetShareItemProvider.h"
#import "TWTRTweetView_Private.h"
#import "TWTRTwitter_Private.h"

@interface TWTRShareButton ()

@property (nonatomic) TWTRTweet *tweet;
@property (nonatomic) TWTRShareButtonSize shareButtonSize;

@end

@implementation TWTRShareButton

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _shareButtonSize = TWTRShareButtonSizeRegular;
        [self shareButtonCommonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame shareButtonSize:TWTRShareButtonSizeRegular];
}

- (instancetype)initWithShareButtonSize:(TWTRShareButtonSize)size
{
    return [self initWithFrame:CGRectZero shareButtonSize:size];
}

- (instancetype)initWithFrame:(CGRect)frame shareButtonSize:(TWTRShareButtonSize)size
{
    self = [super initWithFrame:frame];
    if (self) {
        _shareButtonSize = size;
        [self shareButtonCommonInit];
    }
    return self;
}

- (void)shareButtonCommonInit
{
    self.accessibilityLabel = TWTRLocalizedString(@"tw__tweet_share_button");

    UIImage *image;
    switch (self.shareButtonSize) {
        case TWTRShareButtonSizeRegular:
            image = [TWTRImages shareImage];
            break;
        case TWTRShareButtonSizeLarge:
            image = [TWTRImages shareImageLarge];
            break;
    }
    [self setImage:image forState:UIControlStateNormal];
    [self addTarget:self action:@selector(shareButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.presenterViewController = [TWTRUtils topViewController];
}

- (void)configureWithTweet:(TWTRTweet *)tweet
{
    self.tweet = tweet;
}

- (void)setPresenterViewController:(UIViewController *)presenterViewController
{
    _presenterViewController = presenterViewController ?: [TWTRUtils topViewController];
}

#pragma mark - Sharing

- (void)shareButtonTapped
{
    if (!self.tweet) {
        return;
    }

    [TWTRNotificationCenter postNotificationName:TWTRWillShareTweetNotification tweet:self.tweet userInfo:nil];

    TWTRTweetShareItemProvider *shareItemProvider = [[TWTRTweetShareItemProvider alloc] initWithTweet:self.tweet];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[shareItemProvider] applicationActivities:nil];
    activityVC.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        NSString *notificationName = completed ? TWTRDidShareTweetNotification : TWTRCancelledShareTweetNotification;
        [TWTRNotificationCenter postNotificationName:notificationName tweet:self.tweet userInfo:nil];
    };

    [self presentActivityViewController:activityVC];
}

- (void)presentActivityViewController:(UIActivityViewController *)activityViewController
{
    if ([self shouldPresentShareSheetUsingPopover]) {
        activityViewController.modalPresentationStyle = UIModalPresentationPopover;
        [self.presenterViewController presentViewController:activityViewController animated:YES completion:nil];

        UIPopoverPresentationController *presentationController = [activityViewController popoverPresentationController];
        presentationController.sourceRect = self.bounds;
        presentationController.sourceView = self;
    } else {
        [self.presenterViewController presentViewController:activityViewController animated:YES completion:nil];
    }
}

#pragma mark - Helpers

- (BOOL)shouldPresentShareSheetUsingPopover
{
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);
}

@end
