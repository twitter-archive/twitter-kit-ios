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

#import "TWTRColorUtil.h"

@implementation TWTRColorUtil

#pragma mark - Black and White

+ (UIColor *)blackColor
{
    return [UIColor blackColor];
}

+ (UIColor *)whiteColor
{
    return [UIColor whiteColor];
}

#pragma mark - Blues

+ (UIColor *)blueColor
{
    static UIColor *blueColor;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        blueColor = [TWTRColorUtil colorFromHex:0x1da1f2];
    });

    return blueColor;
}

+ (UIColor *)blueTextColor
{
    static UIColor *color;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        color = [TWTRColorUtil colorFromHex:0x1B95E0];
    });

    return color;
}

+ (UIColor *)lightBlueColor
{
    static UIColor *lightBlueColor;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        lightBlueColor = [TWTRColorUtil colorFromHex:0x88c9f9];
    });

    return lightBlueColor;
}

+ (UIColor *)mediumBlueColor
{
    static UIColor *mediumBlueColor;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        mediumBlueColor = [TWTRColorUtil colorFromHex:0x3ea1ec];
    });

    return mediumBlueColor;
}

+ (UIColor *)darkBlueColor
{
    static UIColor *darkBlueColor;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        darkBlueColor = [TWTRColorUtil colorFromHex:0x226699];
    });

    return darkBlueColor;
}

#pragma mark - Reds

+ (UIColor *)redColor
{
    static UIColor *redColor;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        redColor = [TWTRColorUtil colorFromHex:0xE81C4F];
    });

    return redColor;
}

+ (UIColor *)darkRedColor
{
    static UIColor *darkRedColor;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        darkRedColor = [TWTRColorUtil colorFromHex:0xa0041e];
    });

    return darkRedColor;
}

#pragma mark Purples

+ (UIColor *)darkPurpleColor
{
    static UIColor *darkPurpleColor;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        darkPurpleColor = [TWTRColorUtil colorFromHex:0x553788];
    });

    return darkPurpleColor;
}

+ (UIColor *)deepPurpleColor
{
    static UIColor *deepPurpleColor;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        deepPurpleColor = [TWTRColorUtil colorFromHex:0x744eaa];
    });

    return deepPurpleColor;
}

+ (UIColor *)mediumPurpleColor
{
    static UIColor *mediumPurpleColor;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        mediumPurpleColor = [TWTRColorUtil colorFromHex:0x9266cc];
    });

    return mediumPurpleColor;
}

#pragma mark - Grays

+ (UIColor *)grayColor
{
    static UIColor *grayColor;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        grayColor = [TWTRColorUtil colorFromHex:0xccd6dd];
    });

    return grayColor;
}

+ (UIColor *)borderGrayColor
{
    static UIColor *borderGrayColor;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        borderGrayColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    });

    return borderGrayColor;
}

+ (UIColor *)darkBorderGrayColor
{
    static UIColor *darkBorderGrayColor;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        darkBorderGrayColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    });

    return darkBorderGrayColor;
}

#pragma mark - Gray Colors

+ (UIColor *)grayTextColor
{
    static UIColor *color;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        color = [TWTRColorUtil colorFromHex:0xe1e8ed];
    });

    return color;
}

+ (UIColor *)darkGrayTextColor
{
    static UIColor *color;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        color = [TWTRColorUtil colorFromHex:0x8899A6];
    });

    return color;
}

+ (UIColor *)faintGrayColor
{
    static UIColor *faintGrayColor;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        faintGrayColor = [TWTRColorUtil colorFromHex:0xf5f8fa];
    });

    return faintGrayColor;
}

+ (UIColor *)mediumGrayColor
{
    static UIColor *mediumGrayColor;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        mediumGrayColor = [TWTRColorUtil colorFromHex:0xaab8c2];
    });

    return mediumGrayColor;
}

+ (UIColor *)darkGrayColor
{
    static UIColor *darkGrayColor;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        darkGrayColor = [TWTRColorUtil colorFromHex:0x66757f];
    });

    return darkGrayColor;
}

#pragma mark - Component Colors

+ (UIColor *)textColor
{
    static UIColor *textColor;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        textColor = [TWTRColorUtil colorFromHex:0x292f33];
    });

    return textColor;
}

+ (UIColor *)imagePlaceholderColor
{
    static UIColor *imagePlaceholderColor;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        imagePlaceholderColor = [TWTRColorUtil colorFromHex:0xe1e8ed];
    });

    return imagePlaceholderColor;
}

#pragma mark - Utilities

+ (NSInteger)hexWithColor:(UIColor *)color
{
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    return ((int)(r * 255) << 16) + ((int)(g * 255) << 8) + (int)(b * 255);
}

+ (UIColor *)colorFromHex:(NSInteger)hex
{
    return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16)) / 255.0 green:((float)((hex & 0xFF00) >> 8)) / 255.0 blue:((float)(hex & 0xFF)) / 255.0 alpha:1.0];
}

#if IS_UIKIT_AVAILABLE
// Ganked from Stackoverflow
// http://stackoverflow.com/questions/990976/how-to-create-a-colored-1x1-uiimage-on-the-iphone-dynamically
+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}
#else
+ (NSImage *)imageWithColor:(NSColor *)color
{
    // TODO: make this work
    return nil;
}

#endif

/**
 * This method uses HSL to determine in a human eyesight terms if a color is light or not.
 * See: http://en.wikipedia.org/wiki/HSL_and_HSV. The threshold values are from ITU Rec. 709
 * http://en.wikipedia.org/wiki/Rec._709#Luma_coefficients
 *
 * @param  color A color value
 * @return Whether or not the color is considered light
 */
+ (BOOL)isLightColor:(UIColor *)color
{
    // 0.5 = mid-point of lightness as calculated by HSL weighted RGB constants
    return [[self class] isLightColor:color lightnessThreshold:0.5];
}

+ (BOOL)isLightColor:(UIColor *)color lightnessThreshold:(CGFloat)lightnessThreshold
{
    CGFloat red = 0, green = 0, blue = 0, alpha = 0;
#if IS_UIKIT_AVAILABLE
    BOOL gotColorComponents = [color getRed:&red green:&green blue:&blue alpha:&alpha];

    if (gotColorComponents == NO) {
        // If we can't parse a given color, default
        // to it being a light color.
        return YES;
    }
#else
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
#endif

    CGFloat threshold = (0.2126 * red) + (0.7152 * green) + (0.0722 * blue);
    return threshold > lightnessThreshold;
}

+ (BOOL)isOpaqueColor:(UIColor *)color
{
    CGFloat alpha = 0;
#if IS_UIKIT_AVAILABLE
    const BOOL gotColorComponents = [color getRed:NULL green:NULL blue:NULL alpha:&alpha];

    if (!gotColorComponents) {
        // If we can't determine the alpha,
        // let's default to transparent in case it does have an alpha channel.
        return NO;
    }
#else
    [color getRed:NULL green:NULL blue:NULL alpha:&alpha];
#endif

    const BOOL alphaIsSemiTransparent = (fabs(alpha - 1.0f) >= DBL_EPSILON);

    return !alphaIsSemiTransparent;
}

/**
 *  Calculate the color for secondary text.
 *  Specs: go/native-embedded-tweet-design
 */
+ (UIColor *)secondaryTextColorFromPrimaryTextColor:(UIColor *)primaryTextColor backgroundColor:(UIColor *)backgroundColor
{
    return [self secondaryTextColorFromPrimaryTextColor:primaryTextColor backgroundColor:backgroundColor minAlpha:0.35 maxAlpha:0.4];
}

+ (UIColor *)secondaryTextColorFromPrimaryTextColor:(UIColor *)primaryTextColor backgroundColor:(UIColor *)backgroundColor minAlpha:(CGFloat)minAlpha maxAlpha:(CGFloat)maxAlpha
{
    CGFloat alpha = [self isLightColor:backgroundColor] ? minAlpha : maxAlpha;

    return [primaryTextColor colorWithAlphaComponent:alpha];
}

/**
 *  Calculate the color for media backgrounds (shown when loading)
 *  Specs: go/native-embedded-tweet-design
 */
+ (UIColor *)mediaBackgroundColorFromBackgroundColor:(UIColor *)backgroundColor
{
    static const CGFloat mostlyTransparentAlpha = 0.08;
    static const CGFloat lessTransparentAlpha = 0.12;
    static const CGFloat fullyWhite = 1.0;
    static const CGFloat fullyBlack = 0.0;

    BOOL backgroundColorIsLight = [self isLightColor:backgroundColor];
    CGFloat alpha = (backgroundColorIsLight ? mostlyTransparentAlpha : lessTransparentAlpha);
    CGFloat white = (backgroundColorIsLight ? fullyBlack : fullyWhite);

    return [UIColor colorWithWhite:white alpha:alpha];
}

+ (UIColor *)logoColorFromBackgroundColor:(UIColor *)backgroundColor
{
    if ([self isLightColor:backgroundColor]) {
        return [self blueColor];
    } else {
        return [self whiteColor];
    }
}

+ (UIColor *)contrastingTextColorFromBackgroundColor:(UIColor *)backgroundColor
{
    static const CGFloat opaqueAlpha = 1.0;
    static const CGFloat moreTransparentAlpha = 0.9;
    static const CGFloat fullyWhite = 1.0;
    static const CGFloat partiallyBlack = 0.4;

    const BOOL backgroundColorIsLight = [self isLightColor:backgroundColor];
    CGFloat alpha = (backgroundColorIsLight ? opaqueAlpha : moreTransparentAlpha);
    CGFloat white = (backgroundColorIsLight ? partiallyBlack : fullyWhite);

    return [UIColor colorWithWhite:white alpha:alpha];
}

+ (UIColor *)darkerColorForColor:(UIColor *)color lightnessLevel:(CGFloat)lightnessLevel
{
    CGFloat r, g, b, a;
    if ([color getRed:&r green:&g blue:&b alpha:&a]) return [UIColor colorWithRed:MAX(r - lightnessLevel, 0.0) green:MAX(g - lightnessLevel, 0.0) blue:MAX(b - lightnessLevel, 0.0) alpha:a];
    return nil;
}

+ (UIColor *)lighterColorForColor:(UIColor *)color lightnessLevel:(CGFloat)lightnessLevel
{
    CGFloat r, g, b, a;
    if ([color getRed:&r green:&g blue:&b alpha:&a]) return [UIColor colorWithRed:MIN(r + lightnessLevel, 1.0) green:MIN(g + lightnessLevel, 1.0) blue:MIN(b + lightnessLevel, 1.0) alpha:a];
    return nil;
}

@end
