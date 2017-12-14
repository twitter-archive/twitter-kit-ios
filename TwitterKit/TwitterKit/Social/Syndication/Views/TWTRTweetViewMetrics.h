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
FOUNDATION_EXTERN CGFloat const TWTRTweetViewMaxWidth;
FOUNDATION_EXTERN CGFloat const TWTRTweetViewMinWidth;

@interface TWTRTweetViewMetrics : NSObject

@property (nonatomic, readonly) CGFloat actionsHeight;
@property (nonatomic, readonly) CGFloat actionsBottomMargin;
@property (nonatomic, readonly) CGFloat defaultMargin;
@property (nonatomic, readonly) CGFloat defaultWidth;
@property (nonatomic, readonly) CGFloat fullnameMarginBottom;
@property (nonatomic, readonly) CGFloat imageMarginTop;
@property (nonatomic, readonly) CGFloat marginBottom;
@property (nonatomic, readonly) CGFloat marginTop;
@property (nonatomic, readonly) CGFloat profileImageSize;
@property (nonatomic, readonly) CGFloat profileMarginLeft;
@property (nonatomic, readonly) CGFloat profileMarginRight;
@property (nonatomic, readonly) CGFloat profileMarginTop;
@property (nonatomic, readonly) CGFloat regularMargin;
@property (nonatomic, readonly) CGFloat retweetMargin;
@property (nonatomic, readonly) CGFloat defaultAutolayoutMargin;
@property (nonatomic, readonly) CGFloat profileHeaderMarginBottom;

@property (nonatomic, readonly) NSDictionary *metricsDictionary;

@end
