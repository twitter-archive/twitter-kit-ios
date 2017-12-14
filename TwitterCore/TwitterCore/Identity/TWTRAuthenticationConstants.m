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

#import "TWTRAuthenticationConstants.h"

#pragma mark Twitter API
NSString *const TWTRTwitterDomain = @"twitter.com";

#pragma mark - Authentication
// DO NOT CHANGE THESE VALUES, IT WILL LOG USERS OUT.
NSString *const TWTRAuthDirectoryLegacyName = @"twttrauthentication";
NSString *const TWTRAuthDirectoryName = @"TWTRauthentication";

NSString *const TWTRSDKScheme = @"twittersdk";
NSString *const TWTRSDKRedirectHost = @"callback";

#pragma mark - Paths
NSString *const TWTRTwitterRequestTokenPath = @"/oauth/request_token";
NSString *const TWTRTwitterAuthorizePath = @"/oauth/authorize";
NSString *const TWTRTwitterAccessTokenPath = @"/oauth/access_token";
NSString *const TWTRAppAuthTokenPath = @"/oauth2/token";
NSString *const TWTRGuestAuthTokenPath = @"/1.1/guest/activate.json";

#pragma mark - OAuth strings
NSString *const TWTRAuthOAuthTokenKey = @"oauth_token";
NSString *const TWTRAuthOAuthSecretKey = @"oauth_token_secret";
NSString *const TWTRAuthAppOAuthTokenKey = @"access_token";
NSString *const TWTRGuestAuthOAuthTokenKey = @"guest_token";
NSString *const TWTRAuthAppOAuthUserIDKey = @"user_id";
NSString *const TWTRAuthAppOAuthScreenNameKey = @"screen_name";
NSString *const TWTRAuthAppOAuthVerifierKey = @"oauth_verifier";
NSString *const TWTRAuthAppOAuthDeniedKey = @"denied";
NSString *const TWTRAuthAppOAuthAppKey = @"app";
NSString *const TWTRAuthAppOAuthCallbackConfirmKey = @"oauth_callback_confirmed";
NSString *const TWTRAuthAppOAuthCallbackKey = @"oauth_callback";
NSString *const TWTRAuthTokenTypeKey = @"token_type";
NSString *const TWTRAuthTokenKey = @"token";
NSString *const TWTRAuthSecretKey = @"secret";
NSString *const TWTRAuthUsernameKey = @"username";
NSString *const TWTRAuthTokenSeparator = @"-";

#pragma mark - HTTP Headers
NSString *const TWTRAuthorizationHeaderField = @"Authorization";
NSString *const TWTRGuestTokenHeaderField = @"x-guest-token";

#pragma mark - Resources
NSString *const TWTRLoginButtonImageLocation = @"TWTR-sign-in-with-twitter.png";

#pragma mark - Errors
NSString *const TWTRMissingAccessTokenMsg = @"Missing access token";
