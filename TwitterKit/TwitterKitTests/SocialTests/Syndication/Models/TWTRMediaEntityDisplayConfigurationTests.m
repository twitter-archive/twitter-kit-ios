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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TWTRFixtureLoader.h"
#import "TWTRMediaEntityDisplayConfiguration.h"
#import "TWTRTestCase.h"
#import "TWTRTweetMediaEntity.h"
#import "TWTRTweet_Private.h"

@interface TWTRMediaEntityDisplayConfigurationTests : TWTRTestCase
@property (nonatomic) TWTRTweetMediaEntity *obamaMediaEntity;
@property (nonatomic) TWTRMediaEntityDisplayConfiguration *smallConfig;
@property (nonatomic) TWTRMediaEntityDisplayConfiguration *largeConfig;
@property (nonatomic) TWTRTweet *vineTweet;

@end

@implementation TWTRMediaEntityDisplayConfigurationTests

- (void)setUp
{
    self.obamaMediaEntity = [TWTRFixtureLoader obamaTweetMediaEntity];
    self.vineTweet = [TWTRFixtureLoader vineTweetV13];

    self.smallConfig = [[TWTRMediaEntityDisplayConfiguration alloc] initWithMediaEntity:self.obamaMediaEntity targetWidth:300];
    self.largeConfig = [[TWTRMediaEntityDisplayConfiguration alloc] initWithMediaEntity:self.obamaMediaEntity targetWidth:900];

    [super setUp];
}

- (void)testSetupMediaEntity
{
    XCTAssertNotNil(self.obamaMediaEntity);
}

- (void)testImagePath_small
{
    NSString *targetPath = @"https://pbs.twimg.com/media/A7EiDWcCYAAZT1D.jpg:small";
    XCTAssertEqualObjects(self.smallConfig.imagePath, targetPath);
}

- (void)testImagePath_large
{
    NSString *targetPath = @"https://pbs.twimg.com/media/A7EiDWcCYAAZT1D.jpg:large";
    XCTAssertEqualObjects(self.largeConfig.imagePath, targetPath);
}

- (void)testImageSize_small
{
    CGSize targetSize = CGSizeMake(340, 226);
    CGSize actualSize = self.smallConfig.imageSize;

    XCTAssertTrue(CGSizeEqualToSize(targetSize, actualSize), @"expeted size %@ but got %@", NSStringFromCGSize(targetSize), NSStringFromCGSize(actualSize));
}

- (void)testImageSize_large
{
    CGSize targetSize = CGSizeMake(800, 532);
    CGSize actualSize = self.largeConfig.imageSize;

    XCTAssertTrue(CGSizeEqualToSize(targetSize, actualSize), @"expeted size %@ but got %@", NSStringFromCGSize(targetSize), NSStringFromCGSize(actualSize));
}

- (void)testVineCard_MediaDisplayConfiguration
{
    TWTRMediaEntityDisplayConfiguration *mediaConfig = [TWTRMediaEntityDisplayConfiguration mediaEntityDisplayConfigurationWithCardEntity:self.vineTweet.cardEntity];
    XCTAssertNotNil(mediaConfig);

    XCTAssertEqualObjects(mediaConfig.imagePath, @"https://o.twimg.com/2/proxy.jpg?t=HBiTAWh0dHBzOi8vdi5jZG4udmluZS5jby9yL3ZpZGVvcy8zRkZFMUUyMDA3MTI4MjYwODg2ODU2ODA1NTgwOF80ODZmMzM1MWJjZC40LjAuNjI0NDkwOTg0OTkxMjQyOTQ1Ny5tcDQuanBnP3ZlcnNpb25JZD1nTVRvZ2F6WG9TRFROTW1QbHcxR1k3bUxuUU5INk51cRTABxTABwAWABIA&s=GfB6XVj7OvsuKx-bj7qKnrykBB-esuQWgEE8opJX0DA");
    XCTAssertEqual(mediaConfig.imageSize.width, 480);
    XCTAssertEqual(mediaConfig.imageSize.height, 480);

    XCTAssertNil(mediaConfig.pillText);
    XCTAssertNotNil(mediaConfig.pillImage);
}

@end
