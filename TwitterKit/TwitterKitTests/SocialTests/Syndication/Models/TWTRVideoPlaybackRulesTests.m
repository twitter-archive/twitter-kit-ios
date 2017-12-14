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
#import "TWTRVideoPlaybackConfiguration.h"
#import "TWTRVideoPlaybackRules.h"

@interface TWTRVideoPlaybackRulesTests : XCTestCase

@end

@implementation TWTRVideoPlaybackRulesTests

- (void)testShouldShowControls
{
    XCTAssertFalse([TWTRVideoPlaybackRules shouldShowVideoControlsForType:TWTRMediaTypeGIF]);
    XCTAssertFalse([TWTRVideoPlaybackRules shouldShowVideoControlsForType:TWTRMediaTypePhoto]);
    XCTAssertTrue([TWTRVideoPlaybackRules shouldShowVideoControlsForType:TWTRMediaTypeVideo]);
    XCTAssertFalse([TWTRVideoPlaybackRules shouldShowVideoControlsForType:TWTRMediaTypeVine]);
}

- (void)testShouldAutoLoop
{
    TWTRVideoPlaybackConfiguration *GIFConfig = [[TWTRVideoPlaybackConfiguration alloc] initWithVideoURL:[NSURL URLWithString:@"twitter.com"] aspectRatio:1.0 duration:1.0 mediaType:TWTRMediaTypeGIF mediaID:@"fakeID" deeplinkConfiguration:nil];
    TWTRVideoPlaybackConfiguration *photoConfig = [[TWTRVideoPlaybackConfiguration alloc] initWithVideoURL:[NSURL URLWithString:@"twitter.com"] aspectRatio:1.0 duration:1.0 mediaType:TWTRMediaTypePhoto mediaID:@"fakeID" deeplinkConfiguration:nil];
    TWTRVideoPlaybackConfiguration *vineConfig = [[TWTRVideoPlaybackConfiguration alloc] initWithVideoURL:[NSURL URLWithString:@"twitter.com"] aspectRatio:1.0 duration:1.0 mediaType:TWTRMediaTypeVine mediaID:@"fakeID" deeplinkConfiguration:nil];
    TWTRVideoPlaybackConfiguration *videoConfig = [[TWTRVideoPlaybackConfiguration alloc] initWithVideoURL:[NSURL URLWithString:@"twitter.com"] aspectRatio:1.0 duration:9.0 mediaType:TWTRMediaTypeVideo mediaID:@"fakeID" deeplinkConfiguration:nil];
    TWTRVideoPlaybackConfiguration *shortVideoConfig = [[TWTRVideoPlaybackConfiguration alloc] initWithVideoURL:[NSURL URLWithString:@"twitter.com"] aspectRatio:1.0 duration:3.0 mediaType:TWTRMediaTypeVideo mediaID:@"fakeID" deeplinkConfiguration:nil];

    XCTAssertTrue([TWTRVideoPlaybackRules shouldAutoLoopForConfiguration:GIFConfig]);
    XCTAssertFalse([TWTRVideoPlaybackRules shouldAutoLoopForConfiguration:photoConfig]);
    XCTAssertTrue([TWTRVideoPlaybackRules shouldAutoLoopForConfiguration:vineConfig]);
    XCTAssertFalse([TWTRVideoPlaybackRules shouldAutoLoopForConfiguration:videoConfig]);
    XCTAssertTrue([TWTRVideoPlaybackRules shouldAutoLoopForConfiguration:shortVideoConfig]);
}

@end
