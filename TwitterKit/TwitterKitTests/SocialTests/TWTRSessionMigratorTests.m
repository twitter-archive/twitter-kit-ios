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
#import <TwitterCore/TWTRAuthenticator.h>
#import <TwitterCore/TWTRSessionStore.h>
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TWTRSessionMigrator.h"
#import "TWTRTestSessionStore.h"

@interface TWTRSessionMigratorTests : XCTestCase

@property (nonatomic) id authenticatorMock;
@property (nonatomic) TWTRTestSessionStore *store;
@property (nonatomic) TWTRSessionMigrator *migrator;
@property (nonatomic) NSDictionary *sessionDictionary;

@end

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
@implementation TWTRSessionMigratorTests

- (void)setUp
{
    [super setUp];
    self.authenticatorMock = OCMStrictClassMock([TWTRAuthenticator class]);

    self.store = [[TWTRTestSessionStore alloc] initWithUserSessions:@[] guestSession:nil];
    self.migrator = [[TWTRSessionMigrator alloc] init];
    self.sessionDictionary = @{ @"oauth_token": @"token", @"oauth_token_secret": @"secret", @"screen_name": @"abc", @"user_id": @"1234" };
}

- (void)tearDown
{
    [self.authenticatorMock stopMocking];
    [super tearDown];
}

- (void)testMigrateNoExistingSession
{
    OCMStub([self.authenticatorMock authenticationResponseForAuthType:TWTRAuthTypeUser]).andReturn(nil);
    [self.migrator runMigrationWithDestination:self.store removeOnSuccess:NO];

    NSArray *sessions = [self.store existingUserSessions];
    XCTAssertEqual(sessions.count, 0);
}

- (void)testMigrateExistingSession_SaveSessionNoRemove
{
    OCMStub([self.authenticatorMock authenticationResponseForAuthType:TWTRAuthTypeUser]).andReturn(self.sessionDictionary);

    [self.migrator runMigrationWithDestination:self.store removeOnSuccess:NO];

    NSArray *sessions = [self.store existingUserSessions];
    XCTAssertEqual(sessions.count, 1);
}

- (void)testMigrateExistingSession_SaveSessionWithRemove
{
    OCMStub([self.authenticatorMock authenticationResponseForAuthType:TWTRAuthTypeUser]).andReturn(self.sessionDictionary);

    OCMExpect([self.authenticatorMock logoutAuthType:TWTRAuthTypeUser]);

    [self.migrator runMigrationWithDestination:self.store removeOnSuccess:YES];

    NSArray *sessions = [self.store existingUserSessions];
    XCTAssertEqual(sessions.count, 1);

    OCMVerifyAll(self.authenticatorMock);
}

- (void)testMigrateExistingSession_RemoveFailsUponError
{
    self.store.overrideUserSaveError = [NSError errorWithDomain:@"domain" code:0 userInfo:nil];
    OCMStub([self.authenticatorMock authenticationResponseForAuthType:TWTRAuthTypeUser]).andReturn(self.sessionDictionary);
    [[self.authenticatorMock reject] logoutAuthType:TWTRAuthTypeUser];

    [self.migrator runMigrationWithDestination:self.store removeOnSuccess:YES];

    NSArray *sessions = [self.store existingUserSessions];
    XCTAssertEqual(sessions.count, 0);
}

@end
#pragma GCC diagnostic pop
