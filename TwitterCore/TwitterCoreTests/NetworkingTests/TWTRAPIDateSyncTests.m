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
#import "TWTRAPIDateSync.h"
#import "TWTRDateFormatters.h"
#import "TWTRGCOAuth.h"
#import "TWTRTestCase.h"

@interface TWTRAPIDateSyncTests : XCTestCase

@property (nonatomic) NSURL *URL;
@property (nonatomic) id oAuthMock;

@end

@implementation TWTRAPIDateSyncTests

- (void)setUp
{
    [super setUp];

    _URL = [[NSURL alloc] initWithString:@"http://twitter.com"];
    _oAuthMock = [OCMockObject mockForClass:[TWTRGCOAuth class]];
}

- (void)tearDown
{
    [super tearDown];

    [self.oAuthMock stopMocking];
}

- (void)testSync_noHeader
{
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.URL statusCode:200 HTTPVersion:@"" headerFields:@{}];
    TWTRAPIDateSync *dateSync = [[TWTRAPIDateSync alloc] initWithHTTPResponse:response];

    XCTAssertFalse([dateSync sync]);
}

- (void)testSync_badDateHeader
{
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.URL statusCode:200 HTTPVersion:@"" headerFields:@{@"date": @"25 Nov 2015 02:17:45"}];

    TWTRAPIDateSync *dateSync = [[TWTRAPIDateSync alloc] initWithHTTPResponse:response];

    XCTAssertFalse([dateSync sync]);
}

- (void)testSync_noDelta
{
    [[self.oAuthMock expect] setTimestampOffset:0];

    NSString *dateString = [[TWTRDateFormatters HTTPDateHeaderParsingFormatter] stringFromDate:[NSDate date]];

    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.URL statusCode:200 HTTPVersion:@"" headerFields:@{@"date": dateString}];

    TWTRAPIDateSync *dateSync = [[TWTRAPIDateSync alloc] initWithHTTPResponse:response];

    XCTAssertFalse([dateSync sync]);

    [self.oAuthMock verify];
}

- (void)testSync_smallDeltaAhead
{
    [[self.oAuthMock expect] setTimestampOffset:0];

    // 5 minutes ahead
    NSDate *add5Min = [[NSDate date] dateByAddingTimeInterval:(5 * 60)];
    NSString *dateString = [[TWTRDateFormatters HTTPDateHeaderParsingFormatter] stringFromDate:add5Min];

    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.URL statusCode:200 HTTPVersion:@"" headerFields:@{@"date": dateString}];

    TWTRAPIDateSync *dateSync = [[TWTRAPIDateSync alloc] initWithHTTPResponse:response];

    XCTAssertFalse([dateSync sync]);

    [self.oAuthMock verify];
}

- (void)testSync_smallDeltaBehind
{
    [[self.oAuthMock expect] setTimestampOffset:0];

    // 5 minutes behind
    NSDate *minus5Min = [[NSDate date] dateByAddingTimeInterval:(-5 * 60)];
    NSString *dateString = [[TWTRDateFormatters HTTPDateHeaderParsingFormatter] stringFromDate:minus5Min];

    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.URL statusCode:200 HTTPVersion:@"" headerFields:@{@"date": dateString}];

    TWTRAPIDateSync *dateSync = [[TWTRAPIDateSync alloc] initWithHTTPResponse:response];

    XCTAssertFalse([dateSync sync]);

    [self.oAuthMock verify];
}

- (void)testSync_deltaAhead
{
    [[[self.oAuthMock expect] ignoringNonObjectArgs] setTimestampOffset:0];

    // 15 minutes ahead
    NSDate *add15Min = [[NSDate date] dateByAddingTimeInterval:(15 * 60)];
    NSString *dateString = [[TWTRDateFormatters HTTPDateHeaderParsingFormatter] stringFromDate:add15Min];

    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.URL statusCode:200 HTTPVersion:@"" headerFields:@{@"date": dateString}];

    TWTRAPIDateSync *dateSync = [[TWTRAPIDateSync alloc] initWithHTTPResponse:response];

    XCTAssertTrue([dateSync sync]);

    [self.oAuthMock verify];
}

- (void)testSync_deltaBehind
{
    [[[self.oAuthMock expect] ignoringNonObjectArgs] setTimestampOffset:0];

    // 15 minutes behind
    NSDate *minus15Min = [[NSDate date] dateByAddingTimeInterval:(-15 * 60)];
    NSString *dateString = [[TWTRDateFormatters HTTPDateHeaderParsingFormatter] stringFromDate:minus15Min];

    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.URL statusCode:200 HTTPVersion:@"" headerFields:@{@"date": dateString}];

    TWTRAPIDateSync *dateSync = [[TWTRAPIDateSync alloc] initWithHTTPResponse:response];

    XCTAssertTrue([dateSync sync]);

    [self.oAuthMock verify];
}

@end
