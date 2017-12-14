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

#import "TWTRTwitterAPIServiceConfig.h"
#import <TwitterCore/TWTRAPIServiceConfig.h>
#import <TwitterCore/TWTRAuthenticationConstants.h>

static NSString *const TWTRTwitterAPIHost = @"api.twitter.com";
static NSString *const TWTRHTTPSScheme = @"https";
static NSString *const TWTRAPIServiceName = @"com.twitter.api-service";

static NSString *const TWTRTwitterUploadHost = @"upload.twitter.com";
static NSString *const TWTRUploadServiceName = @"com.twitter.upload-service";

static NSString *const TWTRTwitterCardsHost = @"caps.twitter.com";
static NSString *const TWTRCardsServiceName = @"com.twitter.caps-service";

@implementation TWTRTwitterAPIServiceConfig

- (NSString *)apiHost
{
    return TWTRTwitterAPIHost;
}

- (NSString *)apiScheme
{
    return TWTRHTTPSScheme;
}

- (NSString *)serviceName
{
    return TWTRAPIServiceName;
}

@end

@implementation TWTRTwitterUploadServiceConfig

- (NSString *)apiHost
{
    return TWTRTwitterUploadHost;
}

- (NSString *)apiScheme
{
    return TWTRHTTPSScheme;
}

- (NSString *)serviceName
{
    return TWTRUploadServiceName;
}

@end

@implementation TWTRTwitterCardsServiceConfig

- (NSString *)apiHost
{
    return TWTRTwitterCardsHost;
}

- (NSString *)apiScheme
{
    return TWTRHTTPSScheme;
}

- (NSString *)serviceName
{
    return TWTRCardsServiceName;
}

@end
