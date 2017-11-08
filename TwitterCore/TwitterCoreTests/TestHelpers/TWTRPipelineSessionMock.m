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

#import "TWTRPipelineSessionMock.h"
#import <TwitterCore/TWTRGuestSession.h>
#import <TwitterCore/TWTRSession.h>
#import <TwitterCore/TWTRSessionStore.h>
#import <TwitterCore/TWTRSessionStore_Private.h>

@implementation TWTRPipelineSessionMock

- (TWTRAuthConfig *)authConfig
{
    return [[TWTRAuthConfig alloc] initWithConsumerKey:@"consumer" consumerSecret:@"secret"];
}

- (void)fetchGuestSessionWithCompletion:(TWTRSessionGuestLogInCompletion)completion
{
    self.guestSessionFetchCount += 1;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (completion) {
            completion(self.guestSession, self.error);
        }
    });
}

- (id<TWTRAuthSession>)sessionForUserID:(id<NSCopying>)userID
{
    self.userSessionFetchCount += 1;
    return self.userSession;
}

- (void)refreshSessionClass:(Class)sessionClass sessionID:(id<NSCopying>)sessionID completion:(TWTRSessionStoreRefreshCompletion)completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (completion) {
            completion(self.refreshSession, self.refreshError);
        }
    });
}

- (BOOL)isExpiredSession:(id)session response:(NSHTTPURLResponse *)response
{
    return response.statusCode == 209;
}

- (BOOL)isExpiredSession:(id)session error:(nonnull NSError *)error
{
    return NO;
}

// no ops
- (TWTRSession *)session
{
    return self.userSession;
}
- (void)saveSession:(id<TWTRAuthSession>)session completion:(TWTRSessionStoreSaveCompletion)completion
{
}
- (void)saveSessionWithAuthToken:(NSString *)authToken authTokenSecret:(NSString *)authTokenSecret completion:(TWTRSessionStoreSaveCompletion)completion
{
}
- (NSArray *)existingUserSessions
{
    return @[];
}
- (void)logInWithSystemAccountsCompletion:(TWTRSessionLogInCompletion)completion
{
}
- (void)logOutUserID:(NSString *)userID
{
}
- (BOOL)hasLoggedInUsers
{
    return YES;
}

@end
