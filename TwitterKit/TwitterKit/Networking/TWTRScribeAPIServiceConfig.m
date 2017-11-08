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

#import "TWTRScribeAPIServiceConfig.h"

#import <TwitterCore/TWTRAPIServiceConfig.h>
#import <TwitterCore/TWTRAuthenticationConstants.h>

static NSString *const TWTRScribeAPIHost = @"syndication.twitter.com";
static NSString *const TWTRScribeAPIScheme = @"https";
static NSString *const TWTRScribeServiceName = @"com.twitter.syndication.scribe-service";

@implementation TWTRScribeAPIServiceConfig

- (NSString *)apiHost
{
    return TWTRScribeAPIHost;
}

- (NSString *)apiScheme
{
    return TWTRScribeAPIScheme;
}

- (NSString *)serviceName
{
    return TWTRScribeServiceName;
}

@end
