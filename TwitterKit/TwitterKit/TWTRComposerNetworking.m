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

#import "TWTRComposerNetworking.h"
#import <TwitterCore/TWTRSessionStore.h>
#import "TWTRAPIClient.h"
#import "TWTRComposerAccount.h"
#import "TWTRComposerUser.h"
#import "TWTRTwitter_Private.h"

@interface TWTRComposerNetworking ()

@property (nonatomic) TWTRAPIClient *client;
@property (nonatomic) NSData *pendingVideoData;

@end

@implementation TWTRComposerNetworking

#pragma mark - Internal Methods

- (TWTRAPIClient *)clientWithAccount:(TWTRComposerAccount *)account
{
    if (self.client) {
        return self.client;
    } else {
        return [[TWTRAPIClient alloc] initWithUserID:[account userIDString]];
    }
}

- (NSString *)textForTweet:(TWTRSETweet *)tweet
{
    // Add URL to Tweet text if the attachment was a URL (from an app card)
    if ([tweet.attachment respondsToSelector:@selector(URL)]) {
        TWTRSETweetAttachmentURL *urlAttachment = tweet.attachment;
        return [NSString stringWithFormat:@"%@ %@", tweet.text, urlAttachment.URL.absoluteString];
    }

    return tweet.text;
}

- (UIImage *)imageForTweet:(TWTRSETweet *)tweet
{
    // Return image if attachment has an image
    if ([tweet.attachment respondsToSelector:@selector(image)]) {
        return [(TWTRSETweetAttachmentImage *)tweet.attachment image];
    }

    return nil;
}

#pragma mark - Pending Video Handling

- (void)prepareVideoData:(NSData *)videoData
{
    self.pendingVideoData = videoData;
}

- (void)cancelPendingVideoUpload
{
    self.pendingVideoData = nil;
}

#pragma mark - TWTRSENetworking Protocol Methods

- (void)sendTweet:(TWTRSETweet *)tweet fromAccount:(TWTRComposerAccount *)account completion:(TWTRSENetworkingTweetSendCompletion)completion
{
    __weak typeof(self) weakSelf = self;
    TWTRSendTweetCompletion sendCompletion = ^(TWTRTweet *resultTweet, NSError *error) {
        BOOL success = (resultTweet != nil);

        // For TWTRComposerViewControllerDelegate
        if (success) {
            [weakSelf.delegate didFinishSendingTweet:resultTweet];
        } else {
            [weakSelf.delegate didAbortSendingTweetWithError:error];
        }

        // Next attempted send should not use previous video data
        [weakSelf cancelPendingVideoUpload];

        // For TWTRSETweetShareViewControllerDelegate
        TWTRSENetworkingResult networkResult = success ? TWTRSENetworkingResultSuccess : TWTRSENetworkingResultError;
        completion(networkResult);
    };

    NSString *text = [self textForTweet:tweet];
    TWTRAPIClient *client = [self clientWithAccount:account];
    if (self.pendingVideoData) {
        [client sendTweetWithText:text videoData:self.pendingVideoData completion:sendCompletion];
    } else {
        UIImage *image = [self imageForTweet:tweet];
        if (image) {
            [client sendTweetWithText:text image:image completion:sendCompletion];
        } else {
            [client sendTweetWithText:text completion:sendCompletion];
        }
    }
}

- (void)loadHydratedTwitterUserForAccount:(TWTRComposerAccount *)account completion:(TWTRSENetworkingHydratedTwitterUserLoadCompletion)completion
{
    TWTRAPIClient *client = [self clientWithAccount:account];
    [client loadUserWithID:[account userIDString]
                completion:^(TWTRUser *_Nullable user, NSError *_Nullable error) {
                    TWTRComposerUser *composeUser;
                    if (user != nil) {
                        composeUser = userFromUser(user);
                    }
                    completion(composeUser);
                }];
}

@end
