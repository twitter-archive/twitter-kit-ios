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

// TODO: this is temporary. clean up after refactoring scribe layer
#import <TwitterCore/TWTRSessionStore.h>
#import "TWTRScribeService.h"

@class TWTRAuthConfig;
@protocol TWTRAPIServiceConfig;
@protocol TWTRRefreshStrategies;

NS_ASSUME_NONNULL_BEGIN

typedef void (^TWTRSessionStoreLogoutHook)(NSString *userID);

/**
 *  Completion block called when login succeeds or fails.
 *
 *  @param session Contains the OAuth tokens and minimal information associated with the logged in user or nil.
 *  @param error   Error that will be non nil if the authentication request fails.
 */
typedef void (^TWTRSessionLogInCompletion)(id<TWTRAuthSession> _Nullable session, NSError *_Nullable error);

typedef void (^TWTRSessionStoreUserSessionSavedCompletion)(id<TWTRAuthSession> session);

@protocol TWTRUserSessionStore_Private <TWTRSessionStore>

/**
 *  Saves the existing session to the store after validations.
 *
 *  @param session          The user session to save
 *  @param withVerification Whether to verify against the backend before saving this session
 *  @param completion       Completion block to call when the save request succeeds or fails
 */
- (void)saveSession:(id<TWTRAuthSession>)session withVerification:(BOOL)withVerification completion:(TWTRSessionStoreSaveCompletion)completion;

/**
 *  Triggers user authentication with Twitter.
 *
 *  @param completion Completion block to call when authentication succeeds or fails.
 */
- (void)logInWithSystemAccountsCompletion:(TWTRSessionLogInCompletion)completion __TVOS_UNAVAILABLE;

@end

@protocol TWTRSessionStore_Private <TWTRUserSessionStore_Private>

/**
 *  The current guest session.
 *
 *  @note This might not always reflect the latest state of the guest session. Use `fetchGuestSessionWithCompletion:` to get the latest guest session.
 */
@property (nonatomic, readwrite, nullable) TWTRGuestSession *guestSession;

@end

@interface TWTRSessionStore () <TWTRSessionStore_Private>

/**
 *  Logger for logging important session lifecycle events.
 *  Scribe service used to log events.
 */
@property (nonatomic, readonly) id<TWTRErrorLogger> errorLogger;

/**
 *  Service config for configuring endpoints to make auth requests against.
 */
@property (nonatomic, readonly) id<TWTRAPIServiceConfig> APIServiceConfig;

/*
 * Called when the logoutUserID: method is called.
 */
@property (nonatomic, copy, nullable) TWTRSessionStoreLogoutHook userLogoutHook;

/**
 *  Completion block invoked whenever a user session is saved to the store.
 */
@property (nonatomic, copy, nullable) TWTRSessionStoreUserSessionSavedCompletion userSessionSavedCompletion;

/**
 *  Designated initializer for creating a new session store.
 *
 *  @param authConfig        (required) Auth config containing the app `consumerKey` and `consumerSecret`
 *  @param APIServiceConfig  (required) API service config for specifying server endpoints
 *  @param refreshStrategies (required) Strategies to use to refresh sessions
 *  @param URLSession        (required) URL session used to make authentication requests
 *  @param eventLogger       (required) Logger for logging important session lifecycle events. **This should be removed before we hit production**
 *  @param accessGroup       (optional) An optional access group to use for persistence to the store.
 *
 *  @return A fully initialized session store.
 */
- (instancetype)initWithAuthConfig:(TWTRAuthConfig *)authConfig APIServiceConfig:(id<TWTRAPIServiceConfig>)APIServiceConfig refreshStrategies:(NSArray *)refreshStrategies URLSession:(NSURLSession *)URLSession errorLogger:(id<TWTRErrorLogger>)errorLogger;
- (instancetype)initWithAuthConfig:(TWTRAuthConfig *)authConfig APIServiceConfig:(id<TWTRAPIServiceConfig>)APIServiceConfig refreshStrategies:(NSArray *)refreshStrategies URLSession:(NSURLSession *)URLSession errorLogger:(id<TWTRErrorLogger>)errorLogger accessGroup:(nullable NSString *)accessGroup NS_DESIGNATED_INITIALIZER;

- (NSString *)userSessionServiceName;
- (NSString *)guestSessionServiceName;

@end

NS_ASSUME_NONNULL_END
