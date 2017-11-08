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

NS_ASSUME_NONNULL_BEGIN

/**
 Abstraction around the Twitter REST API networking response validation and errors to handle various
 quirks of the API.
 */
@interface TWTRAPINetworkErrorsShim : NSObject

/**
 *  @param response     response from the API request
 *  @param responseData data from the request response
 */
- (instancetype)initWithHTTPResponse:(NSURLResponse *)response responseData:(NSData *)responseData NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
/**
 *  Validates the error response while taking into account some Twitter-specific quirks.
 *
 *  @return the normalized error if there was something to surface from either the HTTP response
 *          or API response
 */

- (nullable NSError *)validate;

@end

/// This class just simply wraps the TWTRAPINetworkErrorsShim class so that we can use
/// something that conforms to the TWTRNetworkingResponseValidating. It simply creates
/// an instance of TWTRAPINetworkErrorsShim for each validation call. Eventually, the
/// TWTRAPINetworkErrorsShim class can be removed or hidden.
@interface TWTRAPIResponseValidator : NSObject <TWTRNetworkingResponseValidating>
@end

NS_ASSUME_NONNULL_END
