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

#import "TWTRTweetViewSizeCalculator.h"
#import "TWTRTweet.h"
#import "TWTRTweetView.h"
#import "TWTRTweetView_Private.h"

@interface TWTRTweetViewSizeCalculator ()

@property (nonatomic) TWTRTweetView *regularTweetView;
@property (nonatomic) TWTRTweetView *compactTweetView;

@end

static NSString *TWTRCalculatorLockSentinel = @"TWTRTweetViewSizeCalculator";

@implementation TWTRTweetViewSizeCalculator

+ (TWTRTweetView *)cachedTweetViewForStyle:(TWTRTweetViewStyle)style
{
    if (style == TWTRTweetViewStyleCompact) {
        return [self compactTweetView];
    } else {  // Regular
        return [self regularTweetView];
    }
}

+ (TWTRTweetView *)regularTweetView
{
    static TWTRTweetView *tweetView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tweetView = [[TWTRTweetView alloc] initWithTweet:nil style:TWTRTweetViewStyleRegular];
        tweetView.calculationOnly = YES;
    });

    return tweetView;
}

+ (TWTRTweetView *)compactTweetView
{
    static TWTRTweetView *tweetView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tweetView = [[TWTRTweetView alloc] initWithTweet:nil style:TWTRTweetViewStyleCompact];
        tweetView.calculationOnly = YES;
    });

    return tweetView;
}

#pragma mark - Caching

// Cache holding heights keyed by @"TweetID:Style:Width:ShowingActions"
+ (NSMutableDictionary *)heightCache
{
    static NSMutableDictionary *heights;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        heights = [NSMutableDictionary dictionary];
    });

    return heights;
}

+ (CGFloat)calculatedHeightForTweet:(TWTRTweet *)tweet style:(TWTRTweetViewStyle)style fittingWidth:(CGFloat)width showingActions:(BOOL)showActions
{
    TWTRTweetView *tweetView = [self cachedTweetViewForStyle:style];
    [tweetView configureWithTweet:tweet];
    tweetView.showActionButtons = showActions;
    CGSize sizeThatFits = [tweetView sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];

    return sizeThatFits.height;
}

+ (CGFloat)heightForTweet:(TWTRTweet *)tweet style:(TWTRTweetViewStyle)style fittingWidth:(CGFloat)width showingActions:(BOOL)showActions
{
    NSNumber *cachedHeight;

    @synchronized(TWTRCalculatorLockSentinel)
    {
        NSString *key = [NSString stringWithFormat:@"%@:%lu:%f:%d", tweet.tweetID, (unsigned long)style, width, showActions];
        NSMutableDictionary *cache = [self heightCache];
        cachedHeight = cache[key];
        if (cachedHeight == nil) {
            CGFloat calculatedHeight = [self calculatedHeightForTweet:tweet style:style fittingWidth:width showingActions:showActions];
            cachedHeight = @(calculatedHeight);
            cache[key] = cachedHeight;
        }
    }

    return [cachedHeight floatValue];
}

@end
