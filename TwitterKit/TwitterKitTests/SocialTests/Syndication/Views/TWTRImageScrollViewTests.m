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
#import <TwitterCore/TWTRColorUtil.h>
#import <XCTest/XCTest.h>
#import "TWTRImageScrollView.h"
#import "TWTRImageTestHelper.h"

@interface TWTRImageScrollView ()

@property (nonatomic) UIImageView *imageView;
- (void)doubleTapped:(UIGestureRecognizer *)gestureRecognizer;

@end

@interface TWTRImageScrollViewTests : XCTestCase

@property (nonatomic) TWTRImageScrollView *imageScrollView;
@property (nonatomic) UIImage *landscapeImage;

@end

@implementation TWTRImageScrollViewTests

- (void)setUp
{
    [super setUp];
    self.imageScrollView = [[TWTRImageScrollView alloc] init];
    self.imageScrollView.frame = CGRectMake(0, 0, 320, 480);
    UIImage *landscapeImage = [TWTRImageTestHelper imageWithSize:CGSizeMake(800, 500)];
    [self.imageScrollView displayImage:landscapeImage];
}

- (void)testBackgroundColor
{
    XCTAssertEqualObjects(self.imageScrollView.backgroundColor, [TWTRColorUtil blackColor]);
}

#pragma mark - Scaling

- (void)testImageSize_isFullWidth
{
    CGFloat imageWidth = CGRectGetWidth(self.imageScrollView.imageView.frame) / self.imageScrollView.zoomScale;
    CGFloat scrollWidth = CGRectGetWidth(self.imageScrollView.frame);

    XCTAssertEqualWithAccuracy(imageWidth, scrollWidth, 0.001);
}

#pragma mark - Initial Placement

- (void)testImageSize_isCentered
{
    CGPoint imageCenter = self.imageScrollView.imageView.center;
    CGPoint scrollCenter = self.imageScrollView.center;

    XCTAssert(CGPointEqualToPoint(imageCenter, scrollCenter));
}

#pragma mark - Double Tap

- (void)testDoubleTap_zoomsByAtLeast3x
{
    id mockGesture = OCMPartialMock([[UITapGestureRecognizer alloc] init]);
    [[[mockGesture stub] andReturnValue:OCMOCK_VALUE(CGPointMake(10, 30))] locationInView:OCMOCK_ANY];

    CGFloat originalZoom = self.imageScrollView.zoomScale;
    [self.imageScrollView doubleTapped:mockGesture];
    CGFloat afterTapZoom = self.imageScrollView.zoomScale;

    XCTAssert(afterTapZoom > (originalZoom * 3.0));
}

@end
