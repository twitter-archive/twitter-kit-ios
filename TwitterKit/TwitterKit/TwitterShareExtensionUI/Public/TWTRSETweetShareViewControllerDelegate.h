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

@import Foundation.NSObject;

@class TWTRSETweet;
@protocol TWTRSEAccount;

NS_ASSUME_NONNULL_BEGIN

/**
 Methods invoked by `TWTRSETweetShareViewController` to notify about events occured in the UI.
 All of these methods are called in the main thread.
 */
@protocol TWTRSETweetShareViewControllerDelegate <NSObject>

/**
 Called when the user has tapped on the tweet button and the request callback was called with .success or .willPostAsynchronously
 The view controller is not dismissed automatically, you must call `dismissViewController`.

 */
- (void)shareViewControllerDidFinishSendingTweet;

/**
 Called when the user taps on the "Cancel" button on the composer.
 The view controller is not dismissed automatically, you must call `dismissViewController`.
 This gives you the oportunity to implement another behavior, like presenting a confirmation alert, or offer the option
 to safe a draft.

 @param partiallyComposedTweet The contents of the Tweet up the moment the user cancelled. This can be used to be saved as a draft.
 */
- (void)shareViewControllerWantsToCancelComposerWithPartiallyComposedTweet:(TWTRSETweet *)partiallyComposedTweet;

/**
 Called when the composer UI is presented passing an empty array of accounts.
 An alert is presented to the user informing them of this error.
 The view controller is not dismissed automatically, you must call `dismissViewController` when this method is called.

 */
- (void)shareViewControllerPresentedWithNoAccounts;

@optional

/**
 Called when the user changes the currently selected account.

 @param account The account that the user selected. This will be one of the objects proviced when
 the controller was instantiated.
 */
- (void)shareViewControllerDidSelectAccount:(id<TWTRSEAccount>)account;

@end

NS_ASSUME_NONNULL_END
