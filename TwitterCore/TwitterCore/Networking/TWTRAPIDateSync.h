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

/**
 This header is private to the Twitter Core SDK and not exposed for public SDK consumption
 */

#import <Foundation/Foundation.h>
#import "TWTRNetworkingPipeline.h"

/**
 * Abstraction to read off the `date` header from Twitter's API. This offset value can be used to
 * set the correct GTM time to our OAuth requests
 */
@interface TWTRAPIDateSync : NSObject

/**
 *  @param response     response from the API request
 *  @param responseData data from the request response
 */
- (nullable instancetype)initWithHTTPResponse:(nullable NSURLResponse *)response NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)init NS_UNAVAILABLE;

/**
 * Parses http response header and syncs OAuth offsets if necessary
 *
 * @return YES if there was a delta
 */
- (BOOL)sync;

@end
