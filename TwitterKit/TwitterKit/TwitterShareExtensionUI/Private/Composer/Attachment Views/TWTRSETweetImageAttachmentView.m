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

#import "TWTRSETweetImageAttachmentView.h"
#import "TWTRSETweetAttachment.h"

#pragma mark -

@interface TWTRSETweetImageAttachmentView ()

@property (nonatomic, readonly) UIImageView *imageView;

@end

@implementation TWTRSETweetImageAttachmentView

- (instancetype)initWithImageAttachment:(TWTRSETweetAttachmentImage *)imageAttachment
{
    NSParameterAssert(imageAttachment);
    NSParameterAssert(imageAttachment.image);

    if ((self = [super initWithFrame:CGRectZero])) {
        _imageView = [[UIImageView alloc] initWithImage:imageAttachment.image];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        if (@available(iOS 11.0, *)) {
            _imageView.accessibilityIgnoresInvertColors = YES;
        }

        [self addSubview:_imageView];

        [self setUpConstraints];
    }

    return self;
}

- (void)setUpConstraints
{
    CGSize imageSize = self.imageView.image.size;
    CGFloat scale = imageSize.height / imageSize.width;
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.imageView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [self.imageView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.imageView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;

    [self.imageView.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;

    [self.imageView.heightAnchor constraintEqualToAnchor:self.imageView.widthAnchor multiplier:scale].active = YES;
    [self.heightAnchor constraintEqualToAnchor:self.imageView.heightAnchor].active = YES;
}

@end
