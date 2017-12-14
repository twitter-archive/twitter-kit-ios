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

#import "TWTRSystemAccountSerializer.h"
#import <Accounts/Accounts.h>
#import <TwitterCore/TWTRAssertionMacros.h>
#import <TwitterCore/TWTRAuthenticationConstants.h>

@implementation TWTRSystemAccountSerializer

+ (void)saveToSystemAccountCredentials:(NSDictionary *)authDict completion:(void (^)(BOOL success, NSError *error))completion
{
    NSString *token = authDict[TWTRAuthOAuthTokenKey];
    NSString *secret = authDict[TWTRAuthOAuthSecretKey];
    NSString *username = authDict[TWTRAuthAppOAuthUserIDKey];
    NSError *parameterError;
    TWTRParameterAssertSettingError(token, &parameterError);
    TWTRParameterAssertSettingError(secret, &parameterError);
    TWTRParameterAssertSettingError(username, &parameterError);
    if (parameterError && completion) {
        completion(NO, parameterError);
        return;
    }

    ACAccountCredential *credential = [[ACAccountCredential alloc] initWithOAuthToken:token tokenSecret:secret];
    ACAccountStore *store = [[ACAccountStore alloc] init];
    ACAccountType *type = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    ACAccount *newSystemAccount = [[ACAccount alloc] initWithAccountType:type];
    newSystemAccount.credential = credential;
    newSystemAccount.username = username;

    [store saveAccount:newSystemAccount withCompletionHandler:completion];
}

@end
