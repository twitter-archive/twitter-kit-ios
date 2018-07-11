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

#import "TWTRSEConfigurationSelectionTableViewCell.h"
#import "UIView+TSEExtensions.h"

static const CGFloat kLabelMinHorizontalSeparation = 10.0;

@interface TWTRSEConfigurationSelectionTableViewCell ()

@property (nonatomic, readonly) UILabel *configurationNameLabel;
@property (nonatomic, readonly) UILabel *configurationValueLabel;
@property (nonatomic, readonly) UIActivityIndicatorView *loadingIndicatorView;

@end

@implementation TWTRSEConfigurationSelectionTableViewCell

- (instancetype)init
{
    if ((self = [super init])) {
        _configurationNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _configurationValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];

        _configurationValueLabel.textColor = [UIColor grayColor];
        _configurationValueLabel.textAlignment = NSTextAlignmentRight;

        _loadingIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
        _loadingIndicatorView.color = [UIColor grayColor];
        _loadingIndicatorView.hidesWhenStopped = YES;

        [self.contentView addSubview:_configurationNameLabel];
        [self.contentView addSubview:_configurationValueLabel];
        [self.contentView addSubview:_loadingIndicatorView];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];

        [self setUpConstraints];

        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    return self;
}

- (void)setUpConstraints
{
    self.configurationNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.configurationValueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;

    tse_requireContentCompressionResistanceAndHuggingPriority(self.configurationNameLabel);
    tse_requireContentCompressionResistanceAndHuggingPriority(self.configurationValueLabel);

    [self.configurationNameLabel.leadingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.leadingAnchor].active = YES;
    [self.configurationNameLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
    [self.configurationNameLabel.topAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.topAnchor].active = YES;

    [self.configurationValueLabel.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor].active = YES;
    [self.configurationValueLabel.leadingAnchor constraintLessThanOrEqualToAnchor:self.configurationNameLabel.trailingAnchor constant:kLabelMinHorizontalSeparation].active = YES;
    [self.configurationValueLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
    [self.configurationValueLabel.topAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.topAnchor].active = YES;

    [self.loadingIndicatorView.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor].active = YES;
    [self.loadingIndicatorView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
}

- (void)prepareForReuse
{
    [super prepareForReuse];

    self.configurationNameLabel.text = nil;
    self.configurationValueLabel.text = nil;
    self.configurationValueLabel.hidden = NO;
    [self.loadingIndicatorView stopAnimating];
}

- (void)setConfigurationName:(NSString *)configurationName
{
    _configurationName = [configurationName copy];

    self.configurationNameLabel.text = configurationName;
}

- (void)setCurrentConfigurationValue:(NSString *)currentConfigurationValue
{
    _currentConfigurationValue = [currentConfigurationValue copy];

    self.configurationValueLabel.text = currentConfigurationValue;
}

- (void)setLoading:(BOOL)loading
{
    if (loading) {
        [self.loadingIndicatorView startAnimating];
    } else {
        [self.loadingIndicatorView stopAnimating];
    }

    self.configurationValueLabel.hidden = loading;
}

@end
