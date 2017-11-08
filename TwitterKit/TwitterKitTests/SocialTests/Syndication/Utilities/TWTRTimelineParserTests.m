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
#import "TWTRTimelineParser.h"
#import "TWTRTweet.h"

@interface TWTRTimelineParserTests : XCTestCase

@property (nonatomic, readonly) NSDictionary *collectionResponse;

@end

@implementation TWTRTimelineParserTests

- (void)setUp
{
    [super setUp];
    _collectionResponse = [TWTRFixtureLoader collectionAPIResponse];
}

- (void)testTweetsFromCollectionAPIResponse
{
    NSArray *tweets = [TWTRTimelineParser tweetsFromCollectionAPIResponseDictionary:self.collectionResponse];
    XCTAssertNotNil(tweets);
    XCTAssertEqual(tweets.count, 15);
}

- (void)testTweetsFromCollectionAPIResponse_populatesQuoteTweets
{
    NSArray *tweets = [TWTRTimelineParser tweetsFromCollectionAPIResponseDictionary:self.collectionResponse];
    NSInteger quoteTweets = 0;

    for (TWTRTweet *tweet in tweets) {
        if (tweet.isQuoteTweet) {
            quoteTweets += 1;
        }
    }

    XCTAssertEqual(quoteTweets, 3);
}

- (void)testTweetsFromCollectionAPIResponse_preservesOrder
{
    NSArray *tweets = [TWTRTimelineParser tweetsFromCollectionAPIResponseDictionary:self.collectionResponse];
    TWTRTweet *first = tweets.firstObject;
    TWTRTweet *last = tweets.lastObject;

    XCTAssertEqualObjects(first.tweetID, @"773592402292420608");
    XCTAssertEqualObjects(last.tweetID, @"658839613964873728");
}

@end
