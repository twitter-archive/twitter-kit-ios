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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString *const TWTROAuthEchoRequestURLStringKey;
FOUNDATION_EXTERN NSString *const TWTROAuthEchoAuthorizationHeaderKey;

@protocol TWTRCoreOAuthSigning <NSObject>

/**
 *  @name OAuth Echo
 */

/**
 *  OAuth Echo is a means to securely delegate OAuth authorization to a third party while interacting with an API.
 *  For example, you may wish to verify a user's credentials from your app's server (the third party) rather than your app.
 *  This method provides you with the OAuth signature to add to the third party's request to `URLString`, as well as the formed
 *  URL with the query string to send that request to.
 *  This is equivalent to calling `-URLRequestWithMethod:URL:parameters:error:` and getting the URL and the `Authorization` HTTP header out of the request.
 *
 *  @param method       Request method, GET, POST, PUT, DELETE, etc.
 *  @param URLString    The full URL of the Twitter endpoint you plan to send a request to. E.g. https://api.twitter.com/1.1/account/verify_credentials.json
 *  @param parameters   Request parameters.
 *  @param error        Error in the `TWTRErrorDomain` domain. The code will be `TWTRErrorCodeInvalidURL` if the `URLString`'s host is not api.twitter.com
 *
 *  @return `nil` if there's an error or a missing required parameter, or a dictionary with the fully formed request URL under `TWTROAuthEchoRequestURLStringKey` (`NSString`), and the `Authorization` header in `TWTROAuthEchoAuthorizationHeaderKey` (`NSString`), to be used to sign the request.
 *
 *  @see More information about OAuth Echo: https://dev.twitter.com/oauth/echo
 */
- (NSDictionary *)OAuthEchoHeadersForRequestMethod:(NSString *)method URLString:(NSString *)URLString parameters:(nullable NSDictionary *)parameters error:(NSError **)error;

/**
 *  This method provides you with the OAuth signature, as well as the formed URL with the query string, to send a request to `verify_credentials`.
 *
 *  @return A dictionary with the fully formed Request URL under `TWTROAuthEchoRequestURLStringKey` (`NSString`), and the `Authorization` header in `TWTROAuthEchoAuthorizationHeaderKey` (`NSString`), to be used to sign the request.
 *
 *  @see More information about OAuth Echo: https://dev.twitter.com/oauth/echo
 *  @see More information about Verify Credentials: https://dev.twitter.com/rest/reference/get/account/verify_credentials
 */
- (NSDictionary *)OAuthEchoHeadersToVerifyCredentials;

@end

NS_ASSUME_NONNULL_END
