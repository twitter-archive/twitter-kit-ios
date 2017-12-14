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

#import "TWTRSessionRefreshStrategy.h"
#import "TWTRAPIErrorCode.h"
#import "TWTRAPIServiceConfig.h"
#import "TWTRAssertionMacros.h"
#import "TWTRAuthSession.h"
#import "TWTRGuestSession.h"
#import "TWTRNetworkSessionProvider.h"

@interface TWTRGuestSessionRefreshStrategy ()

/**
 *  Auth config associated with the app.
 */
@property (nonatomic, readonly) TWTRAuthConfig *authConfig;

/**
 *  Access/Bearer token for this guest auth. This token is required to get a `getToken`.
 */
@property (nonatomic, copy) NSString *accessToken;

/**
 *  Service config for configuring endpoints to make auth requests against.
 */
@property (nonatomic, readonly) id<TWTRAPIServiceConfig> APIServiceConfig;

@end

@implementation TWTRGuestSessionRefreshStrategy

#pragma mark - Initialization

- (instancetype)initWithAuthConfig:(TWTRAuthConfig *)authConfig APIServiceConfig:(id<TWTRAPIServiceConfig>)APIServiceConfig
{
    TWTRParameterAssertOrReturnValue(authConfig && APIServiceConfig, nil);

    if (self = [super init]) {
        _authConfig = authConfig;
        _APIServiceConfig = APIServiceConfig;
    }

    return self;
}

#pragma mark - TWTRSessionRefreshStrategy Protocol

+ (NSIndexSet *)expiredStatusCodes
{
    static NSIndexSet *validCodes = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
        [indexes addIndex:TWTRAPIErrorCodeBadGuestToken];
        [indexes addIndex:TWTRAPIErrorCodeInvalidOrExpiredToken];
        validCodes = [indexes copy];
    });

    return validCodes;
}

+ (BOOL)canSupportSessionClass:(Class)sessionClass
{
    return [TWTRGuestSession class] == sessionClass;
}

+ (BOOL)isSessionExpiredBasedOnRequestResponse:(NSHTTPURLResponse *)response
{
    return [[self expiredStatusCodes] containsIndex:response.statusCode];
}

+ (BOOL)isSessionExpiredBasedOnRequestError:(NSError *)error
{
    return [[self expiredStatusCodes] containsIndex:error.code];
}

- (void)refreshSession:(id<TWTRBaseSession>)session URLSession:(NSURLSession *)URLSession completion:(TWTRSessionRefreshCompletion)completion
{
    TWTRParameterAssertOrReturn(completion);
    NSError *parameterError;
    TWTRParameterAssertSettingError(session && URLSession && [TWTRGuestSessionRefreshStrategy canSupportSessionClass:[session class]], &parameterError);
    TWTRParameterAssertSettingError([session isKindOfClass:[TWTRGuestSession class]], &parameterError);

    // Ignoring the provided app-auth token in `session` and active a new set of app+guest tokens to
    // handle cases where we received `TWTRAPIErrorCodeInvalidOrExpiredToken` and the bearer token is
    // no longer be valid. This will incur an extra network request.
    [TWTRNetworkSessionProvider guestSessionWithAuthConfig:self.authConfig APIServiceConfig:self.APIServiceConfig URLSession:URLSession accessToken:nil completion:^(TWTRGuestSession *refreshedGuestSession, NSError *guestSessionRefreshError) {
        if (guestSessionRefreshError) {
            NSLog(@"Guest authentication failed: %@", guestSessionRefreshError);
            NSLog(@"[%@] Your app may not be enabled for guest authentication. Please contact support@fabric.io to upgrade your consumer key.", [self class]);
        }
        completion(refreshedGuestSession, guestSessionRefreshError);
    }];
}

@end
