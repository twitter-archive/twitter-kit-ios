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

@interface TWTRFontUtil : NSObject

#pragma mark - Tweet view
+ (UIFont *)fullnameFont;
+ (UIFont *)retweetedByAttributionLabelFont;
+ (UIFont *)timestampFontForStyle:(TWTRTweetViewStyle)style;
+ (UIFont *)tweetFontForStyle:(TWTRTweetViewStyle)style;
+ (UIFont *)usernameFontForStyle:(TWTRTweetViewStyle)style;

#pragma mark - Ads
+ (UIFont *)adBodyFont;
+ (UIFont *)adTitleFont;

#pragma mark - General
+ (CGFloat)defaultFontSize;
+ (CGFloat)minimumLineHeightForFont:(UIFont *)font traitCollection:(UITraitCollection *)traitCollection;
+ (UIFont *)largeBoldSystemFont;
+ (UIFont *)largeSizeSystemFont;
+ (UIFont *)mediumBoldSystemFont;
+ (UIFont *)mediumSizeSystemFont;

@end

NS_ASSUME_NONNULL_END
