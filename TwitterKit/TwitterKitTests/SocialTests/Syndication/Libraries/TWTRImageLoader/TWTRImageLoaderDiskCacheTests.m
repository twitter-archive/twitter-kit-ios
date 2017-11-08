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
#import "TWTRImageLoaderCache.h"
#import "TWTRTestCase.h"

static const NSUInteger MB = 1048576;

@interface TWTRImageLoaderDiskCacheTests : TWTRTestCase

@property (nonatomic) UIImage *image;
@property (nonatomic) TWTRImageLoaderDiskCache *diskCache;

@end

@implementation TWTRImageLoaderDiskCacheTests

- (void)setUp
{
    [super setUp];

    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *assetCacheFullPath = [cacheDir stringByAppendingPathComponent:@"cache/assets_test"];
    self.diskCache = [[TWTRImageLoaderDiskCache alloc] initWithPath:assetCacheFullPath maxSize:1 * MB];

    NSData *imageData = [TWTRFixtureLoader dataFromFile:@"test" ofType:@"png"];
    self.image = [UIImage imageWithData:imageData];
}

- (void)tearDown
{
    [self.diskCache removeAllImages];
    [super tearDown];
}

- (void)testInit_badPathReturnsNil
{
    TWTRImageLoaderDiskCache *cache = [[TWTRImageLoaderDiskCache alloc] initWithPath:@"/bad_path" maxSize:1 * MB];
    XCTAssertNil(cache);
}

- (void)testInit_goodPathOk
{
    XCTAssertNotNil(self.diskCache);
}

- (void)testSetImageWithKey_success
{
    NSString *imageKey = @"key";
    [self.diskCache setImage:self.image forKey:imageKey];
    XCTAssertNotNil([self.diskCache fetchImageForKey:imageKey]);
}

- (void)testSetImageDataWithKey_success
{
    NSString *imageKey = @"key";
    [self.diskCache setImage:self.image forKey:imageKey];
    XCTAssertNotNil([self.diskCache fetchImageForKey:imageKey]);
}

- (void)testFetchImageForKey_nonexistentKeyNil
{
    XCTAssertNil([self.diskCache fetchImageForKey:@"nonexistent"]);
}

- (void)testFetchImageForKey_existingKeyFound
{
    NSString *imageKey = @"key";
    [self.diskCache setImage:self.image forKey:imageKey];
    XCTAssertNotNil([self.diskCache fetchImageForKey:imageKey]);
}

- (void)testRemoveImageForKey_nonexistentKeyReturnsNil
{
    XCTAssertNil([self.diskCache removeImageForKey:@"nonexistent"]);
}

- (void)testRemoveImageForKey_existingKeyReturnsImage
{
    NSString *imageKey = @"key";
    [self.diskCache setImage:self.image forKey:imageKey];
    XCTAssertNotNil([self.diskCache removeImageForKey:imageKey]);
}

- (void)testRemoveAllImages_nothingToRemove
{
    XCTAssertNoThrow([self.diskCache removeAllImages]);
}

- (void)testRemoveAllImages_removesImagesSuccess
{
    [self.diskCache setImage:self.image forKey:@"image1"];
    [self.diskCache setImage:self.image forKey:@"image2"];
    [self.diskCache removeAllImages];

    XCTAssertNil([self.diskCache fetchImageForKey:@"image1"]);
    XCTAssertNil([self.diskCache fetchImageForKey:@"image2"]);
}

@end
