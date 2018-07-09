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

#import "TWTRImageViewController.h"
#import <TwitterCore/TWTRAssertionMacros.h>
#import "TWTRImageLoader.h"
#import "TWTRImageScrollView.h"
#import "TWTRTranslationsUtil.h"
#import "TWTRTweetMediaEntity.h"
#import "TWTRTwitter_Private.h"
#import "TWTRViewUtil.h"

@interface TWTRImageViewController ()

@property (nonatomic) TWTRImageScrollView *scrollView;
@property (nonatomic, nullable) UIImage *image;
@property (nonatomic, readonly) TWTRTweetMediaEntity *mediaEntity;
@property (nonatomic, copy, readonly) NSString *parentTweetID;

@end

@implementation TWTRImageViewController

- (instancetype)initWithImage:(nullable UIImage *)image mediaEntity:(TWTRTweetMediaEntity *)mediaEntity parentTweetID:(NSString *)parentTweetID
{
    if (self = [super init]) {
        _image = image;
        _mediaEntity = mediaEntity;
        _parentTweetID = [parentTweetID copy];
    }

    return self;
}

- (void)loadView
{
    self.scrollView = [[TWTRImageScrollView alloc] init];
    self.view = self.scrollView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - UIViewController Lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.scrollView displayImage:self.image];

    NSURL *imageURL = [self fullResolutionURL];
    if (imageURL) {
        [self loadFullImageWithURL:imageURL];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.scrollView resetZoomScale];
}

#pragma mark - Image Loading

- (void)loadFullImageWithURL:(NSURL *)URL
{
    [[TWTRTwitter sharedInstance].imageLoader fetchImageWithURL:URL
                                                     completion:^(UIImage *fullImage, NSError *error) {
                                                         if (fullImage) {
                                                             [self.scrollView displayImage:fullImage];
                                                         } else {
                                                             NSLog(@"[TwitterKit] Could not load full resolution image: %@", error);
                                                         }
                                                     }];
}

- (nullable NSURL *)fullResolutionURL
{
    if (self.mediaEntity.mediaUrl) {
        return [NSURL URLWithString:self.mediaEntity.mediaUrl];
        ;
    } else {
        return nil;
    }
}

#pragma mark - TWTRMediaContainerPresentable

- (void)willShowInMediaContainer
{
}

- (void)didDismissInMediaContainer
{
}

- (UIImage *)transitionImage
{
    return self.image;
}

- (CGRect)transitionImageTargetFrame
{
    CGSize imageSize = self.image.size;
    CGFloat zoomScale = [self.scrollView initialZoomScaleForImage:self.image constrainedToBounds:self.view.bounds];

    CGSize targetSize = CGSizeMake(imageSize.width * zoomScale, imageSize.height * zoomScale);

    CGFloat x = (self.view.bounds.size.width - targetSize.width) / 2.0;
    CGFloat y = (self.view.bounds.size.height - targetSize.height) / 2.0;

    CGRect rect = CGRectMake(x, y, targetSize.width, targetSize.height);
    return CGRectIntegral(rect);
}

- (void)transitionWillBegin
{
}

- (void)transitionDidComplete
{
}

@end
