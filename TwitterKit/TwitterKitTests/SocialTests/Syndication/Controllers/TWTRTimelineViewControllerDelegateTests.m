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
#import "TWTRKit.h"
#import "TWTRStubTwitterClient.h"
#import "TWTRTimelineDelegate.h"

@interface TWTRTimelineViewControllerDelegateTests : XCTestCase <TWTRTimelineDelegate>

// Test setup
@property (nonatomic) TWTRTimelineViewController *timeline;
@property (nonatomic) TWTRStubTwitterClient *stubClient;
@property (nonatomic) XCTestExpectation *expectation;

// Delegate method parameters
@property (nonatomic) TWTRTimelineViewController *timelineArgument;
@property (nonatomic) NSArray<TWTRTweet *> *tweets;
@property (nonatomic) NSError *error;
@property (nonatomic) BOOL calledDidBegin;
@property (nonatomic) BOOL calledDidEnd;

@end

@implementation TWTRTimelineViewControllerDelegateTests

- (void)setUp
{
    [super setUp];

    self.stubClient = [TWTRStubTwitterClient stubTwitterClient];

    // Setup the timeline
    id<TWTRTimelineDataSource> dataSource = [[TWTRUserTimelineDataSource alloc] initWithScreenName:@"billgates" APIClient:self.stubClient];
    self.timeline = [[TWTRTimelineViewController alloc] initWithDataSource:dataSource];
    self.timeline.timelineDelegate = self;

    // Delegate arguments
    self.timelineArgument = nil;
    self.tweets = nil;
    self.error = nil;
    self.calledDidEnd = NO;
    self.calledDidEnd = NO;
}
#pragma mark - TWTRTimelineDelegate Tests

- (void)testDelegateNotified_viewWillAppear
{
    XCTAssert(self.calledDidBegin == NO);
    [self.timeline viewWillAppear:NO];
    XCTAssert(self.calledDidBegin == YES);
}

- (void)testDelegateNotified_setDataSource
{
    self.expectation = [self expectationWithDescription:@"async expect"];

    XCTAssert(self.calledDidBegin == NO);
    self.timeline.dataSource = [[TWTRUserTimelineDataSource alloc] initWithScreenName:@"fakeuser" APIClient:self.stubClient];
    [self waitForExpectationsWithTimeout:1.0 handler:nil];

    XCTAssert(self.calledDidBegin == YES);
}

- (void)testDelegateNotified_tweetsLoaded
{
    self.expectation = [self expectationWithDescription:@"async expect"];
    self.stubClient.responseData = [TWTRFixtureLoader manyTweetsData];

    XCTAssert(self.calledDidEnd == NO);
    [self.timeline viewWillAppear:NO];
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    XCTAssert(self.calledDidEnd == YES);
    NSArray *expectedTweetIDs = [[TWTRFixtureLoader manyTweets] valueForKeyPath:@"tweetID"];
    NSArray *notifiedTweetIDs = [self.tweets valueForKeyPath:@"tweetID"];
    XCTAssertEqualObjects(expectedTweetIDs, notifiedTweetIDs);
    XCTAssertNil(self.error);
}

- (void)testDelegateNotified_errorLoading
{
    self.expectation = [self expectationWithDescription:@"async expect"];
    NSError *error = [NSError errorWithDomain:@"fakedomain" code:1337 userInfo:nil];
    self.stubClient.responseError = error;

    XCTAssert(self.calledDidEnd == NO);
    [self.timeline viewWillAppear:NO];
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    XCTAssert(self.calledDidEnd == YES);
    XCTAssertEqualObjects(self.error, error);
    XCTAssertNil(self.tweets);
}

#pragma mark - TWTRTimelineDelegate Methods

- (void)timelineDidBeginLoading:(TWTRTimelineViewController *)timeline
{
    self.timeline = timeline;
    self.calledDidBegin = YES;
}

- (void)timeline:(TWTRTimelineViewController *)timeline didFinishLoadingTweets:(NSArray<TWTRTweet *> *)tweets error:(NSError *)error
{
    self.timeline = timeline;
    self.tweets = tweets;
    self.error = error;
    self.calledDidEnd = YES;
    [self.expectation fulfill];
}

@end
