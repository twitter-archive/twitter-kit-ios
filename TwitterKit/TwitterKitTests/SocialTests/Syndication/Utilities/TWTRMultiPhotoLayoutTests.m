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
#import "TWTRMultiPhotoLayout.h"

@interface TWTRMultiPhotoLayoutTests : XCTestCase

@property (nonatomic) UIView *view1;
@property (nonatomic) UIView *view2;
@property (nonatomic) UIView *view3;
@property (nonatomic) UIView *view4;
@property (nonatomic) UIView *superview;

@end

BOOL isLeftOf(UIView *leftView, UIView *rightView)
{
    CGFloat minRightX = CGRectGetMinX(rightView.frame);
    CGFloat maxLeftX = CGRectGetMaxX(leftView.frame);
    return maxLeftX < minRightX;
}

BOOL isAbove(UIView *topView, UIView *bottomView)
{
    CGFloat maxTopY = CGRectGetMaxY(topView.frame);
    CGFloat minBottomY = CGRectGetMinY(bottomView.frame);
    return maxTopY < minBottomY;
}

BOOL fillsSuperviewVerically(UIView *subview)
{
    UIView *superview = subview.superview;
    BOOL equalHeight = superview.frame.size.height == subview.frame.size.height;
    BOOL sameCenterY = superview.center.y == subview.center.y;

    return equalHeight && sameCenterY;
}

@implementation TWTRMultiPhotoLayoutTests

- (void)setUp
{
    [super setUp];

    self.view1 = [[UIView alloc] init];
    self.view2 = [[UIView alloc] init];
    self.view3 = [[UIView alloc] init];
    self.view4 = [[UIView alloc] init];
    self.superview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];

    for (UIView *view in @[self.view1, self.view2, self.view3, self.view4]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.superview addSubview:view];
    }
}

- (void)testSingleView
{
    NSArray *views = @[self.view1];
    [TWTRMultiPhotoLayout layoutViews:views];
    [self.superview setNeedsLayout];
    [self.superview layoutIfNeeded];

    XCTAssert(CGRectEqualToRect(self.view1.frame, self.superview.frame));
}

- (void)testTwoViews
{
    NSArray *views = @[self.view1, self.view2];
    [TWTRMultiPhotoLayout layoutViews:views];
    [self.superview setNeedsLayout];
    [self.superview layoutIfNeeded];

    XCTAssert(fillsSuperviewVerically(self.view1));
    XCTAssert(fillsSuperviewVerically(self.view2));
    XCTAssert(isLeftOf(self.view1, self.view2));
}

- (void)testThreeViews
{
    NSArray *views = @[self.view1, self.view2, self.view3];
    [TWTRMultiPhotoLayout layoutViews:views];
    [self.superview setNeedsLayout];
    [self.superview layoutIfNeeded];

    XCTAssert(fillsSuperviewVerically(self.view1));
    XCTAssert(isLeftOf(self.view1, self.view2));
    XCTAssert(isLeftOf(self.view1, self.view3));
    XCTAssert(isAbove(self.view2, self.view3));
}

- (void)testFourViews
{
    NSArray *views = @[self.view1, self.view2, self.view3, self.view4];
    [TWTRMultiPhotoLayout layoutViews:views];
    [self.superview setNeedsLayout];
    [self.superview layoutIfNeeded];

    XCTAssert(isAbove(self.view1, self.view3));
    XCTAssert(isAbove(self.view2, self.view4));
    XCTAssert(isLeftOf(self.view1, self.view2));
    XCTAssert(isLeftOf(self.view3, self.view4));
}

@end
