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

#import "TWTRNotificationConstants.h"

#pragma mark - Tweet Notifications

NSString *const TWTRDidSelectTweetNotification = @"TWTRDidSelectTweetNotification";
NSString *const TWTRDidShowTweetDetailNotification = @"TWTRDidShowTweetDetailNotification";
NSString *const TWTRWillShareTweetNotification = @"TWTRWillShareTweetNotification";
NSString *const TWTRDidShareTweetNotification = @"TWTRDidShareTweetNotification";
NSString *const TWTRCancelledShareTweetNotification = @"TWTRCancelledShareTweetNotification";
NSString *const TWTRDidLikeTweetNotification = @"TWTRDidLikeTweetNotification";
NSString *const TWTRDidUnlikeTweetNotification = @"TWTRDidUnlikeTweetNotification";

#pragma mark - Media Notifications

NSString *const TWTRVideoPlaybackStateChangedNotification = @"TWTRVideoPlaybackStateChangedNotification";
NSString *const TWTRVideoPlaybackStateKey = @"TWTRVideoPlaybackStateKey";
NSString *const TWTRVideoStateValuePlaying = @"TWTRVideoStateValuePlaying";
NSString *const TWTRVideoStateValuePaused = @"TWTRVideoStateValuePaused";
NSString *const TWTRVideoStateValueCompleted = @"TWTRVideoStateValueCompleted";

#pragma mark - Presentation Notifications

NSString *const TWTRWillPresentVideoNotification = @"TWTRWillPresentVideoNotification";
NSString *const TWTRDidDismissVideoNotification = @"TWTRDidDismissVideoNotification";

NSString *const TWTRVideoTypeKey = @"TWTRVideoTypeKey";

NSString *const TWTRVideoTypeGIF = @"TWTRVideoTypeGIF";
NSString *const TWTRVideoTypeStandard = @"TWTRVideoTypeStandard";
NSString *const TWTRVideoTypeVine = @"TWTRVideoTypeVine";

#pragma mark - Notification User Info

NSString *const TWTRNotificationInfoTweet = @"tweet";

#pragma mark - Log In/Out Notifications
NSString *const TWTRUserDidLogOutNotification = @"TWTRUserDidLogOutNotification";
NSString *const TWTRLoggedOutUserIDKey = @"TWTRLoggedOutUserIDKey";

NSString *const TWTRUserDidLogInNotification = @"TWTRUserDidLogInNotification";
NSString *const TWTRLoggedInUserIDKey = @"TWTRLoggedInUserIDKey";
