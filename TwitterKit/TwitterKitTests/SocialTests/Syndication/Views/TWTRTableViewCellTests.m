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
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TWTRFixtureLoader.h"
#import "TWTRFontUtil.h"
#import "TWTRTestCase.h"
#import "TWTRTweetTableViewCell.h"
#import "TWTRTweetView.h"

@interface TWTRTweetTableViewCellTests : TWTRTestCase

@property (nonatomic) TWTRTweetTableViewCell *cell;

@end

@implementation TWTRTweetTableViewCellTests

- (void)setUp
{
    [super setUp];

    id mockFontUtil = OCMClassMock([TWTRFontUtil class]);
    OCMStub([mockFontUtil defaultFontSize]).andReturn(12.0);

    self.cell = [[TWTRTweetTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TwitterReuse"];
    [self.cell configureWithTweet:[TWTRFixtureLoader gatesTweet]];
}

#pragma mark - Properties

- (void)testTweetTableCell_HasTweetViewSet
{
    XCTAssert(self.cell.tweetView != nil);
}

- (void)testTweetTableCell_AccessibilityLabelExists
{
    XCTAssert([self.cell accessibilityLabel] != nil);
}

- (void)testTweetTableCell_DoesNotHaveBorder
{
    XCTAssertEqual(self.cell.tweetView.layer.borderWidth, 0.0);
}

- (void)testTweetTableCell_NoRoundedCorners
{
    XCTAssertEqual(self.cell.tweetView.layer.cornerRadius, 0.0);
}

- (void)testTweetTableCell_DoesNotShowBorder
{
    XCTAssertEqual(self.cell.tweetView.showBorder, NO);
}

@end
