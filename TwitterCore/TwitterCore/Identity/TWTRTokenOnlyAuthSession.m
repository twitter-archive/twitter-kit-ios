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

#import "TWTRTokenOnlyAuthSession.h"
#import <TwitterCore/TWTRAssertionMacros.h>

static NSString *const TWTRTokenOnlyAuthSessionTokenKey = @"authToken";
static NSString *const TWTRTokenOnlyAuthSessionSecretKey = @"authTokenSecret";

@implementation TWTRTokenOnlyAuthSession

- (instancetype)initWithToken:(NSString *)authToken secret:(NSString *)authTokenSecret
{
    TWTRParameterAssertOrReturnValue(authToken, nil);
    TWTRParameterAssertOrReturnValue(authTokenSecret, nil);

    self = [super init];
    if (self) {
        _authToken = [authToken copy];
        _authTokenSecret = [authTokenSecret copy];
        _userID = @"";
    }
    return self;
}

+ (instancetype)authSessionWithToken:(NSString *)authToken secret:(NSString *)authTokenSecret
{
    return [[self alloc] initWithToken:authToken secret:authTokenSecret];
}

#pragma mark - NSCoding
- (id)initWithCoder:(NSCoder *)coder
{
    NSString *token = [coder decodeObjectForKey:TWTRTokenOnlyAuthSessionTokenKey] ?: @"";
    NSString *secret = [coder decodeObjectForKey:TWTRTokenOnlyAuthSessionSecretKey] ?: @"";
    return [self initWithToken:token secret:secret];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.authToken forKey:TWTRTokenOnlyAuthSessionTokenKey];
    [coder encodeObject:self.authTokenSecret forKey:TWTRTokenOnlyAuthSessionSecretKey];
}

@end
