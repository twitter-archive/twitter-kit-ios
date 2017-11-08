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
#import "TWTRAuthenticationConstants.h"
#import "TWTRFileManager.h"

@interface TWTRFileSystemTests : XCTestCase

@end

@implementation TWTRFileSystemTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testCacheDirectory
{
    NSURL *cacheDirectory = [TWTRFileManager cacheDirectory];
    XCTAssertNotNil(cacheDirectory, @"Unable to create cache directory");
}

- (void)testFileCreate
{
    NSURL *cachesDirectory = [TWTRFileManager cacheDirectory];
    XCTAssertNotNil(cachesDirectory, @"error getting caches directory");
    BOOL success = [TWTRFileManager createFileWithName:@"test.txt" inDirectory:cachesDirectory];
    XCTAssertTrue(success, @"Failed to create file");
}

- (void)testDictionaryToFile
{
    NSURL *cachesDirectory = [TWTRFileManager cacheDirectory];
    XCTAssertNotNil(cachesDirectory, @"error getting caches directory");
    NSDictionary *testDict = @{ @"one": @"hello", @"two": @"world" };
    BOOL success = [TWTRFileManager writeDictionary:testDict toFileName:@"test.plist" inDirectory:cachesDirectory];
    XCTAssertTrue(success, @"Failed to create file");
    NSDictionary *recvdDict = [TWTRFileManager readDictionaryFromFileName:@"test.plist" inDirectory:cachesDirectory];
    XCTAssertEqualObjects(testDict, recvdDict, @"Failed to read dictionary correctly");
}

@end
