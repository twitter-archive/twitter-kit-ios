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

#import "TWTRAssertionMacros.h"
#import "TWTRAuthConfig.h"
#import "TWTRAuthSession.h"
#import "TWTRGCOAuth.h"
#import "TWTROAuth1aAuthRequestSigner.h"

@implementation TWTROAuth1aAuthRequestSigner

+ (NSURLRequest *)signedURLRequest:(NSURLRequest *)URLRequest authConfig:(TWTRAuthConfig *)authConfig session:(id<TWTRAuthSession>)session
{
    TWTRParameterAssertOrReturnValue(URLRequest, nil);
    TWTRParameterAssertOrReturnValue(authConfig, nil);
    TWTRParameterAssertOrReturnValue(session, nil);

    return [TWTRGCOAuth URLRequestFromRequest:URLRequest consumerKey:authConfig.consumerKey consumerSecret:authConfig.consumerSecret accessToken:session.authToken tokenSecret:session.authTokenSecret];
}

@end
