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

/**
 This header is private to the Twitter Kit SDK and not exposed for public SDK consumption
 */

#import "TWTRComposerNetworking.h"
#import "TWTRComposerViewController.h"
#import "TWTRSETweet.h"
#import "TWTRSETweetShareViewController.h"
#import "TWTRSETweetShareViewControllerDelegate.h"

NS_ASSUME_NONNULL_BEGIN
/**
 *  Internal class to wrap the shared TWTRSETweetShareViewController
 *  initialization methods and to pass along delegate method calls.
 *
 *  This is actually the class that is returned when a developer
 *  instantiates a TWTRComposerViewController and TWTRComposer.
 */
@interface TWTRSharedComposerWrapper : TWTRSETweetShareViewController <TWTRSETweetShareViewControllerDelegate, TWTRComposerNetworkingDelegate>

/**
 *  Delegate to notify of composer lifecycle events
 */
@property (nonatomic, weak) id<TWTRComposerViewControllerDelegate> delegate;

/**
 *  Reference to networking class for pending video tracking
 */
@property (nonatomic) TWTRComposerNetworking *networking;

/**
 *  User ID of currently-selected user.
 */
@property (nonatomic) NSString *currentUserID;

#pragma mark - Initialization

/**
 *  Initialize a composer with pre-filled text and an image or video attachment.
 *
 *  @param initialText (optional) Text with which to pre-fill the composer text.
 *  @param image (optional) Image to add as an attachment.
 *  @param videoURL (optional) Video URL to add as an attachment.
 *
 *  Note: Only one type of attachment (image or video) may be added.
 */
- (instancetype)initWithInitialText:(nullable NSString *)initialText image:(nullable UIImage *)image videoURL:(nullable NSURL *)videoURL;

/**
 *  Initialize a composer with pre-filled text and an image or video attachment.
 *
 *  @param initialText (optional) Text with which to pre-fill the composer text.
 *  @param image (optional) Image (or preview image) to add as an attachment.
 *  @param videoData (optional) NSData for video asset to add as an attachment.
 *
 *  Note: Preview image is required if videoData parameter is passed.
 */
- (instancetype)initWithInitialText:(nullable NSString *)initialText image:(nullable UIImage *)image videoData:(nullable NSData *)videoData;

@end

NS_ASSUME_NONNULL_END
