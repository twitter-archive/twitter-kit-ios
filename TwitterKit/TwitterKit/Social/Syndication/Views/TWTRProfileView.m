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

#import "TWTRProfileView.h"
#import <TwitterCore/TWTRColorUtil.h>
#import "TWTRTranslationsUtil.h"
#import "TWTRTweetViewMetrics.h"
#import "TWTRViewUtil.h"

static CGFloat const TWTRTweetViewProfileCornerRadius = 4.0;

@interface TWTRProfileView ()

@property (nonatomic) TWTRTweetViewMetrics *metrics;

@end
@implementation TWTRProfileView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [TWTRColorUtil imagePlaceholderColor];
        self.clipsToBounds = YES;
        self.layer.cornerRadius = TWTRTweetViewProfileCornerRadius;
        self.isAccessibilityElement = YES;
        self.accessibilityLabel = TWTRLocalizedString(@"tw__tweet_profile_accessibility");
        self.translatesAutoresizingMaskIntoConstraints = NO;

        self.metrics = [[TWTRTweetViewMetrics alloc] init];
        [TWTRViewUtil constraintForAttribute:NSLayoutAttributeWidth onView:self value:self.metrics.profileImageSize].active = YES;
        [TWTRViewUtil constraintForAttribute:NSLayoutAttributeHeight onView:self value:self.metrics.profileImageSize].active = YES;
    }
    return self;
}

@end
