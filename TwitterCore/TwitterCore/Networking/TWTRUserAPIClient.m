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

#import "TWTRUserAPIClient.h"
#import <TwitterCore/TWTRAssertionMacros.h>
#import <TwitterCore/TWTRAuthConfig.h>
#import "TWTRGCOAuth.h"

@interface TWTRUserAPIClient ()

@property (nonatomic, copy, readonly) NSString *authToken;
@property (nonatomic, copy, readonly) NSString *authTokenSecret;

@end

@implementation TWTRUserAPIClient

- (instancetype)initWithAuthConfig:(TWTRAuthConfig *)authConfig authToken:(NSString *)authToken authTokenSecret:(NSString *)authTokenSecret
{
    NSParameterAssert(authConfig);

    if ((self = [super initWithAuthConfig:authConfig])) {
        _authToken = authToken.copy;
        _authTokenSecret = authTokenSecret.copy;
    }

    return self;
}

- (NSURLRequest *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters
{
    TWTRParameterAssertOrReturnValue(URLString, nil);

    NSURL *originalURL = [NSURL URLWithString:URLString];
    return [TWTRGCOAuth URLRequestForPath:[originalURL path] GETParameters:parameters scheme:@"https" host:[TWTRUserAPIClient hostWithPortFromURL:originalURL] consumerKey:self.authConfig.consumerKey consumerSecret:self.authConfig.consumerSecret accessToken:[self authToken] tokenSecret:[self authTokenSecret]];
}

- (NSURLRequest *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters
{
    TWTRParameterAssertOrReturnValue(URLString, nil);

    NSURL *originalURL = [NSURL URLWithString:URLString];
    return [TWTRGCOAuth URLRequestForPath:[originalURL path] POSTParameters:parameters scheme:@"https" host:[TWTRUserAPIClient hostWithPortFromURL:originalURL] consumerKey:self.authConfig.consumerKey consumerSecret:self.authConfig.consumerSecret accessToken:[self authToken] tokenSecret:[self authTokenSecret]];
}

- (NSURLRequest *)DELETE:(NSString *)URLString parameters:(NSDictionary *)parameters
{
    TWTRParameterAssertOrReturnValue(URLString, nil);

    NSURL *originalURL = [NSURL URLWithString:URLString];
    return [TWTRGCOAuth URLRequestForPath:[originalURL path] DELETEParameters:parameters scheme:@"https" host:[TWTRUserAPIClient hostWithPortFromURL:originalURL] consumerKey:self.authConfig.consumerKey consumerSecret:self.authConfig.consumerSecret accessToken:[self authToken] tokenSecret:[self authTokenSecret]];
}

- (NSURLRequest *)URLRequestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters
{
    TWTRParameterAssertOrReturnValue(method, nil);
    TWTRParameterAssertOrReturnValue(URLString, nil);

    NSURLRequest *request;
    if ([method isEqualToString:@"GET"]) {
        request = [self GET:URLString parameters:parameters];
    } else if ([method isEqualToString:@"POST"]) {
        request = [self POST:URLString parameters:parameters];
    } else if ([method isEqualToString:@"DELETE"]) {
        request = [self DELETE:URLString parameters:parameters];
    } else {
        [NSException raise:NSInvalidArgumentException format:@"HTTP method %@ is unsupported.", method];
    }
    return request;
}

+ (NSString *)hostWithPortFromURL:(NSURL *)URL
{
    if (URL.port) {
        return [NSString stringWithFormat:@"%@:%@", URL.host, URL.port];
    } else {
        return URL.host;
    }
}

@end
