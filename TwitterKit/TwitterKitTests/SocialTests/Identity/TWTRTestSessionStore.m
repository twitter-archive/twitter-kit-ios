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

#import "TWTRTestSessionStore.h"
#import <TwitterCore/TWTRAuthSession.h>
#import <TwitterCore/TWTRGuestSession.h>
#import <TwitterCore/TWTRSession.h>

@interface TWTRTestSessionStore ()

@property (nonatomic) NSMutableDictionary *userSessions;

@end

@implementation TWTRTestSessionStore

// Just to comform to the protocol
@synthesize authConfig = _authConfig;
@synthesize guestSession = _guestSession;

- (instancetype)initWithUserSessions:(NSArray *)userSessions guestSession:(TWTRGuestSession *)guestSession
{
    if (self = [super init]) {
        _authConfig = [[TWTRAuthConfig alloc] initWithConsumerKey:@"consumer" consumerSecret:@"secret"];
        _userSessions = [NSMutableDictionary dictionary];
        for (id<TWTRAuthSession> session in userSessions) {
            _userSessions[session.userID] = session;
        }
        _guestSession = guestSession;
    }

    return self;
}

#pragma mark - TWTRSessionRefresingStore

- (void)refreshSessionClass:(Class)sessionClass sessionID:(NSString *)sessionID completion:(TWTRSessionStoreRefreshCompletion)completion
{
    if (sessionClass == [TWTRGuestSession class]) {
        completion(self.guestSession, nil);
    } else {
        completion(self.userSessions[sessionID], nil);
    }
}

- (BOOL)isExpiredSession:(id)session response:(NSHTTPURLResponse *)response
{
    return NO;
}

- (BOOL)isExpiredSession:(id)session error:(NSError *)error
{
    return NO;
}

#pragma mark - TWTRUserSessionStore

- (void)saveSession:(id<TWTRAuthSession>)session completion:(TWTRSessionStoreSaveCompletion)completion
{
    [self saveSession:session withVerification:YES completion:completion];
}

- (void)saveSession:(id<TWTRAuthSession>)session withVerification:(BOOL)withVerification completion:(TWTRSessionStoreSaveCompletion)completion
{
    if (self.overrideUserSaveError) {
        completion(nil, self.overrideUserSaveError);
    } else {
        self.userSessions[session.userID] = session;
        completion(session, nil);
    }
}

- (void)saveSessionWithAuthToken:(NSString *)authToken authTokenSecret:(NSString *)authTokenSecret completion:(TWTRSessionStoreSaveCompletion)completion
{
    if (self.overrideUserSaveError) {
        completion(nil, self.overrideUserSaveError);
    } else {
        for (id<TWTRAuthSession> session in self.userSessions) {
            if ([session.authToken isEqualToString:authToken]) {
                completion(session, nil);
                return;
            }
        }

        NSError *notFoundError = [NSError errorWithDomain:@"domain" code:-1 userInfo:@{ NSLocalizedDescriptionKey: @"not found" }];
        completion(nil, notFoundError);
    }
}

- (id<TWTRAuthSession>)sessionForUserID:(NSString *)userID
{
    return self.userSessions[userID];
}

- (NSArray *)existingUserSessions
{
    return [self.userSessions allValues];
}

- (BOOL)hasLoggedInUsers
{
    return ([self existingUserSessions].count > 0);
}

- (id<TWTRAuthSession>)session
{
    return [[self.userSessions allValues] lastObject];
}

- (void)logInWithSystemAccountsCompletion:(TWTRSessionLogInCompletion)completion
{
    if ([[self.userSessions allValues] count] > 0) {
        completion([[self.userSessions allValues] lastObject], nil);
    } else {
        NSError *loginError = [NSError errorWithDomain:@"domain" code:1 userInfo:@{ NSLocalizedDescriptionKey: @"auth error" }];
        completion(nil, loginError);
    }
}

- (void)logOutUserID:(NSString *)userID
{
    [self.userSessions removeObjectForKey:userID];
}

#pragma mark - TWTRGuestSessionStore

- (void)fetchGuestSessionWithCompletion:(TWTRSessionGuestLogInCompletion)completion
{
    if (self.guestSession) {
        completion(self.guestSession, nil);
    } else {
        NSError *notFoundError = [NSError errorWithDomain:@"domain" code:1 userInfo:@{ NSLocalizedDescriptionKey: @"cannot auth" }];
        completion(nil, notFoundError);
    }
}

@end
