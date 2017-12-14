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

#import "TWTRTweetImageViewPill.h"
#import <TwitterCore/TWTRColorUtil.h>
#import "TWTRMediaEntityDisplayConfiguration.h"
#import "TWTRViewUtil.h"

static const CGFloat TWTRImagePillLabelHeight = 20.0;
static const CGFloat TWTRImagePillLabelFontSize = 14.0;
static const CGFloat TWTRImagePillLabelAlpha = 0.3;
static const CGFloat TWTRImagePillCornerRadius = 4.0;

@interface TWTRTweetImageViewPill ()

@property (nonatomic, readonly) UILabel *label;
@property (nonatomic, readonly) UIImageView *imageView;

@end

@implementation TWTRTweetImageViewPill

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[TWTRColorUtil textColor] colorWithAlphaComponent:TWTRImagePillLabelAlpha];
        self.layer.cornerRadius = TWTRImagePillCornerRadius;
        self.clipsToBounds = YES;

        _label = [[UILabel alloc] init];
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        _label.font = [UIFont boldSystemFontOfSize:TWTRImagePillLabelFontSize];
        _label.textColor = [TWTRColorUtil whiteColor];
        [self addSubview:_label];

        _imageView = [[UIImageView alloc] init];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_imageView];

        [TWTRViewUtil constraintForAttribute:NSLayoutAttributeHeight onView:_label value:TWTRImagePillLabelHeight].active = YES;
        [TWTRViewUtil centerViewInSuperview:_label];
        [TWTRViewUtil centerViewInSuperview:_imageView];
    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    if (self.imageView.image) {
        return [self.imageView intrinsicContentSize];
    }

    CGFloat singleSpaceWidth = [@" " sizeWithAttributes:@{NSFontAttributeName: self.label.font}].width;
    return CGSizeMake([self.label intrinsicContentSize].width + (singleSpaceWidth * 2), TWTRImagePillLabelHeight);
}

- (void)configureWithMediaEntityConfiguration:(TWTRMediaEntityDisplayConfiguration *)mediaEntityConfig
{
    if (mediaEntityConfig.pillImage) {
        self.label.text = @"";
        self.imageView.image = mediaEntityConfig.pillImage;
        self.label.hidden = YES;
        self.imageView.hidden = NO;
    } else {
        self.label.text = mediaEntityConfig.pillText;
        ;
        self.imageView.image = nil;
        self.label.hidden = NO;
        self.imageView.hidden = YES;
    }

    [self invalidateIntrinsicContentSize];
}

@end
