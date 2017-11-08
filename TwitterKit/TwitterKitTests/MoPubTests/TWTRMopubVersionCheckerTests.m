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

#import <MoPub/MoPub.h>
#import <OCMock/OCMock.h>
#import "TWTRMoPubVersionChecker.h"
#import "TWTRTestCase.h"

@interface TWTRMopubVersionCheckerTests : TWTRTestCase

@end

@implementation TWTRMopubVersionCheckerTests

- (void)testIntegerVersion_returnsCorrectInteger
{
    [self testVersionParsingWithMoPubVersion:@"4.6.0" test:^BOOL {
        return [TWTRMoPubVersionChecker integerVersion] == 40600;
    }];
}

- (void)testIntegerVersion_noMajorVersion
{
    [self testVersionParsingWithMoPubVersion:@"0.6.0" test:^BOOL {
        return [TWTRMoPubVersionChecker integerVersion] == 600;
    }];
}

- (void)testIntegerVersion_noMinorVersion
{
    [self testVersionParsingWithMoPubVersion:@"0.0.1" test:^BOOL {
        return [TWTRMoPubVersionChecker integerVersion] == 1;
    }];
}

- (void)testIntegerVersion_noPatchVersion
{
    [self testVersionParsingWithMoPubVersion:@"0.1" test:^BOOL {
        return [TWTRMoPubVersionChecker integerVersion] == 100;
    }];
}

- (void)testIntegerVersion_noMinorAndPatchVersion
{
    [self testVersionParsingWithMoPubVersion:@"1" test:^BOOL {
        return [TWTRMoPubVersionChecker integerVersion] == 10000;
    }];
}

- (void)testIntegerVersion_majorButNoMinor
{
    [self testVersionParsingWithMoPubVersion:@"1.0.1" test:^BOOL {
        return [TWTRMoPubVersionChecker integerVersion] == 10001;
    }];
}

- (void)testIntegerVersion_missingVersionNumber
{
    [self testVersionParsingWithMoPubVersion:@"" test:^BOOL {
        return [TWTRMoPubVersionChecker integerVersion] == 0;
    }];
}

- (void)testIsValidVersion_belowRequired
{
    [self testVersionParsingWithMoPubVersion:@"4.5.9" test:^BOOL() {
        return [TWTRMoPubVersionChecker isValidVersion] == NO;
    }];
}

- (void)testIsValidVersion_hasRequired
{
    [self testVersionParsingWithMoPubVersion:@"4.6.0" test:^BOOL() {
        return [TWTRMoPubVersionChecker isValidVersion];
    }];
}

- (void)testIsValidVersion_handlesPlusKit
{
    [self testVersionParsingWithMoPubVersion:@"4.6.0+kit" test:^BOOL() {
        return [TWTRMoPubVersionChecker isValidVersion];
    }];
}

- (void)testVersionParsingWithMoPubVersion:(NSString *)versionString test:(BOOL (^)())testBlock
{
    id mockMopub = OCMClassMock([MoPub class]);
    OCMStub([mockMopub sharedInstance]).andReturn(mockMopub);
    OCMStub([mockMopub performSelector:@selector(version)]).andReturn(versionString);

    XCTAssertTrue(testBlock());
}

@end
