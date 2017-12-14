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

//  Image view which updates it's own height and aspect ratio based on
//  the image passed in.

#import "TWTRTweetImageView.h"
#import <TwitterCore/TWTRAssertionMacros.h>
#import <TwitterCore/TWTRColorUtil.h>
#import <TwitterCore/TWTRUtils.h>
#import "TWTRImageLoader.h"
#import "TWTRMediaEntityDisplayConfiguration.h"
#import "TWTRTweetImageViewPill.h"
#import "TWTRTweetMediaEntity.h"
#import "TWTRTwitter_Private.h"
#import "TWTRVideoMetaData.h"
#import "TWTRViewUtil.h"

@interface TWTRTweetImageView ()

@property (nonatomic, readonly) TWTRTweetViewStyle style;
@property (nonatomic, readonly) TWTRMediaEntityDisplayConfiguration *mediaConfiguration;
@property (nonatomic, readonly) TWTRTweetImageViewPill *pillView;

@end

@implementation TWTRTweetImageView

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _style = TWTRTweetViewStyleRegular;

        _pillView = [[TWTRTweetImageViewPill alloc] init];
        _pillView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_pillView];

        NSDictionary *views = @{@"pill": _pillView};
        [TWTRViewUtil addVisualConstraints:@"H:|-[pill]" views:views];
        [TWTRViewUtil addVisualConstraints:@"V:[pill]-|" views:views];

        self.layer.borderColor = [TWTRColorUtil borderGrayColor].CGColor;
        self.layer.borderWidth = 0.5;
        self.clipsToBounds = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.backgroundColor = [TWTRColorUtil faintGrayColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
    }
    return self;
}

- (void)configureWithMediaEntityConfiguration:(nullable TWTRMediaEntityDisplayConfiguration *)mediaEntityConfiguration style:(TWTRTweetViewStyle)style
{
    self.image = nil;
    self.hidden = YES;

    _style = style;
    _mediaConfiguration = mediaEntityConfiguration;
    if (mediaEntityConfiguration) {
        [self loadImageWithShouldUpdateImageViewCallback:^BOOL {
            return mediaEntityConfiguration == self.mediaConfiguration;
        }];
    }

    [self updatePillViewWithMediaEntityConfiguration:mediaEntityConfiguration];
}

- (void)updatePillViewWithMediaEntityConfiguration:(TWTRMediaEntityDisplayConfiguration *)mediaEntityConfig
{
    [self.pillView configureWithMediaEntityConfiguration:mediaEntityConfig];

    const BOOL shouldShowPill = (mediaEntityConfig.pillText.length > 0) || (mediaEntityConfig.pillImage);
    self.pillView.hidden = !shouldShowPill;
}

- (void)loadImageWithShouldUpdateImageViewCallback:(BOOL (^)(void))shouldUpdateBlock
{
    TWTRParameterAssertOrReturn(shouldUpdateBlock);

    if (self.mediaConfiguration.imagePath) {
        self.hidden = NO;
        @weakify(self);
        NSURL *imageURL = [NSURL URLWithString:self.mediaConfiguration.imagePath];
        [[[TWTRTwitter sharedInstance] imageLoader] fetchImageWithURL:imageURL
                                                           completion:^(UIImage *image, NSError *error) {
                                                               @strongify(self);

                                                               if (error) {
                                                                   NSLog(@"[TwitterKit] Could not load image: %@", error);
                                                               }

                                                               BOOL shouldUpdate = shouldUpdateBlock();
                                                               if (shouldUpdate) {
                                                                   self.image = image;
                                                               }
                                                           }];
    }
}

@end
