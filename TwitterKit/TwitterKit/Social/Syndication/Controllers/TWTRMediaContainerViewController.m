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

#import "TWTRMediaContainerViewController.h"
#import "TWTRImages.h"
#import "TWTRMediaPresentationController.h"
#import "TWTRTranslationsUtil.h"
#import "TWTRViewUtil.h"

NS_ASSUME_NONNULL_BEGIN

@interface TWTRMediaContainerViewController () <UIViewControllerTransitioningDelegate>

@property (nonatomic) CGRect initialViewPosition;
@property (nonatomic) BOOL hideStatusBar;

@property (nonatomic, readonly) UINavigationBar *topBarContainer;
@property (nonatomic, readonly) UIButton *closeButton;

@end

@implementation TWTRMediaContainerViewController

- (instancetype)initWithMediaViewController:(UIViewController<TWTRMediaContainerPresentable> *)mediaViewController
{
    self = [super init];
    if (self) {
        _mediaViewController = mediaViewController;
        _hideStatusBar = NO;
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    // We want the status bar to be hidden for this view controller but we want to avoid hiding
    // the status bar until the view is presented which makes for a smoother animation. We initially
    // set this value to NO and then when we have actually been presented we set it to YES and ask
    // the status bar to update itself. This feels hacky but it makes for a nice animation.
    return self.hideStatusBar;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([self.mediaViewController respondsToSelector:@selector(viewDidLoadWithMediaContainer:)]) {
        [self.mediaViewController viewDidLoadWithMediaContainer:self];
    }

    self.view.backgroundColor = [UIColor blackColor];

    [self embedMediaViewController];
    [self prepareTopBar];
}

- (void)embedMediaViewController
{
    [self addChildViewController:self.mediaViewController];

    self.mediaViewController.view.frame = self.view.bounds;
    self.mediaViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mediaViewController.view];

    [self.mediaViewController didMoveToParentViewController:self];
}

#pragma mark - View Management

- (void)prepareTopBar
{
    UINavigationBar *topBar = [[UINavigationBar alloc] init];
    topBar.barStyle = UIBarStyleBlack;

    // Create an empty image so that the nav bar is transparent
    UIImage *emptyImage = [[UIImage alloc] init];
    [topBar setBackgroundImage:emptyImage forBarMetrics:UIBarMetricsDefault];
    topBar.shadowImage = emptyImage;

    topBar.translatesAutoresizingMaskIntoConstraints = NO;
    topBar.backgroundColor = [UIColor clearColor];
    topBar.tintColor = [UIColor whiteColor];
    [self.view addSubview:topBar];

    NSDictionary *views = NSDictionaryOfVariableBindings(topBar);

    [TWTRViewUtil addVisualConstraints:@"H:|[topBar]|" views:views];
    if (@available(iOS 11, *)) {
        [topBar.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = YES;
    } else {
        [TWTRViewUtil addVisualConstraints:@"V:|[topBar]" views:views];
    }

    UIBarButtonItem *button = [self makeCloseButton];
    UINavigationItem *item = [[UINavigationItem alloc] init];
    item.rightBarButtonItem = button;
    [topBar pushNavigationItem:item animated:NO];

    _topBarContainer = topBar;
}

- (void)setChromeVisible:(BOOL)visible animated:(BOOL)animated
{
    CGAffineTransform topTransform = visible ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0.0, -self.topBarContainer.bounds.size.height / 2.0);
    CGFloat alpha = visible ? 1.0 : 0.0;

    void (^animations)(void) = ^{
        self.topBarContainer.transform = topTransform;
        self.closeButton.alpha = alpha;

        [self.view layoutIfNeeded];
    };

    if (animated) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:animations completion:nil];
    } else {
        animations();
    }
}

- (UIBarButtonItem *)makeCloseButton
{
    const CGFloat width = 40.0;
    const CGFloat height = 44.0;

    UIImage *closeButtonImage = [TWTRImages closeButtonTemplateImage];
    _closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _closeButton.tintColor = [UIColor whiteColor];
    _closeButton.bounds = CGRectMake(0, 0, width, height);

    [_closeButton setImage:closeButtonImage forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(handleCloseButton) forControlEvents:UIControlEventTouchUpInside];
    _closeButton.accessibilityLabel = TWTRLocalizedString(@"tw__close_button");

    // Make sure the close button is 20px from the top and side
    _closeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, (closeButtonImage.size.width - width) / 2.0);
    _closeButton.contentEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 0);

    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithCustomView:_closeButton];
    return closeButton;
}

- (void)handleCloseButton
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.mediaViewController didDismissInMediaContainer];
    }];
}

#pragma mark - Presentation

- (void)showFromView:(UIView *)view inViewController:(UIViewController *)controller completion:(void (^)(void))completion
{
    self.initialViewPosition = [view convertRect:view.bounds toView:self.view];

    self.transitioningDelegate = self;
    self.modalPresentationStyle = UIModalPresentationFullScreen;

    [self.mediaViewController willShowInMediaContainer];

    [controller presentViewController:self animated:YES completion:completion];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (nullable id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    UIView *transitionImageView = [[UIImageView alloc] initWithImage:self.mediaViewController.transitionImage];
    transitionImageView.contentMode = UIViewContentModeScaleAspectFill;
    transitionImageView.clipsToBounds = YES;

    [self.mediaViewController transitionWillBegin];
    self.topBarContainer.alpha = 0.0;

    CGRect targetRect = [self.mediaViewController transitionImageTargetFrame];
    return [[TWTRMediaAnimatedTransitioningPresenter alloc] initWithTransitioningView:transitionImageView initialFrame:self.initialViewPosition targetFrame:targetRect completion:^{

        transitionImageView.frame = targetRect;
        transitionImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [transitionImageView removeFromSuperview];
        self.view.alpha = 1.0;

        [self.mediaViewController transitionDidComplete];
        self.topBarContainer.alpha = 1.0;

        self.hideStatusBar = YES;
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

- (nullable id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return nil;
}

- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    return [[TWTRMediaPresentationController alloc] initWithPresentedViewController:presented presentingViewController:source];
}

@end

NS_ASSUME_NONNULL_END
