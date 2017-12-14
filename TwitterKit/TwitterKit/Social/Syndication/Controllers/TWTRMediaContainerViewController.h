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

/**
 This header is private to the Twitter Kit SDK and not exposed for public SDK consumption
 */

#import <UIKit/UIKit.h>

@protocol TWTRMediaContainerPresentable;

@interface TWTRMediaContainerViewController : UIViewController

@property (nonatomic, readonly) UIViewController<TWTRMediaContainerPresentable> *mediaViewController;

- (instancetype)initWithMediaViewController:(UIViewController<TWTRMediaContainerPresentable> *)mediaViewController;

/**
 * Calling this method will present the view controller from the given view.
 */
- (void)showFromView:(UIView *)view inViewController:(UIViewController *)controller completion:(void (^)(void))completion;

/**
 * Calling this method will hide/show the chrome for the container.
 */
- (void)setChromeVisible:(BOOL)visible animated:(BOOL)animated;

@end

@protocol TWTRMediaContainerPresentable <NSObject>

@required

/**
 * Return the image that will be used for the transition.
 */
- (UIImage *)transitionImage;

/**
 * Specifies the final frame for the image that is being presented.
 */
- (CGRect)transitionImageTargetFrame;

/**
 * This method is called before the transtion begins.
 */
- (void)transitionWillBegin;

/**
 * This method is called when the transtion completes.
 */
- (void)transitionDidComplete;

/**
 * This method is called when the media container will be shown.
 */
- (void)willShowInMediaContainer;

/**
 * This method is called after the media container is dismissed.
 */
- (void)didDismissInMediaContainer;

@optional

/**
 * This method is called during viewDidLoad of the view controller lifecycle.
 */
- (void)viewDidLoadWithMediaContainer:(TWTRMediaContainerViewController *)mediaContainer;

@end
