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
 This header is private to the Twitter Kit SDK and not exposed for public SDK consumption
 */

NS_ASSUME_NONNULL_BEGIN

@class TWTRAuthConfig;

@interface TWTRLoginURLParser : NSObject

/**
 *  Create an instance with a consumer key to use for the
 *  `authRedirectScheme`.
 */
- (instancetype)initWithAuthConfig:(TWTRAuthConfig *)config;

/*
 URL scheme used to redirect back to this app part-way through
 the OAuth authentication flow.

 @note: When using SFSafariViewController, this will be of the form:
 "twitterkit-<Consumer Key>" and must have been set up manually by
 the developer.

 If the URL scheme has not been configured or SFSafariViewController
 is not available (iOS 8), then this will be a constant value of
 "twittersdk" which the TWTRWebView will be looking for.
 */
- (NSString *)authRedirectScheme;

/*
 Determine whether this URL represents a valid redirect URL
 for the Twitter Kit SDK.

  @param url   The URL from the app delegate that the app was
               opened with.
 */
- (BOOL)isTwitterKitRedirectURL:(NSURL *)url;

/*
 * Checks whether app has a valid URL scheme (twitterkit-).
 */
- (BOOL)hasValidURLScheme;

/**
 *  Compares the oauth_token parameter returned from the URL to determine if the url is valid.
 *
 *  Returns YES if the stored stoken matches the token in the url parameter.
 */
- (BOOL)isOauthTokenVerifiedFromURL:(NSURL *)url;

#pragma mark - Mobile SSO

/*
 *  URL to redirect a user to the Twitter App for login.
 */
- (NSURL *)twitterAuthorizeURL;

/*
 *  Whether this URL matches the form of a successful mobile SSO
 *  redirect with authentication key.
 */
- (BOOL)isMobileSSOSuccessURL:(NSURL *)url;

/*
 *  Whether this URL matches the form of a cancelled mobile SSO
 *  redirect with just a scheme and no host or parameters.
 */
- (BOOL)isMobileSSOCancelURL:(NSURL *)url;

/*
 *  The authentication parameters from a mobile SSO
 *  redirect URL.
 */
- (NSDictionary *)parametersForSSOURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
