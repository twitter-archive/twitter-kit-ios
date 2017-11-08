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
#import <XCTest/XCTest.h>
#import "TWTRAPIClient_Private.h"
#import "TWTRListTimelineDataSource.h"
#import "TWTRTestCase.h"

@interface TWTRListTimelineDataSourceTests : TWTRTestCase

@property (nonatomic, strong) TWTRListTimelineDataSource *dataSource;
@property (nonatomic, strong) id mockAPIClient;

@end

@implementation TWTRListTimelineDataSourceTests

- (void)setUp
{
    [super setUp];

    self.mockAPIClient = OCMClassMock([TWTRAPIClient class]);
    self.dataSource = [[TWTRListTimelineDataSource alloc] initWithListID:@"123" APIClient:self.mockAPIClient];
}

#pragma mark - Init

- (void)testInitWithListID_success
{
    TWTRListTimelineDataSource *dataSource = [[TWTRListTimelineDataSource alloc] initWithListID:@"123" APIClient:self.mockAPIClient];
    XCTAssertNotNil(dataSource.listID);
}

- (void)testInitWithListID_setsDefaultMaxTweetsPerRequest
{
    TWTRListTimelineDataSource *dataSource = [[TWTRListTimelineDataSource alloc] initWithListID:@"123" APIClient:self.mockAPIClient];
    XCTAssertEqual(dataSource.maxTweetsPerRequest, 30);
}

- (void)testInitWithListID_setsDefaultIncludeRetweets
{
    TWTRListTimelineDataSource *dataSource = [[TWTRListTimelineDataSource alloc] initWithListID:@"123" APIClient:self.mockAPIClient];
    XCTAssertTrue(dataSource.includeRetweets);
}

- (void)testInitWithListSlugOwner_success
{
    TWTRListTimelineDataSource *dataSource = [[TWTRListTimelineDataSource alloc] initWithListSlug:@"slug" listOwnerScreenName:@"screenname" APIClient:self.mockAPIClient];
    XCTAssertNotNil(dataSource.listSlug);
    XCTAssertNotNil(dataSource.listOwnerScreenName);
}

- (void)testInitWithListSlug_setsDefaultMaxTweetsPerRequest
{
    TWTRListTimelineDataSource *dataSource = [[TWTRListTimelineDataSource alloc] initWithListSlug:@"slug" listOwnerScreenName:@"screenname" APIClient:self.mockAPIClient];
    XCTAssertEqual(dataSource.maxTweetsPerRequest, 30);
}

- (void)testInitWithListSlug_setsDefaultIncludeRetweets
{
    TWTRListTimelineDataSource *dataSource = [[TWTRListTimelineDataSource alloc] initWithListSlug:@"slug" listOwnerScreenName:@"screenname" APIClient:self.mockAPIClient];
    XCTAssertTrue(dataSource.includeRetweets);
}

- (void)testInitWithListIDSlugOwner_IDOnlyIsOK
{
    TWTRListTimelineDataSource *dataSource = [[TWTRListTimelineDataSource alloc] initWithListID:@"123" listSlug:nil listOwnerScreenName:nil APIClient:self.mockAPIClient maxTweetsPerRequest:10 includeRetweets:YES];
    XCTAssertNotNil(dataSource.listID);
}

- (void)testInitWithListIDSlugOwner_slugAndOwnerIsOK
{
    TWTRListTimelineDataSource *dataSource = [[TWTRListTimelineDataSource alloc] initWithListID:nil listSlug:@"slug" listOwnerScreenName:@"screenname" APIClient:self.mockAPIClient maxTweetsPerRequest:10 includeRetweets:YES];
    XCTAssertNotNil(dataSource.listSlug);
    XCTAssertNotNil(dataSource.listOwnerScreenName);
}

- (void)testInitWithListIDSlugOwner_maxTweetsPerRequestSet
{
    TWTRListTimelineDataSource *dataSource = [[TWTRListTimelineDataSource alloc] initWithListID:nil listSlug:@"slug" listOwnerScreenName:@"screenname" APIClient:self.mockAPIClient maxTweetsPerRequest:10 includeRetweets:YES];
    XCTAssertEqual(dataSource.maxTweetsPerRequest, 10);
}

- (void)testInitWithListIDSlugOwner_includeRetweetsTrue
{
    TWTRListTimelineDataSource *dataSource = [[TWTRListTimelineDataSource alloc] initWithListID:nil listSlug:@"slug" listOwnerScreenName:@"screenname" APIClient:self.mockAPIClient maxTweetsPerRequest:10 includeRetweets:YES];
    XCTAssertTrue(dataSource.includeRetweets);
}

- (void)testInitWithListIDSlugOwner_includeRetweetsFalse
{
    TWTRListTimelineDataSource *dataSource = [[TWTRListTimelineDataSource alloc] initWithListID:nil listSlug:@"slug" listOwnerScreenName:@"screenname" APIClient:self.mockAPIClient maxTweetsPerRequest:10 includeRetweets:NO];
    XCTAssertFalse(dataSource.includeRetweets);
}

#pragma mark - API Params

- (void)testLoadPreviousTweets_countSet
{
    OCMExpect([self.mockAPIClient loadTweetsForListID:OCMOCK_ANY parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *params) {
                                                                     return [params[@"count"] isEqualToString:@"30"];
                                                                 }]
                                timelineFilterManager:nil
                                           completion:OCMOCK_ANY]);

    [self.dataSource loadPreviousTweetsBeforePosition:nil completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
    }];
    OCMVerifyAll(self.mockAPIClient);
}

- (void)testLoadPreviousTweets_includeRetweetsSet
{
    OCMExpect([self.mockAPIClient loadTweetsForListID:OCMOCK_ANY parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *params) {
                                                                     return [params[@"include_rts"] isEqualToString:@"true"];
                                                                 }]
                                timelineFilterManager:nil
                                           completion:OCMOCK_ANY]);

    [self.dataSource loadPreviousTweetsBeforePosition:nil completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
    }];
    OCMVerifyAll(self.mockAPIClient);
}

- (void)testLoadPreviousTweets_noMaxIDSet
{
    OCMExpect([self.mockAPIClient loadTweetsForListID:OCMOCK_ANY parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *params) {
                                                                     return params[@"max_id"] == nil;
                                                                 }]
                                timelineFilterManager:nil
                                           completion:OCMOCK_ANY]);

    [self.dataSource loadPreviousTweetsBeforePosition:nil completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
    }];
    OCMVerifyAll(self.mockAPIClient);
}

- (void)testLoadPreviousTweets_maxIDSet
{
    OCMExpect([self.mockAPIClient loadTweetsForListID:OCMOCK_ANY parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *params) {
                                                                     return [params[@"max_id"] isEqualToString:@"12344"];
                                                                 }]
                                timelineFilterManager:nil
                                           completion:OCMOCK_ANY]);

    [self.dataSource loadPreviousTweetsBeforePosition:@"12345" completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
    }];
    OCMVerifyAll(self.mockAPIClient);
}

#pragma mark - Scribing

- (void)testLoadPreviousTweets_HasCorrectTimelineType
{
    XCTAssertEqual(self.dataSource.timelineType, TWTRTimelineTypeList);
}

@end
