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
#import <UIKit/UIKit.h>
#import "TWTRFixtureLoader.h"
#import "TWTRKit.h"
#import "TWTRMoPubAdConfiguration.h"
#import "TWTRNotificationCenter.h"
#import "TWTRNotificationConstants.h"
#import "TWTRProfileHeaderView.h"
#import "TWTRStubTimelineDataSource.h"
#import "TWTRStubTwitterClient.h"
#import "TWTRTestCase.h"
#import "TWTRTimelineCursor.h"
#import "TWTRTimelineViewController.h"
#import "TWTRTweet.h"
#import "TWTRTweetContentView+Layout.h"
#import "TWTRTweetView.h"
#import "TWTRTweetView_Private.h"
#import "TWTRTwitter_Private.h"

@interface TWTRTimelineViewController ()

- (void)setCurrentCursor:(TWTRTimelineCursor *)cursor;
- (void)loadPreviousTweets;
- (void)refresh;
@property (nonatomic) NSMutableArray *tweets;

@end

@interface TWTRTimelineViewControllerTests : TWTRTestCase

@property (nonatomic) TWTRTimelineViewController *timeline;
@property (nonatomic) id mockDataSource;
@property (nonatomic) TWTRMoPubAdConfiguration *adConfig;

@end

@implementation TWTRTimelineViewControllerTests

+ (void)setUp
{
    [[TWTRTwitter sharedInstance] startWithConsumerKey:@"key" consumerSecret:@"secret"];
}

- (void)setUp
{
    [super setUp];

    TWTRStubTwitterClient *stubClient = [TWTRStubTwitterClient stubTwitterClient];
    stubClient.responseData = [TWTRFixtureLoader manyTweetsData];

    self.adConfig = [[TWTRMoPubAdConfiguration alloc] initWithAdUnitID:@"123" keywords:@"foo:bar,baz:qux"];
    TWTRUserTimelineDataSource *dataSource = [[TWTRUserTimelineDataSource alloc] initWithScreenName:@"billgates" APIClient:stubClient];
    self.mockDataSource = OCMPartialMock(dataSource);
    self.timeline = [[TWTRTimelineViewController alloc] initWithDataSource:self.mockDataSource];
    self.timeline.view.frame = CGRectMake(0, 0, 320, 480);  // Needed for cell height calculations
    [self.timeline viewWillAppear:YES];                     // Loads more tweets
}

- (void)tearDown
{
    [self.mockDataSource stopMocking];
}

- (void)testTimelineViewController_HasCorrectNumberOfRows
{
    [self waitForCompletionWithTimeout:1.0
                                 check:^BOOL {
                                     return [self.timeline tableView:self.timeline.tableView numberOfRowsInSection:0] == 7;
                                 }];
}

- (void)testTimelineViewController_HasCorrectNumberOfSections
{
    XCTAssertEqual([self.timeline numberOfSectionsInTableView:self.timeline.tableView], 1);
}

- (void)testTimelineViewController_DoesNotAllowSelection
{
    XCTAssertEqual(self.timeline.tableView.allowsSelection, NO);
}

- (void)testTimelineViewController_LoadsMoreTweetsForLastRow
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"wait for network"];

    dispatch_async(dispatch_get_main_queue(), ^{
        OCMExpect([self.mockDataSource loadPreviousTweetsBeforePosition:[OCMArg any] completion:[OCMArg any]]);  // Should load more once we ask for the last tweet
        [self.timeline tableView:self.timeline.tableView willDisplayCell:[[UITableViewCell alloc] init] forRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:0]];

        OCMVerifyAllWithDelay(self.mockDataSource, 1.0);
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testTimelineViewController_HasAutomaticHeightSet
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    XCTAssertEqual([self.timeline tableView:self.timeline.tableView heightForRowAtIndexPath:indexPath], UITableViewAutomaticDimension);
}

- (void)testTimelineViewController_ReturnsConfiguredTableCell
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"wait for network"];

    dispatch_async(dispatch_get_main_queue(), ^{
        TWTRTweetTableViewCell *cell = (TWTRTweetTableViewCell *)[self.timeline tableView:self.timeline.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        XCTAssertEqualObjects(cell.tweetView.contentView.profileHeaderView.fullname.text, @"CanadianSpaceAgency");
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testTimelineViewController_UsesProperCursorNextTime
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"wait for network"];

    dispatch_async(dispatch_get_main_queue(), ^{
        OCMExpect([self.mockDataSource loadPreviousTweetsBeforePosition:[OCMArg checkWithBlock:^BOOL(NSString *lastTweetID) {
                                           return [lastTweetID isEqualToString:@"483693675445100546"];
                                       }]
                                                             completion:[OCMArg any]]);
        [self.timeline tableView:self.timeline.tableView willDisplayCell:[[UITableViewCell alloc] init] forRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:0]];

        OCMVerifyAllWithDelay(self.mockDataSource, 1.0);
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testTimelineViewController_DoesNotSaveNewCursor
{
    TWTRStubTimelineDataSource *stubDataSource = [[TWTRStubTimelineDataSource alloc] init];
    stubDataSource.tweets = @[];
    id mockTimelineVC = OCMPartialMock([[TWTRTimelineViewController alloc] initWithDataSource:stubDataSource]);
    [[mockTimelineVC reject] setCurrentCursor:[OCMArg any]];

    [mockTimelineVC loadPreviousTweets];
    OCMVerifyAll(mockTimelineVC);
}

#pragma mark - Refresh

- (void)testTimelineViewController_HasRefreshControl
{
    XCTAssert(self.timeline.refreshControl != nil);
}

- (void)testTimelineViewController_LoadsNewestTweets
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"wait for network"];

    dispatch_async(dispatch_get_main_queue(), ^{
        [[self.mockDataSource expect] loadPreviousTweetsBeforePosition:nil completion:OCMOCK_ANY];  // nil Position is newest Tweets

        [self.timeline refresh];
        OCMVerifyAllWithDelay(self.mockDataSource, 1.0);
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testTimelineViewController_EndsRefreshing
{
    TWTRTimelineViewController *timeline = [[TWTRTimelineViewController alloc] initWithDataSource:[[TWTRStubTimelineDataSource alloc] init]];
    [timeline viewDidLoad];

    id timelineMock = OCMPartialMock(timeline);
    id mockRefreshControl = OCMPartialMock(timeline.refreshControl);
    OCMExpect([mockRefreshControl endRefreshing]);
    OCMStub([mockRefreshControl isRefreshing]).andReturn(YES);
    OCMStub([timelineMock refreshControl]).andReturn(mockRefreshControl);

    [timelineMock refresh];

    OCMVerifyAll(mockRefreshControl);
    [mockRefreshControl stopMocking];
}

- (void)testTimelineViewController_ReplacesTweets
{
    TWTRStubTimelineDataSource *stubDataSource = [[TWTRStubTimelineDataSource alloc] init];
    stubDataSource.tweets = @[[TWTRFixtureLoader gatesTweet]];  // 1 Tweet
    self.timeline.dataSource = stubDataSource;
    [self.timeline refresh];
    XCTAssertEqual([self.timeline tableView:self.timeline.tableView numberOfRowsInSection:0], 1);

    stubDataSource.tweets = [TWTRFixtureLoader manyTweets];  // Now there are 7
    [self.timeline refresh];
    XCTAssertEqual([self.timeline tableView:self.timeline.tableView numberOfRowsInSection:0], 7);
}

- (void)testTimelineViewController_UpdatesTweetModelOnLike
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"wait for network"];

    /// Spin the run-loop so the timeline can load.
    dispatch_async(dispatch_get_main_queue(), ^{
        TWTRTweet *secondTweet = self.timeline.tweets[1];
        [TWTRNotificationCenter postNotificationName:TWTRDidLikeTweetNotification tweet:[secondTweet tweetWithLikeToggled] userInfo:nil];
        TWTRTweet *updatedSecond = self.timeline.tweets[1];
        XCTAssert(updatedSecond.isLiked);
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testTimelineViewController_HidesActionsByDefault
{
    XCTAssert(self.timeline.showTweetActions == NO);
}

#pragma mark - MoPub Integration

- (void)testAdConfigUnsetByDefault
{
    TWTRTimelineViewController *vc = [[TWTRTimelineViewController alloc] initWithDataSource:self.mockDataSource];
    XCTAssertNil(vc.adConfiguration);
}

- (void)testAdConfigCanOnlyBeSetOnce
{
    TWTRMoPubAdConfiguration *adConfig2 = [[TWTRMoPubAdConfiguration alloc] initWithAdUnitID:@"1" keywords:@"foo:bar"];
    TWTRTimelineViewController *vc = [[TWTRTimelineViewController alloc] initWithDataSource:self.mockDataSource adConfiguration:self.adConfig];
    vc.adConfiguration = adConfig2;
    XCTAssertEqual(vc.adConfiguration, self.adConfig);
}

@end
