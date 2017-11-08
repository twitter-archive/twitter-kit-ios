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
#import "TWTRMediaContainerViewController.h"
#import "TWTRMediaPresentationController.h"

@interface MockMediaViewController : UIViewController <TWTRMediaContainerPresentable>
@property (nonatomic, readonly) BOOL didCallTransitionWillBegin;
@property (nonatomic, readonly) BOOL didCallTransitionDidComplete;
@property (nonatomic, readonly) BOOL didCallWillShow;
@property (nonatomic, readonly) BOOL didAskForImage;
@property (nonatomic, readonly) BOOL didAskForTargetRect;
@property (nonatomic, copy) dispatch_block_t completionBlock;
@end

@interface TWTRMediaContainerViewControllerTests : XCTestCase

@property (nonatomic, readonly) TWTRMediaContainerViewController *mediaController;
@property (nonatomic, readonly) MockMediaViewController *mockController;

@end

@implementation TWTRMediaContainerViewControllerTests

- (void)setUp
{
    [super setUp];

    _mockController = [[MockMediaViewController alloc] init];
    _mediaController = [[TWTRMediaContainerViewController alloc] initWithMediaViewController:_mockController];
}

- (void)tearDown
{
    _mockController = nil;
    _mediaController = nil;
    [super tearDown];
}

- (void)testMediaControllerPropertySet
{
    XCTAssertEqualObjects(self.mediaController.mediaViewController, self.mockController);
}

- (void)testShowCallsWillShowOnMediaViewController
{
    // Use nil as a VC here so that no exception is thrown by UIKit for presenting without
    // a view in the window hierachy
    [self.mediaController showFromView:[UIView new] inViewController:nil completion:^{
    }];
    XCTAssertTrue(self.mockController.didCallWillShow);
}

- (void)testMediaContainerUsesCorrectTransitionAnimator
{
    // Need to call this method to set up the transitioning delegate
    [self.mediaController showFromView:[UIView new] inViewController:nil completion:^{
    }];

    id animator = [self.mediaController.transitioningDelegate animationControllerForPresentedController:self.mediaController presentingController:[UIViewController new] sourceController:[UIViewController new]];
    XCTAssert([animator isKindOfClass:[TWTRMediaAnimatedTransitioningPresenter class]]);
}

- (void)testAnimatorCallsAppropriateMethodsOnMediaViewController
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"wait for presentation"];

    // Need to call this method to set up the transitioning delegate
    [self.mediaController showFromView:[UIView new] inViewController:nil completion:^{
    }];

    TWTRMediaAnimatedTransitioningPresenter *animator = (TWTRMediaAnimatedTransitioningPresenter *)[self.mediaController.transitioningDelegate animationControllerForPresentedController:self.mediaController presentingController:[UIViewController new] sourceController:[UIViewController new]];

    // kick of the animation. We don't actually need a context for the methods to be properly invoked so
    // pass nil, the cast to id is to satisfy the compiler.
    [animator animateTransition:(_Nonnull id)nil];

    self.mockController.completionBlock = ^{
        [expectation fulfill];
    };

    [self waitForExpectationsWithTimeout:1 handler:nil];

    XCTAssertTrue(self.mockController.didCallTransitionWillBegin);
    XCTAssertTrue(self.mockController.didCallTransitionDidComplete);
}

- (void)testAnimatorAsksMediaControllerForImageAndTargetRect
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"wait for presentation"];

    // Need to call this method to set up the transitioning delegate
    [self.mediaController showFromView:[UIView new] inViewController:nil completion:^{
    }];

    TWTRMediaAnimatedTransitioningPresenter *animator = (TWTRMediaAnimatedTransitioningPresenter *)[self.mediaController.transitioningDelegate animationControllerForPresentedController:self.mediaController presentingController:[UIViewController new] sourceController:[UIViewController new]];

    // kick of the animation. We don't actually need a context for the methods to be properly invoked so
    // pass nil, the cast to id is to satisfy the compiler.
    [animator animateTransition:(_Nonnull id)nil];

    self.mockController.completionBlock = ^{
        [expectation fulfill];
    };

    [self waitForExpectationsWithTimeout:1 handler:nil];

    XCTAssertTrue(self.mockController.didAskForImage);
    XCTAssertTrue(self.mockController.didAskForTargetRect);
}

@end

@implementation MockMediaViewController

- (UIImage *)transitionImage
{
    _didAskForImage = YES;
    return [[UIImage alloc] init];
}

- (CGRect)transitionImageTargetFrame
{
    _didAskForTargetRect = YES;
    return CGRectMake(0, 0, 10, 10);
}

- (void)transitionWillBegin
{
    _didCallTransitionWillBegin = YES;
}

- (void)transitionDidComplete
{
    _didCallTransitionDidComplete = YES;
    self.completionBlock();
}

- (void)willShowInMediaContainer
{
    _didCallWillShow = YES;
}

- (void)didDismissInMediaContainer
{
}

@end
