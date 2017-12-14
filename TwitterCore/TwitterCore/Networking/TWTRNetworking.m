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

#import "TWTRNetworking.h"
#import <Foundation/Foundation.h>
#import "TWTRAPIDateSync.h"
#import "TWTRAPINetworkErrorsShim.h"
#import "TWTRAuthConfig.h"
#import "TWTRCoreConstants.h"
#import "TWTRNetworkingConstants.h"
#import "TWTRNetworkingUtil.h"
#import "TWTRResourcesUtil.h"
#import "TWTRURLSessionDelegate.h"

@implementation TWTRNetworking

- (instancetype)initWithAuthConfig:(TWTRAuthConfig *)authConfig
{
    self = [super init];
    if (self) {
        _authConfig = authConfig;
    }
    return self;
}

- (NSURLRequest *)URLRequestForGETMethodWithURLString:(NSString *)URLString parameters:(NSDictionary *)params
{
    return [self URLRequestWithMethod:@"GET" URLString:URLString parameters:params];
}

- (NSURLRequest *)URLRequestForPOSTMethodWithURLString:(NSString *)URLString parameters:(NSDictionary *)params
{
    return [self URLRequestWithMethod:@"POST" URLString:URLString parameters:params];
}

- (NSURLRequest *)URLRequestForDELETEMethodWithURLString:(NSString *)URLString parameters:(NSDictionary *)params
{
    return [self URLRequestWithMethod:@"DELETE" URLString:URLString parameters:params];
}

- (void)sendAsynchronousRequest:(NSURLRequest *)request completion:(TWTRTwitterNetworkCompletion)completion
{
    NSParameterAssert(request);
    NSParameterAssert(completion);

    NSURLSession *session = [TWTRNetworking URLSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {

                                                NSError *connectionError = nil;

                                                if (error) {
                                                    connectionError = error;
                                                } else {
                                                    TWTRAPINetworkErrorsShim *shim = [[TWTRAPINetworkErrorsShim alloc] initWithHTTPResponse:response responseData:data];
                                                    connectionError = [shim validate];
                                                }

                                                TWTRAPIDateSync *dateSync = [[TWTRAPIDateSync alloc] initWithHTTPResponse:response];
                                                [dateSync sync];

                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    completion(response, data, connectionError);
                                                });
                                            }];

    [task resume];
}

+ (NSURLSession *)URLSession
{
    static NSURLSession *URLSession = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        TWTRURLSessionDelegate *sessionDelegate = [[TWTRURLSessionDelegate alloc] init];

        NSOperationQueue *delegateQueue = [[NSOperationQueue alloc] init];
        delegateQueue.maxConcurrentOperationCount = 1;  // we want this to be serial
        delegateQueue.name = @"com.twittercore.sdk.url-session-queue";

        NSURLSessionConfiguration *sessionConfig = [self defaultConfiguration];
        URLSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:sessionDelegate delegateQueue:delegateQueue];
    });

    return URLSession;
}

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
    NSDictionary *headers = @{TWTRNetworkingUserAgentHeaderKey: [TWTRResourcesUtil userAgentFromKitBundle]};
    return headers;
}

#pragma mark - API

- (NSURLRequest *)URLRequestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    NSString *query = [TWTRNetworkingUtil queryStringFromParameters:parameters];
    NSString *absoluteURLString = [[request URL] absoluteString];
    if ([method isEqualToString:@"POST"]) {
        NSData *data = [query dataUsingEncoding:NSUTF8StringEncoding];
        NSString *length = [NSString stringWithFormat:@"%lu", (unsigned long)[data length]];
        [request setHTTPBody:data];
        [request setValue:TWTRContentTypeURLEncoded forHTTPHeaderField:TWTRContentTypeHeaderField];
        [request setValue:length forHTTPHeaderField:TWTRContentLengthHeaderField];
    } else {
        if ([[request URL] query]) {
            absoluteURLString = [absoluteURLString stringByAppendingFormat:@"&%@", query];
        } else if ([query length] > 0) {
            absoluteURLString = [absoluteURLString stringByAppendingFormat:@"?%@", query];
        }
        NSURL *modifiedURL = [NSURL URLWithString:absoluteURLString];
        [request setURL:modifiedURL];
    }

    [request setHTTPMethod:method];
    NSString *userAgent = [TWTRResourcesUtil userAgentFromKitBundle];
    [request setValue:userAgent forHTTPHeaderField:TWTRNetworkingUserAgentHeaderKey];
    return request;
}

#pragma mark - Internal

- (NSOperationQueue *)operationQueue
{
    static NSOperationQueue *_operationQueue = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        _operationQueue = [[NSOperationQueue alloc] init];
    });
    return _operationQueue;
}

@end
