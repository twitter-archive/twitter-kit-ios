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

#import "TWTRWebAuthenticationTokenRequestor.h"
#import <TwitterCore/TWTRAPIServiceConfig.h>
#import <TwitterCore/TWTRAssertionMacros.h>
#import <TwitterCore/TWTRAuthConfig.h>
#import <TwitterCore/TWTRAuthenticationConstants.h>
#import <TwitterCore/TWTRSessionStore.h>
#import <TwitterCore/TWTRSessionStore_Private.h>
#import <TwitterCore/TWTRUserAPIClient.h>
#import <TwitterCore/TWTRUtils.h>
#import "TWTRLoginURLParser.h"

@interface TWTRWebAuthenticationTokenRequestor ()
@property (nonatomic, readonly) TWTRUserAPIClient *APIClient;
@property (nonatomic, readonly) id<TWTRAPIServiceConfig> serviceConfig;

@end

@implementation TWTRWebAuthenticationTokenRequestor

- (instancetype)initWithAuthConfig:(TWTRAuthConfig *)authConfig serviceConfig:(id<TWTRAPIServiceConfig>)serviceConfig
{
    TWTRParameterAssertOrReturnValue(authConfig, nil);
    TWTRParameterAssertOrReturnValue(serviceConfig, nil);

    self = [super init];
    if (self) {
        _serviceConfig = serviceConfig;
        _APIClient = [[TWTRUserAPIClient alloc] initWithAuthConfig:authConfig authToken:nil authTokenSecret:nil];
    }

    return self;
}

- (void)requestAuthenticationToken:(TWTRAuthenticationTokenRequestCompletion)completion
{
    TWTRParameterAssertOrReturn(completion);
    TWTRAuthConfig *authConfig = self.APIClient.authConfig;
    TWTRLoginURLParser *loginURLParser = [[TWTRLoginURLParser alloc] initWithAuthConfig:authConfig];

    NSString *redirectScheme = [loginURLParser authRedirectScheme];
    NSDictionary *callbackParams = @{TWTRAuthAppOAuthAppKey: authConfig.consumerKey};
    NSString *redirectURL = [NSString stringWithFormat:@"%@://%@?%@", redirectScheme, TWTRSDKRedirectHost, [TWTRUtils queryStringFromDictionary:callbackParams]];

    NSDictionary *params = @{TWTRAuthAppOAuthCallbackKey: redirectURL};

    NSURL *postURL = TWTRAPIURLWithPath(self.serviceConfig, TWTRTwitterRequestTokenPath);
    NSURLRequest *request = [self.APIClient URLRequestWithMethod:@"POST" URLString:postURL.absoluteString parameters:params];

    [self.APIClient sendAsynchronousRequest:request completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [self handleRequestTokenResponse:data error:connectionError completion:completion];
    }];
}

- (void)handleRequestTokenResponse:(NSData *)tokenData error:(NSError *)error completion:(TWTRAuthenticationTokenRequestCompletion)completion
{
    NSString *token = [self tokenFromTokenData:tokenData];
    if (token.length == 0) {
        [self didFailToReceiveOAuthToken:tokenData];
        if (error) {
            completion(nil, error);
        } else {
            NSError *unknownError = [self unknownLoginErrorWithMessage:@"Could not retrieve auth token"];
            completion(nil, unknownError);
        }
    } else {
        completion(token, nil);
    }
}

- (nullable NSString *)tokenFromTokenData:(nullable NSData *)tokenData
{
    return [self dictionaryFromTokenResponseData:tokenData][TWTRAuthOAuthTokenKey];
}

- (nullable NSDictionary *)dictionaryFromTokenResponseData:(nullable NSData *)tokenData
{
    if (!tokenData) {
        return nil;
    }

    NSString *queryString = [[NSString alloc] initWithData:tokenData encoding:NSUTF8StringEncoding];
    return [TWTRUtils dictionaryWithQueryString:queryString];
}

- (void)didFailToReceiveOAuthToken:(NSData *)responseData
{
    NSString *errorDescription;

    if (responseData == nil) {
        errorDescription = @"";
    } else {
        errorDescription = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] ?: @"";
    }

    NSLog(@"[TwitterKit] Error obtaining user auth token.");
}

- (NSError *)unknownLoginErrorWithMessage:(NSString *)message
{
    return [NSError errorWithDomain:TWTRLogInErrorDomain code:TWTRLogInErrorCodeUnknown userInfo:@{NSLocalizedDescriptionKey: message}];
}

@end
