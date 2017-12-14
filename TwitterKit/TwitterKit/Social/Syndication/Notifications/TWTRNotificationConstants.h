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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Constants for notifications that are posted from TwitterKit. These are posted on the default notification center.
 */

#pragma mark - Tweet Action Notifications

/**
 *  Notification indicating a Tweet was selected.
 */
FOUNDATION_EXTERN NSString *const TWTRDidSelectTweetNotification;

/**
 *  Notification indicating the Tweet detail view was shown for a given Tweet.
 */
FOUNDATION_EXTERN NSString *const TWTRDidShowTweetDetailNotification;

/**
 *  Notification indicating the user has selected to share Tweet.
 */
FOUNDATION_EXTERN NSString *const TWTRWillShareTweetNotification;

/**
 *  Notification indicating the Tweet was shared.
 */
FOUNDATION_EXTERN NSString *const TWTRDidShareTweetNotification;

/**
 *  Notification indicating the user has cancelled sharing of the Tweet.
 */
FOUNDATION_EXTERN NSString *const TWTRCancelledShareTweetNotification;

/**
 *  Notification indicating the user has liked a Tweet.
 */
FOUNDATION_EXTERN NSString *const TWTRDidLikeTweetNotification;

/**
 *  Notification indicating the user has unliked a Tweet.
 */
FOUNDATION_EXTERN NSString *const TWTRDidUnlikeTweetNotification;

#pragma mark - Media Notifications

/**
 *  Notification indicating the the playback state of a video
 *  has changed.
 *
 *  object: The UIView emitting these notifications
 *  userInfo: {TWTRVideoPlaybackStateKey: TWTRVideoStateValuePlaying}
 *            {TWTRVideoPlaybackStateKey: TWTRVideoStateValuePaused}
 *            {TWTRVideoPlaybackStateKey: TWTRVideoStateValueCompleted}
 */
FOUNDATION_EXTERN NSString *const TWTRVideoPlaybackStateChangedNotification;

/**
 *  User info key for the state of video playback.
 */
FOUNDATION_EXTERN NSString *const TWTRVideoPlaybackStateKey;

/**
 *  User info values for the state of video playback.
 */
FOUNDATION_EXTERN NSString *const TWTRVideoStateValuePlaying;
FOUNDATION_EXTERN NSString *const TWTRVideoStateValuePaused;
FOUNDATION_EXTERN NSString *const TWTRVideoStateValueCompleted;

#pragma mark - Presentation Notifications

/**
 *  Notification indicating that the video view controller will
 *  be presented.
 *
 *  object: The UIViewController hosting the video view
 *  userInfo: {TWTRVideoTypeKey: TWTRVideoTypeGIF}
 *            {TWTRVideoTypeKey: TWTRVideoTypeStandard}
 *            {TWTRVideoTypeKey: TWTRVideoTypeVine}
 */
FOUNDATION_EXTERN NSString *const TWTRWillPresentVideoNotification;

/**
 *  Notification indicating that the video view controller has
 *  been dismissed.
 *
 *  object: The UIViewController hosting the video view
 */
FOUNDATION_EXTERN NSString *const TWTRDidDismissVideoNotification;

/**
 *  The key to fetch the type of video being displayed in a
 *  TWTRVideoViewController.
 */
FOUNDATION_EXTERN NSString *const TWTRVideoTypeKey;

/**
 *  User info values for the type of video being displayed
 *  in a TWTRVideoViewController.
 */
FOUNDATION_EXTERN NSString *const TWTRVideoTypeGIF;
FOUNDATION_EXTERN NSString *const TWTRVideoTypeStandard;
FOUNDATION_EXTERN NSString *const TWTRVideoTypeVine;

#pragma mark - Notification User Info

/**
 *  User info key to fetch the associated Tweet in the notification.
 */
FOUNDATION_EXTERN NSString *const TWTRNotificationInfoTweet;

/**
 * A notification which is posted when a user logs out of Twitter.
 * The notification will contain a user dictionary which contains
 * the user id which is being logged out. Note, this notification may
 * be posted as a result of starting the Twitter object.
 */
FOUNDATION_EXTERN NSString *const TWTRUserDidLogOutNotification;
FOUNDATION_EXTERN NSString *const TWTRLoggedOutUserIDKey;

/**
 * A notification which is posted when a user logs in to Twitter.
 * The notification will contain a user dictionary which contains
 * the user id which is being logged in. Note, this notification may
 * be posted as a result of starting the Twitter object.
 */
FOUNDATION_EXTERN NSString *const TWTRUserDidLogInNotification;
FOUNDATION_EXTERN NSString *const TWTRLoggedInUserIDKey;

NS_ASSUME_NONNULL_END
