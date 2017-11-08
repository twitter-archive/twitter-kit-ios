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

#import "TWTRBirdView.h"
#import "TWTRBezierPaths.h"

static CGFloat const TWTRBirdSmallSize = 16.0;
static CGFloat const TWTRBirdMediumSize = 24.0;

@interface TWTRBirdView ()

@property (nonatomic, assign) CGSize desiredSize;

@end

@implementation TWTRBirdView
@synthesize birdColor = _birdColor;

+ (instancetype)smallBird
{
    return [[self alloc] initWithFrame:CGRectMake(0, 0, TWTRBirdSmallSize, TWTRBirdSmallSize)];
}

+ (instancetype)mediumBird
{
    return [[self alloc] initWithFrame:CGRectMake(0, 0, TWTRBirdMediumSize, TWTRBirdMediumSize)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.desiredSize = frame.size;
        self.opaque = NO;
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *path = [TWTRBezierPaths twitterLogo];
    CGFloat width = self.bounds.size.width;
    CGAffineTransform transform = CGAffineTransformMakeScale(width, width);
    [path applyTransform:transform];
    [self.birdColor setFill];
    [path fill];
}

- (CGSize)intrinsicContentSize
{
    return self.desiredSize;
}

- (void)setBirdColor:(UIColor *)birdColor
{
    if (_birdColor != birdColor) {
        _birdColor = birdColor;
        [self setNeedsDisplay];
    }
}

- (UIColor *)birdColor
{
    return _birdColor ?: [UIColor whiteColor];
}

@end
