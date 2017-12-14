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

#import "TWTRImageScrollView.h"
#import <TwitterCore/TWTRColorUtil.h>

static CGFloat const TWTRPhoneMaxZoom = 3.0;
static CGFloat const TWTRPadMaxZoom = 4.0;

@interface TWTRImageScrollView () <UIScrollViewDelegate>

@property (nonatomic) UIImageView *imageView;

@end

@implementation TWTRImageScrollView

- (instancetype)init
{
    if (self = [super init]) {
        self.backgroundColor = [TWTRColorUtil blackColor];
        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeCenter;
        self.imageView.userInteractionEnabled = YES;
        [self addSubview:self.imageView];

        self.delegate = self;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.alwaysBounceVertical = YES;
        self.alwaysBounceHorizontal = YES;

        if (@available(iOS 11, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }

        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
        doubleTapGesture.numberOfTapsRequired = 2;
        [self.imageView addGestureRecognizer:doubleTapGesture];
    }

    return self;
}

- (void)displayImage:(UIImage *)image
{
    self.imageView.image = image;
    self.contentSize = image.size;
    self.imageView.frame = [self targetBoundsForImage:image];

    BOOL isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    self.maximumZoomScale = isPad ? TWTRPadMaxZoom : TWTRPhoneMaxZoom;

    CGFloat initialScale = [self initialZoomScale];
    self.minimumZoomScale = initialScale;
    self.zoomScale = initialScale;

    [self setNeedsLayout];
}

- (void)resetZoomScale;
{
    self.zoomScale = [self initialZoomScale];
}

// Zoom scale which would make the smaller dimension *just* fit the screen
- (CGFloat)initialZoomScaleForImage:(UIImage *)image constrainedToBounds:(CGRect)bounds;
{
    CGSize boundsSize = bounds.size;
    CGSize imageSize = image.size;

    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise

    CGFloat zoomScale = MIN(xScale, yScale);

    return zoomScale;
}

- (CGFloat)initialZoomScale
{
    return [self initialZoomScaleForImage:self.imageView.image constrainedToBounds:self.bounds];
}

- (CGRect)targetBoundsForImage:(UIImage *)image
{
    CGSize boundsSize = self.bounds.size;
    return CGRectMake(0, 0, MIN(image.size.width, boundsSize.width), MIN(image.size.height, boundsSize.height));
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];

    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.imageView.frame;

    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }

    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - self.contentInset.top - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }

    // Center
    if (!CGRectEqualToRect(self.imageView.frame, frameToCenter)) {
        self.imageView.frame = CGRectIntegral(frameToCenter);
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - Gesture Recognizers

- (void)doubleTapped:(UIGestureRecognizer *)gestureRecognizer
{
    // Translate touch location to image view location
    CGPoint touchPoint = [gestureRecognizer locationInView:self.imageView];
    CGFloat touchX = touchPoint.x;
    CGFloat touchY = touchPoint.y;
    touchX *= 1 / self.zoomScale;
    touchY *= 1 / self.zoomScale;
    touchX += self.contentOffset.x;
    touchY += self.contentOffset.y;
    CGPoint offsetTouch = CGPointMake(touchX, touchY);

    // Zoom
    BOOL shouldZoom = !(self.zoomScale != self.minimumZoomScale && self.zoomScale != [self initialZoomScale]);
    if (shouldZoom) {  // Zoom in
        CGFloat newZoomScale = ((self.maximumZoomScale + self.minimumZoomScale) / 2);
        CGFloat xsize = self.bounds.size.width / newZoomScale;
        CGFloat ysize = self.bounds.size.height / newZoomScale;
        [self zoomToRect:CGRectMake(offsetTouch.x - xsize / 2, offsetTouch.y - ysize / 2, xsize, ysize) animated:YES];
    } else {  // Zoom out
        [self setZoomScale:self.minimumZoomScale animated:YES];
    }
}

@end
