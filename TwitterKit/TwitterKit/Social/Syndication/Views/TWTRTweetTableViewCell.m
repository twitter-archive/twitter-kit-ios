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

#import "TWTRTweetTableViewCell.h"
#import "TWTRProfileHeaderView.h"
#import "TWTRTimestampLabel.h"
#import "TWTRTranslationsUtil.h"
#import "TWTRTweetContentView+Layout.h"
#import "TWTRTweetLabel.h"
#import "TWTRTweetMediaView.h"
#import "TWTRTweetView.h"
#import "TWTRTweetViewSizeCalculator.h"
#import "TWTRTweetView_Private.h"
#import "TWTRTweet_Private.h"
#import "TWTRViewUtil.h"

@implementation TWTRTweetTableViewCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInit];
    }

    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;

    _tweetView = [[TWTRTweetView alloc] initWithTweet:nil style:TWTRTweetViewStyleCompact];
    _tweetView.translatesAutoresizingMaskIntoConstraints = NO;
    _tweetView.showBorder = NO;
    [self.contentView addSubview:_tweetView];

    NSDictionary *views = @{ @"tweetView": _tweetView };
    [TWTRViewUtil addVisualConstraints:@"H:|[tweetView]|" views:views];
    [TWTRViewUtil addVisualConstraints:@"V:|[tweetView]|" views:views];
}

- (void)configureWithTweet:(TWTRTweet *)tweet
{
    [self.tweetView configureWithTweet:tweet];
}

- (NSString *)accessibilityLabel
{
    NSArray *items = @[self.tweetView.contentView.profileHeaderView.fullname.accessibilityLabel ?: @"", self.tweetView.contentView.tweetLabel.accessibilityLabel ?: @"", self.tweetView.contentView.mediaView.accessibilityLabel ?: @"", self.tweetView.contentView.profileHeaderView.timestamp.accessibilityLabel ?: @""];
    NSString *text = [TWTRTranslationsUtil accessibilityStringByConcatenatingItems:items];

    return text;
}

+ (CGFloat)heightForTweet:(TWTRTweet *)tweet style:(TWTRTweetViewStyle)style width:(CGFloat)width showingActions:(BOOL)actionsAreVisible
{
    return [TWTRTweetViewSizeCalculator heightForTweet:tweet style:style fittingWidth:width showingActions:actionsAreVisible];
}

@end
