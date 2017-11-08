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

#import "TWTRAnimatableImageView.h"
#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "TWTRFrameSheet.h"

@interface TWTRAnimatableImageView ()
@property (nonatomic, copy) void (^animationCompletion)(BOOL);
@end

@interface TWTRAnimatableImageViewLayer : CALayer
@property (nonatomic, weak) TWTRAnimatableImageView *imageView;
@end

@interface TWTRAnimatableImageViewDelegate : NSObject
- (instancetype)initWithImageView:(TWTRAnimatableImageView *)imageView originalDelegate:(id)originalDelegate animationKey:(NSString *)animationKey completion:(void (^)(BOOL))completion;
@property (nonatomic, readonly) TWTRAnimatableImageView *imageView;
@property (nonatomic, readonly) id originalDelegate;
@property (nonatomic, readonly) NSString *animationKey;
@property (nonatomic, readonly) void (^completion)(BOOL);
@end

@implementation TWTRAnimatableImageView

+ (Class)layerClass
{
    return [TWTRAnimatableImageViewLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit
{
    TWTRAnimatableImageViewLayer *layer = (TWTRAnimatableImageViewLayer *)self.layer;
    layer.imageView = self;
}

- (void)startAnimatingWithDuration:(NSTimeInterval)duration repeatCount:(NSUInteger)repeatCount completion:(void (^)(BOOL finished))completion
{
    self.animationDuration = duration;
    self.animationRepeatCount = repeatCount;
    self.animationCompletion = completion;

    [self startAnimating];  // uses self.animationCompletion
    self.animationCompletion = nil;
}

- (void)startAnimatingWithFrameSheet:(TWTRFrameSheet *)frameSheet duration:(NSTimeInterval)duration repeatCount:(NSUInteger)repeatCount completion:(void (^)(BOOL))completion
{
    _frameSheet = frameSheet;
    self.animationImages = frameSheet.frameArray;
    [self startAnimatingWithDuration:duration repeatCount:repeatCount completion:completion];
}

- (CGSize)intrinsicContentSize
{
    if (self.image) {
        return self.image.size;
    } else if (_frameSheet) {
        return CGSizeMake(_frameSheet.imageWidth, _frameSheet.imageHeight);
    }
    return CGSizeZero;
}

@end

@implementation TWTRAnimatableImageViewLayer

- (void)addAnimation:(CAAnimation *)anim forKey:(NSString *)key
{
    if ([key isEqualToString:@"contents"]) {
        // - We want the completion to be called *before* the animation is removed from the render tree. So
        //   tweak the provided animation to guarantee that this happens and save the key so that we can
        //   remove it ourselves once the completion has been called.

        anim.removedOnCompletion = NO;
        anim.fillMode = kCAFillModeForwards;

        TWTRAnimatableImageViewDelegate *newDelegate = [[TWTRAnimatableImageViewDelegate alloc] initWithImageView:self.imageView originalDelegate:anim.delegate animationKey:key completion:self.imageView.animationCompletion];
        anim.delegate = (id)newDelegate;  // keeps a strong reference to newDelegate, released when the animation completes.
    }

    [super addAnimation:anim forKey:key];
}

@end

@implementation TWTRAnimatableImageViewDelegate

- (instancetype)initWithImageView:(TWTRAnimatableImageView *)imageView originalDelegate:(id)originalDelegate animationKey:(NSString *)animationKey completion:(void (^)(BOOL))completion
{
    if (self = [super init]) {
        _imageView = imageView;
        _originalDelegate = originalDelegate;
        _animationKey = [animationKey copy];
        _completion = [completion copy];
    }
    return self;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (_completion) {
        _completion(flag);
    }
    _completion = nil;

    // - Remove the animation only if it's actually the current animation for the key. If a new animation
    //   has taken its place, it's already been removed.

    if (anim == [_imageView.layer animationForKey:_animationKey]) {
        [_imageView.layer removeAnimationForKey:_animationKey];
    }

    if (_originalDelegate && [_originalDelegate respondsToSelector:@selector(animationDidStop:finished:)]) {
        [_originalDelegate animationDidStop:anim finished:flag];
    }
}

@end
