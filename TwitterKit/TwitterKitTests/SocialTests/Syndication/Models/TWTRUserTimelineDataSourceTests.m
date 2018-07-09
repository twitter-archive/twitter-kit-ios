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
#import <XCTest/XCTest.h>
#import "TWTRAPIClient_Private.h"
#import "TWTRKit.h"
#import "TWTRTimelineCursor.h"
#import "TWTRUserTimelineDataSource.h"

@interface TWTRUserTimelineDataSourceTests : XCTestCase

@property (nonatomic, strong) TWTRUserTimelineDataSource *dataSource;
@property (nonatomic, strong) id mockAPIClient;

@end

@implementation TWTRUserTimelineDataSourceTests

- (void)setUp
{
    [super setUp];
    self.mockAPIClient = OCMClassMock([TWTRAPIClient class]);
    self.dataSource = [[TWTRUserTimelineDataSource alloc] initWithScreenName:@"jack" APIClient:self.mockAPIClient];
}

- (void)testUserTimeline_RequestsCorrectTimeline
{
    OCMExpect([self.mockAPIClient loadTweetsForUserTimeline:@"jack" userID:nil parameters:[OCMArg any] timelineFilterManager:nil completion:[OCMArg any]]);

    [self.dataSource loadPreviousTweetsBeforePosition:nil
                                           completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                           }];

    OCMVerifyAll(self.mockAPIClient);
}

#pragma mark - Count

- (void)testUserTimeline_DefaultCount
{
    OCMExpect([self.mockAPIClient loadTweetsForUserTimeline:[OCMArg any]
                                                     userID:nil
                                                 parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *params) {
                                                     return [params[@"count"] isEqualToString:@"30"];
                                                 }]
                                      timelineFilterManager:nil
                                                 completion:[OCMArg any]]);

    [self.dataSource loadPreviousTweetsBeforePosition:nil
                                           completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                           }];

    OCMVerifyAll(self.mockAPIClient);
}

- (void)testUserTimeline_ProperCountIfSet
{
    TWTRUserTimelineDataSource *dataSource = [[TWTRUserTimelineDataSource alloc] initWithScreenName:@"jack" userID:nil APIClient:self.mockAPIClient maxTweetsPerRequest:50 includeReplies:NO includeRetweets:YES];

    OCMExpect([self.mockAPIClient loadTweetsForUserTimeline:[OCMArg any]
                                                     userID:nil
                                                 parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *params) {
                                                     return [params[@"count"] isEqualToString:@"50"];
                                                 }]
                                      timelineFilterManager:nil
                                                 completion:[OCMArg any]]);

    [dataSource loadPreviousTweetsBeforePosition:nil
                                      completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                      }];
    OCMVerifyAll(self.mockAPIClient);
}

#pragma mark - Replies

- (void)testUserTimeline_DefaultValueIncludeReplies
{
    XCTAssert(self.dataSource.includeReplies == NO);
}

- (void)testUserTimeline_ExcludesRepliesByDefault
{
    OCMExpect([self.mockAPIClient loadTweetsForUserTimeline:[OCMArg any]
                                                     userID:nil
                                                 parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *params) {
                                                     return [params[@"exclude_replies"] isEqualToString:@"true"];
                                                 }]
                                      timelineFilterManager:nil
                                                 completion:[OCMArg any]]);

    [self.dataSource loadPreviousTweetsBeforePosition:nil
                                           completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                           }];

    OCMVerifyAll(self.mockAPIClient);
}

- (void)testUserTimeline_IncludesRepliesIfSet
{
    TWTRUserTimelineDataSource *dataSource = [[TWTRUserTimelineDataSource alloc] initWithScreenName:@"jack" userID:nil APIClient:self.mockAPIClient maxTweetsPerRequest:50 includeReplies:YES includeRetweets:YES];

    OCMExpect([self.mockAPIClient loadTweetsForUserTimeline:[OCMArg any]
                                                     userID:nil
                                                 parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *params) {
                                                     return [params[@"exclude_replies"] isEqualToString:@"false"];
                                                 }]
                                      timelineFilterManager:nil
                                                 completion:[OCMArg any]]);

    [dataSource loadPreviousTweetsBeforePosition:nil
                                      completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                      }];

    OCMVerifyAll(self.mockAPIClient);
}

#pragma mark - Retweets

- (void)testUserTimeline_DefaultValueIncludeRetweets
{
    XCTAssert(self.dataSource.includeRetweets == YES);
}

- (void)testUserTimeline_IncludesRetweetsByDefault
{
    OCMExpect([self.mockAPIClient loadTweetsForUserTimeline:[OCMArg any]
                                                     userID:nil
                                                 parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *params) {
                                                     return [params[@"include_rts"] isEqualToString:@"true"];
                                                 }]
                                      timelineFilterManager:nil
                                                 completion:[OCMArg any]]);

    [self.dataSource loadPreviousTweetsBeforePosition:nil
                                           completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                           }];

    OCMVerifyAll(self.mockAPIClient);
}

- (void)testUserTimeline_ExcludesRetweetsIfSet
{
    TWTRUserTimelineDataSource *dataSource = [[TWTRUserTimelineDataSource alloc] initWithScreenName:@"jack" userID:nil APIClient:self.mockAPIClient maxTweetsPerRequest:50 includeReplies:NO includeRetweets:NO];
    OCMExpect([self.mockAPIClient loadTweetsForUserTimeline:[OCMArg any]
                                                     userID:nil
                                                 parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *params) {
                                                     return [params[@"include_rts"] isEqualToString:@"false"];
                                                 }]
                                      timelineFilterManager:nil
                                                 completion:[OCMArg any]]);

    [dataSource loadPreviousTweetsBeforePosition:nil
                                      completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                      }];

    OCMVerifyAll(self.mockAPIClient);
}

#pragma mark - Cursor Handling

- (void)testUserTimeline_NoMaxID
{
    // Make sure that the cursor is added to the dictionary of parameters if tweets have already been received
    OCMExpect([self.mockAPIClient loadTweetsForUserTimeline:[OCMArg any]
                                                     userID:nil
                                                 parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *parameters) {
                                                     return ![[parameters allKeys] containsObject:@"max_id"];  // Make sure the key isn't included
                                                 }]
                                      timelineFilterManager:nil
                                                 completion:[OCMArg any]]);

    [self.dataSource loadPreviousTweetsBeforePosition:nil
                                           completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                           }];

    OCMVerifyAll(self.mockAPIClient);
}

- (void)testUserTimeline_ProperCursorParameters
{
    // Make sure that the cursor is added to the dictionary of parameters if tweets have already been received
    OCMExpect([self.mockAPIClient loadTweetsForUserTimeline:[OCMArg any]
                                                     userID:nil
                                                 parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *parameters) {
                                                     return [parameters[@"max_id"] isEqualToString:@"9086"];  // Needs to use the min position, minus one
                                                 }]
                                      timelineFilterManager:nil
                                                 completion:[OCMArg any]]);

    [self.dataSource loadPreviousTweetsBeforePosition:@"9087"
                                           completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                           }];

    OCMVerifyAll(self.mockAPIClient);
}

#pragma mark - Scribing

- (void)testUserTimeline_HasCorrectTimelineType
{
    XCTAssertEqual(self.dataSource.timelineType, TWTRTimelineTypeUser);
}

@end
