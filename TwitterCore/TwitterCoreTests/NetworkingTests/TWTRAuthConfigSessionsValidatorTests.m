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
#import <XCTest/XCTest.h>
#import "TWTRAuthConfig.h"
#import "TWTRAuthConfigSessionsValidator.h"
#import "TWTRAuthConfigSessionsValidator_Private.h"
#import "TWTRAuthConfigStore.h"
#import "TWTRAuthenticationConstants.h"
#import "TWTRFakeAPIServiceConfig.h"
#import "TWTRGuestSession.h"
#import "TWTRSession.h"
#import "TWTRSessionStore.h"
#import "TWTRSessionStore_Private.h"

@interface TWTRSessionStore ()

- (void)destroyAllSessions;

@end

@interface TWTRAuthConfigSessionsValidatorTests : XCTestCase

@property (nonatomic) TWTRAuthConfigStore *configStore;
@property (nonatomic) TWTRSessionStore *sessionStore;
@property (nonatomic) TWTRAuthConfigSessionsValidator *validator;
@property (nonatomic) TWTRAuthConfig *authConfig;

@property (nonatomic) id configStoreMock;
@property (nonatomic) id sessionStoreMock;

@end

@implementation TWTRAuthConfigSessionsValidatorTests

- (void)setUp
{
    [super setUp];

    self.configStore = [[TWTRAuthConfigStore alloc] initWithNameSpace:@"TWTRAuthConfigSessionsValidatorTests"];
    self.configStoreMock = OCMPartialMock(self.configStore);

    self.authConfig = [[TWTRAuthConfig alloc] initWithConsumerKey:@"consumerKey" consumerSecret:@"consumerSecret"];
    TWTRFakeAPIServiceConfig *serviceConfig = [[TWTRFakeAPIServiceConfig alloc] init];

    self.sessionStore = [[TWTRSessionStore alloc] initWithAuthConfig:self.authConfig APIServiceConfig:serviceConfig refreshStrategies:@[] URLSession:[NSURLSession sharedSession]];

    self.sessionStore.guestSession = [[TWTRGuestSession alloc] initWithSessionDictionary:@{ TWTRAuthAppOAuthTokenKey: @"accessToken", TWTRGuestAuthOAuthTokenKey: @"guestToken" }];
    self.sessionStoreMock = OCMPartialMock(self.sessionStore);

    TWTRSession *userSession = [[TWTRSession alloc] initWithSessionDictionary:@{ TWTRAuthOAuthTokenKey: @"token", TWTRAuthOAuthSecretKey: @"secret", TWTRAuthAppOAuthScreenNameKey: @"screenname", TWTRAuthAppOAuthUserIDKey: @"1" }];
    [self.sessionStore saveSession:userSession withVerification:NO completion:^(id x, id y){
    }];

    self.validator = [[TWTRAuthConfigSessionsValidator alloc] initWithConfigStore:self.configStoreMock sessionStore:self.sessionStoreMock];
}

- (void)tearDown
{
    [self.configStore forgetAuthConfig];
    [self.sessionStore destroyAllSessions];
    [super tearDown];
}

#pragma mark - validateSessionStoreContainsAuthConfig Tests

- (void)testValidate_doesNotPurgeSessions
{
    OCMExpect([self.configStoreMock saveAuthConfig:OCMOCK_ANY]).andDo(nil);
    OCMReject([self.sessionStoreMock logOutUserID:OCMOCK_ANY]);

    [self.validator validateSessionStoreContainsValidAuthConfig];

    OCMVerifyAll(self.configStoreMock);
    OCMVerifyAll(self.sessionStoreMock);
}

- (void)testValidate_doesPurgeSessions
{
    TWTRAuthConfig *incorrectAuthConfig = [[TWTRAuthConfig alloc] initWithConsumerKey:@"consumerKey2" consumerSecret:@"consumerSecret2"];
    OCMStub([self.configStoreMock lastSavedAuthConfig]).andReturn(incorrectAuthConfig);
    OCMExpect([self.sessionStoreMock logOutUserID:OCMOCK_ANY]).andDo(nil);

    [self.validator validateSessionStoreContainsValidAuthConfig];

    OCMVerifyAll(self.sessionStoreMock);
}

#pragma mark - doesSessionStoreNeedPurge Tests

- (void)testDoesSessionStoreNeedPurge_nonExistentAuthConfig
{
    OCMStub([self.configStoreMock lastSavedAuthConfig]).andReturn(nil);
    XCTAssertFalse([self.validator doesSessionStoreNeedPurge]);
}

- (void)testDoesSessionStoreNeedPurse_differingAuthConfigs
{
    TWTRAuthConfig *incorrectAuthConfig = [[TWTRAuthConfig alloc] initWithConsumerKey:@"consumerKey2" consumerSecret:@"consumerSecret2"];
    OCMStub([self.configStoreMock lastSavedAuthConfig]).andReturn(incorrectAuthConfig);
    XCTAssertTrue([self.validator doesSessionStoreNeedPurge]);
}

@end
