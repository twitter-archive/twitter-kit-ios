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

#import "TWTRSharedComposerWrapper.h"
#import <AVFoundation/AVFoundation.h>
#import <TwitterCore/TWTRAssertionMacros.h>
#import <TwitterCore/TWTRSessionStore.h>
#import <TwitterShareExtensionUI/TSETweet.h>
#import <TwitterShareExtensionUI/TSETweetAttachment.h>
#import <TwitterShareExtensionUI/TSETweetShareViewController.h>
#import <UIKit/UIKit.h>
#import "TWTRComposerAccount.h"
#import "TWTRComposerNetworking.h"
#import "TWTRComposerViewController.h"
#import "TWTRErrors.h"
#import "TWTRLocalizedResources.h"
#import "TWTRScribeSink.h"
#import "TWTRTwitterText.h"
#import "TWTRWordRange.h"
#import "Twitter.h"
#import "Twitter_Private.h"

NSArray *existingAccounts()
{
    NSMutableArray<TWTRComposerAccount *> *accounts = [NSMutableArray array];

    TWTRSessionStore *sessionStore = [Twitter sharedInstance].sessionStore;
    NSArray *currentSessions = [sessionStore existingUserSessions];
    for (TWTRSession *session in currentSessions) {
        [accounts addObject:accountFromSession(session)];
    }

    return accounts;
}

UIImage *videoThumbnail(NSURL *url)
{
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMake(1, 30);
    NSError *thumbnailError;
    CGImageRef thumbnailFrame = [generator copyCGImageAtTime:time actualTime:nil error:&thumbnailError];
    if (!thumbnailFrame) {
        NSLog(@"Could not retrieve thumbnail from video URL: %@", thumbnailError);
    }
    UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailFrame];

    return thumbnail;
}

@implementation TWTRSharedComposerWrapper

#pragma mark - Initialization

- (instancetype)initWithText:(NSString *)text image:(UIImage *)image attachment:(id<TSETweetAttachment>)attachment
{
    self.networking = [[TWTRComposerNetworking alloc] init];
    self.networking.delegate = self;

    // Networking & Accounts
    NSArray *accounts = existingAccounts();
    if (accounts.count == 0) {
        NSLog(@"[TwitterKit] Error: Composer created without any user accounts set up. It is the responsibility of the developer to ensure that Twitter Kit has a logged-in user before presenting a composer. See https://dev.twitter.com/twitterkit/ios/compose-tweets#presenting-a-basic-composer");
        [[Twitter sharedInstance].scribeSink didEncounterError:[TWTRErrors noAccountsError] withMessage:@"Composer created with no accounts."];
    }
    TSETweet *tweet = [self tweetWithText:text attachment:attachment image:image];

    // Shared Composer
    TSETweetShareConfiguration *config = [[TSETweetShareConfiguration alloc] initWithInitialTweet:tweet accounts:accounts initiallySelectedAccount:[accounts lastObject] geoTagging:nil autoCompletion:nil cardPreviewProvider:nil imageDownloader:[self imageLoader] localizedResources:[TWTRLocalizedResources class] networking:self.networking twitterText:[TWTRTwitterText class] wordRangeCalculator:[NSString class] scribe:nil delegate:self];

    self = [super initWithConfiguration:config];

    return self;
}

- (instancetype)initWithInitialText:(nullable NSString *)initialText image:(nullable UIImage *)image videoURL:(nullable NSURL *)videoURL
{
    if ([videoURL.scheme isEqualToString:@"assets-library"]) {
        NSLog(@"Incorrect video URL format was provided. Use key `UIImagePickerControllerMediaURL` from the `didFinishPickingMediaWithInfo:` info parameter.");
        return nil;
    }

    if (videoURL && image) {
        NSLog(@"Only one attachment type may be provided (image or video).");
        return nil;
    }

    [[Twitter sharedInstance].scribeSink didOpenComposer];

    if (videoURL) {
        image = videoThumbnail(videoURL);
    }

    if (self = [self initWithText:initialText image:image attachment:nil]) {
        if (videoURL) {
            NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
            // Must set this after [self init] is called
            [self.networking prepareVideoData:videoData];
        }
    }

    return self;
}

- (instancetype)initWithInitialText:(nullable NSString *)initialText image:(nullable UIImage *)image videoData:(nullable NSData *)videoData
{
    if (videoData && !image) {
        NSLog(@"The video doesn't have a preview image to show in composer.");
        return nil;
    }

    [[Twitter sharedInstance].scribeSink didOpenComposer];

    if (self = [self initWithText:initialText image:image attachment:nil]) {
        if (videoData) {
            [self.networking prepareVideoData:videoData];
        }
    }

    return self;
}

#pragma mark - Internal Methods

// Provide backup values for the image loader so tests don't need to call startWithConsumerKey:consumerSecret:
- (TWTRImageLoader *)imageLoader
{
    return [Twitter sharedInstance].imageLoader ?: [[TWTRImageLoader alloc] initWithSession:[NSURLSession sharedSession] cache:nil taskManager:[[TWTRImageLoaderTaskManager alloc] init]];
}

- (TSETweet *)tweetWithText:(NSString *)text attachment:(id<TSETweetAttachment>)attachment image:(UIImage *)image
{
    id<TSETweetAttachment> tweetAttachment = attachment ?: [self attachmentWithImage:image];

    return [[TSETweet alloc] initWithInReplyToTweetID:nil text:text attachment:tweetAttachment place:nil usernames:nil hashtags:nil];
}

- (TSETweetAttachmentImage *)attachmentWithImage:(UIImage *)image
{
    if (image) {
        return [[TSETweetAttachmentImage alloc] initWithImage:image];
    } else {
        return nil;
    }
}

#pragma mark - TSETweetShareViewControllerDelegate Protocol Methods

- (void)shareViewControllerWantsToCancelComposerWithPartiallyComposedTweet:(nonnull TSETweet *)partiallyComposedTweet
{
    [self dismissViewControllerAnimated:YES completion:nil];

    [[Twitter sharedInstance].scribeSink didTapCancelFromComposerWithSelectedUserID:self.currentUserID];

    // Reset the pending video data so that a second Tweet doesn't attempt
    // to send that data again (or send data for a cancelled Tweet)
    [self.networking cancelPendingVideoUpload];
    [self.delegate composerDidCancel:(TWTRComposerViewController *)self];
}

- (void)shareViewControllerDidFinishSendingTweet
{
    [self dismissViewControllerAnimated:YES completion:nil];

    [[Twitter sharedInstance].scribeSink didTapSendFromComposerWithSelectedUserID:self.currentUserID];
}

- (void)shareViewController:(TSETweetShareViewController *)shareViewController didSelectAccount:(id<TSEAccount>)account
{
    self.currentUserID = [NSString stringWithFormat:@"%llu", account.userID];
}

- (void)shareViewControllerPresentedWithNoAccounts
{
    NSLog(@"[TwitterKit] Error: composer presented with no available Twitter accounts.");
    [self dismissViewControllerAnimated:NO completion:^{
        NSError *error = [NSError errorWithDomain:TWTRErrorDomain code:0 userInfo:@{ NSLocalizedDescriptionKey: @"Error: There is no Twitter account." }];
        [self.delegate composerDidFail:(TWTRComposerViewController *)self withError:error];
    }];
}

#pragma mark - TWTRComposerNetworkingDelegate Protocol Methods

- (void)didFinishSendingTweet:(TWTRTweet *)tweet
{
    NSLog(@"Did successfully send Tweet: %@", tweet);
    [self.delegate composerDidSucceed:(TWTRComposerViewController *)self withTweet:tweet];
}

- (void)didAbortSendingTweetWithError:(NSError *)error
{
    NSLog(@"Did encounter error sending Tweet: %@", error);
    [self.delegate composerDidFail:(TWTRComposerViewController *)self withError:error];
}

@end
