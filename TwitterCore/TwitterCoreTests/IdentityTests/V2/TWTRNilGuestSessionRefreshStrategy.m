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

#import "TWTRNilGuestSessionRefreshStrategy.h"
#import "TWTRAPIErrorCode.h"
#import "TWTRGuestSession.h"

@implementation TWTRNilGuestSessionRefreshStrategy

+ (BOOL)canSupportSessionClass:(Class)sessionClass
{
    return [TWTRGuestSession class] == sessionClass;
}

+ (BOOL)isSessionExpiredBasedOnRequestResponse:(NSHTTPURLResponse *)response
{
    return response.statusCode == TWTRAPIErrorCodeInvalidOrExpiredToken || response.statusCode == TWTRAPIErrorCodeBadGuestToken;
}

+ (BOOL)isSessionExpiredBasedOnRequestError:(NSError *)responseError
{
    return responseError.code == TWTRAPIErrorCodeInvalidOrExpiredToken || responseError.code == TWTRAPIErrorCodeBadGuestToken;
}

- (void)refreshSession:(id)session URLSession:(NSURLSession *)URLSession completion:(TWTRSessionRefreshCompletion)completion
{
    NSError *error = [NSError errorWithDomain:@"domain" code:0 userInfo:@{}];
    completion(nil, error);
}

@end
