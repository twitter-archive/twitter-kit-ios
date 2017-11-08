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

#import "TWTRMediaPresentationController.h"
#import "TWTRViewUtil.h"

@interface TWTRMediaPresentationController ()

/**
 * The view that will dim during transitions.
 */
@property (nonatomic) UIView *dimmingView;

@end

@implementation TWTRMediaPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController
{
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];

    if (self) {
        _dimmingView = [[UIView alloc] init];
    }

    return self;
}

- (void)presentationTransitionWillBegin
{
    self.dimmingView.frame = self.containerView.bounds;
    self.dimmingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.dimmingView.backgroundColor = self.presentedViewController.view.backgroundColor;

    [self.containerView addSubview:self.dimmingView];

    self.dimmingView.alpha = 0.0;

    [self.presentingViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.dimmingView.alpha = 1.0;
    }
                                                                         completion:nil];
}

- (void)presentationTransitionDidEnd:(BOOL)completed
{
    if (!completed) {
        [self.dimmingView removeFromSuperview];
    }
}

- (void)dismissalTransitionWillBegin
{
    /// TODO: Dismiss has not been implemented yet so this looks strange if we animate the dimming view
    /// alongside the default dismissal animation. This should be added in when we implement the dismiss.

    //    [self.presentingViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    self.dimmingView.alpha = 0.0;
    //    } completion:nil];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed
{
    if (completed) {
        [self.dimmingView removeFromSuperview];
    }
}

@end

@interface TWTRMediaAnimatedTransitioningPresenter ()

@property (nonatomic) UIView *transitionView;
@property (nonatomic) CGRect initialTransitionFrame;
@property (nonatomic) CGRect targetFrame;
@property (nonatomic, copy) dispatch_block_t completionBlock;

@end

@implementation TWTRMediaAnimatedTransitioningPresenter

- (instancetype)initWithTransitioningView:(UIView *)transitionView initialFrame:(CGRect)frame targetFrame:(CGRect)targetFrame completion:(void (^)(void))completion
{
    self = [super init];
    if (self) {
        _transitionView = transitionView;
        _initialTransitionFrame = frame;
        _targetFrame = targetFrame;
        self.completionBlock = completion;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *presented = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *container = [transitionContext containerView];

    [container addSubview:presented.view];
    presented.view.alpha = 0.0;
    presented.view.frame = container.bounds;
    presented.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [container addSubview:self.transitionView];
    self.transitionView.frame = self.initialTransitionFrame;

    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        self.transitionView.frame = self.targetFrame;
    }
        completion:^(BOOL finished) {
            self.completionBlock();
            [transitionContext completeTransition:finished];
        }];
}

@end
