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

#ifdef DEBUG
#import <QuartzCore/QuartzCore.h>
#endif
#import <UIKit/UIKit.h>
#import "NSStringPunycodeAdditions.h"
#import "TWTRTimelineFilter.h"
#import "TWTRTimelineFilterManager.h"
#import "TWTRTweet.h"
#import "TWTRTweetHashtagEntity.h"
#import "TWTRTweetUrlEntity.h"
#import "TWTRTweetUserMentionEntity.h"
#import "TWTRTweet_Private.h"
#import "TWTRTwitter_Private.h"
#import "TWTRUser.h"

@interface TWTRTimelineFilterManager ()
@property (nonatomic, copy) TWTRTimelineFilter *filters;

// pre-computed values for later comparison
@property (nonatomic, copy) NSSet *filteredHashtags;
@property (nonatomic, copy) NSSet *filteredUrls;
@property (nonatomic, copy) NSSet *filteredHandles;
@property (nonatomic, copy) NSSet *filteredKeywords;
@property (nonatomic) NSUInteger totalFilteredTweets;
@end

@implementation TWTRTimelineFilterManager

- (instancetype)initWithFilters:(TWTRTimelineFilter *)filters
{
    if ((self = [super init])) {
        self.filters = filters;
    }
    return self;
}

#pragma mark - Public

- (NSArray *)filterTweets:(NSArray *)tweets
{
    return [self filterTweetsWithEnumeration:tweets];
}

#pragma mark - Property

- (void)setFilters:(TWTRTimelineFilter *)filters
{
    if (_filters != filters) {
        _filters = filters;

        // precompute hashtags, urls and mentions sets.
        self.filteredHashtags = [self lowercaseSetFromStrings:self.filters.hashtags];
        self.filteredHandles = [self lowercaseSetFromStrings:self.filters.handles];
        self.filteredUrls = [self hostsSetFromStrings:self.filters.urls];
        self.filteredKeywords = [self lowercaseSetFromStrings:self.filters.keywords];

        self.totalFilteredTweets = 0;
    }
}

#pragma mark - Private

- (NSArray *)filterTweetsWithEnumeration:(NSArray *)tweets
{
// measure and benchmark when debugging.
#ifdef DEBUG
    CFTimeInterval startTime = CACurrentMediaTime();
#endif

    __block NSUInteger filteredTweetsInResponse = 0;
    __block NSMutableArray *filteredTweets = [NSMutableArray array];
    [tweets enumerateObjectsUsingBlock:^(TWTRTweet *_Nonnull tweet, NSUInteger idx, BOOL *_Nonnull stop) {

        // filter handles
        BOOL containsFilteredHandles = [self tweet:tweet containsHandles:self.filteredHandles];
        if (containsFilteredHandles) {
            filteredTweetsInResponse++;
            return;  // filter out
        }

        // filter hashtags
        BOOL containsFilteredHashtags = [self tweet:tweet containsHashtags:self.filteredHashtags];
        if (containsFilteredHashtags) {
            filteredTweetsInResponse++;
            return;  // filter out
        }

        // filter urls
        BOOL containsFilteredUrls = [self tweet:tweet containsUrls:self.filteredUrls];
        if (containsFilteredUrls) {
            filteredTweetsInResponse++;
            return;  // filter out
        }

        // filter keywords
        BOOL containsKeyword = [self tweet:tweet containsKeywords:self.filteredKeywords];
        if (containsKeyword) {
            filteredTweetsInResponse++;
            return;  // filter out
        }

        // if we reached here, the tweet should not be filtered out
        [filteredTweets addObject:tweet];

    }];

    self.totalFilteredTweets += filteredTweetsInResponse;

// measure and benchmark when debugging.
#ifdef DEBUG
    CFTimeInterval endTime = CACurrentMediaTime();
    NSLog(@"Total Runtime: %g ms. Filtered %lu tweets (%lu in total)", (endTime - startTime) * 1000, (unsigned long)filteredTweetsInResponse, (unsigned long)self.totalFilteredTweets);
#endif
    return filteredTweets;
}

- (BOOL)tweet:(TWTRTweet *)tweet containsHandles:(NSSet *)handles
{
    if (handles.count == 0) {
        return NO;
    }

    // check originating username
    if ([handles containsObject:[self lowercaseText:tweet.author.screenName]]) {
        return YES;
    }

    // check against user mentions
    NSSet *tweetHandles = [self setFromUsernameEntities:tweet.userMentions];
    return [tweetHandles intersectsSet:handles];  // there's a username that should be filtered.
}

- (BOOL)tweet:(TWTRTweet *)tweet containsHashtags:(NSSet *)hashtags
{
    if (hashtags.count == 0) {
        return NO;
    }

    NSSet *tweetHashtags = [self setFromHashtagsEntities:tweet.hashtags];
    return [tweetHashtags intersectsSet:hashtags];  // there's a hashtag that should be filtered.
}

- (BOOL)tweet:(TWTRTweet *)tweet containsUrls:(NSSet *)urls
{
    if (urls.count == 0) {
        return NO;
    }

    NSSet *tweetUrls = [self setFromURLEntities:tweet.urls];
    return [tweetUrls intersectsSet:urls];  // there's a url that should be filtered.
}

- (BOOL)tweet:(TWTRTweet *)tweet containsKeywords:(NSSet *)keywords
{
    if (keywords.count == 0) {
        return NO;
    }

    NSString *text = [[tweet.text componentsSeparatedByCharactersInSet:[NSCharacterSet punctuationCharacterSet]] componentsJoinedByString:@""];

    for (NSString *keyword in keywords) {
        if ([self text:text containsWord:keyword]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)text:(NSString *)text containsWord:(NSString *)word
{
    if (word) {
        NSString *paddedText = [NSString stringWithFormat:@" %@ ", text];
        NSString *paddedWord = [NSString stringWithFormat:@" %@ ", word];
        if ([paddedText localizedStandardContainsString:paddedWord]) {
            return YES;
        }
    }
    return NO;
}

- (NSSet *)setFromHashtagsEntities:(NSArray *)entities
{
    NSMutableSet *hashtags = [NSMutableSet set];
    for (TWTRTweetHashtagEntity *entity in entities) {
        [hashtags addObject:[self lowercaseText:entity.text]];
    }
    return [hashtags copy];
}

- (NSSet *)setFromURLEntities:(NSArray *)entities
{
    NSMutableSet *urls = [NSMutableSet set];
    for (TWTRTweetUrlEntity *entity in entities) {
        // extract host from full url
        NSString *domain = [self hostFromURLString:entity.expandedUrl];
        if (domain) {
            [urls addObject:domain];
        }
    }
    return [urls copy];
}

- (NSSet *)setFromUsernameEntities:(NSArray *)entities
{
    NSMutableSet *handles = [NSMutableSet set];
    for (TWTRTweetUserMentionEntity *entity in entities) {
        [handles addObject:[self lowercaseText:entity.screenName]];
    }
    return [handles copy];
}

- (NSSet *)lowercaseSetFromStrings:(NSSet *)strings
{
    NSMutableSet *lowercaseStrings = [NSMutableSet set];
    for (NSString *string in strings) {
        [lowercaseStrings addObject:[[self lowercaseText:string] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"#@$\uFF03\uFF20"]]];
    }
    return [lowercaseStrings copy];
}

- (NSSet *)hostsSetFromStrings:(NSSet *)strings
{
    NSMutableSet *hosts = [NSMutableSet set];
    for (NSString *string in strings) {
        NSString *domain = [self lowercaseText:[self hostFromURLString:[string encodedURLString]]];
        if (domain) {
            [hosts addObject:domain];
        }
    }
    return [hosts copy];
}

- (NSString *)lowercaseText:(NSString *)text
{
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    // if we're on iOS9+ use the new localized more performant method.
    if (version >= 9.0) {
        return [[text localizedLowercaseString] copy];
    } else {
        return [[text lowercaseString] copy];
    }
}

- (NSString *)hostFromURLString:(NSString *)URLString
{
    // extract host from full url
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:URLString];
    if (components) {
        /**
         *
         * NSURLComponents won't recognize a puny encoded url if it doesn't contain a scheme.
         *
         * (lldb) po [[[NSURLComponents alloc] initWithString:@"xn--80a0addceeeh.com"] host]
         * nil
         * (lldb) po [[[NSURLComponents alloc] initWithString:@"http://xn--80a0addceeeh.com"] host]
         * xn--80a0addceeeh.com
         *
         */
        if (components.scheme == nil) {
            NSURLComponents *componentsWithScheme = [[NSURLComponents alloc] initWithString:[NSString stringWithFormat:@"http://%@", URLString]];
            return [self lowercaseText:componentsWithScheme.host];
        } else {
            return [self lowercaseText:components.host];
        }
    }
    return nil;
}

@end
