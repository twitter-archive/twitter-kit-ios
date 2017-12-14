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
#import "TWTRCardEntity.h"
#import "TWTRFixtureLoader.h"
#import "TWTRTweet.h"
#import "TWTRTweetMediaEntity.h"
#import "TWTRTweet_Private.h"
#import "TWTRVideoDeeplinkConfiguration.h"
#import "TWTRVideoPlaybackConfiguration.h"

@interface TWTRVideoPlaybackConfigurationTests : XCTestCase

@property (nonatomic, readonly) TWTRTweet *videoTweet;
@property (nonatomic, readonly) TWTRTweet *vineTweet;

@end

@implementation TWTRVideoPlaybackConfigurationTests

- (void)setUp
{
    [super setUp];
    _videoTweet = [TWTRFixtureLoader videoTweet];
    _vineTweet = [TWTRFixtureLoader vineTweetV13];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testVideoTweet_VideoPlaybackConfiguration
{
    TWTRVideoPlaybackConfiguration *videoConfig = [TWTRVideoPlaybackConfiguration playbackConfigurationForTweetMediaEntity:self.videoTweet.media.firstObject];
    XCTAssertNotNil(videoConfig);

    XCTAssertEqualObjects(videoConfig.videoURL.absoluteString, @"https://video.twimg.com/ext_tw_video/663898843579179008/pu/pl/2trF5epotzI5YT07.m3u8");
    XCTAssertEqualWithAccuracy(videoConfig.aspectRatio, 16.0 / 9.0, 0.1);
    XCTAssertEqual(videoConfig.duration, 5.3);
    XCTAssertEqual(videoConfig.mediaType, TWTRMediaTypeVideo);
}

- (void)testVineCard_VideoPlaybackConfiguration
{
    TWTRVideoPlaybackConfiguration *videoConfig = [TWTRVideoPlaybackConfiguration playbackConfigurationForCardEntity:self.vineTweet.cardEntity URLEntities:self.vineTweet.urls];
    XCTAssertNotNil(videoConfig);

    XCTAssertEqualObjects(videoConfig.videoURL.absoluteString, @"https://v.cdn.vine.co/r/videos_h264high/3FFE1E20071282608868568055808_486f3351bcd.4.0.6244909849912429457.mp4?versionId=HdRqgNrs8rQN70K9wqYgQLhaVKrMxgTb");
    XCTAssertEqual(videoConfig.aspectRatio, 1);
    XCTAssertEqual(videoConfig.duration, 6);
    XCTAssertEqual(videoConfig.mediaType, TWTRMediaTypeVine);

    TWTRVideoDeeplinkConfiguration *expectedConfig = [[TWTRVideoDeeplinkConfiguration alloc] initWithDisplayText:@"Open in Vine" targetURL:[NSURL URLWithString:@"https://vine.co/v/iajXxLU0wtr"] metricsURL:[NSURL URLWithString:@"https://t.co/KcqVd4U4AB"]];
    XCTAssertEqualObjects(videoConfig.deeplinkConfiguration, expectedConfig);
}

- (void)testPlayerCard_RequiresURLMapping
{
    TWTRVideoPlaybackConfiguration *videoConfig = [TWTRVideoPlaybackConfiguration playbackConfigurationForCardEntity:self.vineTweet.cardEntity URLEntities:@[]];
    XCTAssertNil(videoConfig.deeplinkConfiguration);
}

@end
