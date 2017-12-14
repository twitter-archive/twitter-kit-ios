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

#import "TWTRAuthConfigSessionsValidator.h"
#import "TWTRAssertionMacros.h"
#import "TWTRAuthConfig.h"
#import "TWTRAuthConfigStore.h"
#import "TWTRAuthSession.h"
#import "TWTRSessionStore.h"
#import "TWTRSessionStore_Private.h"

@interface TWTRAuthConfigSessionsValidator ()

@property (nonatomic, readonly) TWTRAuthConfigStore *configStore;
@property (nonatomic, readonly) id<TWTRSessionStore_Private> sessionStore;

@end

@implementation TWTRAuthConfigSessionsValidator

- (instancetype)initWithConfigStore:(TWTRAuthConfigStore *)configStore sessionStore:(id<TWTRSessionStore_Private>)sessionStore
{
    TWTRParameterAssertOrReturnValue(configStore, nil);
    TWTRParameterAssertOrReturnValue(sessionStore, nil);

    self = [super init];
    if (self) {
        _configStore = configStore;
        _sessionStore = sessionStore;
    }
    return self;
}

- (void)validateSessionStoreContainsValidAuthConfig;
{
    if ([self doesSessionStoreNeedPurge]) {
        [self purgeSessionsFromSessionStore];
    }
    [self.configStore saveAuthConfig:self.sessionStore.authConfig];
}

- (BOOL)doesSessionStoreNeedPurge
{
    TWTRAuthConfig *lastConfig = [self.configStore lastSavedAuthConfig];

    if (lastConfig && ![lastConfig isEqual:self.sessionStore.authConfig]) {
        return YES;
    }
    return NO;
}

- (void)purgeSessionsFromSessionStore
{
    NSLog(@"The application's consumer key or consumer secret has changed since the last launch. Any saved user sessions will be purged from the system because they will no longer work with the current key and secret. User's will need to log in again");
    self.sessionStore.guestSession = nil;

    // Need to copy the sessions so we don't mutate the underlying data structure.
    NSArray *sessions = [[self.sessionStore existingUserSessions] copy];

    for (id<TWTRAuthSession> session in sessions) {
        [self.sessionStore logOutUserID:session.userID];
    }
}

@end
