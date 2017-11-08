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

#import "TWTRGuestAuthRequestSigner.h"
#import "TWTRAssertionMacros.h"
#import "TWTRAuthConfig.h"
#import "TWTRAuthenticationConstants.h"
#import "TWTRGuestSession.h"

@implementation TWTRGuestAuthRequestSigner

+ (NSURLRequest *)signedURLRequest:(NSURLRequest *)URLRequest session:(TWTRGuestSession *)session
{
    TWTRParameterAssertOrReturnValue(URLRequest && session, nil);

    NSMutableURLRequest *mutableRequest = [URLRequest mutableCopy];
    [mutableRequest setValue:session.guestToken forHTTPHeaderField:TWTRGuestTokenHeaderField];
    NSString *appToken = [NSString stringWithFormat:@"Bearer %@", session.accessToken];
    [mutableRequest setValue:appToken forHTTPHeaderField:TWTRAuthorizationHeaderField];
    return mutableRequest;
}

@end
