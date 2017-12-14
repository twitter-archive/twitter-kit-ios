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

#import "TWTRTimelineMessageView.h"
#import <TwitterCore/TWTRColorUtil.h>
#import "TWTRFontUtil.h"
#import "TWTRViewUtil.h"

@interface TWTRTimelineMessageView ()

@property (nonatomic) UILabel *messageLabel;
@property (nonatomic) UIActivityIndicatorView *activityIndicator;
@property (nonatomic) NSLayoutConstraint *spinnerMessageConstraint;

@end

@implementation TWTRTimelineMessageView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.font = [TWTRFontUtil largeSizeSystemFont];
    self.messageLabel.textColor = [TWTRColorUtil contrastingTextColorFromBackgroundColor:self.backgroundColor];

    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.transform = CGAffineTransformMakeScale(1.3, 1.3);

    [self setupConstraints];
}

- (void)setupConstraints
{
    NSDictionary *views = @{ @"message": self.messageLabel, @"spinner": self.activityIndicator };
    for (UIView *view in [views allValues]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:view];
    }

    [TWTRViewUtil centerViewInSuperview:self.messageLabel];
    [TWTRViewUtil centerViewInSuperview:self.activityIndicator];
}

- (void)beginLoading
{
    [self.activityIndicator startAnimating];
    self.messageLabel.hidden = YES;
}

- (void)endLoading
{
    [self.activityIndicator stopAnimating];
}

- (void)endLoadingWithMessage:(NSString *)message
{
    [self endLoading];
    self.messageLabel.hidden = NO;
    self.messageLabel.text = message;
}

@end
