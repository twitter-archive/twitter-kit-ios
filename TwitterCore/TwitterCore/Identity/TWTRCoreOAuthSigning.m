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

#import "TWTRCoreOAuthSigning.h"
#import "TWTRAuthConfig.h"
#import "TWTRAuthSession.h"
#import "TWTRAuthenticationConstants.h"
#import "TWTRConstants.h"
#import "TWTRGCOAuth.h"

NSString *const TWTROAuthEchoRequestURLStringKey = @"X-Auth-Service-Provider";
NSString *const TWTROAuthEchoAuthorizationHeaderKey = @"X-Verify-Credentials-Authorization";

NSDictionary *TWTRCoreOAuthSigningOAuthEchoHeaders(TWTRAuthConfig *authConfig, id<TWTRAuthSession> authSession, NSString *requestMethod, NSString *URLString, NSDictionary *parameters, NSString *expectedAPIHost, NSError **error)
{
    NSCParameterAssert(requestMethod);
    NSCParameterAssert(URLString);
    NSCParameterAssert(expectedAPIHost);

    if (!requestMethod || !URLString) {
        return nil;
    }

    NSURL *URL = [NSURL URLWithString:URLString];

    const BOOL URLIsRightAPIHost = [URL.host isEqualToString:expectedAPIHost];

    if (!URLIsRightAPIHost) {
        if (error) {
            *error = [NSError errorWithDomain:TWTRErrorDomain code:TWTRErrorCodeInvalidURL userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The provided URL's host is not valid. Expected \"%@\"", expectedAPIHost] }];
        }

        return nil;
    }

    NSURLRequest *echoRequest = [TWTRGCOAuth URLRequestForPath:URL.path HTTPMethod:requestMethod parameters:parameters scheme:URL.scheme host:URL.host consumerKey:authConfig.consumerKey consumerSecret:authConfig.consumerSecret accessToken:authSession.authToken tokenSecret:authSession.authTokenSecret];
    return @{TWTROAuthEchoRequestURLStringKey: echoRequest.URL.absoluteString, TWTROAuthEchoAuthorizationHeaderKey: echoRequest.allHTTPHeaderFields[TWTRAuthorizationHeaderField]};
}
