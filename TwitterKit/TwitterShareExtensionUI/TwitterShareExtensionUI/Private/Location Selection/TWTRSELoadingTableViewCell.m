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

#import "TWTRSELoadingTableViewCell.h"

static const CGFloat kSpinnerTopPadding = 10.0;

@interface TWTRSELoadingTableViewCell ()

@property (nonatomic, readonly) UIActivityIndicatorView *loadingIndicatorView;

@end

@implementation TWTRSELoadingTableViewCell

- (instancetype)init
{
    if ((self = [super init])) {
        _loadingIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
        _loadingIndicatorView.color = [UIColor grayColor];
        [_loadingIndicatorView startAnimating];

        [self.contentView addSubview:_loadingIndicatorView];

        self.selectionStyle = UITableViewCellSelectionStyleNone;

        [self setUpConstraints];
    }

    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];

    [self.loadingIndicatorView startAnimating];
}

- (void)setUpConstraints
{
    self.loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.loadingIndicatorView.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
    [self.loadingIndicatorView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
    [self.loadingIndicatorView.topAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.topAnchor constant:kSpinnerTopPadding].active = YES;
}

@end
