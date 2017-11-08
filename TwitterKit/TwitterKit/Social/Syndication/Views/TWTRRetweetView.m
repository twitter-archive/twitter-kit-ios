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

#import "TWTRRetweetView.h"
#import "TWTRFontUtil.h"
#import "TWTRImages.h"
#import "TWTRTweetViewMetrics.h"
#import "TWTRViewUtil.h"

@implementation TWTRRetweetView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _imageView = [[UIImageView alloc] init];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:_imageView];

        _textLabel = [[UILabel alloc] init];
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _textLabel.font = [TWTRFontUtil retweetedByAttributionLabelFont];
        [self addSubview:_textLabel];

        [self setupConstraints];
    }
    return self;
}

- (void)setupConstraints
{
    NSDictionary *views = @{ @"icon": self.imageView, @"label": self.textLabel };
    TWTRTweetViewMetrics *tweetMetrics = [[TWTRTweetViewMetrics alloc] init];
    NSDictionary *metrics = tweetMetrics.metricsDictionary;

    [TWTRViewUtil addVisualConstraints:@"H:|[icon]-profileMarginRight-[label]|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views];
    [TWTRViewUtil addVisualConstraints:@"V:|[label]|" views:views];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.imageView.image = [TWTRImages retweetImageForBackgroundColor:backgroundColor];
    self.textLabel.backgroundColor = backgroundColor;
    self.imageView.backgroundColor = backgroundColor;
}

@end
