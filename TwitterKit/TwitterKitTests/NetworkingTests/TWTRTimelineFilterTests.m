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

@interface TWTRTimelineFilterTests : TWTRTestCase
@end

@implementation TWTRTimelineFilterTests

- (void)testJSONInitializationWithNilDictionary
{
    NSDictionary *dictionary = @{};
    TWTRTimelineFilter *filters = [[TWTRTimelineFilter alloc] initWithJSONDictionary:dictionary];
    XCTAssertTrue(filters.keywords == [NSSet set]);
    XCTAssertTrue(filters.handles == [NSSet set]);
    XCTAssertTrue(filters.hashtags == [NSSet set]);
    XCTAssertTrue(filters.urls == [NSSet set]);
}

- (void)testJSONInitialization
{
    NSDictionary *dictionary = [TWTRFixtureLoader dictFromJSONFile:@"sample_timeline_filter"];
    TWTRTimelineFilter *filters = [[TWTRTimelineFilter alloc] initWithJSONDictionary:dictionary];

    NSSet *keywords = [NSSet setWithObjects:@"Sucks", @"Shucks", nil];
    XCTAssertTrue([filters.keywords isEqualToSet:keywords]);

    NSSet *handles = [NSSet setWithObjects:@"@benward", @"@vam_si", @"@eric", @"@surelyThere", nil];
    XCTAssertTrue([filters.handles isEqualToSet:handles]);

    NSSet *hashtags = [NSSet setWithObjects:@"#justdoit", @"#Coke", @"#CokeIsAwesome", nil];
    XCTAssertTrue([filters.hashtags isEqualToSet:hashtags]);

    NSSet *urls = [NSSet setWithObjects:@"cokeisawesome.com", @"dontbeevil.com", @"fun.coke.com", @"http://coke.com", nil];
    XCTAssertTrue([filters.urls isEqualToSet:urls]);
}

- (void)testFilterProperties
{
    TWTRTimelineFilter *filters = [[TWTRTimelineFilter alloc] init];
    XCTAssertTrue([filters respondsToSelector:@selector(keywords)]);
    XCTAssertTrue([filters respondsToSelector:@selector(urls)]);
    XCTAssertTrue([filters respondsToSelector:@selector(hashtags)]);
    XCTAssertTrue([filters respondsToSelector:@selector(handles)]);
}

- (void)testSupportsCopying
{
    TWTRTimelineFilter *filters = [[TWTRTimelineFilter alloc] init];
    filters.keywords = [NSSet setWithObjects:@"apple", @"twitter", nil];
    filters.urls = [NSSet setWithObjects:@"apple.com", @"twitter.com", nil];
    filters.hashtags = [NSSet setWithObjects:@"#apple", @"#twitter", nil];
    filters.handles = [NSSet setWithObjects:@"@apple", @"@twitter", nil];

    // copy it
    TWTRTimelineFilter *filtersCopy = [filters copy];

    // properties remain the same
    XCTAssert([filtersCopy.keywords isEqualToSet:filters.keywords]);
    XCTAssert([filtersCopy.hashtags isEqualToSet:filters.hashtags]);
    XCTAssert([filtersCopy.urls isEqualToSet:filters.urls]);
    XCTAssert([filtersCopy.handles isEqualToSet:filters.handles]);
}

@end
