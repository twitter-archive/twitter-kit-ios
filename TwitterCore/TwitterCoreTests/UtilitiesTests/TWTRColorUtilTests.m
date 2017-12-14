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
#import "TWTRTestCase.h"

// Convenience class for testing
typedef struct RGBA {
    CGFloat red;
    CGFloat blue;
    CGFloat green;
    CGFloat alpha;
} RGBA;

@interface TWTRColorUtilTests : TWTRTestCase

@end

@implementation TWTRColorUtilTests

- (void)testColorFromHex_negativeResultsInWhite
{
    NSInteger hex = -1;
    UIColor *color = [TWTRColorUtil colorFromHex:hex];
    RGBA rgbaValues = [self RGBAWithColor:color];
    XCTAssertTrue(rgbaValues.red == 1.0);
    XCTAssertTrue(rgbaValues.blue == 1.0);
    XCTAssertTrue(rgbaValues.green == 1.0);
    XCTAssertTrue(rgbaValues.alpha == 1.0);
}

- (void)testColorFromHex_onlyAccountsForLower24Bits
{
    NSInteger hex = 0x1000000;  // max should be 0xFFFFFF
    UIColor *color = [TWTRColorUtil colorFromHex:hex];
    RGBA rgbaValues = [self RGBAWithColor:color];
    XCTAssertTrue(rgbaValues.red == 0.0);
    XCTAssertTrue(rgbaValues.blue == 0.0);
    XCTAssertTrue(rgbaValues.green == 0.0);
    XCTAssertTrue(rgbaValues.alpha == 1.0);
}

- (void)testColorFromHex_red
{
    UIColor *color = [TWTRColorUtil colorFromHex:0xFF0000];
    RGBA rgbaValues = [self RGBAWithColor:color];
    XCTAssertTrue(rgbaValues.red == 1.0);
    XCTAssertTrue(rgbaValues.blue == 0.0);
    XCTAssertTrue(rgbaValues.green == 0.0);
    XCTAssertTrue(rgbaValues.alpha == 1.0);
}

- (void)testColorFromHex_blue
{
    UIColor *color = [TWTRColorUtil colorFromHex:0x00FF00];
    RGBA rgbaValues = [self RGBAWithColor:color];
    XCTAssertTrue(rgbaValues.red == 0.0);
    XCTAssertTrue(rgbaValues.blue == 1.0);
    XCTAssertTrue(rgbaValues.green == 0.0);
    XCTAssertTrue(rgbaValues.alpha == 1.0);
}

- (void)testColorFromHex_green
{
    UIColor *color = [TWTRColorUtil colorFromHex:0x0000FF];
    RGBA rgbaValues = [self RGBAWithColor:color];
    XCTAssertTrue(rgbaValues.red == 0.0);
    XCTAssertTrue(rgbaValues.blue == 0.0);
    XCTAssertTrue(rgbaValues.green == 1.0);
    XCTAssertTrue(rgbaValues.alpha == 1.0);
}

- (void)testHexStringWithColor
{
    NSInteger hex = 0x12345;
    UIColor *color = [TWTRColorUtil colorFromHex:hex];
    NSInteger convertedHex = [TWTRColorUtil hexWithColor:color];
    XCTAssertEqual(hex, convertedHex);
}

- (void)testBlackColor
{
    UIColor *color = [TWTRColorUtil blackColor];
    XCTAssertEqual([UIColor blackColor], color);
}

- (void)testWhiteColor
{
    UIColor *color = [TWTRColorUtil whiteColor];
    XCTAssertEqual([UIColor whiteColor], color);
}

- (void)testBlueColor
{
    NSInteger hex = [TWTRColorUtil hexWithColor:[TWTRColorUtil blueColor]];
    XCTAssertEqual(0x1da1f2, hex);
}

- (void)testLightBlueColor
{
    NSInteger hex = [TWTRColorUtil hexWithColor:[TWTRColorUtil lightBlueColor]];
    XCTAssertEqual(0x88c9f9, hex);
}

- (void)testDarkBlueColor
{
    NSInteger hex = [TWTRColorUtil hexWithColor:[TWTRColorUtil darkBlueColor]];
    XCTAssertEqual(0x226699, hex);
}

- (void)testRedColor
{
    NSInteger hex = [TWTRColorUtil hexWithColor:[TWTRColorUtil redColor]];
    XCTAssertEqual(0xE81C4F, hex);
}

- (void)testDarkRedColor
{
    NSInteger hex = [TWTRColorUtil hexWithColor:[TWTRColorUtil darkRedColor]];
    XCTAssertEqual(0xa0041e, hex);
}

- (void)testDeepPurpleColor
{
    NSInteger hex = [TWTRColorUtil hexWithColor:[TWTRColorUtil deepPurpleColor]];
    XCTAssertEqual(0x744eaa, hex);
}

- (void)testMediumPurpleColor
{
    NSInteger hex = [TWTRColorUtil hexWithColor:[TWTRColorUtil mediumPurpleColor]];
    XCTAssertEqual(0x9266cc, hex);
}

- (void)testDarkPurpleColor
{
    NSInteger hex = [TWTRColorUtil hexWithColor:[TWTRColorUtil darkPurpleColor]];
    XCTAssertEqual(0x553788, hex);
}

- (void)testGrayColor
{
    NSInteger hex = [TWTRColorUtil hexWithColor:[TWTRColorUtil grayColor]];
    XCTAssertEqual(0xccd6dd, hex);
}

- (void)testBorderGrayColor
{
    CGFloat white, alpha;
    [[TWTRColorUtil borderGrayColor] getWhite:&white alpha:&alpha];

    XCTAssertEqualWithAccuracy(white, 0.0, 0.001);
    XCTAssertEqualWithAccuracy(alpha, 0.1, 0.001);
}

- (void)testDarkBorderGrayColor
{
    CGFloat white, alpha;
    [[TWTRColorUtil darkBorderGrayColor] getWhite:&white alpha:&alpha];

    XCTAssertEqualWithAccuracy(white, 0.0, 0.001);
    XCTAssertEqualWithAccuracy(alpha, 0.5, 0.001);
}

- (void)testFaintGrayColor
{
    NSInteger hex = [TWTRColorUtil hexWithColor:[TWTRColorUtil faintGrayColor]];
    XCTAssertEqual(0xf5f8fa, hex);
}

- (void)testMediumGrayColor
{
    NSInteger hex = [TWTRColorUtil hexWithColor:[TWTRColorUtil mediumGrayColor]];
    XCTAssertEqual(0xaab8c2, hex);
}

- (void)testDarkGrayColor
{
    NSInteger hex = [TWTRColorUtil hexWithColor:[TWTRColorUtil darkGrayColor]];
    XCTAssertEqual(0x66757f, hex);
}

- (void)testTextColor
{
    NSInteger hex = [TWTRColorUtil hexWithColor:[TWTRColorUtil textColor]];
    XCTAssertEqual(0x292f33, hex);
}

- (void)testImagePlaceholderColor
{
    NSInteger hex = [TWTRColorUtil hexWithColor:[TWTRColorUtil imagePlaceholderColor]];
    XCTAssertEqual(0xe1e8ed, hex);
}

- (void)testIsLightColor
{
    XCTAssertTrue([TWTRColorUtil isLightColor:[UIColor lightGrayColor]]);
    XCTAssertFalse([TWTRColorUtil isLightColor:[UIColor darkGrayColor]]);
}

- (void)testIsOpaqueColorWithOpaque
{
    XCTAssertTrue([TWTRColorUtil isOpaqueColor:[UIColor colorWithWhite:0 alpha:1.0]]);
    XCTAssertTrue([TWTRColorUtil isOpaqueColor:[UIColor colorWithRed:0.3 green:0.1 blue:1.0 alpha:1.0]]);
}

- (void)testIsOpaqueColorWithTransparent
{
    XCTAssertFalse([TWTRColorUtil isOpaqueColor:[UIColor colorWithWhite:0 alpha:0.9]]);
    XCTAssertFalse([TWTRColorUtil isOpaqueColor:[UIColor colorWithRed:0.3 green:0.1 blue:1.0 alpha:0.1]]);
}

#pragma mark - Logo Colors

- (void)testLogoImage_LightBackgroundGivesBlueLogo
{
    UIColor *color = [TWTRColorUtil logoColorFromBackgroundColor:[UIColor yellowColor]];
    UIColor *expected = [TWTRColorUtil blueColor];
    XCTAssertEqualObjects(color, expected);
}

- (void)testLogoImage_DarkBackgroundGivesWhiteLogo
{
    UIColor *color = [TWTRColorUtil logoColorFromBackgroundColor:[UIColor blackColor]];
    UIColor *expected = [TWTRColorUtil whiteColor];
    XCTAssertEqualObjects(color, expected);
}

#pragma mark - Derived Colors

- (void)testContrastingTextColorFromBackgroundColor_lightToDark
{
    UIColor *darkColor = [UIColor blackColor];
    UIColor *contrastingColor = [TWTRColorUtil contrastingTextColorFromBackgroundColor:darkColor];
    XCTAssertTrue([TWTRColorUtil isLightColor:contrastingColor]);
}

- (void)testContrastingTextColorFromBackgroundColor_darkToLight
{
    UIColor *lightColor = [UIColor whiteColor];
    UIColor *contrastingColor = [TWTRColorUtil contrastingTextColorFromBackgroundColor:lightColor];
    XCTAssertFalse([TWTRColorUtil isLightColor:contrastingColor]);
}

- (void)testDarkerColorForColor_darkensLightColors
{
    UIColor *lightColor = [UIColor whiteColor];
    UIColor *derivedColor = [TWTRColorUtil darkerColorForColor:lightColor lightnessLevel:0.1];
    XCTAssertTrue([self isColor:derivedColor darkerDerivativeOfOtherColor:lightColor]);
}

- (void)testDarkerColorForColor_capsAtBlack
{
    UIColor *lightColor = [UIColor whiteColor];
    UIColor *derivedColor = [TWTRColorUtil darkerColorForColor:lightColor lightnessLevel:2.0];
    XCTAssertEqualObjects(derivedColor, [TWTRColorUtil colorFromHex:0x000000]);
}

- (void)testDarkerColorForColor_lightensDarkColors
{
    UIColor *darkColor = [UIColor blackColor];
    UIColor *derivedColor = [TWTRColorUtil lighterColorForColor:darkColor lightnessLevel:0.1];
    XCTAssertFalse([self isColor:derivedColor darkerDerivativeOfOtherColor:darkColor]);
}

- (void)testDarkerColorForColor_capsAtWhite
{
    UIColor *darkColor = [UIColor blackColor];
    UIColor *derivedColor = [TWTRColorUtil lighterColorForColor:darkColor lightnessLevel:2.0];
    XCTAssertEqualObjects(derivedColor, [TWTRColorUtil colorFromHex:0xFFFFFF]);
}

#pragma mark - Helpers

- (RGBA)RGBAWithColor:(UIColor *)color
{
    CGColorRef colorRef = [color CGColor];
    const CGFloat *components = CGColorGetComponents(colorRef);
    RGBA rgba = {components[0], components[1], components[2], components[3]};
    return rgba;
}

// Naive comparison of whether two colors are darker base on their relative RGB values
- (BOOL)isColor:(UIColor *)color darkerDerivativeOfOtherColor:(UIColor *)otherColor
{
    CGFloat r, g, b, a;
    CGFloat r2, g2, b2, a2;

    [color getRed:&r green:&g blue:&b alpha:&a];
    [otherColor getRed:&r2 green:&g2 blue:&b2 alpha:&a2];

    return r <= r2 && g <= g2 && b <= b2 && a <= a2;
}

@end
