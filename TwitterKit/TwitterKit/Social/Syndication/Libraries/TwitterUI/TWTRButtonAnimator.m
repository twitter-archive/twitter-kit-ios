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

#import "TWTRButtonAnimator.h"
#import <QuartzCore/CALayer.h>
#import <UIKit/UIKit.h>
#import "TWTRAnimatableImageView.h"
#import "TWTRFrameSheet.h"
#import "TWTRImageSequenceConfiguration.h"

@implementation TWTRButtonAnimator

+ (BOOL)performAnimationType:(TWTRButtonAnimationType)animationType onButton:(UIButton *)button completion:(dispatch_block_t)completion
{
    if (TWTRButtonAnimationTypeNone == animationType) {
        return NO;
    }

    [self _abortInFlightAnimation:button];

    switch (animationType) {
        case TWTRButtonAnimationTypeActionBarHeartSequence: {
            [self _performImageSequenceOnButton:button forImageSequenceConfiguration:[TWTRImageSequenceConfiguration heartImageSequenceConfigurationWithSize:TWTRHeartImageSequenceSizeRegular] completion:completion];
            break;
        }
        case TWTRButtonAnimationTypeActionBarHeartSequenceLarge: {
            [self _performImageSequenceOnButton:button forImageSequenceConfiguration:[TWTRImageSequenceConfiguration heartImageSequenceConfigurationWithSize:TWTRHeartImageSequenceSizeLarge] completion:completion];
            break;
        }
        default:
            YES;
    }

    return YES;
}

+ (void)_abortInFlightAnimation:(UIButton *)button
{
    // In case we're interrupting an animation, remove it
    [button.layer removeAllAnimations];
    for (UIView *subview in button.subviews) {
        [subview.layer removeAllAnimations];
    }
}

+ (void)_performImageSequenceOnButton:(UIButton *)button forImageSequenceConfiguration:(TWTRImageSequenceConfiguration *)imageSequenceConfiguration completion:(dispatch_block_t)completion
{
    if ([button.imageView isKindOfClass:[TWTRAnimatableImageView class]]) {
        TWTRFrameSheet *frameSheet = [[TWTRFrameSheet alloc] initWithImage:imageSequenceConfiguration.imageSheet rows:imageSequenceConfiguration.rows columns:imageSequenceConfiguration.columns frameCount:imageSequenceConfiguration.frameCount imageWidth:imageSequenceConfiguration.imageSize.width imageHeight:imageSequenceConfiguration.imageSize.height];

        TWTRAnimatableImageView *imageView = (TWTRAnimatableImageView *)button.imageView;
        @weakify(imageView);
        [imageView startAnimatingWithFrameSheet:frameSheet duration:imageSequenceConfiguration.duration repeatCount:1 completion:^(BOOL finished) {
            @strongify(imageView);
            imageView.animationImages = nil;
            if (completion) {
                completion();
            }
        }];
    }
}

@end
