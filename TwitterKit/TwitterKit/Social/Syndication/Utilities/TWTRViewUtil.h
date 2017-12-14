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

@class TWTRMediaEntitySize;
@class TWTRTweetMediaEntity;

NS_ASSUME_NONNULL_BEGIN

/* Create a new rect with values rounded to the nearest integral pixel (<integer> or <integer>.5 since on a Retina iOS device, one screen point refers to 2 real pixels). This is the equivalent of CGRectIntegral() but rounds values to either whole integers (1, 2, 3) or half integers (1.5, 2.5, 3.5). This will put views onto pixel boundaries for Retina devices, but not the iPhone 6[s] Plus since it does extra downsampling.

    e.g. Rect(1.2, 1.6, 22.2, 12.8) -> Rect(1.0, 1.5, 22.5, 13.0) */
CGRect TWTRRectPixelIntegral(CGRect);

/* Round a float to pixel-sized values (<integer> or <integer>.5) */
CGFloat TWTRRoundHalfInteger(CGFloat);

@interface TWTRViewUtil : NSObject

- (instancetype)init NS_UNAVAILABLE;

/*
 * Returns the TWTRMediaEntitySize that best matches the media entity sizes.
 *
 * @param mediaEntity (required) the media entity object.
 * @param fittingWidth (required) the target width.
 * @return a best fit size or nil.
 */
+ (TWTRMediaEntitySize *)bestMatchSizeFromMediaEntity:(TWTRTweetMediaEntity *)mediaEntity fittingWidth:(CGFloat)fittingWidth;

/**
 * Returns an average of the aspect ratios in the given media
 * entity size dictionary.
 *
 * All 'crop' sizes are ignored.
 */
+ (CGFloat)averageAspectRatioForMediaEntity:(TWTRTweetMediaEntity *)mediaEntity;

/**
 * Calculates the aspect ratio for a given size.
 */
+ (CGFloat)aspectRatioForSize:(CGSize)size;
+ (CGFloat)aspectRatioForWidth:(CGFloat)width height:(CGFloat)height;

/**
 * Returns YES if the aspect ratio is in landscape.
 */
+ (BOOL)aspectRatioIsLandscape:(CGFloat)aspectRatio;

/**
 * Returns a constraint for the given attribute on a view.
 */
+ (NSLayoutConstraint *)constraintForAttribute:(NSLayoutAttribute)attribute onView:(UIView *)view value:(CGFloat)value;

/**
 * Returns a constraint to the top of the super view.
 */
+ (NSLayoutConstraint *)constraintToTopOfSuperview:(UIView *)view;
+ (NSLayoutConstraint *)constraintToTopOfSuperview:(UIView *)view constant:(CGFloat)constant;

/**
 * Returns a constraint to the bottom of the super view.
 */
+ (NSLayoutConstraint *)constraintToBottomOfSuperview:(UIView *)view;
+ (NSLayoutConstraint *)constraintToBottomOfSuperview:(UIView *)view constant:(CGFloat)constant;

/**
 * Creates and activates constraints which centers the view in its superview
 */
+ (void)centerViewInSuperview:(UIView *)view;

/**
 * Creates and activates constraints which centers the view in another view
 */
+ (void)centerView:(UIView *)view inView:(UIView *)otherView;

/**
 * Creates and activates constraints which centers the view horizontally in another view
 */
+ (void)centerViewHorizontally:(UIView *)view inView:(UIView *)otherView;

/**
 * Creates and activates constraints which centers the view horizontally in its superview
 */
+ (void)centerViewHorizontallyInSuperview:(UIView *)view;

/**
 * Creates and activates constraints which centers the view vertically in another view
 */
+ (void)centerViewVertically:(UIView *)view inView:(UIView *)otherView;

/**
 * Creates and activates constraints which centers the view vertically in its superview
 */
+ (void)centerViewVerticallyInSuperview:(UIView *)view;

+ (NSLayoutConstraint *)marginConstraintBetweenTopView:(UIView *)topView bottomView:(UIView *)bottomView;
+ (NSArray<NSLayoutConstraint *> *)constraintsWithFormat:(NSString *)format metrics:(NSDictionary<NSString *, id> *)metrics views:(NSDictionary<NSString *, id> *)views;

+ (NSLayoutConstraint *)constraintForAspectRatio:(CGFloat)aspectRatio onView:(UIView *)view;

/**
 * Creates and activates a constraint which equates the attributes on the given views.
 */
+ (void)equateAttribute:(NSLayoutAttribute)attribute onView:(UIView *)view1 toView:(UIView *)view2;
+ (void)equateAttribute:(NSLayoutAttribute)attribute onView:(UIView *)view1 toView:(UIView *)view2 constant:(CGFloat)constant;

/**
 * Utility method for creating views with the given format and calling active = YES on them.
 */
+ (void)addVisualConstraints:(NSString *)format views:(NSDictionary<NSString *, id> *)views;
+ (void)addVisualConstraints:(NSString *)format metrics:(NSDictionary<NSString *, id> *)metrics views:(NSDictionary<NSString *, id> *)views;
+ (void)addVisualConstraints:(NSString *)format options:(NSLayoutFormatOptions)opts views:(NSDictionary<NSString *, id> *)views;
+ (void)addVisualConstraints:(NSString *)format options:(NSLayoutFormatOptions)opts metrics:(nullable NSDictionary<NSString *, id> *)metrics views:(NSDictionary<NSString *, id> *)views;

+ (void)setConstraints:(NSArray<NSLayoutConstraint *> *)constraints active:(BOOL)active;

@end

NS_ASSUME_NONNULL_END
