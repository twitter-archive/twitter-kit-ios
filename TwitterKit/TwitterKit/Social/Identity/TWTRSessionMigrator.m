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

#import "TWTRSessionMigrator.h"
#import <TwitterCore/TWTRAssertionMacros.h>
#import <TwitterCore/TWTRAuthenticator.h>
#import <TwitterCore/TWTRGuestSession.h>
#import <TwitterCore/TWTRSession.h>
#import <TwitterCore/TWTRSessionStore.h>
#import <TwitterCore/TWTRSessionStore_Private.h>

@implementation TWTRSessionMigrator

- (void)runMigrationWithDestination:(id<TWTRSessionStore>)store removeOnSuccess:(BOOL)removeOnSuccess
{
    [self migrateUserSessionsIntoStore:store removeOnSuccess:removeOnSuccess];
}

- (void)migrateUserSessionsIntoStore:(id<TWTRSessionStore>)store removeOnSuccess:(BOOL)removeOnSuccess
{
    TWTRParameterAssertOrReturn(store);

    NSDictionary *sessionDict = [self authenticatorUserSessionDictionary];

    if (sessionDict == nil) {
        return;
    }

    TWTRSession *session = [[TWTRSession alloc] initWithSessionDictionary:sessionDict];

    void (^completion)(id<TWTRAuthSession>, NSError *) = ^(id<TWTRAuthSession> savedSession, NSError *error) {
        if (error == nil) {
            if (removeOnSuccess) {
                [self logoutAuthenticatorUser];
            }
        }
    };

    if ([store conformsToProtocol:@protocol(TWTRUserSessionStore_Private)]) {
        [(id<TWTRUserSessionStore_Private>)store saveSession:session withVerification:NO completion:completion];
    } else {
        [store saveSession:session completion:completion];
    }
}

- (void)removeDeprecatedSessions
{
    [self logoutAuthenticatorUser];
}

- (void)logoutAuthenticatorUser
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [TWTRAuthenticator logoutAuthType:TWTRAuthTypeUser];
#pragma clang diagnostic pop
}

- (NSDictionary *)authenticatorUserSessionDictionary
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [TWTRAuthenticator authenticationResponseForAuthType:TWTRAuthTypeUser];
    ;
#pragma clang diagnostic pop
}

@end
