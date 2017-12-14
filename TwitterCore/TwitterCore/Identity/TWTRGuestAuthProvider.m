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

#import "TWTRGuestAuthProvider.h"
#import "TWTRAPIServiceConfig.h"
#import "TWTRAppAPIClient.h"
#import "TWTRAuthenticationConstants.h"
#import "TWTRAuthenticationProvider_Private.h"

@interface TWTRGuestAuthProvider ()

@property (nonatomic, strong, readonly) id<TWTRAPIServiceConfig> apiServiceConfig;

/**
 *  Contains the working consumer key and secret
 */
@property (nonatomic, strong, readonly) TWTRAuthConfig *authConfig;
/**
 *  Working app auth access token
 */
@property (nonatomic, copy, readonly) NSString *accessToken;
/**
 *  Client used to activate a new guest token.
 */
@property (nonatomic, strong) TWTRAppAPIClient *appAPIClient;

@end

@implementation TWTRGuestAuthProvider

- (instancetype)initWithAuthConfig:(TWTRAuthConfig *)authConfig apiServiceConfig:(id<TWTRAPIServiceConfig>)apiServiceConfig accessToken:(NSString *)accessToken
{
    NSParameterAssert(authConfig);
    NSParameterAssert(accessToken);
    NSParameterAssert(apiServiceConfig);

    if (self = [super init]) {
        _authConfig = authConfig;
        _apiServiceConfig = apiServiceConfig;
        _accessToken = accessToken;
        _appAPIClient = [[TWTRAppAPIClient alloc] initWithAuthConfig:authConfig accessToken:accessToken];
    }

    return self;
}

#pragma mark - TWTRAuthenticationProvider

- (void)authenticateWithCompletion:(TWTRAuthenticationProviderCompletion)completion
{
    NSParameterAssert(completion);
    [self.appAPIClient sendAsynchronousRequest:[self activateNewGuestTokenRequest]
                                    completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                        [[self class] validateResponseWithResponse:response
                                                                              data:data
                                                                   connectionError:connectionError
                                                                        completion:^(NSDictionary *responseDict, NSError *guestAuthError) {
                                                                            if (guestAuthError) {
                                                                                completion(nil, guestAuthError);
                                                                                return;
                                                                            }

                                                                            NSDictionary *guestAuthResponseDict = [self guestAuthResponseFromValidationResponseDictionary:responseDict];
                                                                            completion(guestAuthResponseDict, nil);
                                                                        }];
                                    }];
}

#pragma mark - Helpers

- (NSURLRequest *)activateNewGuestTokenRequest
{
    NSURL *activateNewGuestTokenURL = TWTRAPIURLWithPath(self.apiServiceConfig, TWTRGuestAuthTokenPath);
    NSURLRequest *activateNewGuestTokenRequest = [self.appAPIClient URLRequestWithMethod:@"POST" URLString:activateNewGuestTokenURL.absoluteString parameters:nil];
    return activateNewGuestTokenRequest;
}

/**
 *  Prepares the expected guest response dictionary from different sources containing the guest and
 *  auth tokens.
 *
 *  @param validationResponseDict validated response from activating a new guest token
 *
 *  @return dictionary containing both the newly activated guest token and provided app token
 */
- (NSDictionary *)guestAuthResponseFromValidationResponseDictionary:(NSDictionary *)responseDict
{
    NSMutableDictionary *guestAuthResponseDict = [responseDict mutableCopy];
    guestAuthResponseDict[TWTRGuestAuthOAuthTokenKey] = responseDict[TWTRGuestAuthOAuthTokenKey];
    guestAuthResponseDict[TWTRAuthAppOAuthTokenKey] = self.accessToken;
    return guestAuthResponseDict;
}

@end
