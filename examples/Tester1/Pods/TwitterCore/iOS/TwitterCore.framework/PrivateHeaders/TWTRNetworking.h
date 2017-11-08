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

#import <Foundation/Foundation.h>
@class TWTRAuthConfig;
/**
 *  Completion block called when the network request succeeds or fails.
 *
 *  @param response        Metadata associated with the response to a URL load request.
 *  @param data            Content data of the response.
 *  @param connectionError Error object describing the network error that occurred.
 */
typedef void (^TWTRTwitterNetworkCompletion)(NSURLResponse *response, NSData *data, NSError *connectionError);

@interface TWTRNetworking : NSObject

@property (nonatomic, readonly) TWTRAuthConfig *authConfig;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAuthConfig:(TWTRAuthConfig *)authConfig;

- (NSURLRequest *)URLRequestForGETMethodWithURLString:(NSString *)URLString parameters:(NSDictionary *)params;
- (NSURLRequest *)URLRequestForPOSTMethodWithURLString:(NSString *)URLString parameters:(NSDictionary *)params;
- (NSURLRequest *)URLRequestForDELETEMethodWithURLString:(NSString *)URLString parameters:(NSDictionary *)params;

- (NSURLRequest *)URLRequestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters;

- (void)sendAsynchronousRequest:(NSURLRequest *)request completion:(TWTRTwitterNetworkCompletion)completion;

@end
