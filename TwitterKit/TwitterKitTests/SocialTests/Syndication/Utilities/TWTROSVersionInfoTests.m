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
#import "TWTROSVersionInfo.h"

@interface TWTROSVersionInfoTests : XCTestCase

@property (nonatomic) id mockProcess;

@end

@implementation TWTROSVersionInfoTests

- (void)setUp
{
    [super setUp];
    self.mockProcess = [OCMockObject niceMockForClass:[NSProcessInfo class]];
    [[[[self.mockProcess stub] classMethod] andReturn:self.mockProcess] processInfo];
}

- (void)tearDown
{
    [self.mockProcess stopMocking];
    [super tearDown];
}

- (void)testiOS8
{
    [self mockMajorVersion:8 minorVersion:0];
    XCTAssert([TWTROSVersionInfo majorVersion] == 8);
}

- (void)testiOS9
{
    [self mockMajorVersion:9 minorVersion:0];

    XCTAssert([TWTROSVersionInfo majorVersion] == 9);
}

- (void)mockMajorVersion:(NSInteger)majorVersion minorVersion:(NSInteger)minorVersion
{
    NSOperatingSystemVersion version = {majorVersion, minorVersion, 0};
    OCMStub([self.mockProcess operatingSystemVersion]).andReturn(version);
}

@end
