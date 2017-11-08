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

#import <XCTest/XCTest.h>
#import "TWTRFixtureLoader.h"
#import "TWTRTestCase.h"
#import "TWTRTimelineFilter.h"
#import "TWTRTimelineFilterManager.h"
#import "TWTRTweet.h"
#import "TWTRTweetUserMentionEntity.h"

@class TWTRTweetHashtagEntity;
@class TWTRTweetUrlEntity;

// expose private methods for testing
@interface TWTRTimelineFilterManager ()
- (NSArray<TWTRTweet *> *)filterTweetsWithConcurrentEnumeration:(NSArray<TWTRTweet *> *)tweets withFilters:(TWTRTimelineFilter *)filters;
- (BOOL)tweet:(TWTRTweet *)tweet containsHandles:(NSSet<NSString *> *)handles;
- (BOOL)tweet:(TWTRTweet *)tweet containsHashtags:(NSSet<NSString *> *)hashtags;
- (BOOL)tweet:(TWTRTweet *)tweet containsUrls:(NSSet<NSString *> *)urls;
- (BOOL)tweet:(TWTRTweet *)tweet containsKeywords:(NSSet<NSString *> *)keywords;
- (BOOL)text:(NSString *)text containsWord:(NSString *)word;
- (NSSet *)setFromHashtagsEntities:(NSArray<TWTRTweetHashtagEntity *> *)entities;
- (NSSet *)setFromURLEntities:(NSArray<TWTRTweetUrlEntity *> *)entities;
- (NSSet *)setFromUsernameEntities:(NSArray<TWTRTweetUserMentionEntity *> *)entities;
- (NSSet *)lowercaseSetFromStrings:(NSSet<NSString *> *)strings;
- (NSString *)lowercaseText:(NSString *)text;
@end

@interface TWTRTimelineFilterManagerTests : TWTRTestCase
@end

@implementation TWTRTimelineFilterManagerTests

- (void)testTweetFilters
{
    // configure filters
    TWTRTimelineFilter *filters = [[TWTRTimelineFilter alloc] init];
    filters.handles = [NSSet setWithObjects:@"twitter", @"@Astro_Alex", @"barackobama", nil];
    filters.keywords = [NSSet setWithObjects:@"TWTR", @"winners", nil];
    filters.hashtags = [NSSet setWithObjects:@"chess", @"#randomhashtag", nil];

    // use the filter manager, and apply it to a list of tweets
    TWTRTimelineFilterManager *filterManager = [[TWTRTimelineFilterManager alloc] initWithFilters:filters];

    NSArray *tweets = [TWTRFixtureLoader manyTweets];

    NSArray *remaining = [filterManager filterTweets:tweets];

    XCTAssertTrue(tweets.count == 7);
    XCTAssertTrue(remaining.count == 3);
}

- (void)testTweetContainsHandles
{
    TWTRTimelineFilterManager *filterManager = [[TWTRTimelineFilterManager alloc] initWithFilters:nil];

    TWTRTweet *tweet = [TWTRFixtureLoader gatesTweet];
    NSSet *handles = [NSSet setWithObjects:@"twitter", @"melindagates", @"barackobama", nil];  // (tweet contains a mention to melindagates)

    XCTAssertTrue([filterManager tweet:tweet containsHandles:handles]);

    NSSet *handles2 = [NSSet setWithObjects:@"disney", @"barackobama", nil];
    XCTAssertFalse([filterManager tweet:tweet containsHandles:handles2]);
}

- (void)testTweetContainsHashtags
{
    TWTRTimelineFilterManager *filterManager = [[TWTRTimelineFilterManager alloc] initWithFilters:nil];

    TWTRTweet *tweet = [TWTRFixtureLoader vineTweetV13];
    NSSet *hashtags = [NSSet setWithObjects:@"twitter", @"nbavote", @"barackobama", nil];  // (tweet contains the hashtag #NBAVote)

    XCTAssertTrue([filterManager tweet:tweet containsHashtags:hashtags]);

    NSSet *hashtags2 = [NSSet setWithObjects:@"disney", @"barackobama", nil];
    XCTAssertFalse([filterManager tweet:tweet containsHashtags:hashtags2]);
}

- (void)testTweetContainsUrl
{
    TWTRTimelineFilterManager *filterManager = [[TWTRTimelineFilterManager alloc] initWithFilters:nil];

    TWTRTweet *tweet = [TWTRFixtureLoader gatesTweet];
    NSSet *urls = [NSSet setWithObjects:@"disney.com", @"b-gat.es", @"www.barackobama.com", nil];  // (tweet contains b-gat.es url)
    XCTAssertTrue([filterManager tweet:tweet containsUrls:urls]);

    NSSet *urls2 = [NSSet setWithObjects:@"disney.com", @"www.barackobama.com", nil];
    XCTAssertFalse([filterManager tweet:tweet containsUrls:urls2]);

    TWTRTweet *tweet3 = [TWTRFixtureLoader cashtagTweet];
    NSSet *urls3 = [NSSet setWithObjects:@"www.twitter.com", nil];
    XCTAssertTrue([filterManager tweet:tweet3 containsUrls:urls3]);
}

- (void)testTweetContainsPunyUrl
{
    // configure filters
    TWTRTimelineFilter *filters = [[TWTRTimelineFilter alloc] init];
    filters.urls = [NSSet setWithObjects:@"транспорт.com", @"www.barackobama.com", nil];

    // use the filter manager, and apply it to a list of tweets
    TWTRTimelineFilterManager *filterManager = [[TWTRTimelineFilterManager alloc] initWithFilters:filters];

    NSArray *tweets = @[[TWTRFixtureLoader punyURLTweet]];

    NSArray *remaining = [filterManager filterTweets:tweets];

    XCTAssertTrue(remaining.count == 0);
}

- (void)textTweetContainsPunyUrlWithEscapedVersion
{
    // configure filters
    TWTRTimelineFilter *filters = [[TWTRTimelineFilter alloc] init];
    filters.urls = [NSSet setWithObjects:@"http://xn--80a0addceeeh.com", nil];

    // use the filter manager, and apply it to a list of tweets
    TWTRTimelineFilterManager *filterManager = [[TWTRTimelineFilterManager alloc] initWithFilters:filters];

    NSArray *tweets = @[[TWTRFixtureLoader punyURLTweet]];

    NSArray *remaining = [filterManager filterTweets:tweets];

    XCTAssertTrue(remaining.count == 0);
}

- (void)testTweetContainsKeywords
{
    TWTRTimelineFilterManager *filterManager = [[TWTRTimelineFilterManager alloc] initWithFilters:nil];

    TWTRTweet *tweet = [TWTRFixtureLoader obamaTweet];
    ;  // (four more years tweet)
    NSSet *keywords = [NSSet setWithObjects:@"President", @"years", @"else", nil];

    XCTAssertTrue([filterManager tweet:tweet containsKeywords:keywords]);

    NSSet *keywords2 = [NSSet setWithObjects:@"President", @"else", nil];
    XCTAssertFalse([filterManager tweet:tweet containsKeywords:keywords2]);
}

- (void)testTextContainsWord
{
    TWTRTimelineFilterManager *filterManager = [[TWTRTimelineFilterManager alloc] initWithFilters:nil];
    XCTAssertTrue([filterManager text:@"Alejandro is not a good programmer" containsWord:@"good"]);
    XCTAssertTrue([filterManager text:@"Alejandro is not a good programmer" containsWord:@"programmer"]);
    XCTAssertFalse([filterManager text:@"Alejandro is not a good programmer" containsWord:@"jan"]);  // should not contain within words
    XCTAssertTrue([filterManager text:@"A" containsWord:@"a"]);
    XCTAssertTrue([filterManager text:@"e" containsWord:@"ě"]);
    XCTAssertTrue([filterManager text:@"Ñandu" containsWord:@"ńandu"]);
    XCTAssertTrue([filterManager text:@"es una vergüenza" containsWord:@"VergÜenza"]);
}

- (void)testLowerCaseTextSetTransformation
{
    TWTRTimelineFilterManager *filterManager = [[TWTRTimelineFilterManager alloc] initWithFilters:nil];

    NSSet *set = [NSSet setWithObjects:@"AleJandrÓ", @"Twitter", nil];
    NSSet *lowercaseSet = [NSSet setWithObjects:@"alejandró", @"twitter", nil];
    XCTAssertTrue([[filterManager lowercaseSetFromStrings:set] isEqualToSet:lowercaseSet]);
}

- (void)testLowerCaseTextTransformation
{
    TWTRTimelineFilterManager *filterManager = [[TWTRTimelineFilterManager alloc] initWithFilters:nil];

    XCTAssertTrue([[filterManager lowercaseText:@"AleJandrÓ"] isEqualToString:@"alejandró"]);
}

@end
