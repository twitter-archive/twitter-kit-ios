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
#import "TWTRAPIServiceConfig.h"
#import "TWTRFakeAPIServiceConfig.h"
#import "TWTRTestCase.h"

@interface TWTRAPIServiceConfigTests : TWTRTestCase

@property (nonatomic, readonly) TWTRFakeAPIServiceConfig *apiServiceConfig;

@end

@implementation TWTRAPIServiceConfigTests

- (void)setUp
{
    [super setUp];

    _apiServiceConfig = [[TWTRFakeAPIServiceConfig alloc] init];
}

- (void)tearDown
{
    [super tearDown];
    _apiServiceConfig = nil;
}

- (void)testTWTRAPIURLWithPath_missingParams
{
    XCTAssertNil(TWTRAPIURLWithPath(nil, @""), @"It must return nil if API configuration is nil");
    XCTAssertNil(TWTRAPIURLWithPath(self.apiServiceConfig, nil), @"It must return nil if path is nil");
}

- (void)testTWTRAPIURLWithPath_root
{
    NSURL *url = TWTRAPIURLWithPath(self.apiServiceConfig, @"/");
    XCTAssertEqualObjects(url.absoluteString, @"https://api.sample.com/");
}

- (void)testTWTRAPIURLWithPath_query
{
    NSURL *url = TWTRAPIURLWithPath(self.apiServiceConfig, @"/?query=tweet");
    XCTAssertEqualObjects(url.absoluteString, @"https://api.sample.com/?query=tweet");
}

- (void)testTWTRAPIURLWithPath_path
{
    NSURL *url = TWTRAPIURLWithPath(self.apiServiceConfig, @"/sample/path?query=tweet");
    XCTAssertEqualObjects(url.absoluteString, @"https://api.sample.com/sample/path?query=tweet");
}

- (void)testTWTRAPIURLWithParams_missingParams
{
    XCTAssertNil(TWTRAPIURLWithParams(nil, @"", nil), @"It must return nil if API configuration is nil");
    XCTAssertNil(TWTRAPIURLWithParams(self.apiServiceConfig, nil, nil), @"It must return nil if path is nil");
    XCTAssertNil(TWTRAPIURLWithParams(self.apiServiceConfig, @"/", nil), @"It must return nil` if params is nil");
}

- (void)testTWTRAPIURLWithParams_newParams
{
    NSURL *url = TWTRAPIURLWithParams(self.apiServiceConfig, @"/", @{ @"param1": @"test" });
    XCTAssertEqualObjects(url.absoluteString, @"https://api.sample.com/?param1=test");
}

- (void)testTWTRAPIURLWithParams_existingParams
{
    NSURL *url = TWTRAPIURLWithParams(self.apiServiceConfig, @"/sample/path?query=test", @{ @"param1": @"test" });
    XCTAssertEqualObjects(url.absoluteString, @"https://api.sample.com/sample/path?query=test&param1=test");
}

@end
