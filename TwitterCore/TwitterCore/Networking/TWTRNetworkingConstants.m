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

#import "TWTRNetworkingConstants.h"

NSString *const TWTRNetworkingErrorDomain = @"TWTRNetworkingErrorDomain";
NSString *const TWTRNetworkingUserAgentHeaderKey = @"User-Agent";
NSString *const TWTRNetworkingStatusCodeKey = @"TWTRNetworkingStatusCode";

#pragma mark - HTTP Headers
NSString *const TWTRContentTypeHeaderField = @"Content-Type";
NSString *const TWTRContentLengthHeaderField = @"Content-Length";
NSString *const TWTRContentTypeURLEncoded = @"application/x-www-form-urlencoded;charset=UTF-8";
NSString *const TWTRAcceptEncodingHeaderField = @"Accept-Encoding";
NSString *const TWTRAcceptEncodingGzip = @"gzip";
