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

#import <Foundation/Foundation.h>
#if IS_UIKIT_AVAILABLE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>

// This adds type name compatibility, but definitely not API cmopatibility for these classes. This
// is really a temporarly workaround to get this code building for OS X.
typedef NSColor UIColor;
typedef NSImage UIImage;
#endif

NS_ASSUME_NONNULL_BEGIN

// Based off of rosetta color palette,
// see https://svn.twitter.biz/design/main/resources/colors/rosetta_colors.html (go/colors).
@interface TWTRColorUtil : NSObject

#pragma mark - Black and White

+ (UIColor *)blackColor;
+ (UIColor *)whiteColor;

#pragma mark - Blues

+ (UIColor *)blueColor;
+ (UIColor *)blueTextColor;
+ (UIColor *)lightBlueColor;
+ (UIColor *)mediumBlueColor;
+ (UIColor *)darkBlueColor;

#pragma mark - Reds

+ (UIColor *)redColor;
+ (UIColor *)darkRedColor;

#pragma mark - Purples

+ (UIColor *)darkPurpleColor;
+ (UIColor *)deepPurpleColor;
+ (UIColor *)mediumPurpleColor;

#pragma mark - Grays

+ (UIColor *)grayTextColor;
+ (UIColor *)darkGrayTextColor;
+ (UIColor *)grayColor;
+ (UIColor *)borderGrayColor;
+ (UIColor *)darkBorderGrayColor;
+ (UIColor *)faintGrayColor;
+ (UIColor *)mediumGrayColor;
+ (UIColor *)darkGrayColor;

#pragma mark - Component Colors

+ (UIColor *)textColor;
+ (UIColor *)imagePlaceholderColor;

#pragma mark - Utilities

+ (NSInteger)hexWithColor:(UIColor *)color;
+ (UIColor *)colorFromHex:(NSInteger)hex;

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (BOOL)isLightColor:(UIColor *)color;
+ (BOOL)isLightColor:(UIColor *)color lightnessThreshold:(CGFloat)lightnessThreshold;

+ (BOOL)isOpaqueColor:(UIColor *)color;

#pragma mark - Color calculations

/**
 * Returns a secondary text color by
 * a) picking an alpha component based on whether the background color is light
 * b) applying that alpha component to the primary text color
 */
+ (UIColor *)secondaryTextColorFromPrimaryTextColor:(UIColor *)primaryTextColor backgroundColor:(UIColor *)backgroundColor;

/**
 * Returns a media background color by
 * a) picking an alpha component based on whether the background color is light
 * b) applying that alpha component to either solid white or black, based on the background
 */
+ (UIColor *)mediaBackgroundColorFromBackgroundColor:(UIColor *)backgroundColor;

/**
 * Returns a logo color appropriate for the background color.
 */
+ (UIColor *)logoColorFromBackgroundColor:(UIColor *)backgroundColor;

/**
 *  Returns a color for the text of a button given its background
 *  color. This is intended for use in buttons or to highlight text.
 *
 *  @param backgroundColor Background color where the text is displayed.
 *
 *  @return Color of the text.
 */
+ (UIColor *)contrastingTextColorFromBackgroundColor:(UIColor *)backgroundColor;

/**
 *  Returns a darker color based on the original color and a percent to darken.
 *
 *  @param color         The original color
 *  @param lightnessLevel   Lightness levels to lighten. Capped to 0 and 1.0.
 */
+ (UIColor *)darkerColorForColor:(UIColor *)color lightnessLevel:(CGFloat)lightnessLevel;

/**
 *  Returns a darker color based on the original color and a percent to lighten.
 *
 *  @param color            The original color
 *  @param lightnessLevel   Lightness levels to lighten. Capped to 0 and 1.0.
 */
+ (UIColor *)lighterColorForColor:(UIColor *)color lightnessLevel:(CGFloat)lightnessLevel;

@end

NS_ASSUME_NONNULL_END
