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

#import "TWTRSession.h"
#import "TWTRAssertionMacros.h"
#import "TWTRAuthenticationConstants.h"
#import "TWTRSession_Private.h"

@implementation TWTRSession

- (instancetype)initWithSessionDictionary:(NSDictionary *)authDictionary
{
    TWTRParameterAssertOrReturnValue(authDictionary, nil);

    NSString *authToken = authDictionary[TWTRAuthOAuthTokenKey];
    NSString *authTokenSecret = authDictionary[TWTRAuthOAuthSecretKey];
    NSString *userName = authDictionary[TWTRAuthAppOAuthScreenNameKey];
    NSString *userID = authDictionary[TWTRAuthAppOAuthUserIDKey];

    return [self initWithAuthToken:authToken authTokenSecret:authTokenSecret userName:userName userID:userID];
}

- (instancetype)initWithSSOResponse:(NSDictionary *)authDictionary
{
    TWTRParameterAssertOrReturnNil(authDictionary);

    NSString *authToken = authDictionary[TWTRAuthTokenKey];
    NSString *authTokenSecret = authDictionary[TWTRAuthSecretKey];
    NSString *userName = authDictionary[TWTRAuthUsernameKey];
    NSString *userID = [[authToken componentsSeparatedByString:TWTRAuthTokenSeparator] firstObject];

    return [self initWithAuthToken:authToken authTokenSecret:authTokenSecret userName:userName userID:userID];
}

- (instancetype)initWithAuthToken:(NSString *)authToken authTokenSecret:(NSString *)authTokenSecret userName:(NSString *)userName userID:(NSString *)userID
{
    TWTRParameterAssertOrReturnValue(authToken, nil);
    TWTRParameterAssertOrReturnValue(authTokenSecret, nil);
    TWTRParameterAssertOrReturnValue(userName, nil);
    TWTRParameterAssertOrReturnValue(userID, nil);

    self = [super init];
    if (self) {
        _authToken = [authToken copy];
        _authTokenSecret = [authTokenSecret copy];
        _userName = [userName copy];
        _userID = [userID copy];
    }
    return self;
}

+ (BOOL)isValidSessionDictionary:(NSDictionary *)dictionary
{
    BOOL (^isValidKey)(NSString *) = ^BOOL(NSString *key) {
        NSString *obj = dictionary[key];
        return ([obj isKindOfClass:[NSString class]] && obj.length > 0);
    };

    NSArray *keys = @[TWTRAuthOAuthTokenKey, TWTRAuthOAuthSecretKey, TWTRAuthAppOAuthScreenNameKey, TWTRAuthAppOAuthUserIDKey];

    for (NSString *key in keys) {
        if (!isValidKey(key)) {
            return NO;
        }
    }
    return YES;
}

- (NSDictionary *)dictionaryRepresentation
{
    return @{TWTRAuthOAuthTokenKey: self.authToken, TWTRAuthOAuthSecretKey: self.authTokenSecret, TWTRAuthAppOAuthScreenNameKey: self.userName, TWTRAuthAppOAuthUserIDKey: self.userID};
}

#pragma mark - NSCoding
- (id)initWithCoder:(NSCoder *)coder
{
    NSString *authToken = [coder decodeObjectForKey:TWTRAuthOAuthTokenKey];
    NSString *authTokenSecret = [coder decodeObjectForKey:TWTRAuthOAuthSecretKey];
    NSString *userName = [coder decodeObjectForKey:TWTRAuthAppOAuthScreenNameKey];
    NSString *userID = [coder decodeObjectForKey:TWTRAuthAppOAuthUserIDKey];

    return [self initWithAuthToken:authToken authTokenSecret:authTokenSecret userName:userName userID:userID];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.authToken forKey:TWTRAuthOAuthTokenKey];
    [coder encodeObject:self.authTokenSecret forKey:TWTRAuthOAuthSecretKey];
    [coder encodeObject:self.userName forKey:TWTRAuthAppOAuthScreenNameKey];
    [coder encodeObject:self.userID forKey:TWTRAuthAppOAuthUserIDKey];
}

#pragma mark - NSObject
- (NSUInteger)hash
{
    return [self.authToken hash] ^ [self.authTokenSecret hash];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[TWTRSession class]]) {
        return [self isEqualToSession:object];
    } else {
        return NO;
    }
}

- (BOOL)isEqualToSession:(TWTRSession *)otherSession
{
    return [self.authToken isEqualToString:otherSession.authToken] && [self.authTokenSecret isEqualToString:otherSession.authTokenSecret] && [self.userName isEqualToString:otherSession.userName] && [self.userID isEqualToString:otherSession.userID];
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"<TWTRSession> %@ - %@", self.userName, self.userID];
}

@end
