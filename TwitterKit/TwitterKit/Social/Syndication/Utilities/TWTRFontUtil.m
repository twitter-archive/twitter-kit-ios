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

//  Large (default)
//  UIFontTextStyleHeadline     SFUIText-Semibold  17.00pt
//  UIFontTextStyleSubhead      SFUIText-Regular   15.00pt
//  UIFontTextStyleBody         SFUIText-Regular   17.00pt
//  UIFontTextStyleFootnote     SFUIText-Regular   13.00pt
//  UIFontTextStyleCaption1     SFUIText-Regular   12.00pt (our base size)
//  UIFontTextStyleCaption2     SFUIText-Regular   11.00pt

#import "TWTRFontUtil.h"

static const CGFloat TWTRFontSizeIncrement = 2.0;

static const CGFloat TWTRCompactWidthCompactHeightLineHeightRatio = 17.0f / 14.0f;
static const CGFloat TWTRRegularWidthCompactHeightLineHeightRatio = 17.0f / 14.0f;
static const CGFloat TWTRCompactWidthRegularHeightLineHeightRatio = 18.0f / 14.0f;
static const CGFloat TWTRRegularWidthRegularHeightLineHeightRatio = 19.0f / 14.0f;

@implementation TWTRFontUtil

#pragma mark - Tweet view
+ (UIFont *)fullnameFont
{
    return [self mediumBoldSystemFont];
}

+ (UIFont *)usernameFontForStyle:(TWTRTweetViewStyle)style
{
    if (style == TWTRTweetViewStyleRegular) {
        return [UIFont systemFontOfSize:[self mediumFontSize]];
    } else {
        return [UIFont systemFontOfSize:[self defaultFontSize]];
    }
}

+ (UIFont *)timestampFontForStyle:(TWTRTweetViewStyle)style
{
    return [self usernameFontForStyle:style];
}

+ (UIFont *)tweetFontForStyle:(TWTRTweetViewStyle)style
{
    if (style == TWTRTweetViewStyleRegular) {
        // System font is already Helvetica Neue but we want Light weight specifically
        return [UIFont fontWithName:@"HelveticaNeue-Light" size:[self largeFontSize]];
    } else {
        return [self mediumSizeSystemFont];
    }
}

+ (UIFont *)retweetedByAttributionLabelFont
{
    return [UIFont systemFontOfSize:[self defaultFontSize]];
}

+ (UIFont *)mediumSizeSystemFont
{
    return [UIFont systemFontOfSize:[self mediumFontSize]];
}

+ (UIFont *)largeSizeSystemFont
{
    return [UIFont systemFontOfSize:[self largeFontSize]];
}

#pragma mark - Ads

+ (UIFont *)adTitleFont
{
    return [self largeBoldSystemFont];
}

+ (UIFont *)adBodyFont
{
    return [self mediumSizeSystemFont];
}

#pragma mark - Helpers

+ (CGFloat)largeFontSize
{
    CGFloat fontSize = [self defaultFontSize] + TWTRFontSizeIncrement * 2;

    return fontSize;
}

+ (CGFloat)mediumFontSize
{
    CGFloat fontSize = [self defaultFontSize] + TWTRFontSizeIncrement;

    return fontSize;
}

+ (UIFont *)largeBoldSystemFont
{
    return [UIFont boldSystemFontOfSize:[self largeFontSize]];
}

+ (UIFont *)mediumBoldSystemFont
{
    return [UIFont fontWithName:@"HelveticaNeue-Medium" size:[self mediumFontSize]];
}

// This is the font size chosen by the user in System Settings
+ (CGFloat)defaultFontSize
{
    static CGFloat fontSize;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // The baseline size should be 13px.
        fontSize = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1].pointSize + 1;
    });

    return fontSize;
}

+ (CGFloat)lineHeightRatioForTraitCollection:(UITraitCollection *)traitCollection
{
    UIUserInterfaceSizeClass verticalSizeClass = traitCollection.verticalSizeClass;
    UIUserInterfaceSizeClass horizontalSizeClass = traitCollection.horizontalSizeClass;

    if (horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
        if (verticalSizeClass == UIUserInterfaceSizeClassCompact) {
            return TWTRCompactWidthCompactHeightLineHeightRatio;
        } else if (verticalSizeClass == UIUserInterfaceSizeClassRegular) {
            return TWTRCompactWidthRegularHeightLineHeightRatio;
        }
    } else {
        if (verticalSizeClass == UIUserInterfaceSizeClassCompact) {
            return TWTRRegularWidthCompactHeightLineHeightRatio;
        } else if (verticalSizeClass == UIUserInterfaceSizeClassRegular) {
            return TWTRRegularWidthRegularHeightLineHeightRatio;
        }
    }

    return 1.0;
}

+ (CGFloat)minimumLineHeightForFont:(UIFont *)font traitCollection:(UITraitCollection *)traitCollection
{
    CGFloat multiplier = [self lineHeightRatioForTraitCollection:traitCollection];
    CGFloat baseHeight = -font.descender + font.ascender;

    return MAX(font.pointSize * multiplier, baseHeight);
}

@end
