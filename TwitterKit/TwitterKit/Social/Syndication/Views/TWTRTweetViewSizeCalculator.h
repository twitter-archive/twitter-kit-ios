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

#import <UIKit/UIKit.h>
#import "TWTRTweetView.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Size calculator for compact Tweet views
 */
@interface TWTRTweetViewSizeCalculator : NSObject

/**
 *  Returns how tall the Tweet view should be.
 *
 *  Uses the system to calculate the Auto Layout height. This is the same as
 *  calling sizeThatFits: on a cached TWTRTweetView instance to let the system
 *  calculate how tall the resulting view will be including the image, Retweet
 *  view, and optional action buttons.
 *
 *  @param tweet           the Tweet
 *  @param style           the style of the Tweet view
 *  @param fittingWidth    the width of the Tweet
 *  @param showingActions  whether the Tweet view will be displaying actions
 *
 *  @return the calculated height of the Tweet view
 */
+ (CGFloat)heightForTweet:(TWTRTweet *)tweet style:(TWTRTweetViewStyle)style fittingWidth:(CGFloat)width showingActions:(BOOL)showActions;

@end

NS_ASSUME_NONNULL_END
