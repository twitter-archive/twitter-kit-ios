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

#pragma mark imports

#import "TWTRSEFonts.h"

#pragma mark - static const definitions

// fallback colors for when Twitter.app is not providing the colors via groupDefaults,
// or when using TwitterKit, which does not get the colors from the app

static const CGFloat kTextColorRed = ((CGFloat)0x14) / ((CGFloat)0xff);
static const CGFloat kTextColorGreen = ((CGFloat)0x17) / ((CGFloat)0xff);
static const CGFloat kTextColorBlue = ((CGFloat)0x1a) / ((CGFloat)0xff);

static const CGFloat kPlaceholderColorRed = ((CGFloat)0x65) / ((CGFloat)0xff);
static const CGFloat kPlaceholderColorGreen = ((CGFloat)0x77) / ((CGFloat)0xff);
static const CGFloat kPlaceholderColorBlue = ((CGFloat)0x86) / ((CGFloat)0xff);

static const CGFloat kCharacterLimitColorRed = ((CGFloat)0xe0) / ((CGFloat)0xff);
static const CGFloat kCharacterLimitColorGreen = ((CGFloat)0x24) / ((CGFloat)0xff);
static const CGFloat kCharacterLimitColorBlue = ((CGFloat)0x5e) / ((CGFloat)0xff);

static const CGFloat kCardTitleColorRed = kTextColorRed;
static const CGFloat kCardTitleColorGreen = kTextColorGreen;
static const CGFloat kCardTitleColorBlue = kTextColorBlue;

static const CGFloat kCardSubtitleColorRed = kPlaceholderColorRed;
static const CGFloat kCardSubtitleColorGreen = kPlaceholderColorGreen;
static const CGFloat kCardSubtitleColorBlue = kPlaceholderColorBlue;

static const CGFloat kUserFullNameColorRed = kTextColorRed;
static const CGFloat kUserFullNameColorGreen = kTextColorGreen;
static const CGFloat kUserFullNameColorBlue = kTextColorBlue;

static const CGFloat kUserUsernameColorRed = kPlaceholderColorRed;
static const CGFloat kUserUsernameColorGreen = kPlaceholderColorGreen;
static const CGFloat kUserUsernameColorBlue = kPlaceholderColorBlue;

static const CGFloat kPlaceNameColorRed = kTextColorRed;
static const CGFloat kPlaceNameColorGreen = kTextColorGreen;
static const CGFloat kPlaceNameColorBlue = kTextColorBlue;

static const CGFloat kPlaceAddressColorRed = kPlaceholderColorRed;
static const CGFloat kPlaceAddressColorGreen = kPlaceholderColorGreen;
static const CGFloat kPlaceAddressColorBlue = kPlaceholderColorBlue;

static const CGFloat kNavigationButtonColorRed = ((CGFloat)0x1d) / ((CGFloat)0xff);
static const CGFloat kNavigationButtonColorGreen = ((CGFloat)0xa1) / ((CGFloat)0xff);
static const CGFloat kNavigationButtonColorBlue = ((CGFloat)0xf2) / ((CGFloat)0xff);

#pragma mark -

@interface TWTRSEFonts ()
@property (nonatomic, nonnull, readonly, class) UIFont *systemFontLight;
@end

@implementation TWTRSEFonts

static NSDictionary<NSString *, NSDictionary<NSString *, id> *> *sFontDictionary;
static UIFont *sSystemFontLight;

+ (UIFont *)systemFontLight
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sSystemFontLight = [UIFont systemFontOfSize:21 weight:UIFontWeightLight];
    });
    return sSystemFontLight;
}

+ (NSDictionary<NSString *, NSDictionary<NSString *, id> *> *)fontDictionary
{
    return sFontDictionary;
}

+ (void)setFontDictionary:(NSDictionary<NSString *, NSDictionary<NSString *, id> *> *)fontDictionary
{
    sFontDictionary = fontDictionary;
}

+ (UIFont *)fontWithDictName:(NSString *)name fallbackFont:(UIFont *)fallbackFont
{
    NSDictionary<NSString *, id> *fontDict;
    if (name) {
        fontDict = self.fontDictionary[name];
    }
    if (!fontDict) {
        return fallbackFont;
    }

    NSString *fontName = fontDict[@"fontName"] ?: fallbackFont.fontName;
    CGFloat fontSize = ((NSNumber *)(fontDict[@"pointSize"]) ?: @(fallbackFont.pointSize)).floatValue;
    return [UIFont fontWithName:fontName size:fontSize];
}

+ (UIFont *)fontWithDictName:(NSString *)name
{
    return [self fontWithDictName:name fallbackFont:self.systemFontLight];
}

+ (UIColor *)colorWithDictName:(NSString *)name
{
    NSDictionary<NSString *, id> *fontDict = sFontDictionary[name];
    if (!fontDict) {
        return nil;
    }

    NSNumber *red = fontDict[@"red"];
    NSNumber *green = fontDict[@"green"];
    NSNumber *blue = fontDict[@"blue"];
    return (red && green && blue) ? [UIColor colorWithRed:red.floatValue green:green.floatValue blue:blue.floatValue alpha:1.] : nil;
}

+ (UIFont *)composerTextFont
{
    return [self fontWithDictName:@"composerText"];
}

+ (UIColor *)composerTextColor
{
    return [self colorWithDictName:@"composerText"] ?: [UIColor colorWithRed:kTextColorRed green:kTextColorGreen blue:kTextColorBlue alpha:1.];
}

+ (UIFont *)composerPlaceholderFont
{
    return [self fontWithDictName:@"composerPlaceholder"];
}

+ (UIColor *)composerPlaceholderColor
{
    return [self colorWithDictName:@"composerPlaceholder"] ?: [UIColor colorWithRed:kPlaceholderColorRed green:kPlaceholderColorGreen blue:kPlaceholderColorBlue alpha:1.0];
}

+ (UIFont *)characterCountFont
{
    NSDictionary<NSString *, id> *fontDict = sFontDictionary[@"characterCount"];
    if (!fontDict) {
        return [UIFont systemFontOfSize:14. weight:UIFontWeightLight];
    }

    NSString *fontName = fontDict[@"fontName"] ?: self.systemFontLight.fontName;
    CGFloat fontSize = (CGFloat)[((NSNumber *)fontDict[@"pointSize"] ?: @(14.0))floatValue];
    return [UIFont fontWithName:fontName size:fontSize];
}

+ (UIColor *)characterCountLimitColor
{
    return [self colorWithDictName:@"characterCount"] ?: [UIColor colorWithRed:kCharacterLimitColorRed green:kCharacterLimitColorGreen blue:kCharacterLimitColorBlue alpha:1.0];
}

+ (UIFont *)cardTitleFont
{
    return [self fontWithDictName:@"cardTitle" fallbackFont:[UIFont systemFontOfSize:16]];
}

+ (UIColor *)cardTitleColor
{
    return [self colorWithDictName:@"cardTitle"] ?: [UIColor colorWithRed:kCardTitleColorRed green:kCardTitleColorGreen blue:kCardTitleColorBlue alpha:1];
}

+ (UIFont *)cardSubtitleFont
{
    return [self fontWithDictName:@"cardSubtitle" fallbackFont:[UIFont systemFontOfSize:16]];
}

+ (UIColor *)cardSubtitleColor
{
    return [self colorWithDictName:@"cardSubtitle"] ?: [UIColor colorWithRed:kCardSubtitleColorRed green:kCardSubtitleColorGreen blue:kCardSubtitleColorBlue alpha:1];
}

+ (UIFont *)userFullNameFont
{
    return [self fontWithDictName:@"userFullName" fallbackFont:[UIFont systemFontOfSize:16]];
}

+ (UIColor *)userFullNameColor
{
    return [self colorWithDictName:@"userFullName"] ?: [UIColor colorWithRed:kUserFullNameColorRed green:kUserFullNameColorGreen blue:kUserFullNameColorBlue alpha:1];
}

+ (UIFont *)userUsernameFont
{
    return [self fontWithDictName:@"userUsername" fallbackFont:[UIFont systemFontOfSize:16]];
}

+ (UIColor *)userUsernameColor
{
    return [self colorWithDictName:@"userUsername"] ?: [UIColor colorWithRed:kUserUsernameColorRed green:kUserUsernameColorGreen blue:kUserUsernameColorBlue alpha:1];
}

+ (UIFont *)placeNameFont
{
    return [self fontWithDictName:@"placeName" fallbackFont:[UIFont systemFontOfSize:15 weight:UIFontWeightSemibold]];
}

+ (UIColor *)placeNameColor
{
    return [self colorWithDictName:@"placeName"] ?: [UIColor colorWithRed:kPlaceNameColorRed green:kPlaceNameColorGreen blue:kPlaceNameColorBlue alpha:1.];
}

+ (UIFont *)placeAddressFont
{
    return [self fontWithDictName:@"placeAddress" fallbackFont:[UIFont systemFontOfSize:16]];
}

+ (UIColor *)placeAddressColor
{
    return [self colorWithDictName:@"placeAddress"] ?: [UIColor colorWithRed:kPlaceAddressColorRed green:kPlaceAddressColorGreen blue:kPlaceAddressColorBlue alpha:1.];
}

+ (UIFont *)navigationButtonFont
{
    return [self fontWithDictName:@"navigationButton" fallbackFont:[UIFont systemFontOfSize:16]];
}

+ (UIColor *)navigationButtonColor
{
    return [self colorWithDictName:@"navigationButton"] ?: [UIColor colorWithRed:kNavigationButtonColorRed green:kNavigationButtonColorGreen blue:kNavigationButtonColorBlue alpha:1.];
}

@end
