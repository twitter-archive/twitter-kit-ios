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

#import <XCTest/XCTest.h>
#import "TWTRHTMLEntityUtil.h"

@interface TWTRHTMLEntityUtilTests : XCTestCase

@end

@implementation TWTRHTMLEntityUtilTests

- (void)testReplacedCharacters
{
    NSString *original = @"This string has &amp; and &gt; and &lt; &copy;";
    NSString *expected = @"This string has & and > and < ©";
    NSString *actual = [TWTRHTMLEntityUtil unescapedHTMLEntitiesStringWithString:original];

    XCTAssert([actual isEqualToString:expected]);
}

- (void)testOtherCharacters
{
    NSString *original = @"This other string has &frasl; and &sdot; and &Delta; &nabla; &#x27;";
    NSString *expected = @"This other string has ⁄ and ⋅ and Δ ∇ '";
    NSString *actual = [TWTRHTMLEntityUtil unescapedHTMLEntitiesStringWithString:original];

    XCTAssert([actual isEqualToString:expected]);
}

- (void)testHTMLunescape
{
    XCTAssertEqualObjects(@"<", [TWTRHTMLEntityUtil unescapedHTMLEntitiesStringWithString:@"&lt;"], @"Failed to parse &lt;");
    XCTAssertEqualObjects(@"<", [TWTRHTMLEntityUtil unescapedHTMLEntitiesStringWithString:@"&LT;"], @"Failed to parse &LT;");
    XCTAssertEqualObjects(@">", [TWTRHTMLEntityUtil unescapedHTMLEntitiesStringWithString:@"&gt;"], @"Failed to parse &gt;");
    XCTAssertEqualObjects(@">", [TWTRHTMLEntityUtil unescapedHTMLEntitiesStringWithString:@"&GT;"], @"Failed to parse &GT;");
    XCTAssertEqualObjects(@"&", [TWTRHTMLEntityUtil unescapedHTMLEntitiesStringWithString:@"&amp;"], @"Failed to parse &amp;");
    XCTAssertEqualObjects(@"&", [TWTRHTMLEntityUtil unescapedHTMLEntitiesStringWithString:@"&AMP;"], @"Failed to parse &AMP;");
    XCTAssertEqualObjects(@"\"", [TWTRHTMLEntityUtil unescapedHTMLEntitiesStringWithString:@"&quot;"], @"Failed to parse &quot;");
    XCTAssertEqualObjects(@"\"", [TWTRHTMLEntityUtil unescapedHTMLEntitiesStringWithString:@"&QUOT;"], @"Failed to parse &QUOT;");
    XCTAssertEqualObjects(@"'", [TWTRHTMLEntityUtil unescapedHTMLEntitiesStringWithString:@"&apos;"], @"Failed to parse &apos;");
    XCTAssertEqualObjects(@"&apOs;", [TWTRHTMLEntityUtil unescapedHTMLEntitiesStringWithString:@"&apOs;"], @"Failed to parse &apOs;");
    XCTAssertEqualObjects(@"amp&amp;amp", [TWTRHTMLEntityUtil unescapedHTMLEntitiesStringWithString:@"amp&amp;amp;amp"], @"Failed to parse &amp;");
    XCTAssertEqualObjects(@"&&<;;&&", [TWTRHTMLEntityUtil unescapedHTMLEntitiesStringWithString:@"&&&lt;;;&&"], @"Failed to parse &lt;");
    XCTAssertEqualObjects(@"€", [TWTRHTMLEntityUtil unescapedHTMLEntitiesStringWithString:@"&euro;"], @"Failed to parse &euro;");
    XCTAssertEqualObjects(@"&EURO;", [TWTRHTMLEntityUtil unescapedHTMLEntitiesStringWithString:@"&EURO;"], @"Failed to parse &EURO;");
    XCTAssertEqualObjects(@"!®", [TWTRHTMLEntityUtil unescapedHTMLEntitiesStringWithString:@"&#33;&#174;"], @"Failed to parse &#33;&#174;");
    XCTAssertEqualObjects(@"///", [TWTRHTMLEntityUtil unescapedHTMLEntitiesStringWithString:@"&#47;&#x2F;&#x2f;"], @"Failed to parse &#47;&#x2f;&#x2F");
}

@end
