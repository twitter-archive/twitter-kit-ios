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

#import "TWTRCookieStorageUtil.h"
#import "TWTRTestCase.h"

@interface TWTRCookieStorageUtilTests : TWTRTestCase

@property (nonatomic) NSHTTPCookieStorage *cookieStorage;
@property (nonatomic) NSHTTPCookie *apiTwitterCookie;
@property (nonatomic) NSHTTPCookie *twitterCookie;
@property (nonatomic) NSHTTPCookie *nonTwitterCookie;

@end

@implementation TWTRCookieStorageUtilTests

- (void)setUp
{
    [super setUp];

    self.apiTwitterCookie = [NSHTTPCookie cookieWithProperties:@{ NSHTTPCookiePath: @"/", NSHTTPCookieName: @"name", NSHTTPCookieValue: @"value", NSHTTPCookieDomain: @"http://api.twitter.com" }];
    self.twitterCookie = [NSHTTPCookie cookieWithProperties:@{ NSHTTPCookiePath: @"/", NSHTTPCookieName: @"name", NSHTTPCookieValue: @"value", NSHTTPCookieDomain: @".twitter.com" }];
    self.nonTwitterCookie = [NSHTTPCookie cookieWithProperties:@{ NSHTTPCookiePath: @"/", NSHTTPCookieName: @"name", NSHTTPCookieValue: @"value", NSHTTPCookieDomain: @".example.com" }];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [cookieStorage setCookie:self.apiTwitterCookie];
    [cookieStorage setCookie:self.twitterCookie];
    [cookieStorage setCookie:self.nonTwitterCookie];
}

- (void)tearDown
{
    [TWTRCookieStorageUtil clearCookiesWithDomainSuffix:@""];

    [super tearDown];
}

- (void)testCookiesWithDomainSuffix_noMatches
{
    NSArray *cookies = [TWTRCookieStorageUtil cookiesWithDomainSuffix:@"badsuffix"];
    XCTAssertEqual([cookies count], 0);
}

- (void)testCookiesWithDomainSuffix_findsOnlyMatchingDomains
{
    NSArray *cookies = [TWTRCookieStorageUtil cookiesWithDomainSuffix:@"twitter.com"];
    XCTAssertEqual([cookies count], 2);
}

- (void)testCookiesWithDomainSuffix_exactMatch
{
    NSArray *cookies = [TWTRCookieStorageUtil cookiesWithDomainSuffix:@"api.twitter.com"];
    XCTAssertEqual([cookies count], 1);
}

- (void)testClearCookiesWithDomainSuffix_multipleMatches
{
    [TWTRCookieStorageUtil clearCookiesWithDomainSuffix:@"twitter.com"];
    NSArray *cookies = [TWTRCookieStorageUtil cookiesWithDomainSuffix:@"twitter.com"];
    XCTAssertEqual([cookies count], 0);
}

- (void)testClearCookiesWithDomainSuffix_exactMatch
{
    [TWTRCookieStorageUtil clearCookiesWithDomainSuffix:@"api.twitter.com"];
    NSArray *cookies = [TWTRCookieStorageUtil cookiesWithDomainSuffix:@"api.twitter.com"];
    XCTAssertEqual([cookies count], 0);
}

- (void)testClearCookiesWithDomainSuffix_noMatches
{
    [TWTRCookieStorageUtil clearCookiesWithDomainSuffix:@"badsuffix"];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    XCTAssertEqual([cookies count], 3);
}

@end
