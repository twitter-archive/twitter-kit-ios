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

#import "TWTRTweetLabel.h"
#import "TWTRAttributedLabel.h"
#import "TWTRFontUtil.h"
#import "TWTRStringUtil.h"
#import "TWTRTweet.h"
#import "TWTRTweetUrlEntity.h"
#import "TWTRTweet_Private.h"
#import "TWTRViewUtil.h"

@interface TWTRTweetLabel ()

@property (nonatomic, readonly) NSArray<TWTRTweetEntityRange *> *entityRanges;

@end

@implementation TWTRTweetLabel

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) {
        _entityDisplayTypes = TWTRTweetEntityDisplayTypeURL;

        self.numberOfLines = 0;
        self.lineBreakMode = NSLineBreakByWordWrapping;

        [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    }

    return self;
}

// Handle multi-line sizing issues (http://www.objc.io/issue-3/advanced-auto-layout-toolbox.html )
- (void)layoutSubviews
{
    self.preferredMaxLayoutWidth = self.frame.size.width;
    [super layoutSubviews];
}

- (void)setLinkColor:(UIColor *)linkColor
{
    _linkColor = linkColor;

    if (linkColor) {
        self.linkAttributes = @{
            NSForegroundColorAttributeName: linkColor,
        };

        self.activeLinkAttributes = @{NSForegroundColorAttributeName: linkColor, kTWTRBackgroundFillColorAttributeName: [linkColor colorWithAlphaComponent:0.2]};
    }
}

- (void)setTextFromTweet:(TWTRTweet *)tweet
{
    if (!tweet) {
        self.text = @"";
        _entityRanges = @[];
        return;
    }

    TWTRTweetPresenter *presenter = [TWTRTweetPresenter presenterForStyle:TWTRTweetViewStyleCompact];

    NSString *text = [presenter textForTweet:tweet];

    _entityRanges = [[presenter entityRangesForTweet:tweet types:self.entityDisplayTypes] copy];

    self.text = [presenter attributedTextForText:text withEntityRanges:_entityRanges];

    [self addLinksForEntityRanges:_entityRanges];
    [self updateTextAlignment:tweet.languageCode];
}

- (void)updateTextAlignment:(NSString *)languageCode
{
    NSWritingDirection direction = [NSParagraphStyle defaultWritingDirectionForLanguage:languageCode];
    if (direction == NSWritingDirectionRightToLeft) {
        self.textAlignment = NSTextAlignmentRight;
    } else {
        self.textAlignment = NSTextAlignmentLeft;
    }
}

- (BOOL)entityExistsAtPoint:(CGPoint)point
{
    return [self entityAtPoint:point] != nil;
}

@end
