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

#import "TWTRAPIServiceConfig.h"
#import "TWTRUtils.h"

NSURL *TWTRAPIURLWithPath(id<TWTRAPIServiceConfig> apiServiceConfig, NSString *path)
{
    if (!path || !apiServiceConfig) {
        return nil;
    }

    NSArray *components = [path componentsSeparatedByString:@"?"];

    if (components.count > 2) {
        return nil;
    }

    NSURLComponents *urlComponents = [[NSURLComponents alloc] init];
    urlComponents.scheme = apiServiceConfig.apiScheme;
    urlComponents.host = apiServiceConfig.apiHost;
    urlComponents.path = components[0];

    if (components.count > 1) {
        urlComponents.query = components[1];
    }

    return urlComponents.URL;
}

NSURL *TWTRAPIURLWithParams(id<TWTRAPIServiceConfig> apiServiceConfig, NSString *path, NSDictionary *params)
{
    if (!params) {
        return nil;
    }

    NSString *queryString = [TWTRUtils queryStringFromDictionary:params];
    NSString *fullPath = [NSString stringWithFormat:@"%@%@%@", path, [path rangeOfString:@"?"].length > 0 ? @"&" : @"?", queryString];

    return TWTRAPIURLWithPath(apiServiceConfig, fullPath);
}
