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

@implementation TWTRCookieStorageUtil

+ (NSArray *)cookiesWithDomainSuffix:(NSString *)domainSuffix
{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSMutableArray *matchingCookies = [NSMutableArray array];
    for (NSHTTPCookie *cookie in [cookieStorage cookies]) {
        if ([cookie.domain hasSuffix:domainSuffix]) {
            [matchingCookies addObject:cookie];
        }
    }

    return matchingCookies;
}

+ (void)clearCookiesWithDomainSuffix:(NSString *)domainSuffix
{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *matchingCookies = [self cookiesWithDomainSuffix:domainSuffix];
    for (NSHTTPCookie *cookie in matchingCookies) {
        [cookieStorage deleteCookie:cookie];
    }
}

@end
