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

#import "TWTROAuthSigning.h"
#import <TwitterCore/TWTRAPIConstantsUser.h>
#import <TwitterCore/TWTRAPIServiceConfig.h>
#import <TwitterCore/TWTRAPIServiceConfigRegistry.h>
#import <TwitterCore/TWTRAssertionMacros.h>
#import <TwitterCore/TWTRAuthConfig.h>
#import <TwitterCore/TWTRAuthenticationConstants.h>
#import <TwitterCore/TWTRCoreOAuthSigning+Private.h>
#import <TwitterCore/TWTRSession.h>

@interface TWTROAuthSigning ()

@property (nonatomic, readonly) TWTRAuthConfig *authConfig;
@property (nonatomic, readonly) TWTRSession *authSession;

@end

@implementation TWTROAuthSigning

- (instancetype)initWithAuthConfig:(TWTRAuthConfig *)authConfig authSession:(TWTRSession *)authSession
{
    TWTRParameterAssertOrReturnValue(authConfig, nil);
    TWTRParameterAssertOrReturnValue(authSession, nil);
    TWTRParameterAssertOrReturnValue(authConfig.consumerKey, nil);
    TWTRParameterAssertOrReturnValue(authConfig.consumerSecret, nil);
    TWTRParameterAssertOrReturnValue(authSession.authToken, nil);
    TWTRParameterAssertOrReturnValue(authSession.authTokenSecret, nil);

    if (self = [super init]) {
        _authConfig = authConfig;
        _authSession = authSession;
    }

    return self;
}

#pragma mark - TWTRCoreOAuthSigning

- (id<TWTRAPIServiceConfig>)APIServiceConfig
{
    return [[TWTRAPIServiceConfigRegistry defaultRegistry] configForType:TWTRAPIServiceConfigTypeDefault];
}

- (NSDictionary *)OAuthEchoHeadersForRequestMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters error:(NSError *__autoreleasing *)error
{
    id<TWTRAPIServiceConfig> config = [self APIServiceConfig];
    return TWTRCoreOAuthSigningOAuthEchoHeaders(self.authConfig, self.authSession, method, URLString, parameters, config.apiHost, error);
}

- (NSDictionary *)OAuthEchoHeadersToVerifyCredentials
{
    NSError *error = nil;
    id<TWTRAPIServiceConfig> config = [self APIServiceConfig];

    NSDictionary *headers = [self OAuthEchoHeadersForRequestMethod:@"GET" URLString:TWTRAPIURLWithPath(config, TWTRAPIConstantsVerifyCredentialsURL).absoluteString parameters:nil error:&error];

    NSParameterAssert(!error);

    if (!headers) {
        // This should never happen, because the only error is un invalid URL, and we control that URL.
        NSLog(@"-[%@ %@] Error generating OAuth Echo Headers: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error);
    }

    return headers;
}

@end
