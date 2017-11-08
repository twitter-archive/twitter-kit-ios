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

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "TWTRFontUtil.h"

static const CGFloat TWTRDefaultFontSize = 12.0;
static const CGFloat TWTRLargeFontSize = 18.0;

@interface TWTRFontUtilTests : XCTestCase

@end

@implementation TWTRFontUtilTests

- (void)testFullnameSize
{
    id mockFontUtil = OCMClassMock([TWTRFontUtil class]);
    OCMStub([mockFontUtil defaultFontSize]).andReturn(TWTRDefaultFontSize);
    XCTAssertEqual([TWTRFontUtil fullnameFont].pointSize, 14);

    id mockLargeFontUtil = OCMClassMock([TWTRFontUtil class]);
    OCMStub([mockLargeFontUtil defaultFontSize]).andReturn(TWTRLargeFontSize);
    XCTAssertEqual([TWTRFontUtil fullnameFont].pointSize, 20);
}

- (void)testTimestampSize_Compact
{
    id mockFontUtil = OCMClassMock([TWTRFontUtil class]);
    OCMStub([mockFontUtil defaultFontSize]).andReturn(TWTRDefaultFontSize);
    XCTAssertEqual([TWTRFontUtil timestampFontForStyle:TWTRTweetViewStyleCompact].pointSize, 12);

    id mockLargeFontUtil = OCMClassMock([TWTRFontUtil class]);
    OCMStub([mockLargeFontUtil defaultFontSize]).andReturn(TWTRLargeFontSize);
    XCTAssertEqual([TWTRFontUtil timestampFontForStyle:TWTRTweetViewStyleCompact].pointSize, 18);
}

- (void)testTimestampSize_Regular
{
    id mockFontUtil = OCMClassMock([TWTRFontUtil class]);
    OCMStub([mockFontUtil defaultFontSize]).andReturn(TWTRDefaultFontSize);
    XCTAssertEqual([TWTRFontUtil timestampFontForStyle:TWTRTweetViewStyleRegular].pointSize, 14);

    id mockLargeFontUtil = OCMClassMock([TWTRFontUtil class]);
    OCMStub([mockLargeFontUtil defaultFontSize]).andReturn(TWTRLargeFontSize);
    XCTAssertEqual([TWTRFontUtil timestampFontForStyle:TWTRTweetViewStyleRegular].pointSize, 20);
}

- (void)testTweetFont_Compact
{
    id mockFontUtil = OCMClassMock([TWTRFontUtil class]);
    OCMStub([mockFontUtil defaultFontSize]).andReturn(TWTRDefaultFontSize);
    XCTAssertEqual([TWTRFontUtil tweetFontForStyle:TWTRTweetViewStyleCompact].pointSize, 14);

    id mockLargeFontUtil = OCMClassMock([TWTRFontUtil class]);
    OCMStub([mockLargeFontUtil defaultFontSize]).andReturn(TWTRLargeFontSize);
    XCTAssertEqual([TWTRFontUtil tweetFontForStyle:TWTRTweetViewStyleCompact].pointSize, 20);
}

- (void)testTweetFont_Regular
{
    id mockFontUtil = OCMClassMock([TWTRFontUtil class]);
    OCMStub([mockFontUtil defaultFontSize]).andReturn(TWTRDefaultFontSize);
    XCTAssertEqual([TWTRFontUtil tweetFontForStyle:TWTRTweetViewStyleRegular].pointSize, 16);

    id mockLargeFontUtil = OCMClassMock([TWTRFontUtil class]);
    OCMStub([mockLargeFontUtil defaultFontSize]).andReturn(TWTRLargeFontSize);
    XCTAssertEqual([TWTRFontUtil tweetFontForStyle:TWTRTweetViewStyleRegular].pointSize, 22);
}

- (void)testUsernameFont_Compact
{
    id mockFontUtil = OCMClassMock([TWTRFontUtil class]);
    OCMStub([mockFontUtil defaultFontSize]).andReturn(TWTRDefaultFontSize);
    XCTAssertEqual([TWTRFontUtil usernameFontForStyle:TWTRTweetViewStyleCompact].pointSize, 12);

    id mockLargeFontUtil = OCMClassMock([TWTRFontUtil class]);
    OCMStub([mockLargeFontUtil defaultFontSize]).andReturn(TWTRLargeFontSize);
    XCTAssertEqual([TWTRFontUtil usernameFontForStyle:TWTRTweetViewStyleCompact].pointSize, 18);
}

- (void)testUsernameFont_Regular
{
    id mockFontUtil = OCMClassMock([TWTRFontUtil class]);
    OCMStub([mockFontUtil defaultFontSize]).andReturn(TWTRDefaultFontSize);
    XCTAssertEqual([TWTRFontUtil usernameFontForStyle:TWTRTweetViewStyleRegular].pointSize, 14);

    id mockLargeFontUtil = OCMClassMock([TWTRFontUtil class]);
    OCMStub([mockLargeFontUtil defaultFontSize]).andReturn(TWTRLargeFontSize);
    XCTAssertEqual([TWTRFontUtil usernameFontForStyle:TWTRTweetViewStyleRegular].pointSize, 20);
}

- (void)testRetweetFont_Compact
{
    id mockFontUtil = OCMClassMock([TWTRFontUtil class]);
    OCMStub([mockFontUtil defaultFontSize]).andReturn(TWTRDefaultFontSize);
    XCTAssertEqual([TWTRFontUtil retweetedByAttributionLabelFont].pointSize, 12);

    id mockLargeFontUtil = OCMClassMock([TWTRFontUtil class]);
    OCMStub([mockLargeFontUtil defaultFontSize]).andReturn(TWTRLargeFontSize);
    XCTAssertEqual([TWTRFontUtil retweetedByAttributionLabelFont].pointSize, 18);
}

#pragma mark - Minimum Line Height

- (void)testMinimumLineHeights_Helvetica
{
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:12];

    [self assertMinimumLineHeight:14 forFont:font verticalSizeClass:UIUserInterfaceSizeClassCompact horizontalSizeClass:UIUserInterfaceSizeClassCompact];

    [self assertMinimumLineHeight:14 forFont:font verticalSizeClass:UIUserInterfaceSizeClassCompact horizontalSizeClass:UIUserInterfaceSizeClassRegular];

    [self assertMinimumLineHeight:16 forFont:font verticalSizeClass:UIUserInterfaceSizeClassRegular horizontalSizeClass:UIUserInterfaceSizeClassRegular];

    [self assertMinimumLineHeight:15 forFont:font verticalSizeClass:UIUserInterfaceSizeClassRegular horizontalSizeClass:UIUserInterfaceSizeClassCompact];
}

- (void)assertMinimumLineHeight:(CGFloat)height forFont:(UIFont *)font verticalSizeClass:(UIUserInterfaceSizeClass)verticalSizeClass horizontalSizeClass:(UIUserInterfaceSizeClass)horizontalSizeClass
{
    UITraitCollection *vertical = [UITraitCollection traitCollectionWithVerticalSizeClass:verticalSizeClass];
    UITraitCollection *horizontal = [UITraitCollection traitCollectionWithHorizontalSizeClass:horizontalSizeClass];

    UITraitCollection *traits = [UITraitCollection traitCollectionWithTraitsFromCollections:@[vertical, horizontal]];

    CGFloat lineHeight = [TWTRFontUtil minimumLineHeightForFont:font traitCollection:traits];

    XCTAssertEqualWithAccuracy(lineHeight, height, 1.0);
}

@end
