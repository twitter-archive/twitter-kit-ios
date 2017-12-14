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

#import "TWTRAssetURLSessionConfig.h"
#import <TwitterCore/TWTRNetworkingConstants.h>
#import <TwitterCore/TWTRResourcesUtil.h>

@implementation TWTRAssetURLSessionConfig

+ (NSURLSessionConfiguration *)defaultConfiguration
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.HTTPShouldUsePipelining = YES;
    NSMutableDictionary *additionalHTTPHeaders = [configuration.HTTPAdditionalHeaders mutableCopy] ?: [NSMutableDictionary dictionary];
    [additionalHTTPHeaders addEntriesFromDictionary:[self defaultAdditionalHeaders]];
    configuration.HTTPAdditionalHeaders = additionalHTTPHeaders;
    return configuration;
}

+ (NSDictionary *)defaultAdditionalHeaders
{
    return @{ TWTRNetworkingUserAgentHeaderKey: [TWTRResourcesUtil userAgentFromKitBundle], @"Accept": @"image/*" };  // should only respond with images
}

@end
