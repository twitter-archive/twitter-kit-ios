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

#import "TWTRTweetViewMetrics.h"

CGFloat const TWTRTweetViewMaxWidth = 530.0;
CGFloat const TWTRTweetViewMinWidth = 200.0;

@implementation TWTRTweetViewMetrics

- (instancetype)init
{
    if (self = [super init]) {
        _actionsBottomMargin = 6;
        _actionsHeight = 30;
        _defaultMargin = 12;
        _defaultWidth = 300;
        _fullnameMarginBottom = 4;
        _imageMarginTop = 8;
        _marginBottom = 13;
        _marginTop = 13;
        _profileImageSize = 36;
        _profileMarginLeft = 15;
        _profileMarginRight = 9;
        _profileMarginTop = 15;
        _regularMargin = 20;
        _retweetMargin = 10;
        _defaultAutolayoutMargin = 8;
        _profileHeaderMarginBottom = 11;
    }

    return self;
}

- (NSDictionary *)metricsDictionary
{
    return @{
        @"actionsHeight": @(self.actionsHeight),
        @"actionsBottomMargin": @(self.actionsBottomMargin),
        @"defaultMargin": @(self.defaultMargin),
        @"defaultWidth": @(self.defaultWidth),
        @"fullnameMarginBottom": @(self.fullnameMarginBottom),
        @"imageMarginTop": @(self.imageMarginTop),
        @"marginBottom": @(self.marginBottom),
        @"marginTop": @(self.marginTop),
        @"profileImageSize": @(self.profileImageSize),
        @"profileMarginLeft": @(self.profileMarginLeft),
        @"profileMarginRight": @(self.profileMarginRight),
        @"profileMarginTop": @(self.profileMarginTop),
        @"regularMargin": @(self.regularMargin),
        @"retweetMargin": @(self.retweetMargin),
        @"defaultAutolayoutMargin": @(self.defaultAutolayoutMargin),
        @"profileHeaderMarginBottom": @(self.profileHeaderMarginBottom)
    };
}

@end
