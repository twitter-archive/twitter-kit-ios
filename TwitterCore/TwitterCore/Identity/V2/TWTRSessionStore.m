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

#import "TWTRSessionStore.h"
#import "TWTRAPIServiceConfig.h"
#import "TWTRAssertionMacros.h"
#import "TWTRAuthSession.h"
#import "TWTRGenericKeychainItem.h"
#import "TWTRGuestSession.h"
#import "TWTRNetworkSessionProvider.h"
#import "TWTRSession.h"
#import "TWTRSessionRefreshStrategy.h"

#import "TWTRSessionStore_Private.h"

static NSString *const TWTRSessionStoreGuestUserName = @"com.twitter.sdk.ios.core.guest-session-user";

@interface TWTRSessionStore ()

/**
 *  URL session used to make authentication requests.
 */
@property (nonatomic, readonly) NSURLSession *URLSession;

/**
 *  In-memory cache of authenticated user sessions.
 */
@property (nonatomic) NSMutableArray *authSessionCache;

/**
 *  List of registered refresh strategies to fetch new sessions with.
 */
@property (nonatomic, copy, readonly) NSArray *refreshStrategies;

/**
 * An optional access group to use for persistence to the keychain.
 */
@property (nonatomic, copy, readonly, nullable) NSString *accessGroup;

/**
 * Used to verify the oauth token during web login.
 */
@property (nonatomic, copy) NSString *oauthToken;

@end

@implementation TWTRSessionStore
@synthesize authConfig = _authConfig;
@synthesize guestSession = _guestSession;

#pragma mark - Initialization

- (instancetype)initWithAuthConfig:(TWTRAuthConfig *)authConfig APIServiceConfig:(id<TWTRAPIServiceConfig>)APIServiceConfig refreshStrategies:(NSArray *)refreshStrategies URLSession:(NSURLSession *)URLSession
{
    return [self initWithAuthConfig:authConfig APIServiceConfig:APIServiceConfig refreshStrategies:refreshStrategies URLSession:URLSession accessGroup:nil];
}

- (instancetype)initWithAuthConfig:(TWTRAuthConfig *)authConfig APIServiceConfig:(id<TWTRAPIServiceConfig>)APIServiceConfig refreshStrategies:(NSArray *)refreshStrategies URLSession:(NSURLSession *)URLSession accessGroup:(nullable NSString *)accessGroup
{
    TWTRParameterAssertOrReturnValue(authConfig && APIServiceConfig && refreshStrategies && URLSession, nil);

    if (self = [super init]) {
        _APIServiceConfig = APIServiceConfig;
        _authConfig = authConfig;
        _accessGroup = [accessGroup copy];

        _authSessionCache = [NSMutableArray array];

        _refreshStrategies = [refreshStrategies copy];
        _URLSession = URLSession;

        [self primeWriteThroughCaches];
    }

    return self;
}

- (void)reloadSessionStore
{
    [self primeWriteThroughCaches];
}

#pragma mark - TWTRSessionStore Methods

- (void)saveSession:(id<TWTRAuthSession>)session completion:(TWTRSessionStoreSaveCompletion)completion
{
    TWTRCheckArgumentWithCompletion2(session, completion);
    [self saveSession:session withVerification:YES completion:completion];
}

- (void)saveSession:(id<TWTRAuthSession>)session withVerification:(BOOL)verifySession completion:(TWTRSessionStoreSaveCompletion)completion
{
    TWTRCheckArgumentWithCompletion2(session, completion);

    if (verifySession) {
        [TWTRNetworkSessionProvider verifyUserSession:session withAuthConfig:self.authConfig APIServiceConfig:self.APIServiceConfig URLSession:self.URLSession completion:^(TWTRSession *userSession, NSError *error) {
            if (userSession) {
                [self storeSession:userSession];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                completion(userSession, error);
            });
        }];
    } else {
        [self storeSession:session];

        dispatch_async(dispatch_get_main_queue(), ^{
            completion(session, nil);
        });
    }
}

- (void)saveSessionWithAuthToken:(NSString *)authToken authTokenSecret:(NSString *)authTokenSecret completion:(TWTRSessionStoreSaveCompletion)completion
{
    TWTRCheckArgumentWithCompletion2(authToken && authTokenSecret, completion);
    [TWTRNetworkSessionProvider verifySessionWithAuthToken:authToken authSecret:authTokenSecret withAuthConfig:self.authConfig APIServiceConfig:self.APIServiceConfig URLSession:self.URLSession completion:^(TWTRSession *userSession, NSError *error) {
        if (userSession) {
            [self storeSession:userSession];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            completion(userSession, error);
        });
    }];
}

- (id<TWTRAuthSession>)sessionForUserID:(NSString *)userID
{
    TWTRParameterAssertOrReturnValue(userID, nil);
    NSArray *existingSessions = [self existingUserSessions];
    NSUInteger indexOfMatchingSession = [existingSessions indexOfObjectPassingTest:^BOOL(id<TWTRAuthSession> session, NSUInteger idx, BOOL *stop) {
        if ([session.userID isEqualToString:userID]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];

    return indexOfMatchingSession != NSNotFound ? existingSessions[indexOfMatchingSession] : nil;
}

- (NSArray *)existingUserSessions
{
    NSArray *sessions = [self allUserSessions];
    return sessions;
}

- (BOOL)hasLoggedInUsers
{
    return [self allUserSessions].count > 0;
}

- (id<TWTRAuthSession>)session
{
    return [[self existingUserSessions] lastObject];
}

- (void)logInWithSystemAccountsCompletion:(TWTRSessionLogInCompletion)completion __TVOS_UNAVAILABLE
{
    TWTRParameterAssertOrReturn(completion);

    [TWTRNetworkSessionProvider userSessionWithAuthConfig:self.authConfig APIServiceConfig:self.APIServiceConfig completion:^(TWTRSession *userSession, NSError *userAuthError) {
        if (userSession) {
            [self storeSession:userSession];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            completion(userSession, userAuthError);
        });
    }];
}

- (void)logOutUserID:(NSString *)userID
{
    TWTRParameterAssertOrReturn(userID);
    [self removeSessionWithSessionID:userID];

    if (self.userLogoutHook) {
        self.userLogoutHook(userID);
    }
}

#pragma mark - TWTRGuestSessionStore Methods

- (void)fetchGuestSessionWithCompletion:(TWTRSessionGuestLogInCompletion)completion
{
    TWTRParameterAssertOrReturn(completion);

    // make a local copy to avoid potential threading issues.
    TWTRGuestSession *localGuestSession = self.guestSession;

    if (localGuestSession) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(localGuestSession, nil);
        });
        return;
    }

    // TODO: there is a chance that we could make multiple guest session requests here if this method is called while a fetch is in flight.
    NSString *accessToken = localGuestSession.accessToken;
    [TWTRNetworkSessionProvider guestSessionWithAuthConfig:self.authConfig APIServiceConfig:self.APIServiceConfig URLSession:self.URLSession accessToken:accessToken completion:^(TWTRGuestSession *guestSession, NSError *guestAuthError) {
        if (guestSession) {
            self.guestSession = guestSession;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            completion(guestSession, guestAuthError);
        });
    }];
}

#pragma mark - TWTRSessionRefreshingStore Methods

- (void)refreshSessionClass:(Class)sessionClass sessionID:(NSString *)sessionID completion:(TWTRSessionStoreRefreshCompletion)completion
{
    id<TWTRSessionRefreshStrategy> refreshStrategy = [self sessionRefreshStrategyForSessionClass:sessionClass];
    if (refreshStrategy) {
        if (sessionClass == [TWTRGuestSession class]) {
            [self refreshGuestSessionWithStrategy:refreshStrategy completion:completion];
        } else if ([sessionClass conformsToProtocol:@protocol(TWTRAuthSession)]) {
            [self refreshAuthSessionID:sessionID withStrategy:refreshStrategy completion:completion];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *const cannotRefreshSessionError = [NSError errorWithDomain:TWTRLogInErrorDomain code:TWTRLogInErrorCodeCannotRefreshSession userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Does not support refreshing session of class %@", sessionClass] }];
                completion(nil, cannotRefreshSessionError);
            });
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *const cannotRefreshSessionError = [NSError errorWithDomain:TWTRLogInErrorDomain code:TWTRLogInErrorCodeCannotRefreshSession userInfo:@{ NSLocalizedDescriptionKey: @"Error trying to refresh session tokens." }];
            completion(nil, cannotRefreshSessionError);
        });
    }
}

- (BOOL)isExpiredSession:(id)session response:(NSHTTPURLResponse *)response
{
    TWTRParameterAssertOrReturnValue(session && response, NO);

    return [self isExpiredSession:session response:response error:nil];
}

- (BOOL)isExpiredSession:(id)session error:(NSError *)error
{
    TWTRParameterAssertOrReturnValue(session, NO);
    TWTRParameterAssertOrReturnValue(error, NO);

    return [self isExpiredSession:session response:nil error:error];
}

- (BOOL)isExpiredSession:(id)session response:(NSHTTPURLResponse *)response error:(NSError *)error
{
    if ([session isKindOfClass:[TWTRGuestSession class]]) {
        id<TWTRSessionRefreshStrategy> refreshStrategy = [self sessionRefreshStrategyForSessionClass:[TWTRGuestSession class]];
        if (response) {
            return [[refreshStrategy class] isSessionExpiredBasedOnRequestResponse:response];
        } else if (error) {
            return [[refreshStrategy class] isSessionExpiredBasedOnRequestError:error];
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

#pragma mark - Helpers

- (nullable id<TWTRSessionRefreshStrategy>)sessionRefreshStrategyForSessionClass:(Class)sessionClass
{
    for (id<TWTRSessionRefreshStrategy> strategy in self.refreshStrategies) {
        if ([[strategy class] canSupportSessionClass:sessionClass]) {
            return strategy;
        }
    }
    return nil;
}

+ (dispatch_queue_t)concurrentSessionQueue
{
    /// We need a queue which all classes can use since multiple instances of one store can manage the same sessions
    static dispatch_queue_t queue = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.twitter.sdk.ios.core.session-store", DISPATCH_QUEUE_CONCURRENT);
    });

    return queue;
}

- (NSString *)guestSessionServiceName
{
    static NSString *const guestSessionServiceName = @"guest-session-store-service-name";
    return [self namespacedServiceNameWithName:guestSessionServiceName];
}

- (NSString *)userSessionServiceName
{
    static NSString *const userSessionServiceName = @"user-session-store-service-name";
    return [self namespacedServiceNameWithName:userSessionServiceName];
}

- (NSString *)namespacedServiceNameWithName:(NSString *)name
{
    return [NSString stringWithFormat:@"%@.%@", self.APIServiceConfig.serviceName, name];
}

#pragma mark - Guest Keychain Access Control (These methods are thread-safe, reads are synchronous and writes are async)

- (TWTRGuestSession *)guestSession
{
    TWTRGuestSession *__block session = nil;

    dispatch_sync([[self class] concurrentSessionQueue], ^{
        session = self->_guestSession;
    });
    return session;
}

- (void)setGuestSession:(nullable TWTRGuestSession *)guestSession
{
    dispatch_barrier_async([[self class] concurrentSessionQueue], ^{
        [self unsafeSetGuestSession:guestSession];
    });
}

- (void)unsafeSetGuestSession:(nullable TWTRGuestSession *)guestSession
{
    if (guestSession) {
        [self unsafePersistGuestSession:guestSession];
    } else {
        [self unsafeDeleteGuestSession];
    }
    self->_guestSession = guestSession;
}

- (TWTRGenericKeychainQuery *)guestSessionQuery
{
    return [TWTRGenericKeychainQuery queryForService:[self guestSessionServiceName] account:TWTRSessionStoreGuestUserName];
}

#pragma mark - User Keychain Access (These methods are thread-safe, reads are synchronous and writes are async)

- (nullable id<TWTRAuthSession>)sessionWithSessionID:(NSString *)sessionID
{
    TWTRParameterAssertOrReturnValue(sessionID, nil);

    __block id<TWTRAuthSession> session = nil;
    dispatch_sync([[self class] concurrentSessionQueue], ^{
        session = [self unsafeCachedSessionWithSessionID:sessionID];
    });

    return session;
}

- (void)removeSessionWithSessionID:(NSString *)sessionID
{
    TWTRParameterAssertOrReturn(sessionID);

    dispatch_barrier_async([[self class] concurrentSessionQueue], ^{
        [self unsafePurgeCachedSessionWithSessionID:sessionID];
        [self unsafeDeleteUserSessionWithSessionID:sessionID];
    });
}

- (void)storeSession:(id<TWTRAuthSession>)session
{
    TWTRParameterAssertOrReturn(session);

    if (self.userSessionSavedCompletion) {
        self.userSessionSavedCompletion(session);
    }

    dispatch_barrier_async([[self class] concurrentSessionQueue], ^{
        [self unsafeCacheSession:session];
        [self unsafePersistAuthSession:session];
    });
}

- (NSArray *)allUserSessions
{
    NSArray *__block sessions = [NSMutableArray array];

    dispatch_sync([[self class] concurrentSessionQueue], ^{
        sessions = [self unsafeAllCachedUserSessions];
    });

    return sessions;
}

/**
 * Creates a keychain query object for the user sessions. If the sessionID
 * is nil it will query for all user sessions.
 */
- (TWTRGenericKeychainQuery *)userSessionQueryWithID:(nullable NSString *)sessionID;
{
    return [TWTRGenericKeychainQuery queryForService:[self userSessionServiceName] account:sessionID];
}

#pragma mark - OAuth Token
- (void)saveOauthToken:(NSString *)token
{
    _oauthToken = token;
}

- (BOOL)isValidOauthToken:(NSString *)token
{
    if (token && self.oauthToken) {
        return [token isEqualToString:self.oauthToken];
    } else {
        return NO;
    }
}

#pragma mark - Cache Priming
- (void)primeWriteThroughCaches
{
    dispatch_barrier_async([[self class] concurrentSessionQueue], ^{
        [self unsafePrimeGuestSessionCache];
        [self unsafePrimeUserSessionCache];
    });
}

- (void)unsafePrimeGuestSessionCache
{
    TWTRGuestSession *session = [self unsafeLoadGuestSession];

    // Check if we should keep using this token.
    if (!session.probablyNeedsRefreshing) {
        [self unsafeSetGuestSession:session];
    } else {
        [self unsafeSetGuestSession:nil];
    }
}

- (void)unsafePrimeUserSessionCache
{
    NSArray *sessions = [self unsafeLoadAllUserSessions];
    [self.authSessionCache removeAllObjects];

    for (id<TWTRAuthSession> session in sessions) {
        [self unsafeCacheSession:session];
    }
}

#pragma mark - Session Cache (These methods are not thread-safe)

- (void)unsafeCacheSession:(id<TWTRAuthSession>)session
{
    TWTRParameterAssertOrReturn(session);
    [self.authSessionCache removeObject:session];
    [self.authSessionCache addObject:session];
}

- (NSArray *)unsafeAllCachedUserSessions
{
    return self.authSessionCache;
}

- (nullable id<TWTRAuthSession>)unsafeCachedSessionWithSessionID:(NSString *)sessionID
{
    TWTRParameterAssertOrReturnValue(sessionID, nil);
    NSInteger index = [self indexOfCachedSessionWithSessionID:sessionID];

    if (index != NSNotFound) {
        return self.authSessionCache[index];
    }
    return nil;
}

- (void)unsafePurgeCachedSessionWithSessionID:(NSString *)sessionID
{
    TWTRParameterAssertOrReturn(sessionID);
    NSInteger index = [self indexOfCachedSessionWithSessionID:sessionID];

    if (index != NSNotFound) {
        [self.authSessionCache removeObjectAtIndex:index];
    }
}

- (NSInteger)indexOfCachedSessionWithSessionID:(NSString *)sessionID
{
    TWTRParameterAssertOrReturnValue(sessionID, NSNotFound);
    return [self.authSessionCache indexOfObjectPassingTest:^BOOL(id<TWTRAuthSession> obj, NSUInteger idx, BOOL *stop) {
        return [obj.userID isEqualToString:sessionID];
    }];
}

#pragma mark - Session Keychain Persistence (These methods are not thread-safe)

- (void)unsafePersistAuthSession:(id<TWTRAuthSession>)session
{
    [self unsafePersistSession:session service:[self userSessionServiceName] sessionID:session.userID];
}

- (void)unsafePersistGuestSession:(id<TWTRBaseSession>)session
{
    [self unsafePersistSession:session service:[self guestSessionServiceName] sessionID:TWTRSessionStoreGuestUserName];
}

- (void)unsafePersistSession:(id<TWTRBaseSession>)session service:(NSString *)service sessionID:(NSString *)sessionID
{
    TWTRParameterAssertOrReturn(session);
    TWTRParameterAssertOrReturn(sessionID);
    TWTRParameterAssertOrReturn(service);

    NSData *sessionData = [NSKeyedArchiver archivedDataWithRootObject:session];

    TWTRGenericKeychainItem *item = [[TWTRGenericKeychainItem alloc] initWithService:service account:sessionID secret:sessionData];
    [self saveKeychainItem:item];
}

- (void)saveKeychainItem:(TWTRGenericKeychainItem *)item
{
    NSError *error = nil;
    if (![item storeInKeychain:&error]) {
        NSLog(@"error saving session: %@", error);  // TODO: handle error?
    }
}

#pragma mark - Session Keychain Deletion (These methods are not thread-safe)

- (void)unsafeDeleteUserSessionWithSessionID:(NSString *)sessionID
{
    TWTRParameterAssertOrReturn(sessionID);
    [self unsafeDeleteSessionForService:[self userSessionServiceName] sessionID:sessionID];
}

- (void)unsafeDeleteGuestSession
{
    [self unsafeDeleteSessionForService:[self guestSessionServiceName] sessionID:TWTRSessionStoreGuestUserName];
}

- (void)unsafeDeleteSessionForService:(NSString *)service sessionID:(NSString *)sessionID
{
    TWTRGenericKeychainQuery *query = [TWTRGenericKeychainQuery queryForService:service account:sessionID];
    NSError *error = nil;

    if (![TWTRGenericKeychainItem removeAllItemsForQuery:query error:&error]) {
        NSLog(@"error removing session: %@", error);  // TODO: handle error?
    }
}

#pragma mark - Session Keychain Loading (These methods are not thread-safe)

- (NSArray *)unsafeLoadAllUserSessions
{
    TWTRGenericKeychainQuery *query = [self userSessionQueryWithID:nil];
    return [self unsafeLoadSessionsWithQuery:query passingTest:^BOOL(id obj) {
        return [obj conformsToProtocol:@protocol(TWTRAuthSession)];
    }];
}

- (nullable TWTRGuestSession *)unsafeLoadGuestSession
{
    TWTRGenericKeychainQuery *query = [self guestSessionQuery];
    NSArray *sessions = [self unsafeLoadSessionsWithQuery:query passingTest:^BOOL(id obj) {
        return [obj isKindOfClass:[TWTRGuestSession class]];
    }];

    if (sessions.count > 1) {
        NSLog(@"Error: there should not be more than 1 guest session");  // TODO: better handling
    }

    return [sessions firstObject];
}

- (NSArray *)unsafeLoadSessionsWithQuery:(TWTRGenericKeychainQuery *)query passingTest:(BOOL (^)(id obj))predicate
{
    TWTRParameterAssertOrReturnValue(query && predicate, @[]);

    NSArray *keychainItems = [self keychainItemsMatchingQuery:query];
    [self updateKeychainItemsAccessGroupIfNeeded:keychainItems];

    return [self transformedKeychainItems:keychainItems passingTest:predicate];
}

- (NSArray *)keychainItemsMatchingQuery:(TWTRGenericKeychainQuery *)query
{
    TWTRParameterAssertOrReturnValue(query, @[]);
    NSError *error;
    NSArray *keychainItems = [TWTRGenericKeychainItem storedItemsMatchingQuery:query error:&error];

    if (!keychainItems) {
        NSLog(@"error loading sessions: %@", error);  // TODO: handle error
    }

    return keychainItems ?: @[];
}

- (NSArray *)transformedKeychainItems:(NSArray *)keychainItems passingTest:(BOOL (^)(id obj))predicate
{
    TWTRParameterAssertOrReturnValue(predicate, @[]);

    NSArray *sortedKeychainItems = [keychainItems sortedArrayUsingComparator:^NSComparisonResult(TWTRGenericKeychainItem *obj1, TWTRGenericKeychainItem *obj2) {
        return [obj1.lastSavedDate compare:obj2.lastSavedDate];
    }];

    NSMutableArray *sessions = [NSMutableArray array];

    [sortedKeychainItems enumerateObjectsUsingBlock:^(TWTRGenericKeychainItem *item, NSUInteger idx, BOOL *stop) {
        id<TWTRBaseSession> session = [NSKeyedUnarchiver unarchiveObjectWithData:item.secret];

        if (session && predicate(session)) {
            [sessions addObject:session];
        }
    }];

    return sessions;
}

- (void)updateKeychainItemsAccessGroupIfNeeded:(NSArray *)keychainItems
{
    NSString *accessGroup = self.accessGroup;

    for (TWTRGenericKeychainItem *item in keychainItems) {
        // In practice the access group is never nil after a fetch
        if ([item.accessGroup isEqualToString:accessGroup] == NO) {
            TWTRGenericKeychainItem *newItem = [[TWTRGenericKeychainItem alloc] initWithService:item.service account:item.account secret:item.secret genericValue:item.genericValue accessGroup:accessGroup];
            [self saveKeychainItem:newItem];
        }
    }
}

#pragma mark - Helpers

/**
 *  Refreshes an auth session given the strategy.
 *
 *  @param sessionID  ID of the session to lookup for refresh
 *  @param strategy   Strategy used to refresh the session
 *  @param completion Completion block to call when refresh succeeds or fails. The block will run on the main thread.
 */
- (void)refreshAuthSessionID:(NSString *)sessionID withStrategy:(id<TWTRSessionRefreshStrategy>)strategy completion:(TWTRSessionStoreRefreshCompletion)completion
{
    TWTRCheckArgumentWithCompletion2(sessionID && strategy, completion);

    id<TWTRAuthSession> session = [self sessionForUserID:sessionID];
    if (session) {
        [strategy refreshSession:session URLSession:self.URLSession completion:^(id refreshedSession, NSError *refreshError) {
            if (refreshedSession) {
                [self saveSession:refreshedSession withVerification:NO completion:^(id<TWTRAuthSession> savedSession, NSError *saveError) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(savedSession, saveError);
                    });
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, refreshError);
                });
            }
        }];
    } else {
        NSError *const noSessionFoundError = [NSError errorWithDomain:TWTRLogInErrorDomain code:TWTRLogInErrorCodeSessionNotFound userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Error fetching existing session for user ID %@.", sessionID] }];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, noSessionFoundError);
        });
    }
}

/**
 *  Refreshes a guest session given the strategy.
 *
 *  @param strategy   Strategy used to refresh the guest session.
 *  @param completion Completion block to call when refresh succeeds or fails. Block will run on the main thread.
 */
- (void)refreshGuestSessionWithStrategy:(id<TWTRSessionRefreshStrategy>)strategy completion:(TWTRSessionStoreRefreshCompletion)completion
{
    TWTRCheckArgumentWithCompletion2(strategy && self.guestSession, completion);

    [strategy refreshSession:self.guestSession URLSession:self.URLSession completion:^(TWTRGuestSession *refreshedSession, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (refreshedSession) {
                self.guestSession = refreshedSession;
            }
            completion(refreshedSession, error);
        });
    }];
}

#pragma mark - Testing Utility
/**
 * A method that will destory all the active sessions in the store.
 * This method is here to facilitate testing. It should not be used
 * in production code. If you need to remove any sessions use the
 * deleteXXX methods instead.
 */
- (void)destroyAllSessions
{
    TWTRGenericKeychainQuery *guestQuery = [self guestSessionQuery];
    TWTRGenericKeychainQuery *userQuery = [self userSessionQueryWithID:nil];

    [TWTRGenericKeychainItem removeAllItemsForQuery:guestQuery error:nil];
    [TWTRGenericKeychainItem removeAllItemsForQuery:userQuery error:nil];
}

@end
