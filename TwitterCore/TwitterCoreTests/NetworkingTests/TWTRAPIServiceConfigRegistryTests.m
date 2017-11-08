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

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "TWTRAPIServiceConfig.h"
#import "TWTRAPIServiceConfigRegistry.h"
#import "TWTRFakeAPIServiceConfig.h"

@interface TWTRAPIServiceConfigRegistryTests : XCTestCase
@property (nonatomic, readonly) TWTRAPIServiceConfigRegistry *registry;
@property (nonatomic, readonly) id<TWTRAPIServiceConfig> config;

@end

@implementation TWTRAPIServiceConfigRegistryTests

- (void)setUp
{
    [super setUp];
    _registry = [[TWTRAPIServiceConfigRegistry alloc] init];
    _config = [[TWTRRandomAPIServiceConfig alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testDefaultConfigRegistry
{
    TWTRAPIServiceConfigRegistry *first = [TWTRAPIServiceConfigRegistry defaultRegistry];
    TWTRAPIServiceConfigRegistry *second = [TWTRAPIServiceConfigRegistry defaultRegistry];
    XCTAssertEqual(first, second);
}

- (void)testRegisterWithType_actuallyRegisters
{
    TWTRAPIServiceConfigType type = TWTRAPIServiceConfigTypeDefault;
    XCTAssertNil([self.registry configForType:type]);
    [self.registry registerServiceConfig:self.config forType:type];
    XCTAssertEqualObjects(self.config, [self.registry configForType:type]);
}

- (void)testRegisterWithType_onlyReturnForRegisteredType
{
    [self.registry registerServiceConfig:self.config forType:TWTRAPIServiceConfigTypeDefault];
    XCTAssertNotNil([self.registry configForType:TWTRAPIServiceConfigTypeDefault]);
    XCTAssertNil([self.registry configForType:TWTRAPIServiceConfigTypeCards]);
}

- (void)testRegisterWithType_multipleTypes
{
    id<TWTRAPIServiceConfig> defaultConfig = [[TWTRRandomAPIServiceConfig alloc] init];
    id<TWTRAPIServiceConfig> cardsConfig = [[TWTRRandomAPIServiceConfig alloc] init];

    [self.registry registerServiceConfig:defaultConfig forType:TWTRAPIServiceConfigTypeDefault];
    [self.registry registerServiceConfig:cardsConfig forType:TWTRAPIServiceConfigTypeCards];

    XCTAssertEqualObjects(defaultConfig, [self.registry configForType:TWTRAPIServiceConfigTypeDefault]);
    XCTAssertEqualObjects(cardsConfig, [self.registry configForType:TWTRAPIServiceConfigTypeCards]);
}

@end
