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

#import "TWTRAssetURLSessionConfig.h"
#import "TWTRTestCase.h"

@interface TWTRAssetURLSessionConfigTests : TWTRTestCase

@property (nonatomic) NSURLSessionConfiguration *sessionConfig;

@end

@implementation TWTRAssetURLSessionConfigTests

- (void)setUp
{
    [super setUp];
    self.sessionConfig = [TWTRAssetURLSessionConfig defaultConfiguration];
}

- (void)testDefaultAssetURLSessionConfiguration_onlyAcceptImages
{
    XCTAssertEqualObjects(self.sessionConfig.HTTPAdditionalHeaders[@"Accept"], @"image/*");
}

- (void)testDefaultSessionConfiguration_pipeliningEnabled
{
    XCTAssertTrue(self.sessionConfig.HTTPShouldUsePipelining);
}

- (void)testDefaultConfigurationContainsUserAgent
{
    NSURLSessionConfiguration *config = [TWTRAssetURLSessionConfig defaultConfiguration];
    XCTAssertNotNil(config.HTTPAdditionalHeaders[@"User-Agent"]);
}

@end
