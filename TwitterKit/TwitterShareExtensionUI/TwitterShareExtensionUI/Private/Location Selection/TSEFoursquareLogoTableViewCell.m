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

#import "TSEFoursquareLogoTableViewCell.h"
#import "TSEUIBundle.h"
#import "UIView+TSEExtensions.h"


@interface TSEFoursquareLogoTableViewCell ()

@property (nonatomic, readonly) UIImageView *foursquareLogoImageView;

@end

@implementation TSEFoursquareLogoTableViewCell

- (instancetype)init
{
    if ((self = [super init])) {
        _foursquareLogoImageView = [[UIImageView alloc] initWithImage:[TSEUIBundle imageNamed:@"icn_logo_foursquare"]];
        _foursquareLogoImageView.contentMode = UIViewContentModeScaleAspectFit;

        [self.contentView addSubview:_foursquareLogoImageView];

        [self setUpConstraints];
    }

    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self.foursquareLogoImageView sizeToFit];
}

- (void)setUpConstraints
{
    self.foursquareLogoImageView.translatesAutoresizingMaskIntoConstraints = NO;

    tse_requireContentCompressionResistanceAndHuggingPriority(self.foursquareLogoImageView);

    [self.foursquareLogoImageView.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
    [self.foursquareLogoImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
    [self.foursquareLogoImageView.topAnchor constraintGreaterThanOrEqualToAnchor:self.contentView.layoutMarginsGuide.topAnchor].active = YES;
}

@end
