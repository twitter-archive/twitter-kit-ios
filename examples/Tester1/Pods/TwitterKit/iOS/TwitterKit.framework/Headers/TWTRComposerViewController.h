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

#import <UIKit/UIKit.h>
@class TWTRTweet;
@protocol TWTRComposerViewControllerDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Composer interface to allow users to compose & send Tweets from
 *  inside an app.
 *
 *  It is the developers' responsibility to ensure that there exists a
 *  logged in Twitter user before creating a `TWTRComposerViewController`.
 *
 *  See: https://dev.twitter.com/twitterkit/ios/compose-tweets#presenting-a-basic-composer
 *
 *  Initial Text
 *  If you wish to add default mentions to the Tweet, add them to the
 *  beginning of `initialText`.
 *
 *  If you wish to add default hashtags or links to the Tweet,
 *  add them at the end of `initialText`.
 */
@interface TWTRComposerViewController : UIViewController

/**
 * The delegate for this composer view controller.
 */
@property (nonatomic, weak) id<TWTRComposerViewControllerDelegate> delegate;

/**
 *  Create an empty composer view controller. The developer must handle ensuring
 *  that a logged in Twitter user exists before creating this controller.
 */
+ (instancetype)emptyComposer;

/**
 *  Initialize a composer with pre-filled text and an image or video attachment.
 *  Requires a logged in Twitter user.
 *
 *  @param initialText (optional) Text with which to pre-fill the composer text.
 *  @param image (optional) Image to add as an attachment.
 *  @param videoURL (optional) Video URL to add as an attachment. Of the form of `assets-library`.
 *
 *  Note: Only one type of attachment (image or video) may be added.
 */
- (instancetype)initWithInitialText:(nullable NSString *)initialText image:(nullable UIImage *)image videoURL:(nullable NSURL *)videoURL;

/**
 *  Initialize a composer with pre-filled text and an image or video attachment.
 *
 *  @param initialText (optional) Text with which to pre-fill the composer text.
 *  @param image (required) Image (or preview image) to add as an attachment.
 *  @param videoData (optional) NSData for video asset to add as an attachment.
 *
 *  Note: Preview image is required if videoData parameter is passed.
 */
- (instancetype)initWithInitialText:(nullable NSString *)initialText image:(nullable UIImage *)image videoData:(nullable NSData *)videoData;

- (instancetype)init NS_UNAVAILABLE;

@end

@protocol TWTRComposerViewControllerDelegate <NSObject>

@optional
/**
 * Called when the user taps the cancel button. This method will be called after the view controller is dismissed.
 */
- (void)composerDidCancel:(TWTRComposerViewController *)controller;

/**
 * Called when the user successfully sends a Tweet. The resulting Tweet object is returned.
 * This method is called after the view controller is dimsissed and the API response is
 * received.
 */
- (void)composerDidSucceed:(TWTRComposerViewController *)controller withTweet:(TWTRTweet *)tweet;

/**
 * This method is called if the composer is not able to send the Tweet.
 * The view controller will not be dismissed automatically if this method is called.
 */
- (void)composerDidFail:(TWTRComposerViewController *)controller withError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
