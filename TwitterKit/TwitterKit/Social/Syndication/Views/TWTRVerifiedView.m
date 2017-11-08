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

#import "TWTRVerifiedView.h"
#import "TWTRConstants_Private.h"
#import "TWTRImages.h"

static const CGFloat TWTRVerifiedViewPadding = 6;
static const CGFloat TWTRVerifiedSize = 15;

@implementation TWTRVerifiedView

- (instancetype)init
{
    self = [super init];

    if (self) {
        self.image = [TWTRImages verifiedIcon];
    }

    return self;
}

- (CGSize)intrinsicContentSize
{
    CGFloat width = TWTRVerifiedSize + (2 * TWTRVerifiedViewPadding);
    CGFloat height = TWTRVerifiedSize;

    return CGSizeMake(width, height);
}

- (UIEdgeInsets)alignmentRectInsets
{
    if (self.hidden) {
        return UIEdgeInsetsZero;
    } else {
        return UIEdgeInsetsMake(0, -TWTRVerifiedViewPadding, 0, -TWTRVerifiedViewPadding);
    }
}

@end
