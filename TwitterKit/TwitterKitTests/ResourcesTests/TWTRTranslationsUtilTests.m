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

#import <OCMock/OCMock.h>
#import <TwitterCore/TWTRResourcesUtil.h>
#import "TWTRConstants_Private.h"
#import "TWTRTestCase.h"
#import "TWTRTranslationsUtil.h"

@interface TWTRTranslationsUtilTests : TWTRTestCase

@property (nonatomic, strong) id mockResourcesUtil;

@end

@implementation TWTRTranslationsUtilTests

- (void)testLocalizedStringForKey_callsResourceUtilMethod
{
    NSString *key = @"some key";
    id resourceUtilMock = [OCMockObject mockForClass:[TWTRResourcesUtil class]];
    [[resourceUtilMock expect] localizedStringForKey:key bundlePath:TWTRResourceBundleLocation];

    [TWTRTranslationsUtil localizedStringForKey:key];

    [resourceUtilMock verify];
    [resourceUtilMock stopMocking];
}

- (void)testTranslateFunction
{
    XCTAssert([TWTRLocalizedString(@"tw__test_string") isEqualToString:[TWTRTranslationsUtil localizedStringForKey:@"tw__test_string"]]);
}

- (void)testConcatenatePutsInSeparators
{
    NSArray *items = @[@"First Name", @"Last Name", @"Text"];
    NSString *concatentatedString = [TWTRTranslationsUtil accessibilityStringByConcatenatingItems:items];
    XCTAssert([concatentatedString isEqualToString:@"First Name.\nLast Name.\nText"]);
}

- (void)testEnglishOneString
{
    NSString *str1 = @"abc";

    NSString *expected = @"abc";
    NSString *result = [TWTRTranslationsUtil accessibilityStringByConcatenatingItems:@[str1]];
    XCTAssertTrue([expected isEqualToString:result], @"Single string concat failed. Expected: %@ Got: %@", expected, result);
}

- (void)testEnglishTwoStrings
{
    NSString *str1 = @"abc";
    NSString *str2 = @"def";

    NSString *expected = @"abc.\ndef";
    NSString *result = [TWTRTranslationsUtil accessibilityStringByConcatenatingItems:@[str1, str2]];
    XCTAssertTrue([expected isEqualToString:result], @"Two string concat failed. Expected: %@ Got: %@", expected, result);
}

- (void)testEnglishThreeStrings
{
    NSString *str1 = @"abc";
    NSString *str2 = @"def";
    NSString *str3 = @"ghi";

    NSString *expected = @"abc.\ndef.\nghi";
    NSString *result = [TWTRTranslationsUtil accessibilityStringByConcatenatingItems:@[str1, str2, str3]];
    XCTAssertTrue([expected isEqualToString:result], @"Three string concat failed. Expected: %@ Got: %@", expected, result);
}

- (void)testEnglishPuncuated
{
    NSString *str1 = @"abc!";
    NSString *str2 = @"def.";

    NSString *expected = @"abc!\ndef.";
    NSString *result = [TWTRTranslationsUtil accessibilityStringByConcatenatingItems:@[str1, str2]];
    XCTAssertTrue([expected isEqualToString:result], @"Pre-punctuated concat failed. Expected: %@ Got: %@", expected, result);
}

- (void)testEnglishPuncuatedUsingConcatString
{
    NSString *str1 = @"abc.";
    NSString *str2 = @"def.";

    NSString *expected = @"abc.\ndef.";
    NSString *result = [TWTRTranslationsUtil accessibilityStringByConcatenatingItems:@[str1, str2]];
    XCTAssertTrue([expected isEqualToString:result], @"Pre-punctuated w/ concat string concat failed. Expected: %@ Got: %@", expected, result);
}

- (void)testEnglishEmptyString1
{
    NSString *str1 = @"abc";
    NSString *str2 = @"";
    NSString *str3 = @"ghi";

    NSString *expected = @"abc.\nghi";
    NSString *result = [TWTRTranslationsUtil accessibilityStringByConcatenatingItems:@[str1, str2, str3]];
    XCTAssertTrue([expected isEqualToString:result], @"Empty string concat failed. Expected: %@ Got: %@", expected, result);
}

- (void)testEnglishEmptyString2
{
    NSString *str1 = @"";
    NSString *str2 = @"";
    NSString *str3 = @"";

    NSString *expected = @"";
    NSString *result = [TWTRTranslationsUtil accessibilityStringByConcatenatingItems:@[str1, str2, str3]];
    XCTAssertTrue([expected isEqualToString:result], @"Empty string concat failed. Expected: %@ Got: %@", expected, result);
}

- (void)testEnglishWhitespaceNewlineString1
{
    NSString *str1 = @"abc";
    NSString *str2 = @"   \n";
    NSString *str3 = @"ghi";

    NSString *expected = @"abc.\nghi";
    NSString *result = [TWTRTranslationsUtil accessibilityStringByConcatenatingItems:@[str1, str2, str3]];
    XCTAssertTrue([expected isEqualToString:result], @"Whitespace string concat failed. Expected: %@ Got: %@", expected, result);
}

- (void)testEnglishWhitespaceNewlineString2
{
    NSString *str1 = @" a b c ";
    NSString *str2 = @" \n  \n";
    NSString *str3 = @" \n g h \ni \n";

    NSString *expected = @"a b c.\ng h \ni";
    NSString *result = [TWTRTranslationsUtil accessibilityStringByConcatenatingItems:@[str1, str2, str3]];
    XCTAssertTrue([expected isEqualToString:result], @"Whitespace string concat failed. Expected: %@ Got: %@", expected, result);
}

- (void)testJapaneseOneString
{
    NSString *str1 = @"平仮名";

    NSString *expected = @"平仮名";
    NSString *result = [TWTRTranslationsUtil accessibilityStringByConcatenatingItems:@[str1]];
    XCTAssertTrue([expected isEqualToString:result], @"Japanese one string concat failed. Expected: %@ Got: %@", expected, result);
}

- (void)testJapaneseTwoStrings
{
    NSString *str1 = @"平仮名";
    NSString *str2 = @"送り仮名";

    NSString *expected = @"平仮名.\n送り仮名";
    NSString *result = [TWTRTranslationsUtil accessibilityStringByConcatenatingItems:@[str1, str2]];
    XCTAssertTrue([expected isEqualToString:result], @"Japanese one string concat failed. Expected: %@ Got: %@", expected, result);
}

@end
