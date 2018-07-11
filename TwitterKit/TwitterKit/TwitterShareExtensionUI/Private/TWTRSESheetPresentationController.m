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

#pragma mark imports

#import "TWTRSESheetPresentationController.h"

#pragma mark - static const definitions

static const CGFloat kModalPreferredVerticalPositionFactor = (CGFloat)0.33;
static const CGFloat kModalMaximumWidth = 550.0;
static const CGFloat kModalBottomPaddingKeyboardUp = 0;
static const CGFloat kModalBottomPaddingKeyboardDown = 10.0;
static const CGFloat kModalCompactHorizontalPadding = 15.0;
static const CGFloat kModalRegularHorizontalPadding = 60.0;
static const CGFloat kModalCornerRadius = 5.0;

#pragma mark -

@interface TWTRSESheetPresentationController : UIPresentationController

@property (nonatomic, nonnull, readonly) UIView *dimmingView;

@property (nonatomic) CGFloat keyboardHeight;
@property (nonatomic) BOOL keyboardOnScreen;

@property (nonatomic, readonly) CGFloat minimumTopPadding;
@property (nonatomic, readonly) CGFloat bottomPadding;
@property (nonatomic, readonly) CGFloat horizontalPadding;

@end

@implementation TWTRSESheetPresentationManager

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    return [[TWTRSESheetPresentationController alloc] initWithPresentedViewController:presented presentingViewController:source];
}

@end

@implementation TWTRSESheetPresentationController {
    CGFloat _minimumCompactSizeClassPadding;
    CGFloat _minimumRegularSizeClassPadding;
}

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController
{
    if ((self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController])) {
        _dimmingView = [[UIView alloc] init];
        _dimmingView.backgroundColor = [UIColor grayColor];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    }

    return self;
}

- (BOOL)shouldPresentInFullscreen
{
    return NO;
}

- (BOOL)shouldRemovePresentersView
{
    return NO;
}

- (CGFloat)minimumTopPadding
{
    // the point of this getter is to avoid bumping into edges, whilst trying to minimize
    // the amount of padding; the point of caching the values calculated for each size
    // is to avoid bouncing behavior that can be caused by rotation and/or size changes
    // (which could cause the _minimum to be slightly over one threshold in one case, but
    // under it the next time ... which would cause the top of the view to bounce).

    UIView *navBar = self.presentedViewController.navigationController.navigationBar;
    if (UIUserInterfaceSizeClassRegular != self.traitCollection.verticalSizeClass) {
        // this padding takes care of a case like Google Chrome, which leaves the status bar up
        // in landscape, even on a small device
        if (_minimumCompactSizeClassPadding < navBar.frame.origin.y) {
            _minimumCompactSizeClassPadding = navBar.frame.origin.y;
            [navBar setNeedsLayout];
        }
        return _minimumCompactSizeClassPadding;
    } else {
        UIView *presenting = self.presentingViewController.view;

        // this padding takes care of most cases
        if (_minimumRegularSizeClassPadding < presenting.layoutMargins.top) {
            _minimumRegularSizeClassPadding = presenting.layoutMargins.top;
        }
        if (@available(iOS 11.0, *)) {
            // this padding deals with some iOS 11 cases for safe areas,
            // most particularly iPhone X, but also other apps that use safeAreaInsets
            if (_minimumRegularSizeClassPadding < presenting.safeAreaInsets.top) {
                _minimumRegularSizeClassPadding = presenting.safeAreaInsets.top;
            }
        }
        // this padding takes care of being presented from com.apple.screenshotServicesServices
        // (without having to peek at the presenting VC's "hostBundleID", which appears to be apple private)
        if (_minimumRegularSizeClassPadding < navBar.frame.origin.y) {
            _minimumRegularSizeClassPadding = navBar.frame.origin.y;
        }
        return _minimumRegularSizeClassPadding;
    }
}

- (CGFloat)bottomPadding
{
    return self.keyboardOnScreen ? kModalBottomPaddingKeyboardUp : kModalBottomPaddingKeyboardDown;
}

- (CGFloat)horizontalPadding
{
    return self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact ? kModalCompactHorizontalPadding : kModalRegularHorizontalPadding;
}

- (CGSize)sizeForChildContentContainer:(id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize
{
    CGFloat preferredHeight = self.presentedViewController.preferredContentSize.height;

    if (preferredHeight == 0) {
        preferredHeight = parentSize.height;
    }

    const CGFloat maxHeight = MAX(0, parentSize.height - self.keyboardHeight - self.minimumTopPadding - self.bottomPadding);
    if (preferredHeight > maxHeight) {
        preferredHeight = maxHeight;
    }

    CGFloat preferredWidth = MAX(0, (parentSize.width - self.horizontalPadding * 2));
    if (preferredWidth > kModalMaximumWidth) {
        preferredWidth = kModalMaximumWidth;
    }

    return CGSizeMake(preferredWidth, preferredHeight);
}

- (CGRect)frameOfPresentedViewInContainerView
{
    CGRect presentedViewFrame = CGRectZero;

    UIViewController *contentContainer = self.presentedViewController;
    const CGRect containerBounds = self.containerView.bounds;

    presentedViewFrame.size = [self sizeForChildContentContainer:contentContainer withParentContainerSize:containerBounds.size];

    presentedViewFrame.origin.x = (CGRectGetWidth(containerBounds) - CGRectGetWidth(presentedViewFrame)) / (CGFloat)2.0;

    // kModalPreferredVerticalPositionFactor is better than always using minimumTopPadding in very big screens
    CGFloat originY = (CGRectGetHeight(containerBounds) * kModalPreferredVerticalPositionFactor) - (CGRectGetHeight(presentedViewFrame) / (CGFloat)2.0);

    const CGFloat minimumTopPadding = self.minimumTopPadding;
    if (originY < minimumTopPadding) {
        originY = minimumTopPadding;
    }

    // Avoid the keyboard covering the modal
    if (originY + CGRectGetHeight(presentedViewFrame) > CGRectGetHeight(containerBounds) - self.keyboardHeight - self.bottomPadding) {
        originY = minimumTopPadding;
    }

    presentedViewFrame.origin.y = originY;

    return CGRectIntegral(presentedViewFrame);
}

- (void)containerViewWillLayoutSubviews
{
    [super containerViewWillLayoutSubviews];
    [self layoutSubviews];
}

- (void)layoutSubviews
{
    [self.presentedViewController.navigationController.navigationBar setNeedsLayout];
    self.presentedView.frame = [self frameOfPresentedViewInContainerView];
    self.dimmingView.frame = self.containerView.bounds;
}

- (void)presentationTransitionWillBegin
{
    self.presentedView.layer.cornerRadius = kModalCornerRadius;
    self.presentedView.layer.masksToBounds = YES;

    self.dimmingView.alpha = 0;
    [self.containerView addSubview:self.dimmingView];
    [self.containerView sendSubviewToBack:self.dimmingView];

    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        self.dimmingView.alpha = 0.5;
    }
                                                                        completion:nil];
}

- (void)dismissalTransitionWillBegin
{
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        self.dimmingView.alpha = 0;
    }
                                                                        completion:nil];
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(id<UIContentContainer>)container
{
    // Force an update of the size of the sheet if the preferred size of the presented controller changes.
    if (container == self.presentedViewController) {
        [self layoutSubviews];
    }
}

#pragma mark - Keyboard Handling

- (void)setKeyboardOnScreen:(BOOL)keyboardOnScreen
{
    if (keyboardOnScreen != _keyboardOnScreen) {
        _keyboardOnScreen = keyboardOnScreen;

        [self layoutSubviews];
    }
}

- (void)setKeyboardHeight:(CGFloat)keyboardHeight
{
    if (keyboardHeight != _keyboardHeight) {
        _keyboardHeight = keyboardHeight;

        [self layoutSubviews];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    self.keyboardHeight = CGRectGetHeight([notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue]);
    self.keyboardOnScreen = YES;
}

- (void)keyboardWillHide
{
    self.keyboardOnScreen = NO;
    self.keyboardHeight = 0;
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    self.keyboardHeight = CGRectGetHeight([notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue]);
}

@end
