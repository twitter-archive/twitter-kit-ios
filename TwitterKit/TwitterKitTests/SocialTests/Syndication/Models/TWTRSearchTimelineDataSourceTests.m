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
#import "TWTRSearchTimelineDataSource.h"
#import "TWTRTimelineCursor.h"

@interface TWTRSearchTimelineDataSourceTests : XCTestCase

@property (nonatomic, strong) TWTRSearchTimelineDataSource *dataSource;
@property (nonatomic, strong) id mockAPIClient;

@end

@implementation TWTRSearchTimelineDataSourceTests

- (void)setUp
{
    [super setUp];
    self.mockAPIClient = OCMClassMock([TWTRAPIClient class]);
    self.dataSource = [[TWTRSearchTimelineDataSource alloc] initWithSearchQuery:@"#hashtag" APIClient:self.mockAPIClient];
}

#pragma mark - Retweets

- (void)testSearchTimeline_DefaultSearchQueryFiltersRetweets
{
    // Should have the extra filter added
    OCMExpect([self.mockAPIClient loadTweetsForSearchQuery:[OCMArg checkWithBlock:^BOOL(NSString *searchQuery) {
                                      return [searchQuery containsString:@"-filter:retweets"];
                                  }]
                                                parameters:[OCMArg any]
                                     timelineFilterManager:nil
                                                completion:[OCMArg any]]);

    [self.dataSource loadPreviousTweetsBeforePosition:nil
                                           completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                           }];
    OCMVerifyAll(self.mockAPIClient);
}

#pragma mark - Batch Size

- (void)testSearchTimeline_DefaultBatchSize
{
    OCMExpect([self.mockAPIClient loadTweetsForSearchQuery:[OCMArg any]
                                                parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *parameters) {
                                                    return [parameters[@"count"] isEqualToString:@"30"];
                                                }]
                                     timelineFilterManager:nil
                                                completion:[OCMArg any]]);

    [self.dataSource loadPreviousTweetsBeforePosition:nil
                                           completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                           }];

    OCMVerifyAll(self.mockAPIClient);
}

- (void)testSearchTimeline_SetsBatchSize
{
    TWTRSearchTimelineDataSource *dataSource = [[TWTRSearchTimelineDataSource alloc] initWithSearchQuery:@"query" APIClient:self.mockAPIClient languageCode:nil maxTweetsPerRequest:40 resultType:nil];

    OCMExpect([self.mockAPIClient loadTweetsForSearchQuery:[OCMArg any]
                                                parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *parameters) {
                                                    return [parameters[@"count"] isEqualToString:@"40"];
                                                }]
                                     timelineFilterManager:nil
                                                completion:[OCMArg any]]);

    [dataSource loadPreviousTweetsBeforePosition:nil
                                      completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                      }];

    OCMVerifyAll(self.mockAPIClient);
}

#pragma mark - Language Code

- (void)testSearchTimeline_NoLanguageCodeByDefault
{
    OCMExpect([self.mockAPIClient loadTweetsForSearchQuery:[OCMArg any]
                                                parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *parameters) {
                                                    return ![[parameters allKeys] containsObject:@"lang"];
                                                }]
                                     timelineFilterManager:nil
                                                completion:[OCMArg any]]);

    [self.dataSource loadPreviousTweetsBeforePosition:nil
                                           completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                           }];

    // Search timeline should not include the 'lang' parameter by default
    OCMVerifyAll(self.mockAPIClient);
}

- (void)testSearchTimeline_AddsLanguageCode
{
    OCMExpect([self.mockAPIClient loadTweetsForSearchQuery:[OCMArg any]
                                                parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *parameters) {
                                                    return [parameters[@"lang"] isEqualToString:@"es"];
                                                }]
                                     timelineFilterManager:nil
                                                completion:[OCMArg any]]);
    TWTRSearchTimelineDataSource *dataSource = [[TWTRSearchTimelineDataSource alloc] initWithSearchQuery:@"query" APIClient:self.mockAPIClient languageCode:@"es" maxTweetsPerRequest:40 resultType:nil];

    [dataSource loadPreviousTweetsBeforePosition:nil
                                      completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                      }];

    // Should both include the 'lang' parameter and ensure the value is correct
    OCMVerifyAll(self.mockAPIClient);
}

#pragma mark - Cursor

- (void)testSearchTimeline_NoCursorKeyIfMissing
{
    OCMExpect([self.mockAPIClient loadTweetsForSearchQuery:[OCMArg any]
                                                parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *parameters) {
                                                    return ![[parameters allKeys] containsObject:@"max_id"];
                                                }]
                                     timelineFilterManager:nil
                                                completion:[OCMArg any]]);

    [self.dataSource loadPreviousTweetsBeforePosition:nil
                                           completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                           }];
    OCMVerifyAll(self.mockAPIClient);
}

- (void)testSearchTimeline_ProperCursorParameters
{
    OCMExpect([self.mockAPIClient loadTweetsForSearchQuery:[OCMArg any]
                                                parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *parameters) {
                                                    return [parameters[@"max_id"] isEqualToString:@"9086"];
                                                }]
                                     timelineFilterManager:nil
                                                completion:[OCMArg any]]);

    [self.dataSource loadPreviousTweetsBeforePosition:@"9087"
                                           completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                           }];
    OCMVerifyAll(self.mockAPIClient);
}

#pragma mark - Timeline Type

- (void)testSearchTimeline_HasCorrectTimelineType
{
    XCTAssertEqual(self.dataSource.timelineType, TWTRTimelineTypeSearch);
}

#pragma mark - Filtered Results

- (void)testSearchTimeline_MixedResultTypeByDefault
{
    OCMExpect([self.mockAPIClient loadTweetsForSearchQuery:[OCMArg any]
                                                parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *parameters) {
                                                    return [parameters[@"result_type"] isEqualToString:@"mixed"];
                                                }]
                                     timelineFilterManager:nil
                                                completion:[OCMArg any]]);

    [self.dataSource loadPreviousTweetsBeforePosition:nil
                                           completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                           }];
    OCMVerifyAll(self.mockAPIClient);
}

#pragma mark - Safe Search

- (void)testSearchTimeline_SafeSearchByDefault
{
    OCMExpect([self.mockAPIClient loadTweetsForSearchQuery:[OCMArg checkWithBlock:^BOOL(NSString *query) {
                                      return [query containsString:@"filter:safe"];
                                  }]
                                                parameters:[OCMArg any]
                                     timelineFilterManager:nil
                                                completion:[OCMArg any]]);

    [self.dataSource loadPreviousTweetsBeforePosition:nil
                                           completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                           }];
    OCMVerifyAll(self.mockAPIClient);
}

- (void)testSearchTimeline_FalseRemovesQuery
{
    OCMExpect([self.mockAPIClient loadTweetsForSearchQuery:[OCMArg checkWithBlock:^BOOL(NSString *query) {
                                      return ![query containsString:@"filter:safe"];
                                  }]
                                                parameters:[OCMArg any]
                                     timelineFilterManager:nil
                                                completion:[OCMArg any]]);

    self.dataSource.filterSensitiveTweets = NO;
    [self.dataSource loadPreviousTweetsBeforePosition:nil
                                           completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                           }];
    OCMVerifyAll(self.mockAPIClient);
}

#pragma mark - Geocode

- (void)testSearchTimeline_AddsGeocodeWhenPassedIn
{
    OCMExpect([self.mockAPIClient loadTweetsForSearchQuery:[OCMArg any]
                                                parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *parameters) {
                                                    return [parameters[@"geocode"] isEqualToString:@"37.781157,-122.398720,1mi"];
                                                }]
                                     timelineFilterManager:nil
                                                completion:[OCMArg any]]);
    TWTRSearchTimelineDataSource *dataSource = [[TWTRSearchTimelineDataSource alloc] initWithSearchQuery:@"query" APIClient:self.mockAPIClient languageCode:nil maxTweetsPerRequest:40 resultType:nil];
    dataSource.geocodeSpecifier = @"37.781157,-122.398720,1mi";

    [dataSource loadPreviousTweetsBeforePosition:nil
                                      completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                      }];

    // Should both include the 'geocode' parameter and ensure the value is correct
    OCMVerifyAll(self.mockAPIClient);
}

- (void)testSearchTimeline_DoesNotAddParameterByDefault
{
    OCMExpect([self.mockAPIClient loadTweetsForSearchQuery:[OCMArg any]
                                                parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *parameters) {
                                                    return ![[parameters allKeys] containsObject:@"geocode"];
                                                }]
                                     timelineFilterManager:nil
                                                completion:[OCMArg any]]);

    [self.dataSource loadPreviousTweetsBeforePosition:nil
                                           completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                           }];
    OCMVerifyAll(self.mockAPIClient);
}

- (void)testSearchTimeline_AddsResultTypeWhenPassed
{
    OCMExpect([self.mockAPIClient loadTweetsForSearchQuery:[OCMArg any]
                                                parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *parameters) {
                                                    return [parameters[@"result_type"] isEqualToString:@"recent"];
                                                }]
                                     timelineFilterManager:nil
                                                completion:[OCMArg any]]);

    TWTRSearchTimelineDataSource *dataSource = [[TWTRSearchTimelineDataSource alloc] initWithSearchQuery:@"query" APIClient:self.mockAPIClient languageCode:nil maxTweetsPerRequest:40 resultType:@"recent"];
    [dataSource loadPreviousTweetsBeforePosition:nil
                                      completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                      }];

    [self.dataSource loadPreviousTweetsBeforePosition:nil
                                           completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                           }];
    OCMVerifyAll(self.mockAPIClient);
}

- (void)testSearchTimeline_DefaultToMixedWhenWrongResultTypeWasPassed
{
    OCMExpect([self.mockAPIClient loadTweetsForSearchQuery:[OCMArg any]
                                                parameters:[OCMArg checkWithBlock:^BOOL(NSDictionary *parameters) {
                                                    return [parameters[@"result_type"] isEqualToString:@"mixed"];
                                                }]
                                     timelineFilterManager:nil
                                                completion:[OCMArg any]]);

    TWTRSearchTimelineDataSource *dataSource = [[TWTRSearchTimelineDataSource alloc] initWithSearchQuery:@"query" APIClient:self.mockAPIClient languageCode:nil maxTweetsPerRequest:40 resultType:@"typo"];
    [dataSource loadPreviousTweetsBeforePosition:nil
                                      completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                      }];

    [self.dataSource loadPreviousTweetsBeforePosition:nil
                                           completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error){
                                           }];
    OCMVerifyAll(self.mockAPIClient);
}

@end
