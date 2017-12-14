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
#import "TWTRPersistentStore.h"

@interface TWTRPersistentStoreTests : XCTestCase
@property (nonatomic, strong) TWTRPersistentStore *store;
@end

@implementation TWTRPersistentStoreTests

- (void)setUp
{
    [super setUp];

    static const NSUInteger MB = 1048576;
    static const NSUInteger AssetCacheMaxSize = 10 * MB;

    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];

    NSString *AssetCachePath = @"cache/assets";
    NSString *assetCacheFullPath = [cacheDir stringByAppendingPathComponent:AssetCachePath];
    self.store = [[TWTRPersistentStore alloc] initWithPath:assetCacheFullPath maxSize:AssetCacheMaxSize];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testStoreInstantiatesCorrectly
{
    XCTAssertNotNil(self.store, @"Should have created a store.");
}

- (void)testStoreSetsObject
{
    NSDate *date = [NSDate date];
    [self.store setObject:date forKey:@"today"];
    NSDate *retrievedDate = [self.store objectForKey:@"today"];
    XCTAssertTrue([date isEqual:retrievedDate], @"Should have returned the same object");
}

- (void)testStoreWorksWithURLs
{
    NSString *key = @"https://www.testurl.com/details?query=search";
    NSDate *date = [NSDate date];
    [self.store setObject:date forKey:key];
    NSDate *retrievedDate = [self.store objectForKey:key];
    XCTAssertTrue([date isEqual:retrievedDate], @"Should have returned the same object");
}

@end
