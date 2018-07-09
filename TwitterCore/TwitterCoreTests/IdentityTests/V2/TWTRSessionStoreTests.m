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

#import <OCMock/OCMock.h>
#import "TWTRAPIServiceConfig.h"
#import "TWTRAuthConfig.h"
#import "TWTRAuthenticationConstants.h"
#import "TWTRConstants.h"
#import "TWTRFakeAPIServiceConfig.h"
#import "TWTRGenericKeychainItem.h"
#import "TWTRGuestSession.h"
#import "TWTRMockURLSessionProtocol.h"
#import "TWTRNetworkSessionProvider.h"
#import "TWTRNilGuestSessionRefreshStrategy.h"
#import "TWTRSecItemWrapper.h"
#import "TWTRSession.h"
#import "TWTRSessionFixtureLoader.h"
#import "TWTRSessionRefreshStrategy.h"
#import "TWTRSessionStore.h"
#import "TWTRSessionStore_Private.h"
#import "TWTRTestCase.h"
#import "TWTRTestGuestSessionRefreshStrategy.h"

@interface TWTRSessionStore ()

- (void)destroyAllSessions;

@end

@interface TWTRSessionStoreTests : TWTRTestCase

@property (nonatomic, readonly) TWTRAuthConfig *authConfig;
@property (nonatomic, readonly) TWTRSessionStore *sessionStore;
@property (nonatomic, readonly) TWTRSessionStore *noStrategyStore;
@property (nonatomic, readonly) id<TWTRAPIServiceConfig> serviceConfig;
@property (nonatomic, readonly) NSArray *refreshStrategies;
@property (nonatomic, readonly) NSHTTPURLResponse *okResponse;
@property (nonatomic, readonly) NSHTTPURLResponse *badAppTokenResponse;
@property (nonatomic, readonly) NSHTTPURLResponse *badGuestTokenResponse;
@property (nonatomic, readonly) TWTRGuestSession *guestSession;
@property (nonatomic, readonly) TWTRSession *userSession;
@property (nonatomic, readonly) id networkSessionProviderMock;
@property (nonatomic, readonly) NSString *userVerificationResponse;

@end

@implementation TWTRSessionStoreTests

- (TWTRSessionStore *)instantiateSessionStore
{
    XCTAssertNotNil(self.authConfig);
    XCTAssertNotNil(self.serviceConfig);
    XCTAssertNotNil(self.refreshStrategies);
    return [[TWTRSessionStore alloc] initWithAuthConfig:self.authConfig APIServiceConfig:self.serviceConfig refreshStrategies:self.refreshStrategies URLSession:[NSURLSession sharedSession]];
}

- (void)setUp
{
    [super setUp];

    [NSURLProtocol registerClass:[TWTRMockURLSessionProtocol class]];

    _userVerificationResponse = @"{\"id\": 123, \"screen_name\": \"screen_name\"}";

    _authConfig = [[TWTRAuthConfig alloc] initWithConsumerKey:@"consumerKey" consumerSecret:@"consumerSecret"];
    _serviceConfig = [[TWTRFakeAPIServiceConfig alloc] init];
    TWTRTestGuestSessionRefreshStrategy *strategy = [[TWTRTestGuestSessionRefreshStrategy alloc] init];
    _refreshStrategies = @[strategy];
    _sessionStore = [self instantiateSessionStore];
    _noStrategyStore = [[TWTRSessionStore alloc] initWithAuthConfig:_authConfig APIServiceConfig:_serviceConfig refreshStrategies:@[] URLSession:[NSURLSession sharedSession]];

    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"];
    _okResponse = [[NSHTTPURLResponse alloc] initWithURL:url statusCode:200 HTTPVersion:@"1.1" headerFields:@{}];
    _badAppTokenResponse = [[NSHTTPURLResponse alloc] initWithURL:url statusCode:89 HTTPVersion:@"1.1" headerFields:@{}];
    _badGuestTokenResponse = [[NSHTTPURLResponse alloc] initWithURL:url statusCode:239 HTTPVersion:@"1.1" headerFields:@{}];
    _guestSession = [[TWTRGuestSession alloc] initWithSessionDictionary:@{ TWTRAuthAppOAuthTokenKey: @"accessToken", TWTRGuestAuthOAuthTokenKey: @"guestToken" }];
    _sessionStore.guestSession = _guestSession;
    _noStrategyStore.guestSession = _guestSession;
    _userSession = [[TWTRSession alloc] initWithSessionDictionary:@{ TWTRAuthOAuthTokenKey: @"token", TWTRAuthOAuthSecretKey: @"secret", TWTRAuthAppOAuthScreenNameKey: @"screenname", TWTRAuthAppOAuthUserIDKey: @"1" }];
    _networkSessionProviderMock = OCMClassMock([TWTRNetworkSessionProvider class]);

    [self.sessionStore destroyAllSessions];
    [self.noStrategyStore destroyAllSessions];
}

- (void)tearDown
{
    XCTAssertTrue([TWTRMockURLSessionProtocol isEmpty]);
    [NSURLProtocol unregisterClass:[TWTRMockURLSessionProtocol class]];
    self.sessionStore.guestSession = nil;
    [self.networkSessionProviderMock stopMocking];

    // clear all the sessions
    [self.sessionStore destroyAllSessions];
    [self.noStrategyStore destroyAllSessions];

    [super tearDown];
}

#pragma mark - TWTRUserSessionStore

- (void)testSaveSession_succeess
{
    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithString:self.userVerificationResponse]];

    [self.sessionStore saveSession:self.userSession completion:^(id<TWTRAuthSession> session, NSError *error) {
        id<TWTRAuthSession> savedSession = [self.sessionStore sessionForUserID:session.userID];
        XCTAssertNotNil(savedSession);
        self.asyncComplete = YES;
    }];

    [self waitForCompletion];
}

- (void)testSaveSession_verificationFails
{
    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithError:[NSError errorWithDomain:@"error" code:1 userInfo:@{}]]];

    [self.sessionStore saveSession:self.userSession completion:^(id<TWTRAuthSession> session, NSError *error) {
        XCTAssertNotNil(error);
        self.asyncComplete = YES;
    }];

    [self waitForCompletion];
}

- (void)testSaveSessionWithTokens_succeess
{
    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithString:self.userVerificationResponse]];

    [self.sessionStore saveSessionWithAuthToken:@"token" authTokenSecret:@"secret" completion:^(id<TWTRAuthSession> session, NSError *error) {
        id<TWTRAuthSession> savedSession = [self.sessionStore sessionForUserID:session.userID];
        XCTAssertNotNil(savedSession);
        XCTAssertEqualObjects(session.authToken, @"token");
        XCTAssertEqualObjects(session.authTokenSecret, @"secret");
        XCTAssertEqualObjects(session.userID, @"123");
        self.asyncComplete = YES;
    }];

    [self waitForCompletion];
}

- (void)testSaveSessionWithTokens_verificationFails
{
    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithError:[NSError errorWithDomain:@"error" code:1 userInfo:@{}]]];

    [self.sessionStore saveSessionWithAuthToken:@"token" authTokenSecret:@"secret" completion:^(id<TWTRAuthSession> session, NSError *error) {
        XCTAssertNotNil(error);
        self.asyncComplete = YES;
    }];

    [self waitForCompletion];
}

- (void)testSessionForUserID_nilIfNotFound
{
    id<TWTRAuthSession> session = [self.sessionStore sessionForUserID:@"-1"];
    XCTAssertNil(session);
}

- (void)testSessionForUserID_returnsSessionIfSaved
{
    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithString:[TWTRSessionFixtureLoader twitterSessionDictionaryStringWithUserID:self.userSession.userID]]];

    [self.sessionStore saveSession:self.userSession completion:^(id<TWTRAuthSession> session, NSError *error) {
        id<TWTRAuthSession> savedSession = [self.sessionStore sessionForUserID:session.userID];
        XCTAssertNotNil(savedSession);
        XCTAssertEqualObjects(session.userID, savedSession.userID);
        self.asyncComplete = YES;
    }];

    [self waitForCompletion];
}

- (void)testExistingSessions_returnsEmptyListIfNone
{
    NSArray *sessions = [self.sessionStore existingUserSessions];
    XCTAssertEqual([sessions count], 0);
}

- (void)testExistingSessions_returnsListOfSavedSessions
{
    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithString:[TWTRSessionFixtureLoader twitterSessionDictionaryStringWithUserID:self.userSession.userID]]];

    [self.sessionStore saveSession:self.userSession completion:^(id<TWTRAuthSession> session, NSError *error) {
        NSArray *sessions = [self.sessionStore existingUserSessions];
        XCTAssertEqual([sessions count], 1);
        TWTRSession *existingSession = sessions.firstObject;
        XCTAssertEqualObjects(session.userID, existingSession.userID);
        self.asyncComplete = YES;
    }];

    [self waitForCompletion];
}

- (void)testExistingSessions_returnsListOfSavedSessionsInSortedOrderAfterReload
{
    NSDictionary *firstSessionDictionary = @{ TWTRAuthOAuthTokenKey: @"first_token", TWTRAuthOAuthSecretKey: @"first_secret", TWTRAuthAppOAuthScreenNameKey: @"first_screen_name", TWTRAuthAppOAuthUserIDKey: @"first_id" };
    NSDictionary *secondSessionDictionary = @{ TWTRAuthOAuthTokenKey: @"second_token", TWTRAuthOAuthSecretKey: @"second_secret", TWTRAuthAppOAuthScreenNameKey: @"second_screen_name", TWTRAuthAppOAuthUserIDKey: @"second_id" };

    TWTRSession *firstSession = [[TWTRSession alloc] initWithSessionDictionary:firstSessionDictionary];
    TWTRSession *secondSession = [[TWTRSession alloc] initWithSessionDictionary:secondSessionDictionary];

    id secItemWrapper = OCMClassMock([TWTRSecItemWrapper class]);
    OCMStub([secItemWrapper secItemAdd:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);

    void (^saveSession)(TWTRSession *, dispatch_block_t) = ^(TWTRSession *session, dispatch_block_t then) {

        [self.sessionStore saveSession:session withVerification:NO completion:^(TWTRSession *savedSession, NSError *error) {
            XCTAssertNotNil(savedSession);
            XCTAssertNil(error);
            if (then) {
                then();
            }
        }];

    };

    XCTestExpectation *expectation = [self expectationWithDescription:@"wait for all saving"];

    dispatch_block_t checkSessions = ^{
        NSArray *existingSessions = [self.sessionStore existingUserSessions];
        XCTAssertEqual(existingSessions.count, 2);
        XCTAssertEqual([existingSessions indexOfObject:firstSession], 0);
        XCTAssertEqual([existingSessions indexOfObject:secondSession], 1);
    };

    saveSession(firstSession, ^{
        saveSession(secondSession, ^{
            // Mock Response from Keychain
            NSData *firstSecret = [NSKeyedArchiver archivedDataWithRootObject:firstSession];
            NSData *secondSecret = [NSKeyedArchiver archivedDataWithRootObject:secondSession];
            TWTRGenericKeychainItem *firstItem = [[TWTRGenericKeychainItem alloc] initWithService:[self.sessionStore userSessionServiceName] account:firstSession.userID secret:firstSecret];
            TWTRGenericKeychainItem *secondItem = [[TWTRGenericKeychainItem alloc] initWithService:[self.sessionStore userSessionServiceName] account:secondSession.userID secret:secondSecret];
            NSArray *returnedItems = @[firstItem, secondItem];
            id keychainItemMock = OCMClassMock([TWTRGenericKeychainItem class]);
            OCMStub([keychainItemMock storedItemsMatchingQuery:OCMOCK_ANY error:(NSError * __autoreleasing *)[OCMArg anyPointer]]).andReturn(returnedItems);

            [self.sessionStore reloadSessionStore];
            checkSessions();
            [expectation fulfill];
        });
    });

    [self waitForExpectationsWithTimeout:100 handler:nil];
}

- (void)testExistingSessions_returnsListOfSavedSessionsInSortedOrderWithoutReload
{
    NSDictionary *firstSessionDictionary = @{ TWTRAuthOAuthTokenKey: @"first_token", TWTRAuthOAuthSecretKey: @"first_secret", TWTRAuthAppOAuthScreenNameKey: @"first_screen_name", TWTRAuthAppOAuthUserIDKey: @"first_id" };
    NSDictionary *secondSessionDictionary = @{ TWTRAuthOAuthTokenKey: @"second_token", TWTRAuthOAuthSecretKey: @"second_secret", TWTRAuthAppOAuthScreenNameKey: @"second_screen_name", TWTRAuthAppOAuthUserIDKey: @"second_id" };

    TWTRSession *firstSession = [[TWTRSession alloc] initWithSessionDictionary:firstSessionDictionary];
    TWTRSession *secondSession = [[TWTRSession alloc] initWithSessionDictionary:secondSessionDictionary];

    void (^saveSession)(TWTRSession *) = ^(TWTRSession *session) {

        [self.sessionStore saveSession:session withVerification:NO completion:^(TWTRSession *savedSession, NSError *error) {
            XCTAssertNotNil(savedSession);
            XCTAssertNil(error);
        }];

    };

    NSArray *existingSessions;

    saveSession(firstSession);
    existingSessions = [self.sessionStore existingUserSessions];
    XCTAssertEqual(existingSessions.count, 1);  /// FAIL
    XCTAssertEqual([existingSessions indexOfObject:firstSession], 0);

    saveSession(secondSession);
    existingSessions = [self.sessionStore existingUserSessions];
    XCTAssertEqual(existingSessions.count, 2);
    XCTAssertEqual([existingSessions indexOfObject:firstSession], 0);
    XCTAssertEqual([existingSessions indexOfObject:secondSession], 1);

    // Should swap order
    saveSession(firstSession);
    existingSessions = [self.sessionStore existingUserSessions];
    XCTAssertEqual(existingSessions.count, 2);
    XCTAssertEqual([existingSessions indexOfObject:firstSession], 1);
    XCTAssertEqual([existingSessions indexOfObject:secondSession], 0);
}

#if !TARGET_OS_TV

- (void)testLogIn_success
{
    [OCMStub([self.networkSessionProviderMock userSessionWithAuthConfig:OCMOCK_ANY APIServiceConfig:OCMOCK_ANY completion:OCMOCK_ANY]) andDo:^(NSInvocation *invocation) {
        TWTRSessionLogInCompletion loginCompletion;
        [invocation getArgument:&loginCompletion atIndex:invocation.methodSignature.numberOfArguments - 1];
        loginCompletion(self.userSession, nil);
    }];
    [self.sessionStore logInWithSystemAccountsCompletion:^(id<TWTRAuthSession> session, NSError *error) {
        XCTAssertEqualObjects(session.userID, self.userSession.userID);
        self.asyncComplete = YES;
    }];

    [self waitForCompletion];
}

- (void)testLogIn_failure
{
    [OCMStub([self.networkSessionProviderMock userSessionWithAuthConfig:OCMOCK_ANY APIServiceConfig:OCMOCK_ANY completion:OCMOCK_ANY]) andDo:^(NSInvocation *invocation) {
        NSError *error = [NSError errorWithDomain:@"domain" code:0 userInfo:@{}];
        TWTRSessionLogInCompletion loginCompletion;
        [invocation getArgument:&loginCompletion atIndex:invocation.methodSignature.numberOfArguments - 1];
        loginCompletion(nil, error);
    }];
    [self.sessionStore logInWithSystemAccountsCompletion:^(id<TWTRAuthSession> session, NSError *error) {
        XCTAssertNotNil(error);
        self.asyncComplete = YES;
    }];

    [self waitForCompletion];
}

- (void)testLogIn_doesNotPersistSessionIfLoginFails
{
    [OCMStub([self.networkSessionProviderMock userSessionWithAuthConfig:OCMOCK_ANY APIServiceConfig:OCMOCK_ANY completion:OCMOCK_ANY]) andDo:^(NSInvocation *invocation) {
        NSError *error = [NSError errorWithDomain:@"domain" code:0 userInfo:@{}];
        TWTRSessionLogInCompletion loginCompletion;
        [invocation getArgument:&loginCompletion atIndex:invocation.methodSignature.numberOfArguments - 1];
        loginCompletion(nil, error);
    }];
    [self.sessionStore logInWithSystemAccountsCompletion:^(id<TWTRAuthSession> session, NSError *error) {
        NSArray *existingSessions = [self.sessionStore existingUserSessions];
        XCTAssertEqual([existingSessions count], 0);
        self.asyncComplete = YES;
    }];

    [self waitForCompletion];
}

#endif

- (void)testLogOut_noopIfBadUserID
{
    [self.sessionStore logOutUserID:@"-1"];
    NSArray *sessions = [self.sessionStore existingUserSessions];
    XCTAssertEqual([sessions count], 0);
}

- (void)testLogOut_threadSafeLogOut
{
    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithString:[TWTRSessionFixtureLoader twitterSessionDictionaryStringWithUserID:self.userSession.userID]]];

    [self.sessionStore saveSession:self.userSession completion:^(id<TWTRAuthSession> session, NSError *error) {
        [self.sessionStore logOutUserID:session.userID];
        NSArray *sessions = [self.sessionStore existingUserSessions];
        XCTAssertEqual([sessions count], 0);
        self.asyncComplete = YES;
    }];

    [self waitForCompletion];
}

#pragma mark - TWTRGuestSessionStore

- (void)testFetchGuestSession_fetchReturnsSavedGuestSession
{
    self.sessionStore.guestSession = self.guestSession;

    [self.sessionStore fetchGuestSessionWithCompletion:^(TWTRGuestSession *guestSession, NSError *error) {
        XCTAssertEqualObjects(guestSession.guestToken, self.guestSession.guestToken);
        self.asyncComplete = YES;
    }];

    [self waitForCompletion];
}

- (void)testFetchGuestSession_fetchNewAppAndGuestSessionWhenNil
{
    [OCMStub([self.networkSessionProviderMock guestSessionWithAuthConfig:OCMOCK_ANY APIServiceConfig:OCMOCK_ANY URLSession:OCMOCK_ANY accessToken:OCMOCK_ANY completion:OCMOCK_ANY]) andDo:^(NSInvocation *invocation) {
        TWTRGuestSession *guestSession = [[TWTRGuestSession alloc] initWithSessionDictionary:@{ TWTRAuthAppOAuthTokenKey: @"newAccessToken", TWTRGuestAuthOAuthTokenKey: @"newGuestToken" }];
        TWTRSessionRefreshCompletion refreshCompletion;
        [invocation getArgument:&refreshCompletion atIndex:6];
        refreshCompletion(guestSession, nil);
    }];
    self.sessionStore.guestSession = nil;
    [self.sessionStore fetchGuestSessionWithCompletion:^(TWTRGuestSession *guestSession, NSError *error) {
        XCTAssertEqualObjects(guestSession.guestToken, @"newGuestToken");
        self.asyncComplete = YES;
    }];

    [self waitForCompletion];
}

- (void)testFetchGuestSession_fetchNewAppAndGuestSessionErrorWhenNil
{
    [OCMStub([self.networkSessionProviderMock guestSessionWithAuthConfig:OCMOCK_ANY APIServiceConfig:OCMOCK_ANY URLSession:OCMOCK_ANY accessToken:OCMOCK_ANY completion:OCMOCK_ANY]) andDo:^(NSInvocation *invocation) {
        NSError *error = [NSError errorWithDomain:@"domain" code:0 userInfo:@{}];
        TWTRSessionRefreshCompletion refreshCompletion;
        [invocation getArgument:&refreshCompletion atIndex:6];
        refreshCompletion(nil, error);
    }];
    self.sessionStore.guestSession = nil;
    [self.sessionStore fetchGuestSessionWithCompletion:^(TWTRGuestSession *guestSession, NSError *error) {
        XCTAssertNotNil(error);
        self.asyncComplete = YES;
    }];

    [self waitForCompletion];
}

#pragma mark - TWTRSessionRefreshingStore

- (void)testIsExpiredSession_validResponseButNoStrategy_returnsNo
{
    XCTAssertFalse([self.noStrategyStore isExpiredSession:self.guestSession response:self.okResponse]);
}

- (void)testIsExpiredSession_badAppResponseButNoStrategy_returnsNo
{
    XCTAssertFalse([self.noStrategyStore isExpiredSession:self.guestSession response:self.badAppTokenResponse]);
}

- (void)testIsExpiredSession_badGuestResponseButNoStrategy_returnsNo
{
    XCTAssertFalse([self.noStrategyStore isExpiredSession:self.guestSession response:self.badGuestTokenResponse]);
}

- (void)testIsExpiredSession_validResponseWithStrategy_returnsNo
{
    XCTAssertFalse([self.sessionStore isExpiredSession:self.guestSession response:self.okResponse]);
}

- (void)testIsExpiredSession_badAppResponseWithStrategy_returnsYes
{
    XCTAssertTrue([self.sessionStore isExpiredSession:self.guestSession response:self.badAppTokenResponse]);
}

- (void)testIsExpiredSession_badGuestResponseWithStrategy_returnsYes
{
    XCTAssertTrue([self.sessionStore isExpiredSession:self.guestSession response:self.badGuestTokenResponse]);
}

- (void)testRefreshOAuth1aSession_cannotRefreshUserSessions
{
    TWTRSession *userSession = [[TWTRSession alloc] initWithSessionDictionary:@{ TWTRAuthOAuthTokenKey: @"accessToken", TWTRAuthOAuthSecretKey: @"accessTokenSecret", TWTRAuthAppOAuthScreenNameKey: @"screenname", TWTRAuthAppOAuthUserIDKey: @"123" }];
    [self.sessionStore refreshSessionClass:[userSession class] sessionID:userSession.userID completion:^(TWTRSession *session, NSError *error) {
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(error.domain, TWTRLogInErrorDomain);
        XCTAssertEqual(error.code, TWTRLogInErrorCodeCannotRefreshSession);
        self.asyncComplete = YES;
    }];

    [self waitForCompletion];
}

- (void)testRefreshGuestSession_succeeds
{
    [self.sessionStore refreshSessionClass:[self.guestSession class] sessionID:self.guestSession.guestToken completion:^(TWTRGuestSession *refreshedSession, NSError *error) {
        XCTAssertEqualObjects(refreshedSession.guestToken, @"newGuestToken");
        self.asyncComplete = YES;
    }];

    [self waitForCompletion];
}

- (void)testRefreshGuestSession_fails
{
    id<TWTRSessionRefreshStrategy> cannotRefreshGuestStrategy = [[TWTRNilGuestSessionRefreshStrategy alloc] init];
    TWTRSessionStore *cannotRefreshGuestSessionsStore = [[TWTRSessionStore alloc] initWithAuthConfig:self.authConfig APIServiceConfig:self.serviceConfig refreshStrategies:@[cannotRefreshGuestStrategy] URLSession:[NSURLSession sharedSession]];

    cannotRefreshGuestSessionsStore.guestSession = self.guestSession;
    [cannotRefreshGuestSessionsStore refreshSessionClass:[self.guestSession class] sessionID:self.guestSession.guestToken completion:^(TWTRGuestSession *refreshedSession, NSError *error) {
        XCTAssertNotNil(error);
        self.asyncComplete = YES;
    }];

    [self waitForCompletion];
}

#pragma mark - Keychain Tests
- (void)testGuestSession_succeeds
{
    self.sessionStore.guestSession = nil;
    XCTAssertNil(self.sessionStore.guestSession);

    TWTRGuestSession *session = [TWTRSessionFixtureLoader twitterGuestSession];
    self.sessionStore.guestSession = session;

    XCTAssertNotNil(self.sessionStore.guestSession);
    XCTAssertEqual(session, self.sessionStore.guestSession);
}

- (void)testGuestSession_restoresSavedSession
{
    self.sessionStore.guestSession = nil;
    TWTRGuestSession *session = [TWTRSessionFixtureLoader twitterGuestSession];
    self.sessionStore.guestSession = session;

    id secItemWrapperMock = OCMClassMock([TWTRSecItemWrapper class]);
    OCMStub([secItemWrapperMock secItemAdd:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);

    NSData *sessionData = [NSKeyedArchiver archivedDataWithRootObject:session];
    TWTRGenericKeychainItem *item = [[TWTRGenericKeychainItem alloc] initWithService:[self.sessionStore guestSessionServiceName] account:@"com.twitter.sdk.ios.core.guest-session-user" secret:sessionData];
    id keychainWrapperMock = OCMClassMock([TWTRGenericKeychainItem class]);
    OCMStub([keychainWrapperMock storedItemsMatchingQuery:OCMOCK_ANY error:(NSError * __autoreleasing *)[OCMArg anyPointer]]).andReturn(@[item]);

    TWTRSessionStore *store = [self instantiateSessionStore];

    XCTAssertNotNil(store.guestSession);
    XCTAssertEqualObjects(store.guestSession, session);
}

- (void)testReloadSessionStore
{
    NSDictionary *sessionDictionary = @{ TWTRAuthOAuthTokenKey: @"some_token", TWTRAuthOAuthSecretKey: @"some_secret", TWTRAuthAppOAuthScreenNameKey: @"other_screen_name", TWTRAuthAppOAuthUserIDKey: @"other_user_id" };
    TWTRSession *session = [[TWTRSession alloc] initWithSessionDictionary:sessionDictionary];

    id secItemWrapperMock = OCMClassMock([TWTRSecItemWrapper class]);
    OCMStub([secItemWrapperMock secItemAdd:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);

    TWTRSessionStore *otherStore = [self instantiateSessionStore];
    [otherStore saveSession:session withVerification:NO completion:^(id<TWTRAuthSession> s, NSError *e){
    }];

    // Should be present in one but not the other
    XCTAssertTrue([[otherStore existingUserSessions] containsObject:session]);
    XCTAssertFalse([[self.sessionStore existingUserSessions] containsObject:session]);
    NSData *sessionData = [NSKeyedArchiver archivedDataWithRootObject:session];

    TWTRGenericKeychainItem *item = [[TWTRGenericKeychainItem alloc] initWithService:[self.sessionStore userSessionServiceName] account:session.userID secret:sessionData];
    id keychainWrapperMock = OCMClassMock([TWTRGenericKeychainItem class]);
    OCMStub([keychainWrapperMock storedItemsMatchingQuery:OCMOCK_ANY error:(NSError * __autoreleasing *)[OCMArg anyPointer]]).andReturn(@[item]);

    [self.sessionStore reloadSessionStore];
    XCTAssertTrue([[self.sessionStore existingUserSessions] containsObject:session]);
    XCTAssertEqual([[self.sessionStore existingUserSessions] count], 1);
}

#pragma mark - Custom Hooks

- (void)testSaveSessionWithoutVerification_invokesSessionSavedCompletion
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"should call user session saved completion"];
    @weakify(self);
    self.sessionStore.userSessionSavedCompletion = ^(id<TWTRAuthSession> session) {
        @strongify(self);
        XCTAssertEqualObjects(self.userSession, session);
        [expectation fulfill];
    };

    [self.sessionStore saveSession:self.userSession withVerification:NO completion:^(id<TWTRAuthSession> session, NSError *error){
    }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testSaveSessionWithVerification_invokesSessionSavedCompletion
{
    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithString:self.userVerificationResponse]];

    XCTestExpectation *expectation = [self expectationWithDescription:@"should call user session saved completion"];
    @weakify(self);
    self.sessionStore.userSessionSavedCompletion = ^(id<TWTRAuthSession> session) {
        @strongify(self);
        XCTAssertEqualObjects(self.userSession, session);
        [expectation fulfill];
    };

    [self.sessionStore saveSession:self.userSession withVerification:YES completion:^(id<TWTRAuthSession> session, NSError *error){
    }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testSaveSessionWithToken_invokesSessionSavedCompletion
{
    [TWTRMockURLSessionProtocol pushResponse:[TWTRMockURLResponse responseWithString:self.userVerificationResponse]];

    XCTestExpectation *expectation = [self expectationWithDescription:@"should call user session saved completion"];
    @weakify(self);
    self.sessionStore.userSessionSavedCompletion = ^(id<TWTRAuthSession> session) {
        @strongify(self);
        XCTAssertNotNil(session);
        [expectation fulfill];
    };

    [self.sessionStore saveSessionWithAuthToken:@"token" authTokenSecret:@"secret" completion:^(id<TWTRAuthSession> session, NSError *error){
    }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testLogout_invokesUserLogoutHook
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"should invoke user logout hoook"];
    [self.sessionStore saveSession:self.userSession withVerification:NO completion:^(id<TWTRAuthSession> session, NSError *error){
    }];
    @weakify(self);
    self.sessionStore.userLogoutHook = ^(NSString *userID) {
        @strongify(self);
        XCTAssertEqualObjects(self.userSession.userID, userID);
        [expectation fulfill];
    };

    [self.sessionStore logOutUserID:self.userSession.userID];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

#pragma mark - Has Logged In Users

- (void)testHasLoggedIn_returnsYes
{
    [self.sessionStore saveSession:self.userSession withVerification:NO completion:^(id<TWTRAuthSession> session, NSError *error){
    }];

    XCTAssertTrue([self.sessionStore hasLoggedInUsers]);
}

- (void)testHasLoggedIn_returnsNo
{
    XCTAssertFalse([self.sessionStore hasLoggedInUsers]);
}

@end
