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
#import "TWTRFixtureLoader.h"
#import "TWTRTweetCache.h"
#import "TWTRTweetMediaEntity.h"
#import "TWTRTweetRepository.h"
#import "TWTRTweet_Private.h"
#import "TWTRVideoMetaData.h"
#import "TWTRVideoPlaybackConfiguration.h"

@interface TWTRVideoEntityTests : XCTestCase

@property (nonatomic, readonly) TWTRTweet *videoTweet;
@property (nonatomic, readonly) TWTRVideoMetaData *videoMetaData;

@end

@implementation TWTRVideoEntityTests

- (void)setUp
{
    _videoTweet = [TWTRFixtureLoader videoTweet];
    _videoMetaData = _videoTweet.videoMetaData;

    [super setUp];
}

- (void)testVideoTweet_initializedVideoURL
{
    XCTAssert(self.videoMetaData.videoURL != nil);
}

- (void)testVideoTweet_serializesProperly
{
    NSData *archivedTweet = [NSKeyedArchiver archivedDataWithRootObject:self.videoTweet];
    TWTRTweet *restoredTweet = [NSKeyedUnarchiver unarchiveObjectWithData:archivedTweet];

    XCTAssertEqualObjects(restoredTweet.videoMetaData.videoURL, self.videoTweet.videoMetaData.videoURL);
    XCTAssertEqualObjects(restoredTweet.videoMetaData.variants, self.videoTweet.videoMetaData.variants);
    XCTAssertEqualWithAccuracy(restoredTweet.videoMetaData.aspectRatio, self.videoTweet.videoMetaData.aspectRatio, __FLT_EPSILON__);
    XCTAssertEqual(restoredTweet.videoMetaData.duration, self.videoTweet.videoMetaData.duration);
}

- (void)testVideoTweet_initializedDuration
{
    XCTAssertEqualWithAccuracy(self.videoMetaData.duration, 5.3, __FLT_EPSILON__);
}

- (void)testVideoTweet_initializedAspectRatio
{
    XCTAssertEqualWithAccuracy(self.videoMetaData.aspectRatio, 16.0 / 9.0, __FLT_EPSILON__);
}

- (void)testVideoTweet_variantsCount
{
    XCTAssert(self.videoMetaData.variants.count == 6);
}

- (void)testVideoTweet_variantFirst
{
    TWTRVideoMetaDataVariant *variant = [self.videoMetaData.variants firstObject];
    XCTAssertEqual(variant.bitrate, 2176000);
    XCTAssertEqualObjects(variant.contentType, TWTRMediaTypeMP4);
    XCTAssertEqualObjects(variant.URL, [NSURL URLWithString:@"https://video.twimg.com/ext_tw_video/663898843579179008/pu/vid/1280x720/WNuByFKseh6PHDbv.mp4"]);
}

@end
