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

#import "TWTRMultiImageViewController.h"
#import <TwitterCore/TWTRAssertionMacros.h>
#import "TWTRImageViewController.h"
#import "TWTRTwitter_Private.h"

@interface TWTRMultiImageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, readonly) NSInteger initialImageViewControllerIndex;
@property (nonatomic, readonly) NSArray *imageViewControllers;

@end

@implementation TWTRMultiImageViewController

- (instancetype)initWithImagePresentationContexts:(NSArray<TWTRImagePresentationContext *> *)contexts initialContextIndex:(NSInteger)index
{
    TWTRParameterAssertOrReturnValue(contexts.count > 0, nil);
    TWTRParameterAssertOrReturnValue(index < contexts.count && index >= 0, nil);

    NSDictionary *options = @{ UIPageViewControllerOptionInterPageSpacingKey: @10 };
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
    if (self) {
        _contexts = [contexts copy];
        _initialImageViewControllerIndex = index;
        _imageViewControllers = [[self class] imageViewControllersForContexts:contexts];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.dataSource = self;
    self.delegate = self;

    [self setViewControllers:@[[self initialImageViewController]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

+ (NSArray<TWTRImageViewController *> *)imageViewControllersForContexts:(NSArray<TWTRImagePresentationContext *> *)contexts
{
    NSMutableArray<TWTRImageViewController *> *controllers = [NSMutableArray array];

    for (TWTRImagePresentationContext *context in contexts) {
        TWTRImageViewController *vc = [self imageViewControllerForContext:context];
        [controllers addObject:vc];
    }

    return controllers;
}

+ (TWTRImageViewController *)imageViewControllerForContext:(TWTRImagePresentationContext *)context
{
    return [[TWTRImageViewController alloc] initWithImage:context.image mediaEntity:context.mediaEntity parentTweetID:context.parentTweetID];
}

- (NSInteger)indexOfViewController:(UIViewController *)viewController
{
    return [self.imageViewControllers indexOfObject:viewController];
}

#pragma mark - Datasource

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger previousIndex = [self indexOfViewController:viewController] - 1;
    return (previousIndex < 0) ? nil : self.imageViewControllers[previousIndex];
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger nextIndex = [self indexOfViewController:viewController] + 1;
    return (nextIndex == self.imageViewControllers.count) ? nil : self.imageViewControllers[nextIndex];
}

#pragma mark - Delegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
}

#pragma mark - TWTRMediaContainerPresentable

- (TWTRImageViewController *)initialImageViewController
{
    return self.imageViewControllers[self.initialImageViewControllerIndex];
}

- (void)willShowInMediaContainer
{
}

- (void)didDismissInMediaContainer
{
}

- (UIImage *)transitionImage
{
    return [[self initialImageViewController] transitionImage];
}

- (CGRect)transitionImageTargetFrame
{
    return [[self initialImageViewController] transitionImageTargetFrame];
}

- (void)transitionWillBegin
{
}

- (void)transitionDidComplete
{
}

@end

@implementation TWTRImagePresentationContext

+ (instancetype)contextWithImage:(nullable UIImage *)image mediaEntity:(TWTRTweetMediaEntity *)mediaEntity parentTweetID:(NSString *)parentTweetID
{
    return [[self alloc] initWithImage:image mediaEntity:mediaEntity parentTweetID:parentTweetID];
}

- (instancetype)initWithImage:(nullable UIImage *)image mediaEntity:(TWTRTweetMediaEntity *)mediaEntity parentTweetID:(NSString *)parentTweetID
{
    self = [super init];
    if (self) {
        _image = image;
        _mediaEntity = mediaEntity;
        _parentTweetID = [parentTweetID copy];
    }
    return self;
}

@end
