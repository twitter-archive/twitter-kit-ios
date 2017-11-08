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
#import "TWTRSampleSubscriber.h"
#import "TWTRStore.h"
#import "TWTRSubscription.h"
#import "TWTRTweet.h"

@interface TWTRStoreTests : XCTestCase

@property (nonatomic) TWTRSampleSubscriber *subscriber;
@property (nonatomic) TWTRSampleSubscriber *subscriber2;
@property (nonatomic) TWTRStore *store;

@end

@implementation TWTRStoreTests

- (void)setUp
{
    [super setUp];

    self.subscriber = [[TWTRSampleSubscriber alloc] init];
    self.subscriber2 = [[TWTRSampleSubscriber alloc] init];
    self.store = [[TWTRStore alloc] init];
}

#pragma mark - Notifications

- (void)testNotify_sendsUpdatedObject
{
    TWTRTweet *testTweet = [TWTRFixtureLoader videoTweet];
    [self.store subscribeSubscriber:self.subscriber toClass:[TWTRTweet class] objectID:@"663898858817089536"];

    [self.store notifySubscribersOfChangesToObject:testTweet withID:testTweet.tweetID];

    XCTAssertEqualObjects(self.subscriber.latestObject, testTweet);
}

- (void)testNotify_updatesAllSubscribers
{
    TWTRTweet *testTweet = [TWTRFixtureLoader videoTweet];
    [self.store subscribeSubscriber:self.subscriber toClass:[TWTRTweet class] objectID:@"663898858817089536"];
    [self.store subscribeSubscriber:self.subscriber2 toClass:[TWTRTweet class] objectID:@"663898858817089536"];

    [self.store notifySubscribersOfChangesToObject:testTweet withID:testTweet.tweetID];

    XCTAssertEqualObjects(self.subscriber.latestObject, testTweet);
    XCTAssertEqualObjects(self.subscriber2.latestObject, testTweet);
}

#pragma mark - Unsubscription

- (void)testUnsubscribe_doesNotNotify
{
    TWTRTweet *testTweet = [TWTRFixtureLoader videoTweet];

    // Subscribe, then unsubscribe
    [self.store subscribeSubscriber:self.subscriber toClass:[TWTRTweet class] objectID:testTweet.tweetID];  // Previous tests ensure this works
    [self.store unsubscribeSubscriber:self.subscriber fromClass:[TWTRTweet class] objectID:testTweet.tweetID];

    // Shouldn't notify
    [self.store notifySubscribersOfChangesToObject:testTweet withID:testTweet.tweetID];

    XCTAssertNil(self.subscriber.latestObject);
}

@end
