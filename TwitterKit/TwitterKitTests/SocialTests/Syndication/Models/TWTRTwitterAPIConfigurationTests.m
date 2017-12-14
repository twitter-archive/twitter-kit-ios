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

#import "TWTRFixtureLoader.h"
#import "TWTRTestCase.h"
#import "TWTRTwitterAPIConfiguration.h"

@interface TWTRTwitterAPIConfigurationTests : TWTRTestCase

@property (nonatomic, readonly) TWTRTwitterAPIConfiguration *APIConfiguration;

@end

@implementation TWTRTwitterAPIConfigurationTests

- (void)setUp
{
    [super setUp];

    NSDictionary *configurationDict = [TWTRFixtureLoader dictFromJSONFile:@"APIConfiguration"];
    _APIConfiguration = [[TWTRTwitterAPIConfiguration alloc] initWithJSONDictionary:configurationDict];
}

- (void)testDMTextCharacterLimit
{
    XCTAssertEqual(self.APIConfiguration.DMTextCharacterLimit, 10000);
}

- (void)testCharactersReservedPerMedia
{
    XCTAssertEqual(self.APIConfiguration.charactersReservedPerMedia, 23);
}

- (void)testMaxMediaPerUpload
{
    XCTAssertEqual(self.APIConfiguration.maxMediaPerUpload, 1);
}

- (void)testNonUsernamePaths
{
    XCTAssertGreaterThan([self.APIConfiguration.nonUsernamePaths count], 0);
}

- (void)testPhotoSizeLimit
{
    XCTAssertEqual(self.APIConfiguration.photoSizeLimit, 3145728);
}

- (void)testPhotoSizes
{
    XCTAssertEqual([self.APIConfiguration.photoSizes count], 4);
}

- (void)testShortURLLength
{
    XCTAssertEqual(self.APIConfiguration.shortURLLength, 22);
}

- (void)testShortURLLengthHTTPS
{
    XCTAssertEqual(self.APIConfiguration.shortURLLengthHTTPS, 23);
}

@end
