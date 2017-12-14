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
#import "TWTRCollectionTimelineDataSource.h"
#import "TWTRKit.h"
#import "TWTRTimelineCursor.h"

@interface TWTRCollectionTimelineDataSourceTests : XCTestCase

@property (nonatomic, strong) TWTRCollectionTimelineDataSource *dataSource;
@property (nonatomic, strong) id mockAPIClient;

@end

@implementation TWTRCollectionTimelineDataSourceTests

- (void)setUp
{
    [super setUp];

    self.mockAPIClient = OCMClassMock([TWTRAPIClient class]);
    self.dataSource = [[TWTRCollectionTimelineDataSource alloc] initWithCollectionID:@"393773266801659904" APIClient:self.mockAPIClient];
}

- (void)testCollectionTimeline_RequestsCorrectTimeline
{
    OCMExpect([self.mockAPIClient loadTweetsForCollectionID:@"393773266801659904" parameters:[OCMArg any] timelineFilterManager:nil completion:[OCMArg any]]);

    [self.dataSource loadPreviousTweetsBeforePosition:nil
                                           completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                           }];

    OCMVerifyAll(self.mockAPIClient);
}

#pragma mark - Default Parameters

- (void)testCollectionTimeline_DefaultParametersEmptyDict
{
    OCMExpect([self.mockAPIClient loadTweetsForCollectionID:[OCMArg any]
                                                 parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *params) {
                                                     NSLog(@"%@", params);
                                                     return [params isEqual:@{}];
                                                 }]
                                      timelineFilterManager:nil
                                                 completion:[OCMArg any]]);

    [self.dataSource loadPreviousTweetsBeforePosition:nil
                                           completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                           }];

    OCMVerifyAll(self.mockAPIClient);
}

#pragma mark - Count

- (void)testCollectionTimeline_ProperCountIfSet
{
    TWTRCollectionTimelineDataSource *dataSource = [[TWTRCollectionTimelineDataSource alloc] initWithCollectionID:@"123225235" APIClient:self.mockAPIClient maxTweetsPerRequest:60];
    OCMExpect([self.mockAPIClient loadTweetsForCollectionID:[OCMArg any]
                                                 parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *params) {
                                                     return [params[@"count"] isEqualToString:@"60"];
                                                 }]
                                      timelineFilterManager:nil
                                                 completion:[OCMArg any]]);

    [dataSource loadPreviousTweetsBeforePosition:nil
                                      completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                      }];

    OCMVerifyAll(self.mockAPIClient);
}

#pragma mark - Cursors

- (void)testCollectionTimeline_MaxPositionSet
{
    OCMExpect([self.mockAPIClient loadTweetsForCollectionID:[OCMArg any]
                                                 parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *params) {
                                                     return [params[@"max_position"] isEqualToString:@"9087"];
                                                 }]
                                      timelineFilterManager:nil
                                                 completion:[OCMArg any]]);

    [self.dataSource loadPreviousTweetsBeforePosition:@"9087"
                                           completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                           }];

    OCMVerifyAll(self.mockAPIClient);
}

@end
