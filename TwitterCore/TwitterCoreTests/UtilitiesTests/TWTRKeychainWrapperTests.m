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
#import "TWTRKeychainWrapper.h"
#import "TWTRKeychainWrapper_Private.h"
#import "TWTRSecItemWrapper.h"
#import "TWTRTestCase.h"

NSString *const keychainServiceTest = @"api.sample.com";

@interface TWTRKeychainWrapperTests : TWTRTestCase

@property (nonatomic, strong) TWTRKeychainWrapper *userAuthWrapper;

@end

@implementation TWTRKeychainWrapperTests

- (void)setUp
{
    [super setUp];

    self.userAuthWrapper = [[TWTRKeychainWrapper alloc] initWithAccount:@"user" service:keychainServiceTest accessGroup:nil];
}

- (void)tearDown
{
    [self.userAuthWrapper resetKeychainItem];

    [super tearDown];
}

- (void)testSetObjectForKey_nilObject
{
    XCTAssertFalse([self.userAuthWrapper setObject:nil forKey:(__bridge id)(kSecValueData)]);
}

- (void)testSetObjectForKey_exitingObject
{
    [[self.userAuthWrapper keychainItemData] setObject:@"value" forKey:@"key"];
    id keyChainWrapperMock = OCMPartialMock(self.userAuthWrapper);
    OCMReject([keyChainWrapperMock writeToKeychain]);
    XCTAssertTrue([self.userAuthWrapper setObject:@"value" forKey:@"key"]);
    OCMVerifyAll(keyChainWrapperMock);
}

- (void)testSetObjectForKey_newObject
{
    id keyChainWrapperMock = OCMPartialMock(self.userAuthWrapper);
    OCMExpect([keyChainWrapperMock writeToKeychain]).andReturn(YES);
    XCTAssertTrue([self.userAuthWrapper setObject:@"value" forKey:@"key"]);
    OCMVerifyAll(keyChainWrapperMock);
}

- (void)testWriteToKeychain_addNewResult
{
    id secItemWrapperMock = OCMClassMock([TWTRSecItemWrapper class]);
    OCMStub([secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg anyPointer]]).andReturn(errSecItemNotFound);

    OCMStub([secItemWrapperMock secItemAdd:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);
    XCTAssertTrue([self.userAuthWrapper writeToKeychain]);
}

- (void)testWriteToKeychain_updateExistingResult
{
    id secItemWrapperMock = OCMClassMock([TWTRSecItemWrapper class]);
    OCMStub([secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg anyPointer]]).andReturn(errSecSuccess);
    OCMStub([secItemWrapperMock secItemUpdate:[OCMArg anyPointer] withAttributes:[OCMArg anyPointer]]).andReturn(errSecSuccess);
    XCTAssertTrue([self.userAuthWrapper writeToKeychain]);
}

- (void)testResetKeychainItem_existingKeyChainItemData
{
    id secItemWrapperMock = OCMClassMock([TWTRSecItemWrapper class]);
    OCMExpect([secItemWrapperMock secItemDelete:[OCMArg anyPointer]]).andReturn(errSecSuccess);

    [self.userAuthWrapper.keychainItemData setObject:@"value" forKey:(__bridge id)kSecAttrAccount];
    [self.userAuthWrapper.keychainItemData setObject:@"value" forKey:(__bridge id)kSecAttrLabel];
    [self.userAuthWrapper.keychainItemData setObject:@"value" forKey:(__bridge id)kSecAttrDescription];
    [self.userAuthWrapper.keychainItemData setObject:@"value" forKey:(__bridge id)kSecAttrService];
    [self.userAuthWrapper.keychainItemData setObject:@"value" forKey:(__bridge id)kSecValueData];

    [self.userAuthWrapper resetKeychainItem];

    OCMVerifyAll(secItemWrapperMock);

    XCTAssertEqualObjects(@"", [self.userAuthWrapper objectForKey:(__bridge id)(kSecAttrAccount)]);
    XCTAssertEqualObjects(@"", [self.userAuthWrapper objectForKey:(__bridge id)(kSecAttrLabel)]);
    XCTAssertEqualObjects(@"", [self.userAuthWrapper objectForKey:(__bridge id)(kSecAttrDescription)]);
    XCTAssertEqualObjects(@"", [self.userAuthWrapper objectForKey:(__bridge id)(kSecAttrService)]);
    XCTAssertEqualObjects(@"", [self.userAuthWrapper objectForKey:(__bridge id)(kSecValueData)]);
}

- (void)testResetKeychainItem_nonExistentKeyChainItemData
{
    id secItemWrapperMock = OCMClassMock([TWTRSecItemWrapper class]);
    OCMReject([secItemWrapperMock secItemDelete:[OCMArg anyPointer]]);

    self.userAuthWrapper.keychainItemData = nil;
    [self.userAuthWrapper resetKeychainItem];

    OCMVerifyAll(secItemWrapperMock);

    XCTAssertEqualObjects(@"", [self.userAuthWrapper objectForKey:(__bridge id)(kSecAttrAccount)]);
    XCTAssertEqualObjects(@"", [self.userAuthWrapper objectForKey:(__bridge id)(kSecAttrLabel)]);
    XCTAssertEqualObjects(@"", [self.userAuthWrapper objectForKey:(__bridge id)(kSecAttrDescription)]);
    XCTAssertEqualObjects(@"", [self.userAuthWrapper objectForKey:(__bridge id)(kSecAttrService)]);
    XCTAssertEqualObjects(@"", [self.userAuthWrapper objectForKey:(__bridge id)(kSecValueData)]);
}

@end
