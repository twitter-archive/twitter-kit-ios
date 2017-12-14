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

#import "TWTRErrors.h"
#import <TwitterCore/TWTRConstants.h>

@implementation TWTRErrors

+ (NSError *)mobileSSOCancelError
{
    return [[NSError alloc] initWithDomain:TWTRLogInErrorDomain code:TWTRLogInErrorCodeCancelled userInfo:@{NSLocalizedDescriptionKey: @"User cancelled login from Twitter App"}];
}

+ (NSError *)invalidSourceApplicationError
{
    return [[NSError alloc] initWithDomain:TWTRLogInErrorDomain code:TWTRLogInErrorCodeFailed userInfo:@{NSLocalizedDescriptionKey: @"Authentication was made from an invalid application."}];
}

+ (NSError *)noTwitterAppError
{
    return [[NSError alloc] initWithDomain:TWTRLogInErrorDomain code:TWTRLoginErrorNoTwitterApp userInfo:@{NSLocalizedDescriptionKey: @"No Twitter App installed. Unable to perform Mobile SSO login flow."}];
}

+ (NSError *)webCancelError
{
    return [[NSError alloc] initWithDomain:TWTRLogInErrorDomain code:TWTRLogInErrorCodeCancelled userInfo:@{NSLocalizedDescriptionKey: @"User cancelled login flow."}];
}

+ (NSError *)noAccountsError
{
    return [[NSError alloc] initWithDomain:TWTRErrorDomain code:TWTRLogInErrorCodeNoAccounts userInfo:@{NSLocalizedDescriptionKey: @"Composer created without any logged in Twitter accounts."}];
}

@end
