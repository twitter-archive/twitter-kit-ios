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

#import "TWTRTweetPresenter.h"
#import <TwitterCore/TWTRColorUtil.h>
#import "TWTRCardEntity.h"
#import "TWTRDateFormatter.h"
#import "TWTRFontUtil.h"
#import "TWTRHTMLEntityUtil.h"
#import "TWTRMediaEntityDisplayConfiguration.h"
#import "TWTRPlayerCardEntity.h"
#import "TWTRTranslationsUtil.h"
#import "TWTRTweet.h"
#import "TWTRTweetCashtagEntity.h"
#import "TWTRTweetHashtagEntity.h"
#import "TWTRTweetMediaEntity.h"
#import "TWTRTweetUrlEntity.h"
#import "TWTRTweetUserMentionEntity.h"
#import "TWTRTweet_Private.h"
#import "TWTRUser.h"
#import "TWTRViewUtil.h"

const CGFloat TWTRAspectRatio16x10 = 16.0 / 10.0;

@implementation TWTRTweetEntityRange

- (instancetype)initWithEntity:(TWTRTweetEntity *)entity textRange:(NSRange)range
{
    self = [super init];
    if (self) {
        _entity = entity;
        _textRange = range;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ - %@", NSStringFromClass([self.entity class]), NSStringFromRange(self.textRange)];
}

@end

@implementation TWTRTweetPresenter

+ (instancetype)presenterForStyle:(TWTRTweetViewStyle)style
{
    return [[self alloc] initWithTweetViewStyle:style];
}

- (instancetype)initWithTweetViewStyle:(TWTRTweetViewStyle)style
{
    self = [super init];
    if (self) {
        _style = style;
    }
    return self;
}

- (NSString *)retweetedByTextForRetweet:(TWTRTweet *)retweet
{
    if (!(retweet && retweet.isRetweet)) {
        return nil;
    }

    return [NSString stringWithFormat:TWTRLocalizedString(@"tw__tweet_retweeted_by_user"), retweet.author.name];
}

- (NSString *)textForTweet:(nullable TWTRTweet *)tweet
{
    if (!tweet) {
        return @"";
    }

    NSString *tweetText = tweet.text;

    tweetText = [self stripLastImage:[tweet.media lastObject] fromText:tweetText];     // Remove trailing image URL
    tweetText = [self stripCardEntity:tweet.cardEntity.URLString fromText:tweetText];  // remove the card url
    tweetText = [self stripQuoteTweetURLForTweetID:tweet.quotedTweet.tweetID entities:tweet.urls fromText:tweetText];
    tweetText = [self replaceDisplayURLs:tweet.urls fromText:tweetText];               // Replace t.co URLs with display URLs
    tweetText = [self stripWhitespaceFromText:tweetText];                              // Strip whitespace from either end
    tweetText = [TWTRHTMLEntityUtil unescapedHTMLEntitiesStringWithString:tweetText];  // Escape HTML entities

    return tweetText;
}

- (NSAttributedString *)attributedTextForText:(NSString *)text withEntityRanges:(NSArray<TWTRTweetEntityRange *> *)entityRanges
{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
    return string;
}

#pragma mark - Image

- (NSString *)stripLastImage:(TWTRTweetMediaEntity *)mediaEntity fromText:(NSString *)tweetText
{
    if (mediaEntity) {
        return [tweetText stringByReplacingOccurrencesOfString:mediaEntity.tweetTextURL withString:@""];
    } else {
        return tweetText;
    }
}

- (NSString *)replaceDisplayURLs:(NSArray *)urlEntities fromText:(NSString *)tweetText
{
    for (TWTRTweetUrlEntity *urlEntity in urlEntities) {
        tweetText = [tweetText stringByReplacingOccurrencesOfString:urlEntity.url withString:urlEntity.displayUrl];
    }
    return tweetText;
}

- (NSString *)stripQuoteTweetURLForTweetID:(NSString *)status entities:(NSArray<TWTRTweetUrlEntity *> *)entities fromText:(NSString *)tweetText
{
    if (!status) {
        return tweetText;
    }

    for (TWTRTweetUrlEntity *urlEntity in entities) {
        // check if the url contains Tweet ID and also if Tweet text ends with url
        if ([urlEntity.expandedUrl containsString:status] && ([tweetText hasSuffix:urlEntity.displayUrl] || [tweetText hasSuffix:urlEntity.url])) {
            return [tweetText stringByReplacingOccurrencesOfString:urlEntity.url withString:@""];
        }
    }
    return tweetText;
}

- (NSString *)stripCardEntity:(nullable NSString *)url fromText:(NSString *)tweetText
{
    if (url.length == 0) {
        return tweetText;
    }

    return [tweetText stringByReplacingOccurrencesOfString:url withString:@""];
}

- (NSString *)stripWhitespaceFromText:(NSString *)tweetText
{
    return [tweetText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

#pragma mark Media
- (CGFloat)mediaAspectRatioForTweet:(TWTRTweet *)tweet
{
    if (![tweet hasMedia]) {
        return 0.0;
    }

    if (tweet.media.count > 1) {
        return [self aspectRatioForMultiphotoDisplayOfTweet:tweet];
    } else {
        return [self mediaAspectRatioForTweetWithSingleMediaEntity:tweet];
    }
}

- (CGFloat)mediaAspectRatioForTweetWithSingleMediaEntity:(TWTRTweet *)tweet
{
    CGFloat averageAspectRatio = 0.0;

    if (tweet.media.count > 0) {
        averageAspectRatio = [TWTRViewUtil averageAspectRatioForMediaEntity:tweet.media[0]];
    } else if (tweet.cardEntity) {
        TWTRMediaEntityDisplayConfiguration *mediaConfig = [TWTRMediaEntityDisplayConfiguration mediaEntityDisplayConfigurationWithCardEntity:tweet.cardEntity];
        averageAspectRatio = [TWTRViewUtil aspectRatioForSize:mediaConfig.imageSize];
    }

    return [self aspectRatioForStyleFromAverageRatio:averageAspectRatio];
}

- (CGFloat)aspectRatioForStyleFromAverageRatio:(CGFloat)averageAspectRatio
{
    return (self.style == TWTRTweetViewStyleCompact) ? TWTRAspectRatio16x10 : averageAspectRatio;
}

- (CGFloat)aspectRatioForMultiphotoDisplayOfTweet:(TWTRTweet *)tweet
{
    // Rules:
    // - For Regular style
    //     - 2-3 images ratio = 3:2
    //     - 4 images ratio = 2:2
    // - For compact style always = 16:10

    const CGFloat _3x2 = 3.0 / 2.0;
    const CGFloat _2x2 = 1.0;

    switch (self.style) {
        case TWTRTweetViewStyleCompact: {
            return TWTRAspectRatio16x10;
        }
        case TWTRTweetViewStyleRegular:
            if (tweet.media.count == 2 || tweet.media.count == 3) {
                return _3x2;
            } else {
                return _2x2;
            }
    }
}

#pragma mark - Display Entities
- (NSArray<TWTRTweetEntityRange *> *)entityRangesForTweet:(TWTRTweet *)tweet types:(TWTRTweetEntityDisplayType)types
{
    /// Collect the objects
    NSArray *entities = [self entitiesForTweet:tweet types:types];
    NSString *text = [self textForTweet:tweet];
    NSUInteger location = 0;
    NSUInteger textLength = text.length;

    NSMutableArray *entityRanges = [NSMutableArray arrayWithCapacity:entities.count];

    for (TWTRTweetEntity *entity in entities) {
        NSString *textToFind;
        if ([entity isKindOfClass:[TWTRTweetUrlEntity class]]) {
            textToFind = [(TWTRTweetUrlEntity *)entity displayUrl];
        } else if ([entity isKindOfClass:[TWTRTweetHashtagEntity class]]) {
            textToFind = [NSString stringWithFormat:@"#%@", [(TWTRTweetHashtagEntity *)entity text]];
        } else if ([entity isKindOfClass:[TWTRTweetCashtagEntity class]]) {
            textToFind = [NSString stringWithFormat:@"$%@", [(TWTRTweetCashtagEntity *)entity text]];
        } else if ([entity isKindOfClass:[TWTRTweetUserMentionEntity class]]) {
            textToFind = [NSString stringWithFormat:@"@%@", [(TWTRTweetUserMentionEntity *)entity screenName]];
        } else {
            NSLog(@"[TwitterKit] Invalid entity type found %@", entity);
            continue;
        }

        NSRange searchRange = NSMakeRange(location, textLength - location);
        NSRange foundRange = [text rangeOfString:textToFind options:0 range:searchRange];

        if (foundRange.location != NSNotFound) {
            TWTRTweetEntityRange *entityRange = [[TWTRTweetEntityRange alloc] initWithEntity:entity textRange:foundRange];
            [entityRanges addObject:entityRange];

            location = foundRange.location + foundRange.length;
        }
    }

    return entityRanges;
}

- (NSArray<TWTRTweetEntityRange *> *)entitiesForTweet:(TWTRTweet *)tweet types:(TWTRTweetEntityDisplayType)types
{
    NSMutableArray *entityRanges = [NSMutableArray array];

    void (^addEnities)(NSArray *, TWTRTweetEntityDisplayType) = ^(NSArray *entities, TWTRTweetEntityDisplayType type) {
        if ((types & type) && entities) {
            [entityRanges addObjectsFromArray:entities];
        }
    };

    addEnities(tweet.urls, TWTRTweetEntityDisplayTypeURL);
    addEnities(tweet.hashtags, TWTRTweetEntityDisplayTypeHashtag);
    addEnities(tweet.cashtags, TWTRTweetEntityDisplayTypeCashtag);
    addEnities(tweet.userMentions, TWTRTweetEntityDisplayTypeUserMention);

    return [self entityRangesSortedByPosition:entityRanges];
}

- (NSArray<TWTRTweetEntityRange *> *)entityRangesSortedByPosition:(NSArray<TWTRTweetEntityRange *> *)entityRanges
{
    return [entityRanges sortedArrayUsingComparator:^NSComparisonResult(TWTRTweetEntity *obj1, TWTRTweetEntity *obj2) {
        return [@(obj1.startIndex) compare:@(obj2.startIndex)];
    }];
}

@end
