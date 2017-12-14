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
#import "TWTRImages.h"

@interface TWTRImagesTests : XCTestCase

@end

@implementation TWTRImagesTests

- (void)testLikeOn_NotNil
{
    XCTAssertNotNil([TWTRImages likeOn]);
}

- (void)testLikeOff_NotNil
{
    XCTAssertNotNil([TWTRImages likeOff]);
}

- (void)testLikeImageSheet_NotNil
{
    XCTAssertNotNil([TWTRImages likeImageSheet]);
}

- (void)testShare_NotNil
{
    XCTAssertNotNil([TWTRImages shareImage]);
}

- (void)testPlay_NotNil
{
    XCTAssertNotNil([TWTRImages playIcon]);
}

#pragma mark - Retweet

- (void)testLightRetweet_NotNil
{
    XCTAssertNotNil([TWTRImages lightRetweet]);
}

- (void)testDarkRetweet_NotNil
{
    XCTAssertNotNil([TWTRImages darkRetweet]);
}

- (void)testRetweetImage_LightBackgroundGivesDarkRetweet
{
    UIImage *image = [TWTRImages retweetImageForBackgroundColor:[UIColor yellowColor]];
    UIImage *expected = [TWTRImages darkRetweet];
    XCTAssertEqualObjects(image, expected);
}

- (void)testRetweetImage_DarkBackgroundGivesLightRetweet
{
    UIImage *image = [TWTRImages retweetImageForBackgroundColor:[UIColor blackColor]];
    UIImage *expected = [TWTRImages lightRetweet];
    XCTAssertEqualObjects(image, expected);
}

#pragma mark - Verified

- (void)testVerified_NotNil
{
    XCTAssertNotNil([TWTRImages verifiedIcon]);
}

#pragma mark - Video

- (void)testVideoImages
{
    XCTAssertNotNil([TWTRImages mediaPauseTemplateImage]);
    XCTAssertNotNil([TWTRImages mediaPlayTemplateImage]);
    XCTAssertNotNil([TWTRImages mediaReplayTemplateImage]);
    XCTAssertNotNil([TWTRImages mediaScrubberThumb]);
    XCTAssertNotNil([TWTRImages vineBadgeImage]);
}

@end
