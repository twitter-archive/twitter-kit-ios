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

#import "TWTRSETweetURLAttachmentView.h"
#import "TWTRSEColors.h"
#import "TWTRSEFonts.h"
#import "TWTRSETweetAttachment.h"
#import "UIView+TSEExtensions.h"

@import MobileCoreServices;
@import UIKit;

#pragma mark - extern const definitions

const CGFloat TWTRSETweetURLAttachmentViewPreferredViewHeight = 80.0;

#pragma mark - static const definitions

static const CGFloat kLabelsLeadingMargin = 10.0;

#pragma mark -

typedef NS_ENUM(NSUInteger, TWTRSEURLAttachmentLoadState) { TWTRSEURLAttachmentLoadStatePending = 1, TWTRSEURLAttachmentLoadStateLoading, TWTRSEURLAttachmentLoadStateFinishedLoading };

#pragma mark -

@interface TWTRSETweetURLAttachmentView ()

// Views
@property (nonatomic, readonly) UIImageView *linkPreviewImageView;
@property (nonatomic, readonly) UIView *labelsContainerView;

@end

@implementation TWTRSETweetURLAttachmentView

- (instancetype)initWithURLAttachment:(TWTRSETweetAttachmentURL *)attachment
{
    NSParameterAssert(attachment);

    if ((self = [super initWithFrame:CGRectZero])) {
        self.clipsToBounds = YES;

        _linkPreviewImageView = [[UIImageView alloc] init];
        _labelsContainerView = [[UIView alloc] init];
        _linkTitleLabel = [[UILabel alloc] init];
        _linkDomainLabel = [[UILabel alloc] init];

        if (@available(iOS 11.0, *)) {
            _linkPreviewImageView.accessibilityIgnoresInvertColors = YES;
        }
        _linkPreviewImageView.contentMode = UIViewContentModeScaleAspectFill;
        _linkPreviewImageView.clipsToBounds = YES;

        _linkTitleLabel.numberOfLines = 2;
        _linkDomainLabel.numberOfLines = 2;

        _linkTitleLabel.font = [TWTRSEFonts cardTitleFont];
        _linkDomainLabel.font = [TWTRSEFonts cardSubtitleFont];

        _linkTitleLabel.textColor = [TWTRSEFonts cardTitleColor];
        _linkDomainLabel.textColor = [TWTRSEFonts cardSubtitleColor];

        [self addSubview:_linkPreviewImageView];
        [self addSubview:_labelsContainerView];
        [_labelsContainerView addSubview:_linkTitleLabel];
        [_labelsContainerView addSubview:_linkDomainLabel];

        [self setUpConstraints];

        _linkTitleLabel.text = attachment.title;
        _linkDomainLabel.text = attachment.URL.host;
        _linkPreviewImageView.image = attachment.previewImage;
        _linkPreviewImageView.backgroundColor = TWTRSEUITwitterColorImagePlaceholder();
    }

    return self;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, TWTRSETweetURLAttachmentViewPreferredViewHeight);
}

#pragma mark - Private

- (void)setUpConstraints
{
    self.linkPreviewImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.labelsContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.linkTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.linkDomainLabel.translatesAutoresizingMaskIntoConstraints = NO;

    tse_requireContentCompressionResistanceAndHuggingPriority(self.linkTitleLabel);
    tse_requireContentCompressionResistanceAndHuggingPriority(self.linkDomainLabel);

    [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

    [self.labelsContainerView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

    [self.linkPreviewImageView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.linkPreviewImageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [self.linkPreviewImageView.heightAnchor constraintEqualToConstant:TWTRSETweetURLAttachmentViewPreferredViewHeight].active = YES;
    [self.linkPreviewImageView.widthAnchor constraintEqualToConstant:TWTRSETweetURLAttachmentViewPreferredViewHeight].active = YES;

    [self.labelsContainerView.topAnchor constraintGreaterThanOrEqualToAnchor:self.topAnchor].active = YES;
    [self.labelsContainerView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    [self.labelsContainerView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
    [self.labelsContainerView.leadingAnchor constraintEqualToAnchor:self.linkPreviewImageView.trailingAnchor constant:kLabelsLeadingMargin].active = YES;
    [self.labelsContainerView.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.leadingAnchor constant:kLabelsLeadingMargin].active = YES;
    [self.linkTitleLabel.topAnchor constraintEqualToAnchor:self.labelsContainerView.topAnchor].active = YES;
    [self.linkTitleLabel.leadingAnchor constraintEqualToAnchor:self.labelsContainerView.leadingAnchor].active = YES;
    [self.linkDomainLabel.leadingAnchor constraintEqualToAnchor:self.linkTitleLabel.leadingAnchor].active = YES;
    [self.linkTitleLabel.trailingAnchor constraintEqualToAnchor:self.labelsContainerView.layoutMarginsGuide.trailingAnchor].active = YES;
    [self.linkDomainLabel.trailingAnchor constraintEqualToAnchor:self.labelsContainerView.layoutMarginsGuide.trailingAnchor].active = YES;
    [self.linkDomainLabel.topAnchor constraintEqualToAnchor:self.linkTitleLabel.bottomAnchor].active = YES;
    [self.linkDomainLabel.bottomAnchor constraintEqualToAnchor:self.labelsContainerView.bottomAnchor].active = YES;

    [self.heightAnchor constraintEqualToAnchor:self.linkPreviewImageView.heightAnchor];
}

@end
