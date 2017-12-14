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
#import "TWTRMediaEntitySize.h"
#import "TWTRTweetMediaEntity.h"
#import "TWTRTweet_Private.h"

@interface TWTRMediaEntitySizeTests : XCTestCase

@end

@implementation TWTRMediaEntitySizeTests

- (void)testPropertiesSet
{
    NSString *name = @"large";
    TWTRMediaEntitySizeResizingMode resizingMode = TWTRMediaEntitySizeResizingModeCrop;
    CGSize size = CGSizeMake(100, 100);
    TWTRMediaEntitySize *mediaSize = [[TWTRMediaEntitySize alloc] initWithName:name resizingMode:resizingMode size:size];

    XCTAssertTrue(CGSizeEqualToSize(size, mediaSize.size));
    XCTAssertEqual(mediaSize.resizingMode, TWTRMediaEntitySizeResizingModeCrop);
    XCTAssertEqualObjects(name, mediaSize.name);
}

- (void)testEquality
{
    NSString *name = @"";
    TWTRMediaEntitySizeResizingMode resizingMode = TWTRMediaEntitySizeResizingModeFit;
    CGSize size = CGSizeMake(100, 100);

    TWTRMediaEntitySize *size1 = [[TWTRMediaEntitySize alloc] initWithName:name resizingMode:resizingMode size:size];
    TWTRMediaEntitySize *size2 = [[TWTRMediaEntitySize alloc] initWithName:name resizingMode:resizingMode size:size];

    XCTAssertEqualObjects(size1, size2);
}

- (void)testNotEqual_name
{
    CGSize size = CGSizeMake(100, 100);
    XCTAssertNotEqualObjects([[TWTRMediaEntitySize alloc] initWithName:@"large" resizingMode:TWTRMediaEntitySizeResizingModeFit size:size], [[TWTRMediaEntitySize alloc] initWithName:@"medium" resizingMode:TWTRMediaEntitySizeResizingModeFit size:size]);
}

- (void)testNotEqual_size
{
    NSString *name = @"large";
    XCTAssertNotEqualObjects([[TWTRMediaEntitySize alloc] initWithName:name resizingMode:TWTRMediaEntitySizeResizingModeFit size:CGSizeZero], [[TWTRMediaEntitySize alloc] initWithName:name resizingMode:TWTRMediaEntitySizeResizingModeFit size:CGSizeMake(100, 100)]);
}

- (void)testNotEqual_resizingMode
{
    NSString *name = @"large";
    XCTAssertNotEqualObjects([[TWTRMediaEntitySize alloc] initWithName:name resizingMode:TWTRMediaEntitySizeResizingModeCrop size:CGSizeZero], [[TWTRMediaEntitySize alloc] initWithName:name resizingMode:TWTRMediaEntitySizeResizingModeFit size:CGSizeZero]);
}

- (void)testJSONParsing_createsProperly
{
    NSDictionary<NSString *, TWTRMediaEntitySize *> *entitySizes = [TWTRMediaEntitySize mediaEntitySizesWithJSONDictionary:@{ @"large": @{@"h": @100, @"resize": @"fit", @"w": @200}, @"thumb": @{@"h": @450, @"resize": @"crop", @"w": @600} }];

    XCTAssertEqual(entitySizes.count, 2);
    XCTAssertEqualObjects(entitySizes[@"thumb"].name, @"thumb");
    XCTAssertEqualObjects(entitySizes[@"large"].name, @"large");
    XCTAssertEqual(entitySizes[@"thumb"].size.width, 600);
    XCTAssertEqual(entitySizes[@"thumb"].size.height, 450);
    XCTAssertEqual(entitySizes[@"thumb"].resizingMode, TWTRMediaEntitySizeResizingModeCrop);
}

- (void)testLoading_videoTweet
{
    TWTRTweet *videoTweet = [TWTRFixtureLoader videoTweet];

    CGFloat (^width)(NSString *) = ^CGFloat(NSString *key) {
        TWTRMediaEntitySize *size = videoTweet.media.firstObject.sizes[key];
        return size.size.width;
    };

    XCTAssertEqual(width(@"large"), 1024);
    XCTAssertEqual(width(@"medium"), 600);
    XCTAssertEqual(width(@"small"), 340);
}

#pragma mark - NSCoding

- (void)testCoding_RestoresExactly
{
    TWTRTweetMediaEntity *originalEntity = [TWTRFixtureLoader largeTweetMediaEntity];
    NSData *encodedEntity = [NSKeyedArchiver archivedDataWithRootObject:originalEntity];
    TWTRTweetMediaEntity *decodedEntity = [NSKeyedUnarchiver unarchiveObjectWithData:encodedEntity];

    XCTAssertEqualObjects(originalEntity.sizes, decodedEntity.sizes);
    XCTAssertEqualObjects(originalEntity, decodedEntity);
}

@end
