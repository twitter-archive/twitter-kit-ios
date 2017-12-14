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

#import <TwitterCore/TWTRDateFormatters.h>
#import <XCTest/XCTest.h>
#import "TWTRJSONKeyRequirement.h"
#import "TWTRJSONValidator.h"
#import "TWTRValueTransformers.h"

@interface TWTRJSONValidatorTests : XCTestCase
@property (nonatomic) NSValueTransformer *serverDateTransformer;
@property (nonatomic) NSValueTransformer *myRetweetIDTransformer;

@end

@implementation TWTRJSONValidatorTests

- (void)setUp
{
    [super setUp];
    self.serverDateTransformer = [NSValueTransformer valueTransformerForName:TWTRServerDateValueTransformerName];
    self.myRetweetIDTransformer = [NSValueTransformer valueTransformerForName:TWTRMyRetweetIDValueTransformerName];
}

- (void)tearDown
{
    [super tearDown];
}

#pragma mark - Transforms Values
- (void)testValidator_transformsDate
{
    NSString *dateString = @"Tue Jul 01 01:00:00 +0000 2014";
    NSDictionary *JSON = @{ @"date": dateString };
    TWTRJSONValidator *validator = [[TWTRJSONValidator alloc] initWithValueTransformers:@{ @"date": self.serverDateTransformer } outputValues:@{ @"date": [TWTRJSONKeyRequirement optionalKeyOfAnyClass] }];
    NSDictionary *dict = [validator validatedDictionaryFromJSON:JSON];

    NSDate *expected = [[TWTRDateFormatters serverParsingDateFormatter] dateFromString:dateString];
    XCTAssertEqualObjects(dict[@"date"], expected);
}

- (void)testValidator_transformsOnlySpecifiedValues
{
    NSString *dateString = @"Tue Jul 01 01:00:00 +0000 2014";
    NSDictionary *JSON = @{ @"date1": dateString, @"date2": dateString };
    NSDictionary *output = @{ @"date1": [TWTRJSONKeyRequirement optionalKeyOfAnyClass], @"date2": [TWTRJSONKeyRequirement optionalKeyOfAnyClass] };
    TWTRJSONValidator *validator = [[TWTRJSONValidator alloc] initWithValueTransformers:@{ @"date1": self.serverDateTransformer } outputValues:output];
    NSDictionary *dict = [validator validatedDictionaryFromJSON:JSON];

    XCTAssertEqualObjects(dict[@"date2"], dateString);
    XCTAssertNotEqualObjects(dict[@"date1"], dateString);
}

#pragma mark - Required Values

- (void)testOutputValues_failsIfMissingRequiredKey
{
    NSDictionary *JSON = @{ @"A": @"B" };
    NSDictionary *outputValues = @{ @"B": [TWTRJSONKeyRequirement requiredString] };
    TWTRJSONValidator *validator = [[TWTRJSONValidator alloc] initWithValueTransformers:@{} outputValues:outputValues];
    XCTAssertNil([validator validatedDictionaryFromJSON:JSON]);
}

- (void)testOutputValues_failsIfRequiredKeyWrongClass
{
    NSDictionary *JSON = @{ @"A": @"B" };
    NSDictionary *outputValues = @{ @"A": [TWTRJSONKeyRequirement requiredNumber] };
    TWTRJSONValidator *validator = [[TWTRJSONValidator alloc] initWithValueTransformers:@{} outputValues:outputValues];
    XCTAssertNil([validator validatedDictionaryFromJSON:JSON]);
}

- (void)testOutputValues_passIfRequiredKeysPresent
{
    NSDictionary *JSON = @{ @"A": @"B" };
    NSDictionary *outputValues = @{ @"A": [TWTRJSONKeyRequirement optionalString] };
    TWTRJSONValidator *validator = [[TWTRJSONValidator alloc] initWithValueTransformers:@{} outputValues:outputValues];
    XCTAssertEqualObjects(JSON, [validator validatedDictionaryFromJSON:JSON]);
}

- (void)testOutputValues_passIgnoreOptionalKeys
{
    NSDictionary *JSON = @{};
    NSDictionary *outputValues = @{ @"A": [TWTRJSONKeyRequirement optionalString] };
    TWTRJSONValidator *validator = [[TWTRJSONValidator alloc] initWithValueTransformers:@{} outputValues:outputValues];
    XCTAssertEqualObjects(JSON, [validator validatedDictionaryFromJSON:JSON]);
}

- (void)testFailsValidation_forNSNull
{
    NSDictionary *JSON = @{ @"A": [NSNull null] };
    NSDictionary *outputValues = @{ @"A": [TWTRJSONKeyRequirement requiredString] };

    TWTRJSONValidator *validator = [[TWTRJSONValidator alloc] initWithValueTransformers:@{} outputValues:outputValues];
    XCTAssertNil([validator validatedDictionaryFromJSON:JSON]);
}

#pragma mark - Alternate Keys

- (void)testAlternateKeys_failIfMissingAlternateKeys
{
    NSDictionary *JSON = @{ @"A": @"B" };
    NSDictionary *outputValues = @{ @"C": [TWTRJSONKeyRequirement requiredStringWithAlternateKeys:@[@"D"]] };
    TWTRJSONValidator *validator = [[TWTRJSONValidator alloc] initWithValueTransformers:@{} outputValues:outputValues];
    XCTAssertNil([validator validatedDictionaryFromJSON:JSON]);
}

- (void)testAlternateKeys_passIfAlternateKeysPresent
{
    NSString *key = @"A";
    NSString *value = @"B";
    NSString *altKey = @"C";

    NSDictionary *JSON = @{altKey: value};
    NSDictionary *outputValues = @{ key: [TWTRJSONKeyRequirement requiredStringWithAlternateKeys:@[altKey]] };
    TWTRJSONValidator *validator = [[TWTRJSONValidator alloc] initWithValueTransformers:@{} outputValues:outputValues];
    NSDictionary *dictionary = [validator validatedDictionaryFromJSON:JSON];

    XCTAssertEqualObjects(dictionary[key], value);
}

- (void)testAlternateKeys_failIfAlternateKeysPresentButWrongClass
{
    NSString *key = @"A";
    NSNumber *value = @1;
    NSString *altKey = @"C";

    NSDictionary *JSON = @{altKey: value};
    NSDictionary *outputValues = @{ key: [TWTRJSONKeyRequirement requiredStringWithAlternateKeys:@[altKey]] };
    TWTRJSONValidator *validator = [[TWTRJSONValidator alloc] initWithValueTransformers:@{} outputValues:outputValues];

    XCTAssertNil([validator validatedDictionaryFromJSON:JSON]);
}

#pragma mark - Pruning

- (void)testValidationRemovesExtraKeys
{
    NSDictionary *JSON = @{ @"A": @"B", @"C": @"D", @"E": @"F" };

    NSDictionary *expected = @{ @"A": @"B", @"C": @"D" };

    NSDictionary *outputValues = @{ @"A": [TWTRJSONKeyRequirement optionalKeyOfAnyClass], @"C": [TWTRJSONKeyRequirement requiredString] };

    TWTRJSONValidator *validator = [[TWTRJSONValidator alloc] initWithValueTransformers:@{} outputValues:outputValues];

    NSDictionary *validated = [validator validatedDictionaryFromJSON:JSON];

    XCTAssertEqualObjects(validated, expected);
}

- (void)testOptionalKeyOfWrongClassRemoved
{
    NSDictionary *JSON = @{ @"A": @1 };
    NSDictionary *expected = @{};

    NSDictionary *outputValues = @{ @"A": [TWTRJSONKeyRequirement optionalString] };

    TWTRJSONValidator *validator = [[TWTRJSONValidator alloc] initWithValueTransformers:@{} outputValues:outputValues];

    NSDictionary *validated = [validator validatedDictionaryFromJSON:JSON];

    XCTAssertEqualObjects(validated, expected);
}

@end
