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

#import "TWTRImageLoaderImageUtils.h"
#import "TWTRImageTestHelper.h"
#import "TWTRTestCase.h"

@interface TWTRImageLoaderImageUtilsTests : TWTRTestCase

@property (nonatomic) UIImage *imageWithAlphaChannel;
@property (nonatomic) UIImage *imageWithNoAlphaChannel;

@end

@implementation TWTRImageLoaderImageUtilsTests

- (void)setUp
{
    [super setUp];

    self.imageWithAlphaChannel = [TWTRImageTestHelper imageWithColor:[UIColor whiteColor] size:CGSizeMake(1, 1) opaque:NO];
    self.imageWithNoAlphaChannel = [TWTRImageTestHelper imageWithColor:[UIColor whiteColor] size:CGSizeMake(1, 1) opaque:YES];
}

- (void)testImageHasAlphaChannel_yes
{
    const BOOL hasAlpha = [TWTRImageLoaderImageUtils imageHasAlphaChannel:self.imageWithAlphaChannel];
    XCTAssertTrue(hasAlpha);
}

- (void)testImageHasAlphaChannel_no
{
    const BOOL hasAlpha = [TWTRImageLoaderImageUtils imageHasAlphaChannel:self.imageWithNoAlphaChannel];
    XCTAssertFalse(hasAlpha);
}

- (void)testImageDataFromImageCompressionQuality_qualityTooLowOk
{
    NSData *const imageData = [TWTRImageLoaderImageUtils imageDataFromImage:self.imageWithAlphaChannel compressionQuality:-1.0];
    XCTAssertNotNil(imageData);
}

- (void)testImageDataFromImageCompressionQuality_qualityTooHighOk
{
    NSData *const imageData = [TWTRImageLoaderImageUtils imageDataFromImage:self.imageWithAlphaChannel compressionQuality:100];
    XCTAssertNotNil(imageData);
}

@end
