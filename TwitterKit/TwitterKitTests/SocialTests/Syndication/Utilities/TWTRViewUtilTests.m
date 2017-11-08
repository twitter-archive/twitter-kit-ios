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
#import "TWTRFixtureLoader.h"
#import "TWTRMediaEntitySize.h"
#import "TWTRTestCase.h"
#import "TWTRTweetMediaEntity.h"
#import "TWTRViewUtil.h"

@interface TWTRViewUtilTests : TWTRTestCase

@property (nonatomic) NSDictionary<NSString *, TWTRMediaEntitySize *> *oneSize;
@property (nonatomic) TWTRTweetMediaEntity *largeMediaEntity;
@property (nonatomic) TWTRTweetMediaEntity *legacyMediaEntity;
@property (nonatomic) UIView *view;
@property (nonatomic) UIView *siblingView;
@property (nonatomic) UIView *view3;
@property (nonatomic) UIView *superview;
@property (nonatomic) UIView *superSuperview;
@property (nonatomic) id mediaEntityMock;
@property (nonatomic) id oneSizeEntityMock;

@end

@implementation TWTRViewUtilTests

- (void)setUp
{
    [super setUp];

    self.legacyMediaEntity = [TWTRFixtureLoader obamaTweetMediaEntity];
    self.largeMediaEntity = [TWTRFixtureLoader largeTweetMediaEntity];

    self.oneSize = [TWTRMediaEntitySize mediaEntitySizesWithJSONDictionary:@{ @"large": @{@"h": @768, @"resize": @"fit", @"w": @1024} }];

    self.superSuperview = [[UIView alloc] init];
    self.superview = [[UIView alloc] init];
    self.view = [[UIView alloc] init];
    self.siblingView = [[UIView alloc] init];
    self.view3 = [[UIView alloc] init];
    [self.superview addSubview:self.view];
    [self.superview addSubview:self.siblingView];
    [self.superSuperview addSubview:self.superview];
    [self.superSuperview addSubview:self.view3];

    self.mediaEntityMock = [OCMockObject partialMockForObject:[TWTRFixtureLoader obamaTweetMediaEntity]];

    self.oneSizeEntityMock = [OCMockObject partialMockForObject:[TWTRFixtureLoader obamaTweetMediaEntity]];
    [[[self.oneSizeEntityMock stub] andReturn:self.oneSize] sizes];
}

#pragma mark - Best Match Sizes

- (void)testBestMatchSize_zeroWidthGivesSmall
{
    CGFloat desiredWidth = 0;
    TWTRMediaEntitySize *entitySize = [TWTRViewUtil bestMatchSizeFromMediaEntity:self.largeMediaEntity fittingWidth:desiredWidth];

    XCTAssertEqual(entitySize.size.width, 680);
    XCTAssertEqualObjects(entitySize.name, @"small");
}

- (void)testBestMatchSize_smallWidthGivesSmallest
{
    CGFloat desiredWidth = 200;
    TWTRMediaEntitySize *entitySize = [TWTRViewUtil bestMatchSizeFromMediaEntity:self.largeMediaEntity fittingWidth:desiredWidth];

    XCTAssertEqual(entitySize.size.width, 680);
    XCTAssertEqualObjects(entitySize.name, @"small");
}

- (void)testBestMatchSize_smallWidth
{
    CGFloat desiredWidth = 700;
    TWTRMediaEntitySize *entitySize = [TWTRViewUtil bestMatchSizeFromMediaEntity:self.largeMediaEntity fittingWidth:desiredWidth];

    XCTAssertEqual(entitySize.size.width, 680);
    XCTAssertEqualObjects(entitySize.name, @"small");
}

- (void)testBestMatchSize_mediumWidth
{
    CGFloat desiredWidth = 1500;
    TWTRMediaEntitySize *entitySize = [TWTRViewUtil bestMatchSizeFromMediaEntity:self.largeMediaEntity fittingWidth:desiredWidth];

    XCTAssertEqual(entitySize.size.width, 1200);
    XCTAssertEqualObjects(entitySize.name, @"medium");
}

- (void)testBestMatchSize_largeWidth
{
    CGFloat desiredWidth = 2400;
    TWTRMediaEntitySize *entitySize = [TWTRViewUtil bestMatchSizeFromMediaEntity:self.largeMediaEntity fittingWidth:desiredWidth];

    XCTAssertEqual(entitySize.size.width, 2048);
    XCTAssertEqualObjects(entitySize.name, @"large");
}

#pragma mark - Average Aspect Ratios

- (void)testAverageAspectRatios_singleSize
{
    CGFloat aspectRatio = [TWTRViewUtil averageAspectRatioForMediaEntity:self.oneSizeEntityMock];
    CGFloat expected = 1024.0 / 768.0;
    XCTAssertEqualWithAccuracy(aspectRatio, expected, __FLT_EPSILON__);
}

- (void)testAverageAspectRatios_noSizes
{
    [[[self.mediaEntityMock stub] andReturn:nil] sizes];
    CGFloat aspectRatio = [TWTRViewUtil averageAspectRatioForMediaEntity:self.mediaEntityMock];
    CGFloat expected = 0.0;
    XCTAssertEqualWithAccuracy(aspectRatio, expected, __FLT_EPSILON__);
}

- (void)testAverageAspectRatios_multipleSizes
{
    CGFloat aspectRatio = [TWTRViewUtil averageAspectRatioForMediaEntity:self.oneSizeEntityMock];
    CGFloat expected = 1.3464;
    XCTAssertEqualWithAccuracy(aspectRatio, expected, 0.1);
}

- (void)testAverageAspectRatios_ignoresNonFit
{
    NSDictionary *entitySizes = [TWTRMediaEntitySize mediaEntitySizesWithJSONDictionary:@{ @"large": @{@"h": @100, @"resize": @"fit", @"w": @200}, @"thumb": @{@"h": @450, @"resize": @"crop", @"w": @600} }];

    [[[self.mediaEntityMock stub] andReturn:entitySizes] sizes];
    CGFloat aspectRatio = [TWTRViewUtil averageAspectRatioForMediaEntity:self.mediaEntityMock];
    CGFloat expected = 200.0 / 100.0;
    XCTAssertEqualWithAccuracy(aspectRatio, expected, __FLT_EPSILON__);
}

- (void)testAspectRatioForZeroHeight
{
    XCTAssertEqualWithAccuracy([TWTRViewUtil aspectRatioForSize:CGSizeMake(100, 0.0)], 0.0, __FLT_EPSILON__);
}

- (void)testAspectRatioCalculation
{
    XCTAssertEqualWithAccuracy([TWTRViewUtil aspectRatioForSize:CGSizeMake(200, 100)], 2.0, __FLT_EPSILON__);
}

- (void)testIsLandscape_landscape
{
    CGFloat aspectRatio = [TWTRViewUtil aspectRatioForWidth:200 height:100];
    XCTAssertTrue([TWTRViewUtil aspectRatioIsLandscape:aspectRatio]);
}

- (void)testIsLandscape_portrait
{
    CGFloat aspectRatio = [TWTRViewUtil aspectRatioForWidth:100 height:200];
    XCTAssertFalse([TWTRViewUtil aspectRatioIsLandscape:aspectRatio]);
}

- (void)testIsLandscape_square
{
    CGFloat aspectRatio = [TWTRViewUtil aspectRatioForWidth:100 height:100];
    XCTAssertFalse([TWTRViewUtil aspectRatioIsLandscape:aspectRatio]);
}

#pragma mark - Auto Layout

- (void)testConstraintForAttribute
{
    NSLayoutConstraint *constraint = [TWTRViewUtil constraintForAttribute:NSLayoutAttributeWidth onView:self.view value:5];
    XCTAssertEqual(constraint.constant, 5);
    XCTAssertEqual(constraint.firstItem, self.view);
    XCTAssertEqual(constraint.firstAttribute, NSLayoutAttributeWidth);
    XCTAssertEqual(constraint.secondItem, nil);
    XCTAssertEqual(constraint.relation, NSLayoutAttributeNotAnAttribute);
}

- (void)testcenterViewInSuperview
{
    [TWTRViewUtil centerViewInSuperview:self.view];
    NSArray<NSLayoutConstraint *> *constraints = self.superview.constraints;

    NSIndexSet *xConstraints = [constraints indexesOfObjectsPassingTest:^BOOL(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *_Nonnull stop) {
        return constraint.firstAttribute == NSLayoutAttributeCenterX && constraint.secondAttribute == NSLayoutAttributeCenterX && constraint.firstItem == self.view && constraint.secondItem == self.superview;
    }];

    NSIndexSet *yConstraints = [constraints indexesOfObjectsPassingTest:^BOOL(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *_Nonnull stop) {
        return constraint.firstAttribute == NSLayoutAttributeCenterY && constraint.secondAttribute == NSLayoutAttributeCenterY && constraint.firstItem == self.view && constraint.secondItem == self.superview;
    }];

    XCTAssertEqual(xConstraints.count, 1);
    XCTAssertEqual(yConstraints.count, 1);
}

- (void)testCenterViewInOtherView
{
    [TWTRViewUtil centerView:self.view inView:self.siblingView];
    NSArray<NSLayoutConstraint *> *constraints = self.superview.constraints;

    NSIndexSet *xConstraints = [constraints indexesOfObjectsPassingTest:^BOOL(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *_Nonnull stop) {
        return constraint.firstAttribute == NSLayoutAttributeCenterX && constraint.secondAttribute == NSLayoutAttributeCenterX && constraint.firstItem == self.view && constraint.secondItem == self.siblingView;
    }];

    NSIndexSet *yConstraints = [constraints indexesOfObjectsPassingTest:^BOOL(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *_Nonnull stop) {
        return constraint.firstAttribute == NSLayoutAttributeCenterY && constraint.secondAttribute == NSLayoutAttributeCenterY && constraint.firstItem == self.view && constraint.secondItem == self.siblingView;
    }];

    XCTAssertEqual(xConstraints.count, 1);
    XCTAssertEqual(yConstraints.count, 1);
}

- (void)testCenterViewHorizontally
{
    [TWTRViewUtil centerViewHorizontallyInSuperview:self.view];
    NSLayoutConstraint *constraint = [self.superview.constraints firstObject];
    XCTAssertEqual(constraint.firstItem, self.view);
    XCTAssertEqual(constraint.secondItem, self.superview);
    XCTAssertEqual(constraint.firstAttribute, NSLayoutAttributeCenterX);
}

- (void)testCenterViewVertically
{
    [TWTRViewUtil centerViewVerticallyInSuperview:self.view];
    NSLayoutConstraint *constraint = [self.superview.constraints firstObject];
    XCTAssertEqual(constraint.firstItem, self.view);
    XCTAssertEqual(constraint.secondItem, self.superview);
    XCTAssertEqual(constraint.firstAttribute, NSLayoutAttributeCenterY);
}

- (void)testCenterViewHorizontallyInOtherView
{
    [TWTRViewUtil centerViewHorizontally:self.view inView:self.siblingView];
    NSLayoutConstraint *constraint = [self.superview.constraints firstObject];
    XCTAssertEqual(constraint.firstItem, self.view);
    XCTAssertEqual(constraint.secondItem, self.siblingView);
    XCTAssertEqual(constraint.firstAttribute, NSLayoutAttributeCenterX);
}

- (void)testCenterViewVerticallyInOtherView
{
    [TWTRViewUtil centerViewVertically:self.view inView:self.siblingView];
    NSLayoutConstraint *constraint = [self.superview.constraints firstObject];
    XCTAssertEqual(constraint.firstItem, self.view);
    XCTAssertEqual(constraint.secondItem, self.siblingView);
    XCTAssertEqual(constraint.firstAttribute, NSLayoutAttributeCenterY);
}

#pragma mark - Pixel Integral

// It should not round the origin fractions, but expand to include them
- (void)testPixelIntegral_containsOrigin
{
    CGRect inputRect = CGRectMake(1.9, 3.45, 10, 20);
    CGRect adjustedRect = TWTRRectPixelIntegral(inputRect);
    CGRect expectedRect = CGRectMake(1.5, 3, 10, 20);
    XCTAssert(CGRectEqualToRect(adjustedRect, expectedRect));
}

- (void)testPixelIntegral_roundsSizesDown
{
    CGRect inputRect = CGRectMake(1.5, 3, 10.1, 20.749);
    CGRect adjustedRect = TWTRRectPixelIntegral(inputRect);
    CGRect expectedRect = CGRectMake(1.5, 3, 10, 20.5);
    XCTAssert(CGRectEqualToRect(adjustedRect, expectedRect));
}

- (void)testPixelIntegral_roundsSizesUp
{
    CGRect inputRect = CGRectMake(1.5, 3, 10.26, 20.8);
    CGRect adjustedRect = TWTRRectPixelIntegral(inputRect);
    CGRect expectedRect = CGRectMake(1.5, 3, 10.5, 21);
    XCTAssert(CGRectEqualToRect(adjustedRect, expectedRect));
}

@end
