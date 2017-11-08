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

#import <OCMock/OCMock.h>
#import "TWTRFixtureLoader.h"
#import "TWTRPersistentStore.h"
#import "TWTRTestCase.h"
#import "TWTRTweet.h"
#import "TWTRTweetCache.h"
#import "TWTRTweet_Private.h"
#import "TWTRUser.h"

#define _TweetTestKey1(key) [NSString stringWithFormat:@"TWTRTweet:%td::%@", [TWTRTweet version], key]
#define _TweetTestKey2(perspective, key) [NSString stringWithFormat:@"TWTRTweet:%td:%@:%@", [TWTRTweet version], perspective, key]

#define UserTestKey (_TweetTestKey2(@"42", @"123"))
#define NoUserTestKey (_TweetTestKey1(@"123"))
#define NoUserHitKey (_TweetTestKey1(@"456"))
#define NoUserMissKey (_TweetTestKey1(@"789"))

static NSString *TestUserID = @"42";
static NSString *const TestTweetID = @"123";
static NSString *const HitTweetID = @"456";
static NSString *const MissTweetID = @"789";

@interface TWTRTweetCacheTests : TWTRTestCase

@property (nonatomic) TWTRTweetCache *cache;
@property (nonatomic) TWTRTweetCache *realCache;
@property (nonatomic) TWTRTweet *obamaTweet;
@property (nonatomic) TWTRTweet *gatesTweet;
@property (nonatomic) id storeMock;

@end

@implementation TWTRTweetCacheTests

- (void)setUp
{
    [super setUp];

    self.gatesTweet = [TWTRFixtureLoader gatesTweet];
    self.obamaTweet = [TWTRFixtureLoader obamaTweet];

    id storeMock = [OCMockObject mockForClass:[TWTRPersistentStore class]];
    TWTRTweetCache *cache = [[TWTRTweetCache alloc] initWithPath:@"cache_test/tweets" maxSize:1048576];
    TWTRTweetCache *realCache = [[TWTRTweetCache alloc] initWithPath:@"cache_test/tweets" maxSize:1048576];
    [realCache.store removeAllObjects];

    self.storeMock = storeMock;
    cache.store = storeMock;
    self.cache = cache;
    self.realCache = realCache;
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testStoreTweetPropagatesStoreReturnValue
{
    TWTRTweetCache *cache = [self cache];
    id storeMock = [self storeMock];

    TWTRTweet *hitTweet = self.obamaTweet;
    TWTRTweet *missTweet = self.gatesTweet;
    [hitTweet setValue:HitTweetID forKey:@"tweetID"];
    [missTweet setValue:MissTweetID forKey:@"tweetID"];
    [(TWTRPersistentStore *)[[storeMock stub] andReturnValue:@YES] setObject:hitTweet forKey:NoUserHitKey];
    [(TWTRPersistentStore *)[[storeMock stub] andReturnValue:@NO] setObject:missTweet forKey:NoUserMissKey];

    XCTAssertTrue([cache storeTweet:hitTweet perspective:nil]);
    XCTAssertFalse([cache storeTweet:missTweet perspective:nil]);
}

- (void)testStoreTweetIncludesViewingUserID
{
    TWTRTweetCache *cache = [self cache];
    id storeMock = [self storeMock];

    TWTRTweet *mockTweet = self.obamaTweet;
    [mockTweet setValue:TestTweetID forKey:@"tweetID"];

    [(TWTRPersistentStore *)[storeMock expect] setObject:mockTweet forKey:UserTestKey];

    [cache storeTweet:mockTweet perspective:TestUserID];
    [storeMock verify];
}

- (void)testTweetWithIDIncludesViewingUserID
{
    TWTRTweetCache *cache = [self cache];
    id storeMock = [self storeMock];

    TWTRTweet *mockTweet = self.obamaTweet;
    [mockTweet setValue:TestTweetID forKey:@"tweetID"];

    [[storeMock expect] objectForKey:UserTestKey];

    [cache tweetWithID:TestTweetID perspective:TestUserID];
    [storeMock verify];
}

- (void)testTweetWithIDReturnsTweet
{
    TWTRTweetCache *cache = [self cache];
    id storeMock = [self storeMock];

    TWTRTweet *tweet = self.obamaTweet;
    [[[storeMock stub] andReturn:tweet] objectForKey:NoUserHitKey];

    XCTAssertTrue([cache tweetWithID:HitTweetID perspective:nil]);
}

- (void)testTweetWithIDReturnsNilIfTypeMismatch
{
    TWTRTweetCache *cache = [self cache];
    id storeMock = [self storeMock];

    NSObject *mismatch = [[NSObject alloc] init];
    [[[storeMock stub] andReturn:mismatch] objectForKey:NoUserTestKey];
    [(TWTRPersistentStore *)[storeMock expect] removeObjectForKey:NoUserTestKey];

    XCTAssertNil([cache tweetWithID:TestTweetID perspective:nil]);
}

- (void)testTweetWithIDReturnsNilIfStoreEntryIsNil
{
    TWTRTweetCache *cache = [self cache];
    id storeMock = [self storeMock];

    [[[storeMock stub] andReturn:nil] objectForKey:NoUserTestKey];

    XCTAssertNil([cache tweetWithID:TestTweetID perspective:nil]);
}

- (void)testTweetWithIDRemoveStoreEntryIfTypeMismatch
{
    TWTRTweetCache *cache = [self cache];
    id storeMock = [self storeMock];

    NSObject *mismatch = [[NSObject alloc] init];
    [[[storeMock stub] andReturn:mismatch] objectForKey:NoUserTestKey];
    [(TWTRPersistentStore *)[storeMock expect] removeObjectForKey:NoUserTestKey];

    XCTAssertNil([cache tweetWithID:TestTweetID perspective:nil]);
    [storeMock verify];
}

- (void)testTweetVersionBump_doesNotRetrieveOldVersion
{
    NSString *tweetID = @"123";
    TWTRTweet *tweet = self.obamaTweet;
    [tweet setValue:tweetID forKey:@"tweetID"];
    NSInteger currentVersion = [TWTRTweet version];

    [self.realCache storeTweet:tweet perspective:nil];
    XCTAssertNotNil([self.realCache tweetWithID:tweetID perspective:nil]);

    // bump the version
    NSInteger newVersion = currentVersion + 1;
    id tweetClassMock = OCMClassMock([TWTRTweet class]);
    [[[tweetClassMock stub] andReturnValue:@(newVersion)] version];

    XCTAssertNil([self.realCache tweetWithID:tweetID perspective:nil]);

    [tweetClassMock stopMocking];
}

@end
