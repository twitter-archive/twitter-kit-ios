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

#import "TWTRViewUtil.h"
#import <TwitterCore/TWTRAssertionMacros.h>
#import <TwitterCore/TWTRDictUtil.h>
#import "TWTRAPIConstantsStatus.h"
#import "TWTRMediaEntitySize.h"
#import "TWTRTweetMediaEntity.h"

static CGFloat const TWTRTweetMediaViewDefaultWidthHint = 300.0;

CGFloat TWTRRoundHalfInteger(CGFloat number)
{
    return round(number * 2) / 2;
}

CGFloat TWTRFloorHalfInteger(CGFloat number)
{
    return floor(number * 2) / 2;
}

CGRect TWTRRectPixelIntegral(CGRect rect)
{
    CGFloat newX = TWTRFloorHalfInteger(rect.origin.x);
    CGFloat newY = TWTRFloorHalfInteger(rect.origin.y);
    CGFloat newWidth = TWTRRoundHalfInteger(rect.size.width);
    CGFloat newHeight = TWTRRoundHalfInteger(rect.size.height);

    CGRect newRect = CGRectMake(newX, newY, newWidth, newHeight);
    return newRect;
}

@implementation TWTRViewUtil

+ (TWTRMediaEntitySize *)bestMatchSizeFromMediaEntity:(TWTRTweetMediaEntity *)mediaEntity fittingWidth:(CGFloat)fittingWidth
{
    NSParameterAssert(mediaEntity);
    fittingWidth = MAX(fittingWidth, TWTRTweetMediaViewDefaultWidthHint);
    if (mediaEntity.sizes.count == 0) {
        return nil;
    }

    // Strip out sizes that are too small
    NSMutableDictionary<NSString *, TWTRMediaEntitySize *> *validSizes = [NSMutableDictionary dictionary];
    [mediaEntity.sizes enumerateKeysAndObjectsUsingBlock:^(NSString *sizeName, TWTRMediaEntitySize *sizeDetails, BOOL *stop) {
        BOOL validSize = sizeDetails.size.width >= TWTRTweetMediaViewDefaultWidthHint;
        BOOL validResizeMode = sizeDetails.resizingMode == TWTRMediaEntitySizeResizingModeFit;

        if (validSize && validResizeMode) {
            validSizes[sizeName] = sizeDetails;
        }
    }];

    // If we just stripped out *all* images as invalid, use the original dict
    NSDictionary<NSString *, TWTRMediaEntitySize *> *sizesToCompare = (validSizes.count > 0) ? validSizes : mediaEntity.sizes;

    // Sort sizes by the difference in width to determine the size that
    // fills the most pixels (scales least) while minimizing bandwidth
    NSArray *sortedSizes = [sizesToCompare keysSortedByValueUsingComparator:^NSComparisonResult(TWTRMediaEntitySize *size1, TWTRMediaEntitySize *size2) {
        CGFloat width1 = size1.size.width;
        CGFloat width2 = size2.size.width;

        if (fabs(width1 - fittingWidth) < fabs(width2 - fittingWidth)) {
            return (NSComparisonResult)NSOrderedAscending;
        } else {
            return (NSComparisonResult)NSOrderedDescending;
        }
    }];
    NSString *chosenKey = [sortedSizes firstObject];
    TWTRMediaEntitySize *entitySize = sizesToCompare[chosenKey];

    return entitySize;
}

+ (CGFloat)averageAspectRatioForMediaEntity:(TWTRTweetMediaEntity *)mediaEntity
{
    CGFloat __block sum = 0.0;
    NSInteger __block count = 0;

    [mediaEntity.sizes enumerateKeysAndObjectsUsingBlock:^(NSString *key, TWTRMediaEntitySize *mediaSize, BOOL *stop) {
        if (mediaSize.resizingMode == TWTRMediaEntitySizeResizingModeFit) {
            count++;
            sum += [self aspectRatioForSize:mediaSize.size];
        }
    }];

    if (count > 0) {
        return sum / count;
    } else {
        return 0.0;
    }
}

+ (CGFloat)aspectRatioForSize:(CGSize)size
{
    return [self aspectRatioForWidth:size.width height:size.height];
}

+ (CGFloat)aspectRatioForWidth:(CGFloat)width height:(CGFloat)height
{
    if (height == 0.0) {
        return 0.0;
    }

    return width / height;
}

+ (BOOL)aspectRatioIsLandscape:(CGFloat)aspectRatio
{
    return aspectRatio > 1.0;
}

+ (NSLayoutConstraint *)constraintForAttribute:(NSLayoutAttribute)attribute onView:(UIView *)view value:(CGFloat)value
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view attribute:attribute relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:value];

    return constraint;
}

+ (NSLayoutConstraint *)constraintToTopOfSuperview:(UIView *)view
{
    return [self constraintToTopOfSuperview:view constant:0.0];
}

+ (NSLayoutConstraint *)constraintToTopOfSuperview:(UIView *)view constant:(CGFloat)constant
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:constant];

    return constraint;
}

+ (NSLayoutConstraint *)constraintToBottomOfSuperview:(UIView *)view
{
    return [self constraintToBottomOfSuperview:view constant:0.0];
}

+ (NSLayoutConstraint *)constraintToBottomOfSuperview:(UIView *)view constant:(CGFloat)constant
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view.superview attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:constant];

    return constraint;
}

+ (NSLayoutConstraint *)constraintForAspectRatio:(CGFloat)aspectRatio onView:(UIView *)view
{
    return [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeHeight multiplier:aspectRatio constant:0];
}
+ (NSLayoutConstraint *)marginConstraintBetweenTopView:(UIView *)topView bottomView:(UIView *)bottomView
{
    return [NSLayoutConstraint constraintWithItem:bottomView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:topView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
}

+ (void)centerView:(UIView *)view inView:(UIView *)otherView
{
    [self centerViewVertically:view inView:otherView];
    [self centerViewHorizontally:view inView:otherView];
}

+ (void)centerViewInSuperview:(UIView *)view
{
    [self centerView:view inView:view.superview];
}

+ (void)centerViewHorizontally:(UIView *)view inView:(UIView *)otherView
{
    TWTRParameterAssertOrReturn(view);
    TWTRParameterAssertOrReturn(otherView);
    [self equateAttribute:NSLayoutAttributeCenterX onView:view toView:otherView];
}

+ (void)centerViewHorizontallyInSuperview:(UIView *)view
{
    [self centerViewHorizontally:view inView:view.superview];
}

+ (void)centerViewVertically:(UIView *)view inView:(UIView *)otherView
{
    TWTRParameterAssertOrReturn(view);
    TWTRParameterAssertOrReturn(otherView);
    [self equateAttribute:NSLayoutAttributeCenterY onView:view toView:otherView];
}

+ (void)centerViewVerticallyInSuperview:(UIView *)view
{
    [self centerViewVertically:view inView:view.superview];
}

+ (NSArray *)constraintsWithFormat:(NSString *)format metrics:(NSDictionary *)metrics views:(NSDictionary *)views
{
    return [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
}

+ (void)equateAttribute:(NSLayoutAttribute)attribute onView:(UIView *)view1 toView:(UIView *)view2
{
    [self equateAttribute:attribute onView:view1 toView:view2 constant:0.0];
}

+ (void)equateAttribute:(NSLayoutAttribute)attribute onView:(UIView *)view1 toView:(UIView *)view2 constant:(CGFloat)constant
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view1 attribute:attribute relatedBy:NSLayoutRelationEqual toItem:view2 attribute:attribute multiplier:1.0 constant:constant];
    constraint.active = YES;
}

+ (void)addVisualConstraints:(NSString *)format views:(NSDictionary<NSString *, id> *)views
{
    [self addVisualConstraints:format options:0 metrics:nil views:views];
}

+ (void)addVisualConstraints:(NSString *)format metrics:(NSDictionary<NSString *, id> *)metrics views:(NSDictionary<NSString *, id> *)views
{
    [self addVisualConstraints:format options:0 metrics:metrics views:views];
}

+ (void)addVisualConstraints:(NSString *)format options:(NSLayoutFormatOptions)opts views:(NSDictionary<NSString *, id> *)views
{
    [self addVisualConstraints:format options:opts metrics:nil views:views];
}

+ (void)addVisualConstraints:(NSString *)format options:(NSLayoutFormatOptions)opts metrics:(nullable NSDictionary<NSString *, id> *)metrics views:(NSDictionary<NSString *, id> *)views
{
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:opts metrics:metrics views:views];

    [self setConstraints:constraints active:YES];
}

+ (void)setConstraints:(NSArray<NSLayoutConstraint *> *)constraints active:(BOOL)active
{
    for (NSLayoutConstraint *constraint in constraints) {
        constraint.active = active;
    }
}

@end
