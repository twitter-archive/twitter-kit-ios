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

#import "TWTRAuthenticator.h"
#import <TwitterCore/TWTRAssertionMacros.h>
#import "TWTRAuthenticationConstants.h"
#import "TWTRAuthenticationProvider.h"
#import "TWTRCoreConstants.h"
#import "TWTRFileManager.h"
#import "TWTRKeychainWrapper.h"

@implementation TWTRAuthenticator

#pragma mark - Authentication Response

+ (NSDictionary *)authenticationResponseForAuthType:(TWTRAuthType)authType
{
    TWTRKeychainWrapper *wrapper = [self keychainWrapperForAuthType:authType];
    NSString *keychainValue = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    if ([keychainValue length] == 0) {
        return nil;
    }

    NSMutableDictionary *authResponse = [[self readAuthDirectoryForAuthType:authType] mutableCopy];
    if (authResponse == nil) {
        return nil;
    }
    if (authType == TWTRAuthTypeUser) {
        authResponse[TWTRAuthOAuthSecretKey] = keychainValue;
    } else if (authType == TWTRAuthTypeGuest) {
        NSArray *keychainValueParts = [keychainValue componentsSeparatedByString:@":"];
        authResponse[TWTRAuthAppOAuthTokenKey] = keychainValueParts[0];
        authResponse[TWTRGuestAuthOAuthTokenKey] = keychainValueParts[1];
    } else {
        authResponse[TWTRAuthAppOAuthTokenKey] = keychainValue;
    }
    return authResponse;
}

#pragma mark - Logout

+ (void)logoutAuthType:(TWTRAuthType)authType
{
    TWTRKeychainWrapper *wrapper = [self keychainWrapperForAuthType:authType];
    [wrapper resetKeychainItem];
}

#pragma mark - Helpers

/* Auth Dict:
 {
    "oauth_token" = "1234-abc";
    "oauth_token_secret" = oinfalskdfj;
    "screen_name" = abc;
    "user_id" = 1234;
 }
 */
+ (BOOL)saveAuthenticationWithDictionary:(NSDictionary *)authDict forAuthType:(TWTRAuthType)authType error:(NSError *__autoreleasing *)error
{
    NSError *parameterError;
    TWTRParameterAssertSettingError(authDict, &parameterError);
    TWTRParameterAssertSettingError(authDict, &parameterError);
    if (parameterError) {
        if (error != NULL) {
            *error = parameterError;
        }
        return NO;
    }

    NSMutableDictionary *authResponse = [authDict mutableCopy];
    NSString *keychainValue;
    if (authType == TWTRAuthTypeUser) {
        keychainValue = authResponse[TWTRAuthOAuthSecretKey];
        authResponse[TWTRAuthOAuthSecretKey] = @"";
    } else if (authType == TWTRAuthTypeGuest) {
        keychainValue = [NSString stringWithFormat:@"%@:%@", authResponse[TWTRAuthAppOAuthTokenKey], authResponse[TWTRGuestAuthOAuthTokenKey]];
    } else {
        keychainValue = authResponse[TWTRAuthAppOAuthTokenKey];
    }
    TWTRKeychainWrapper *wrapper = [self keychainWrapperForAuthType:authType];
    BOOL keychainSuccess = [wrapper setObject:keychainValue forKey:(__bridge id)(kSecValueData)];
    if (!keychainSuccess) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:TWTRErrorDomain code:TWTRErrorCodeKeychainSerializationFailure userInfo:@{ NSLocalizedDescriptionKey: @"Failed to save OAuth secret to keychain." }];
        }
        return NO;
    }

    NSURL *cachesDirectory = [TWTRFileManager cacheDirectory];
    NSURL *directory = [cachesDirectory URLByAppendingPathComponent:TWTRAuthDirectoryName isDirectory:YES];
    BOOL diskSuccess = [TWTRFileManager writeDictionary:authResponse toFileName:[self authPlistFilenameForAuthType:authType] inDirectory:directory];
    if (!diskSuccess) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:TWTRErrorDomain code:TWTRErrorCodeDiskSerializationError userInfo:@{ NSLocalizedDescriptionKey: @"Failed to save auth response to disk." }];
        }
        return NO;
    }

    return YES;
}

+ (TWTRKeychainWrapper *)keychainWrapperForAuthType:(TWTRAuthType)authType
{
    NSString *account = [self keychainAccountStringForAuthType:authType];
    // the account and service uniquely identify a keychain item
    TWTRKeychainWrapper *wrapper = [[TWTRKeychainWrapper alloc] initWithAccount:account service:TWTRKeychainServiceString accessGroup:nil];
    return wrapper;
}

+ (NSDictionary *)readAuthDirectoryForAuthType:(TWTRAuthType)authType
{
    NSURL *cachesDirectory = [TWTRFileManager cacheDirectory];
    NSURL *directory = [cachesDirectory URLByAppendingPathComponent:TWTRAuthDirectoryName isDirectory:YES];
    NSDictionary *dictionaryFromFile = [TWTRFileManager readDictionaryFromFileName:[self authPlistFilenameForAuthType:authType] inDirectory:directory];

    // In 1.7 we accidentally changed the dictionary name logging out the users. Bug found in 1.8.
    // Reverting the dictionary name would yet again log out all those 1.7+ users.
    // We will default look ups on the new name, but also fallback to the legacy name for those 1.7- users.
    if (dictionaryFromFile == nil) {
        directory = [cachesDirectory URLByAppendingPathComponent:TWTRAuthDirectoryLegacyName isDirectory:YES];
        dictionaryFromFile = [TWTRFileManager readDictionaryFromFileName:[self authPlistFilenameForAuthType:authType] inDirectory:directory];
    }

    return dictionaryFromFile;
}

#pragma mark - Authentication Types

static NSString *const TWTRAuthTypeKeyUser = @"user_auth";
static NSString *const TWTRAuthTypeKeyApp = @"app_auth";
static NSString *const TWTRAuthTypeKeyGuest = @"guest_auth";
static NSString *const TWTRKeychainServiceString = @"api.twitter.com";

+ (NSString *)authTypeStringForAuthType:(TWTRAuthType)authType
{
    switch (authType) {
        case TWTRAuthTypeApp:
            return TWTRAuthTypeKeyApp;
        case TWTRAuthTypeGuest:
            return TWTRAuthTypeKeyGuest;
        case TWTRAuthTypeUser:
            return TWTRAuthTypeKeyUser;
    }

    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unknown auth type value provided" userInfo:nil];
}

+ (NSString *)keychainAccountStringForAuthType:(TWTRAuthType)authType
{
    // This string can't change for backwards compatibility reasons
    static NSString *const TWTRKeychainNamespace = @"com.twitter.sdk.ios";

    return [NSString stringWithFormat:@"%@.%@.%@", TWTRKeychainNamespace, @"keychain", [self authTypeStringForAuthType:authType]];
}

+ (NSString *)authPlistFilenameForAuthType:(TWTRAuthType)authType
{
    return [NSString stringWithFormat:@"%@.plist", [self authTypeStringForAuthType:authType]];
}

@end
