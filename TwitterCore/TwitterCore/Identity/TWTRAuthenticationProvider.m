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

#import "TWTRAuthenticationProvider.h"
#import "TWTRConstants.h"

@implementation TWTRAuthenticationProvider

- (void)authenticateWithCompletion:(TWTRAuthenticationProviderCompletion)completion
{
    // Default implementation does nothing
}

+ (void)validateResponseWithResponse:(NSURLResponse *)response data:(NSData *)data connectionError:(NSError *)connectionError completion:(TWTRAuthenticationProviderCompletion)completion
{
    if (connectionError) {
        completion(nil, connectionError);
        return;
    }

    NSError *jsonError;
    id json;
    if (data) {
        json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
    }
    if (jsonError) {
        completion(nil, jsonError);
        return;
    }

    if (![json isKindOfClass:[NSDictionary class]]) {
        jsonError = [NSError errorWithDomain:TWTRLogInErrorDomain code:1 userInfo:@{ NSLocalizedDescriptionKey: @"Unexpected JSON Response: Top level json entity not an object" }];
        completion(nil, jsonError);
        return;
    }

    completion(json, nil);
}

@end
