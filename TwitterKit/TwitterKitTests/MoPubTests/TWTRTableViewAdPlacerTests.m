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

#import <MoPub/MPTableViewAdPlacer.h>
#import <OCMock/OCMock.h>
#import "TWTRMoPubAdConfiguration.h"
#import "TWTRTableViewAdPlacer.h"
#import "TWTRTestCase.h"

@interface TWTRTableViewAdPlacerTests : TWTRTestCase

@property (nonatomic, readonly) TWTRTableViewAdPlacer *adPlacer;
@property (nonatomic, readonly) TWTRMoPubAdConfiguration *config;
@property (nonatomic, readonly) id mockTableView;
@property (nonatomic, readonly) id mockViewController;
@property (nonatomic, readonly) id mockMPTableViewAdPlacer;

@end

@implementation TWTRTableViewAdPlacerTests

- (void)setUp
{
    [super setUp];

    _mockTableView = OCMClassMock([UITableView class]);
    _mockViewController = OCMClassMock([UIViewController class]);
    _config = [[TWTRMoPubAdConfiguration alloc] initWithAdUnitID:@"123" keywords:nil];
    _adPlacer = [[TWTRTableViewAdPlacer alloc] initWithTableView:_mockTableView viewController:_mockViewController adConfiguration:_config];
    _mockMPTableViewAdPlacer = OCMClassMock([MPTableViewAdPlacer class]);
}

- (void)tearDown
{
    [self.mockMPTableViewAdPlacer stopMocking];
    [super tearDown];
}

- (void)testLoadAds_configIsValid
{
    [OCMStub([self.mockMPTableViewAdPlacer placerWithTableView:OCMOCK_ANY viewController:OCMOCK_ANY rendererConfigurations:OCMOCK_ANY]) andReturn:self.mockMPTableViewAdPlacer];
    OCMStub([self.mockMPTableViewAdPlacer loadAdsForAdUnitID:self.config.adUnitID targeting:OCMOCK_ANY]);

    [self.adPlacer loadAdUnitIfConfigured];
    OCMVerifyAll(self.mockMPTableViewAdPlacer);
}

@end
