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

#pragma mark Twitter API
FOUNDATION_EXTERN NSString *const TWTRTwitterDomain;

#pragma mark - Authentication
FOUNDATION_EXTERN NSString *const TWTRAuthDirectoryLegacyName;
FOUNDATION_EXTERN NSString *const TWTRAuthDirectoryName;
FOUNDATION_EXTERN NSString *const TWTRSDKScheme;
FOUNDATION_EXTERN NSString *const TWTRSDKRedirectHost;

#pragma mark - Paths
FOUNDATION_EXTERN NSString *const TWTRTwitterRequestTokenPath;
FOUNDATION_EXTERN NSString *const TWTRTwitterAuthorizePath;
FOUNDATION_EXTERN NSString *const TWTRTwitterAccessTokenPath;
FOUNDATION_EXTERN NSString *const TWTRAppAuthTokenPath;
FOUNDATION_EXTERN NSString *const TWTRGuestAuthTokenPath;

#pragma mark - OAuth strings
FOUNDATION_EXTERN NSString *const TWTRAuthOAuthTokenKey;
FOUNDATION_EXTERN NSString *const TWTRAuthOAuthSecretKey;
FOUNDATION_EXTERN NSString *const TWTRAuthAppOAuthTokenKey;
FOUNDATION_EXTERN NSString *const TWTRGuestAuthOAuthTokenKey;
FOUNDATION_EXTERN NSString *const TWTRAuthAppOAuthUserIDKey;
FOUNDATION_EXTERN NSString *const TWTRAuthAppOAuthScreenNameKey;
FOUNDATION_EXTERN NSString *const TWTRAuthAppOAuthVerifierKey;
FOUNDATION_EXTERN NSString *const TWTRAuthAppOAuthDeniedKey;
FOUNDATION_EXTERN NSString *const TWTRAuthAppOAuthAppKey;
FOUNDATION_EXTERN NSString *const TWTRAuthAppOAuthCallbackConfirmKey;
FOUNDATION_EXTERN NSString *const TWTRAuthAppOAuthCallbackKey;
FOUNDATION_EXTERN NSString *const TWTRAuthTokenTypeKey;
FOUNDATION_EXTERN NSString *const TWTRAuthTokenKey;
FOUNDATION_EXTERN NSString *const TWTRAuthSecretKey;
FOUNDATION_EXTERN NSString *const TWTRAuthUsernameKey;
FOUNDATION_EXTERN NSString *const TWTRAuthTokenSeparator;

#pragma mark - HTTP Headers
FOUNDATION_EXTERN NSString *const TWTRAuthorizationHeaderField;
FOUNDATION_EXTERN NSString *const TWTRGuestTokenHeaderField;

#pragma mark - Resources
FOUNDATION_EXTERN NSString *const TWTRLoginButtonImageLocation;

#pragma mark - Errors
FOUNDATION_EXTERN NSString *const TWTRMissingAccessTokenMsg;

typedef NS_ENUM(NSInteger, TWTRAuthType) { TWTRAuthTypeApp = 1, TWTRAuthTypeGuest = 2, TWTRAuthTypeUser = 3 };
