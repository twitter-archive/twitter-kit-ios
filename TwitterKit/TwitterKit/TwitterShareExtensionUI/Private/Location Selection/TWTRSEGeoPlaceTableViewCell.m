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

#pragma mark imports

#import "TWTRSEGeoPlaceTableViewCell.h"
#import "TWTRSEFonts.h"
#import "TWTRSEGeoPlace.h"
#import "TWTRSELocalizedString.h"
#import "UIView+TSEExtensions.h"

#pragma mark - static const definitions

static const CGFloat kLabelVerticalMultiplier = 1.5;  // helps approximate the size of similar cells in the app

#pragma mark -

@interface TWTRSEGeoPlaceTableViewCell ()

@property (nonatomic, readonly) UIView *labelsContainerView;

@property (nonatomic, readonly) UILabel *placeNameLabel;
@property (nonatomic, readonly) UILabel *placeAddressLabel;

@end

@implementation TWTRSEGeoPlaceTableViewCell

- (instancetype)init
{
    if ((self = [super init])) {
        _labelsContainerView = [[UIView alloc] init];

        _placeNameLabel = [[UILabel alloc] init];
        _placeAddressLabel = [[UILabel alloc] init];

        _placeNameLabel.numberOfLines = 0;
        _placeAddressLabel.numberOfLines = 0;

        _placeNameLabel.font = TWTRSEFonts.placeNameFont;
        _placeAddressLabel.font = TWTRSEFonts.placeAddressFont;

        [self.contentView addSubview:_labelsContainerView];
        [self.labelsContainerView addSubview:_placeNameLabel];
        [self.labelsContainerView addSubview:_placeAddressLabel];

        [self setUpConstraints];
    }

    return self;
}

- (void)setUpConstraints
{
    self.labelsContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.placeNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.placeAddressLabel.translatesAutoresizingMaskIntoConstraints = NO;

    tse_requireContentCompressionResistanceAndHuggingPriority(self.labelsContainerView);
    tse_requireContentCompressionResistanceAndHuggingPriority(self.placeNameLabel);
    tse_requireContentCompressionResistanceAndHuggingPriority(self.placeAddressLabel);

    [self.labelsContainerView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
    [self.labelsContainerView.leadingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.leadingAnchor].active = YES;
    [self.labelsContainerView.trailingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.trailingAnchor].active = YES;
    [self.labelsContainerView.topAnchor constraintGreaterThanOrEqualToAnchor:self.contentView.layoutMarginsGuide.topAnchor].active = YES;
    [self.labelsContainerView.bottomAnchor constraintLessThanOrEqualToAnchor:self.contentView.layoutMarginsGuide.bottomAnchor].active = YES;

    // without a guaranteed minimum height, cells with no placeAddress will have no placeAddressLabel, and the
    // layout rules would cause the contentView to be about 1/2 size for those views; this guarantees uniformity
    CGFloat labelsContainerViewHeight = ([TWTRSEFonts placeNameFont].pointSize + [TWTRSEFonts placeAddressFont].pointSize) * kLabelVerticalMultiplier;
    [self.labelsContainerView.heightAnchor constraintGreaterThanOrEqualToConstant:labelsContainerViewHeight].active = YES;

    [self.placeNameLabel.topAnchor constraintGreaterThanOrEqualToAnchor:self.labelsContainerView.topAnchor].active = YES;
    [self.placeNameLabel.leadingAnchor constraintEqualToAnchor:self.labelsContainerView.leadingAnchor].active = YES;
    [self.placeNameLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.labelsContainerView.trailingAnchor].active = YES;
    [self.placeNameLabel.centerYAnchor constraintLessThanOrEqualToAnchor:self.labelsContainerView.centerYAnchor].active = YES;

    [self.placeAddressLabel.leadingAnchor constraintEqualToAnchor:self.labelsContainerView.leadingAnchor].active = YES;
    [self.placeAddressLabel.topAnchor constraintEqualToAnchor:self.placeNameLabel.bottomAnchor].active = YES;
    [self.placeAddressLabel.topAnchor constraintEqualToAnchor:self.labelsContainerView.centerYAnchor].active = YES;
    [self.placeAddressLabel.bottomAnchor constraintLessThanOrEqualToAnchor:self.labelsContainerView.bottomAnchor].active = YES;
    [self.placeAddressLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.labelsContainerView.trailingAnchor].active = YES;
}

- (void)prepareForReuse
{
    [super prepareForReuse];

    self.placeNameLabel.text = nil;
    self.placeAddressLabel.text = nil;

    self.accessoryType = [self accessoryTypeForSelected:NO];
}

- (UITableViewCellAccessoryType)accessoryTypeForSelected:(BOOL)selected
{
    return selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

- (void)configureWithPlace:(id<TWTRSEGeoPlace>)place selected:(BOOL)selected
{
    NSParameterAssert(place);

    self.placeNameLabel.text = place.name;
    if (0 != place.address.length) {
        self.placeAddressLabel.text = place.address;
    } else {
        [self.placeAddressLabel removeFromSuperview];
    }

    self.accessoryType = [self accessoryTypeForSelected:selected];
}

- (void)configureWithNullSelectionSelected:(BOOL)selected
{
    self.placeNameLabel.text = [TSELocalized localizedString:TSEUI_LOCALIZABLE_SHARE_EXT_NONE_VALUE];
    [self.placeAddressLabel removeFromSuperview];

    self.accessoryType = [self accessoryTypeForSelected:selected];
}

@end
