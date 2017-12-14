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
#import "TWTRAuthConfigStore.h"
#import "TWTRAuthConfigStore_Private.h"
#import "TWTRGenericKeychainItem.h"

@interface TWTRAuthConfigStoreTests : XCTestCase

@property (nonatomic) TWTRAuthConfig *authConfig;
@property (nonatomic) TWTRAuthConfig *otherAuthConfig;
@property (nonatomic) TWTRAuthConfigStore *store;

@end

@implementation TWTRAuthConfigStoreTests

- (void)setUp
{
    [super setUp];
    _authConfig = [[TWTRAuthConfig alloc] initWithConsumerKey:@"consumer_key" consumerSecret:@"consumer_secret"];
    _otherAuthConfig = [[TWTRAuthConfig alloc] initWithConsumerKey:@"other_key" consumerSecret:@"other_secret"];

    NSString *ns = [[NSUUID UUID] UUIDString];
    _store = [[TWTRAuthConfigStore alloc] initWithNameSpace:ns];
}

- (void)tearDown
{
    [self.store forgetAuthConfig];
    [super tearDown];
}

#pragma mark - persistAuthConfigWithKeychainItem Tests

- (void)testPersistAuthConfigWithKeychainItem_savesConfig
{
    NSData *secret = [NSKeyedArchiver archivedDataWithRootObject:self.authConfig];
    TWTRGenericKeychainItem *item = [[TWTRGenericKeychainItem alloc] initWithService:[self.store nameSpacedServiceKey] account:[self.store nameSpacedAccountKey] secret:secret];
    id mockKeychainItem = OCMPartialMock(item);
    OCMStub([mockKeychainItem storeInKeychain:(NSError * __autoreleasing *)[OCMArg anyPointer]]).andReturn(YES);
    [self.store persistAuthConfig:self.authConfig withKeychainItem:item];

    OCMStub([mockKeychainItem storedItemsMatchingQuery:OCMOCK_ANY error:(NSError * __autoreleasing *)[OCMArg anyPointer]]).andReturn(@[item]);
    XCTAssertEqualObjects([self.store lastSavedAuthConfig], self.authConfig);
}
- (void)testPersistAuthConfigWithKeychainItem_differingNamespaces
{
    NSData *secret = [NSKeyedArchiver archivedDataWithRootObject:self.authConfig];
    TWTRGenericKeychainItem *item = [[TWTRGenericKeychainItem alloc] initWithService:[self.store nameSpacedServiceKey] account:[self.store nameSpacedAccountKey] secret:secret];
    id mockKeychainItem = OCMPartialMock(item);
    OCMStub([mockKeychainItem storeInKeychain:(NSError * __autoreleasing *)[OCMArg anyPointer]]).andReturn(YES);

    [self.store persistAuthConfig:self.authConfig withKeychainItem:item];

    TWTRAuthConfigStore *otherStore = [[TWTRAuthConfigStore alloc] initWithNameSpace:@"other_name_space"];
    NSData *otherSecret = [NSKeyedArchiver archivedDataWithRootObject:self.otherAuthConfig];
    TWTRGenericKeychainItem *otherItem = [[TWTRGenericKeychainItem alloc] initWithService:[otherStore nameSpacedServiceKey] account:[otherStore nameSpacedAccountKey] secret:otherSecret];
    id otherMockKeychainItem = OCMPartialMock(otherItem);
    OCMStub([otherMockKeychainItem storeInKeychain:(NSError * __autoreleasing *)[OCMArg anyPointer]]).andReturn(YES);

    [otherStore persistAuthConfig:self.otherAuthConfig withKeychainItem:otherItem];

    id keychainItemMock = OCMClassMock([TWTRGenericKeychainItem class]);
    OCMStub([keychainItemMock storedItemsMatchingQuery:OCMOCK_ANY error:(NSError * __autoreleasing *)[OCMArg anyPointer]]).andReturn(@[otherItem]);

    XCTAssertEqualObjects([otherStore lastSavedAuthConfig], self.otherAuthConfig);

    // Redefine keychain item mock to return the expected value.
    keychainItemMock = OCMClassMock([TWTRGenericKeychainItem class]);
    OCMStub([keychainItemMock storedItemsMatchingQuery:OCMOCK_ANY error:(NSError * __autoreleasing *)[OCMArg anyPointer]]).andReturn(@[item]);

    XCTAssertEqualObjects([self.store lastSavedAuthConfig], self.authConfig);

    [otherStore forgetAuthConfig];
}

#pragma mark - forgetAuthConfig Tests

- (void)testForgetAuthConfig_removesConfig
{
    NSData *secret = [NSKeyedArchiver archivedDataWithRootObject:self.authConfig];
    TWTRGenericKeychainItem *item = [[TWTRGenericKeychainItem alloc] initWithService:[self.store nameSpacedServiceKey] account:[self.store nameSpacedAccountKey] secret:secret];

    id mockKeychainItem = OCMClassMock([TWTRGenericKeychainItem class]);
    OCMStub([mockKeychainItem storeInKeychain:(NSError * __autoreleasing *)[OCMArg anyPointer]]).andReturn(YES);
    OCMStub([mockKeychainItem removeAllItemsForQuery:OCMOCK_ANY error:(NSError * __autoreleasing *)[OCMArg anyPointer]]).andReturn(YES);
    OCMStub([mockKeychainItem storedItemsMatchingQuery:OCMOCK_ANY error:(NSError * __autoreleasing *)[OCMArg anyPointer]]).andReturn(@[item]);
    [self.store persistAuthConfig:self.authConfig withKeychainItem:item];

    XCTAssertNotNil([self.store lastSavedAuthConfig]);

    [self.store forgetAuthConfig];

    // Redeclare mock to reset stub
    mockKeychainItem = OCMClassMock([TWTRGenericKeychainItem class]);
    OCMStub([mockKeychainItem storedItemsMatchingQuery:OCMOCK_ANY error:(NSError * __autoreleasing *)[OCMArg anyPointer]]).andReturn(nil);

    XCTAssertNil([self.store lastSavedAuthConfig]);
}

#pragma mark - lastSavedAuthConfig Tests

- (void)testLastSavedAuthConfig_fetchesConfig
{
    id keychainItemMock = OCMClassMock([TWTRGenericKeychainItem class]);
    NSData *secret = [NSKeyedArchiver archivedDataWithRootObject:self.authConfig];
    TWTRGenericKeychainItem *item = [[TWTRGenericKeychainItem alloc] initWithService:[self.store nameSpacedServiceKey] account:[self.store nameSpacedAccountKey] secret:secret];
    OCMStub([keychainItemMock storedItemsMatchingQuery:OCMOCK_ANY error:(NSError * __autoreleasing *)[OCMArg anyPointer]]).andReturn(@[item]);

    XCTAssertNotNil([self.store lastSavedAuthConfig]);
}

- (void)testLastSavedAuthConfig_returnsNil
{
    id keychainItemMock = OCMClassMock([TWTRGenericKeychainItem class]);
    OCMStub([keychainItemMock storedItemsMatchingQuery:OCMOCK_ANY error:(NSError * __autoreleasing *)[OCMArg anyPointer]]).andReturn(nil);
    XCTAssertNil([self.store lastSavedAuthConfig]);
}

@end
