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
@class TWTRTimelineViewController;

NS_ASSUME_NONNULL_BEGIN

@protocol TWTRTimelineDelegate <NSObject>

@optional

/**
 *  The Timeline started loading new Tweets. This would be an
 *  appropriate place to begin showing a loading indicator.
 *
 *  @param timeline Timeline controller providing the updates
 */
- (void)timelineDidBeginLoading:(TWTRTimelineViewController *)timeline;

/**
 *  The Timeline has finished loading more Tweets.
 *
 *  If Tweets array is `nil`, you should check the error object
 *  for a description of the failure case.
 *
 *  @param timeline Timeline displaying loaded Tweets
 *  @param tweets   Tweet objects loaded from the network
 *  @param error    Error object describing details of failure
 */
- (void)timeline:(TWTRTimelineViewController *)timeline didFinishLoadingTweets:(nullable NSArray *)tweets error:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
