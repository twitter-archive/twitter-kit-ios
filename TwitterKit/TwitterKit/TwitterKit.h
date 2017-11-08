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

#import <AVFoundation/AVFoundation.h>
#import <Accounts/Accounts.h>
#import <CoreMedia/CoreMedia.h>
#import <Foundation/Foundation.h>
#import <TwitterCore/TwitterCore.h>
#import <UIKit/UIKit.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 90000
#error "TwitterKit doesn't support iOS 8.x and lower. Please, change your minimum deployment target to iOS 9.0"
#endif

#import "TWTRAPIClient.h"
#import "TWTRCollectionTimelineDataSource.h"
#import "TWTRComposer.h"
#import "TWTRComposerViewController.h"
#import "TWTRJSONConvertible.h"
#import "TWTRListTimelineDataSource.h"
#import "TWTRLogInButton.h"
#import "TWTRMediaEntitySize.h"
#import "TWTRMoPubAdConfiguration.h"
#import "TWTRMoPubNativeAdContainerView.h"
#import "TWTRNotificationConstants.h"
#import "TWTROAuthSigning.h"
#import "TWTRSearchTimelineDataSource.h"
#import "TWTRTimelineCursor.h"
#import "TWTRTimelineDataSource.h"
#import "TWTRTimelineDelegate.h"
#import "TWTRTimelineFilter.h"
#import "TWTRTimelineType.h"
#import "TWTRTimelineViewController.h"
#import "TWTRTweet.h"
#import "TWTRTweetCashtagEntity.h"
#import "TWTRTweetEntity.h"
#import "TWTRTweetHashtagEntity.h"
#import "TWTRTweetTableViewCell.h"
#import "TWTRTweetUrlEntity.h"
#import "TWTRTweetUserMentionEntity.h"
#import "TWTRTweetView.h"
#import "TWTRTweetViewDelegate.h"
#import "TWTRVideoPlaybackState.h"
#import "TWTRUser.h"
#import "TWTRUserTimelineDataSource.h"
#import "TWTRVideoMetaData.h"
#import "Twitter.h"
