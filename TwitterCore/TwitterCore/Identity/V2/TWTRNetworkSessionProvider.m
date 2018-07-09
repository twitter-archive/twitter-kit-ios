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

#import "TWTRNetworkSessionProvider.h"
#import "TWTRAPIConstantsUser.h"
#import "TWTRAPIServiceConfig.h"
#import "TWTRAppAuthProvider.h"
#import "TWTRAppleSocialAuthenticaticationProvider.h"
#import "TWTRAssertionMacros.h"
#import "TWTRAuthConfig.h"
#import "TWTRAuthenticationConstants.h"
#import "TWTRConstants.h"
#import "TWTRDictUtil.h"
#import "TWTRGuestAuthProvider.h"
#import "TWTRGuestSession_Private.h"
#import "TWTRSession.h"
#import "TWTRTokenOnlyAuthSession.h"
#import "TWTRUserAuthRequestSigner.h"

@implementation TWTRNetworkSessionProvider

#if !TARGET_OS_TV

+ (void)userSessionWithAuthConfig:(TWTRAuthConfig *)authConfig APIServiceConfig:(id<TWTRAPIServiceConfig>)APIServiceConfig completion:(TWTRNetworkSessionProviderUserLogInCompletion)completion
{
    TWTRCheckArgumentWithCompletion2(authConfig && APIServiceConfig, completion);

    // Make the completion block retain this variable by using __block
    __block TWTRAppleSocialAuthenticaticationProvider *appleSocialAuthProvider = [[TWTRAppleSocialAuthenticaticationProvider alloc] initWithAuthConfig:authConfig apiServiceConfig:APIServiceConfig];

    [appleSocialAuthProvider authenticateWithCompletion:^(NSDictionary *socialAuthResponseDict, NSError *socialAuthError) {
        appleSocialAuthProvider = nil;  // accessed here to retain it while the action sheet created by it may be visible.

        if (socialAuthError) {
            NSLog(@"[TwitterKit] Unable to authenticate using the system account.");
            [self callUserCompletionWithResponseDict:nil withError:socialAuthError completion:completion];
        } else {
            [self callUserCompletionWithResponseDict:socialAuthResponseDict withError:nil completion:completion];
        }
    }];
}

#endif

+ (void)verifyUserSession:(id<TWTRAuthSession>)userSession withAuthConfig:(TWTRAuthConfig *)authConfig APIServiceConfig:(id<TWTRAPIServiceConfig>)APIServiceConfig URLSession:(NSURLSession *)URLSession completion:(TWTRNetworkSessionProviderUserLogInCompletion)completion
{
    TWTRCheckArgumentWithCompletion2(userSession && authConfig && APIServiceConfig && URLSession, completion);

    NSURL *verifyURL = TWTRAPIURLWithPath(APIServiceConfig, TWTRAPIConstantsVerifyCredentialsURL);
    NSURLRequest *verifyRequest = [NSURLRequest requestWithURL:verifyURL];
    NSURLRequest *signedVerifyRequest = [TWTRUserAuthRequestSigner signedURLRequest:verifyRequest authConfig:authConfig session:userSession];
    NSURLSessionDataTask *verifySessionTask = [URLSession dataTaskWithRequest:signedVerifyRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"[TwitterKit] Cannot verify session credentials.");
            completion(nil, connectionError);
            return;
        }

        completion(userSession, nil);
    }];
    [verifySessionTask resume];
}

+ (void)verifySessionWithAuthToken:(NSString *)authToken authSecret:(NSString *)authTokenSecret withAuthConfig:(TWTRAuthConfig *)authConfig APIServiceConfig:(id<TWTRAPIServiceConfig>)APIServiceConfig URLSession:(NSURLSession *)URLSession completion:(TWTRNetworkSessionProviderUserLogInCompletion)completion
{
    TWTRCheckArgumentWithCompletion2(authToken && authTokenSecret && authConfig && APIServiceConfig && URLSession, completion);

    TWTRTokenOnlyAuthSession *tokenOnlySession = [[TWTRTokenOnlyAuthSession alloc] initWithToken:authToken secret:authTokenSecret];
    NSURL *verifyURL = TWTRAPIURLWithPath(APIServiceConfig, TWTRAPIConstantsVerifyCredentialsURL);
    NSURLRequest *verifyRequest = [NSURLRequest requestWithURL:verifyURL];
    NSURLRequest *signedVerifyRequest = [TWTRUserAuthRequestSigner signedURLRequest:verifyRequest authConfig:authConfig session:tokenOnlySession];
    NSURLSessionDataTask *verifySessionTask = [URLSession dataTaskWithRequest:signedVerifyRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"[TwitterKit] Cannot verify session credentials.");
            completion(nil, connectionError);
            return;
        }

        TWTRSession *userSession = [self userSessionWithAuthToken:authToken authTokenSecret:authTokenSecret fromResponseData:data];

        completion(userSession, nil);
    }];
    [verifySessionTask resume];
}

+ (void)guestSessionWithAuthConfig:(TWTRAuthConfig *)authConfig APIServiceConfig:(id<TWTRAPIServiceConfig>)APIServiceConfig URLSession:(NSURLSession *)URLSession accessToken:(NSString *)accessToken completion:(TWTRNetworkSessionProviderGuestLogInCompletion)completion
{
    TWTRCheckArgumentWithCompletion2(authConfig && APIServiceConfig && URLSession, completion);

    if (accessToken) {
        [TWTRNetworkSessionProvider guestSessionWithAuthConfig:authConfig APIServiceConfig:APIServiceConfig accessToken:accessToken completion:completion];
    } else {
        [TWTRNetworkSessionProvider appSessionWithAuthConfig:authConfig APIServiceConfig:APIServiceConfig completion:^(NSString *appAccessToken, NSError *appAuthError) {
            if (appAccessToken) {
                [TWTRNetworkSessionProvider guestSessionWithAuthConfig:authConfig APIServiceConfig:APIServiceConfig accessToken:appAccessToken completion:completion];
            } else {
                completion(nil, appAuthError);
            }
        }];
    }
}

#pragma mark - Helper

+ (void)callUserCompletionWithResponseDict:(NSDictionary *)dictionary withError:(NSError *)error completion:(TWTRNetworkSessionProviderUserLogInCompletion)completion
{
    TWTRCheckArgumentWithCompletion2(dictionary || error, completion);

    TWTRSession *userSession = [TWTRNetworkSessionProvider sessionWithResponseDict:dictionary];

    if (completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(userSession, error);
        });
    }
}

+ (nullable TWTRSession *)sessionWithResponseDict:(NSDictionary *)dictionary
{
    TWTRSession *userSession = nil;
    if (dictionary) {
        userSession = [[TWTRSession alloc] initWithSessionDictionary:dictionary];
    }
    return userSession;
}

+ (void)appSessionWithAuthConfig:(TWTRAuthConfig *)authConfig APIServiceConfig:(id<TWTRAPIServiceConfig>)APIServiceConfig completion:(TWTRNetworkSessionProviderAppLogInCompletion)completion
{
    TWTRCheckArgumentWithCompletion2(authConfig && APIServiceConfig, completion);

    TWTRAppAuthProvider *appAuthProvider = [[TWTRAppAuthProvider alloc] initWithAuthConfig:authConfig apiServiceConfig:APIServiceConfig];
    [appAuthProvider authenticateWithCompletion:^(NSDictionary *appAuthResponseDict, NSError *appAuthError) {
        NSString *accessToken = nil;
        if (appAuthError == nil) {
            accessToken = appAuthResponseDict[TWTRAuthAppOAuthTokenKey];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(accessToken, appAuthError);
        });
    }];
}

+ (void)guestSessionWithAuthConfig:(TWTRAuthConfig *)authConfig APIServiceConfig:(id<TWTRAPIServiceConfig>)APIServiceConfig accessToken:(NSString *)accessToken completion:(TWTRNetworkSessionProviderGuestLogInCompletion)completion
{
    TWTRCheckArgumentWithCompletion2(authConfig && APIServiceConfig, completion);

    TWTRGuestAuthProvider *guestAuthProvider = [[TWTRGuestAuthProvider alloc] initWithAuthConfig:authConfig apiServiceConfig:APIServiceConfig accessToken:accessToken];
    [guestAuthProvider authenticateWithCompletion:^(NSDictionary *guestResponseDict, NSError *guestAuthError) {
        TWTRGuestSession *guestSession = nil;
        if (guestAuthError == nil) {
            guestSession = [[TWTRGuestSession alloc] initWithSessionDictionary:guestResponseDict creationDate:[NSDate date]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(guestSession, guestAuthError);
        });
    }];
}

+ (void)callGuestCompletion:(TWTRGuestLogInCompletion)completion withSession:(TWTRGuestSession *)session error:(NSError *)error
{
    TWTRCheckArgumentWithCompletion2(session || error, completion);

    if (completion) {
        completion(session, error);
    } else {
        NSLog(@"[%@] Log in guest called without a completion block.", [self class]);
    }
}

+ (nullable TWTRSession *)userSessionWithAuthToken:(NSString *)authToken authTokenSecret:(NSString *)authTokenSecret fromResponseData:(NSData *)responseData
{
    TWTRParameterAssertOrReturnValue(authToken, nil);
    TWTRParameterAssertOrReturnValue(authTokenSecret, nil);
    TWTRParameterAssertOrReturnValue(responseData, nil);

    NSError *jsonError;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
    if (jsonError) {
        return nil;
    } else {
        NSString *const userID = [TWTRDictUtil twtr_stringFromNumberForKey:@"id" inDict:json].copy;
        NSString *const userName = [TWTRDictUtil twtr_stringForKey:@"screen_name" inDict:json].copy;
        TWTRSession *session = [[TWTRSession alloc] initWithAuthToken:authToken authTokenSecret:authTokenSecret userName:userName userID:userID];
        return session;
    }
}

@end
