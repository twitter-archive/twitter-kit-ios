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

#import "TWTRNetworkingUtil.h"
#import "TWTRTestCase.h"

@interface TWTRNetworkUtilTests : TWTRTestCase

@end

@implementation TWTRNetworkUtilTests

#pragma mark - queryStringFromParameters

- (void)testQueryStringFromParameters_empty
{
    NSString *queryString = [TWTRNetworkingUtil queryStringFromParameters:@{}];
    XCTAssertEqualObjects(queryString, @"");
}

- (void)testQueryStringFromParameters_nonEmpty
{
    NSDictionary *params = @{ @"a": @"1", @"b": @"2" };
    NSString *queryString = [TWTRNetworkingUtil queryStringFromParameters:params];
    XCTAssertEqualObjects(queryString, @"a=1&b=2");
}

- (void)testQueryStringFromParameters_escapingCharacters
{
    NSDictionary *params = @{ @"a": @"1", @"b": @"[\"foo bar\"]" };
    NSString *queryString = [TWTRNetworkingUtil queryStringFromParameters:params];
    XCTAssertEqualObjects(queryString, @"a=1&b=%5B%22foo%20bar%22%5D");
}

#pragma mark - parametersFromQueryString

- (void)testParametersFromQueryString_empty
{
    NSString *queryString = @"";
    NSDictionary *expectedResult = [NSDictionary dictionary];
    NSDictionary *responseDict = [TWTRNetworkingUtil parametersFromQueryString:queryString];
    XCTAssertEqualObjects(responseDict, expectedResult);
}

- (void)testParametersFromQueryString_nonEmpty
{
    NSString *queryString = @"a=1&b=2";
    NSDictionary *expectedResult = @{ @"a": @"1", @"b": @"2" };
    NSDictionary *responseDict = [TWTRNetworkingUtil parametersFromQueryString:queryString];
    XCTAssertEqualObjects(responseDict, expectedResult);
}

- (void)testParametersFromQueryString_escapingCharacters
{
    NSString *queryString = @"a=1&b=%5B%22foo%20bar%22%5D";
    NSDictionary *expectedResult = @{ @"a": @"1", @"b": @"[\"foo bar\"]" };
    NSDictionary *params = [TWTRNetworkingUtil parametersFromQueryString:queryString];
    XCTAssertEqualObjects(params, expectedResult);
}

#pragma mark - percentEscapedQueryStringWithString

- (void)testPercentEscapedQueryStringWithString_empty
{
    NSString *result = [TWTRNetworkingUtil percentEscapedQueryStringWithString:@"" encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(result, @"");
}

- (void)testPercentEscapedQueryStringWithString_doNotEscapeCharacters
{
    NSString *input = @"~ABC.123_foo-bar~";
    NSString *result = [TWTRNetworkingUtil percentEscapedQueryStringWithString:input encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(result, input);
}

- (void)testPercentEscapedQueryStringWithString_escapesCurlyBrackets
{
    NSString *input = @"Hello {insert name}";
    NSString *result = [TWTRNetworkingUtil percentEscapedQueryStringWithString:input encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(result, @"Hello%20%7Binsert%20name%7D");
}

- (void)testPercentEscapedQueryStringWithString_escapeCharacters
{
    NSString *input = @":/?&=;+!@#$()',*[]%";
    NSString *queryString = [TWTRNetworkingUtil percentEscapedQueryStringWithString:input encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(queryString, @"%3A%2F%3F%26%3D%3B%2B%21%40%23%24%28%29%27%2C%2A%5B%5D%25");
}

/**
 *  The following test cases are from Twitter.com Oauth docs
 *  @see https://dev.twitter.com/oauth/overview/percent-encoding-parameters
 */

- (void)testPercentEscapedQueryStringWithString_spaceAndPlus
{
    NSString *input = @"Ladies + Gentlemen";
    NSString *queryString = [TWTRNetworkingUtil percentEscapedQueryStringWithString:input encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(queryString, @"Ladies%20%2B%20Gentlemen");
}

- (void)testPercentEscapedQueryStringWithString_spaceAndReservedCharacters
{
    NSString *input = @"An encoded string!";
    NSString *queryString = [TWTRNetworkingUtil percentEscapedQueryStringWithString:input encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(queryString, @"An%20encoded%20string%21");
}

- (void)testPercentEscapedQueryStringWithString_reservedBetweenSpaceCharacters
{
    NSString *input = @"Dogs, Cats & Mice";
    NSString *queryString = [TWTRNetworkingUtil percentEscapedQueryStringWithString:input encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(queryString, @"Dogs%2C%20Cats%20%26%20Mice");
}

- (void)testPercentEscapedQueryStringWithString_unicode
{
    NSString *input = @"☃";
    NSString *queryString = [TWTRNetworkingUtil percentEscapedQueryStringWithString:input encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(queryString, @"%E2%98%83");
}

#pragma mark - percentUnescapedQueryStringWithString

- (void)testPercentUnescapedQueryStringWithString_empty
{
    NSString *queryString = @"";
    NSString *originalString = [TWTRNetworkingUtil percentUnescapedQueryStringWithString:queryString encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(originalString, queryString);
}

- (void)testPercentUnescapedQueryStringWithString_doNotEscapeCharacters
{
    NSString *queryString = @"~ABC.123_foo-bar~";
    NSString *originalString = [TWTRNetworkingUtil percentUnescapedQueryStringWithString:queryString encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(originalString, queryString);
}

- (void)testPercentUnescapedQueryStringWithString_escapeCharacters
{
    NSString *queryString = @"%3A%2F%3F%26%3D%3B%2B%21%40%23%24%28%29%27%2C%2A%5B%5D";
    NSString *originalString = [TWTRNetworkingUtil percentUnescapedQueryStringWithString:queryString encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(originalString, @":/?&=;+!@#$()',*[]");
}

@end
