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

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "TWTRGenericKeychainItem.h"
#import "TWTRSecItemWrapper.h"

@interface TWTRSimpleNSCodingObject : NSObject <NSCoding>

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *UUID;

- (instancetype)initWithName:(NSString *)name UUID:(NSString *)UUID;

@end

@interface TWTRGenericKeychainItemTests : XCTestCase
@property (nonatomic, copy) NSString *service;
@property (nonatomic) TWTRGenericKeychainQuery *serviceQuery;
@property (nonatomic) NSData *secretData;
@property (nonatomic, copy) NSString *account;
@property (nonatomic) id secItemWrapperMock;
@property (nonatomic) CFTypeRef keychainResult;
@end

@implementation TWTRGenericKeychainItemTests

- (void)setUp
{
    NSString *service = [[NSUUID UUID] UUIDString];
    self.account = [[NSUUID UUID] UUIDString];
    self.service = service;
    self.secretData = [@"secret" dataUsingEncoding:NSUTF8StringEncoding];
    self.secItemWrapperMock = OCMClassMock([TWTRSecItemWrapper class]);

    NSDictionary *keychainResultDict = @{
                          (__bridge id)kSecAttrService: self.service,
                          (__bridge id)kSecAttrAccount: self.account,
                          (__bridge id)kSecAttrModificationDate: [NSDate date],
                          (__bridge id)kSecValueData: self.secretData
                          };
    NSArray *keychainResultArray = @[keychainResultDict];
    self.keychainResult = CFBridgingRetain(keychainResultArray);

    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

#pragma mark - Query Tests
- (void)testInitQueryForAll
{
    TWTRGenericKeychainQuery *query = [TWTRGenericKeychainQuery queryForAllItems];
    XCTAssert(query.service.length == 0);
    XCTAssert(query.account.length == 0);
}

- (void)testInitQueryForService
{
    TWTRGenericKeychainQuery *query = [TWTRGenericKeychainQuery queryForService:self.service];
    XCTAssert(query.account.length == 0);
    XCTAssert([query.service isEqualToString:self.service]);
}

- (void)testInitQueryForAccount
{
    NSString *account = self.account;
    TWTRGenericKeychainQuery *query = [TWTRGenericKeychainQuery queryForAccount:account];
    XCTAssert(query.service.length == 0);
    XCTAssert([query.account isEqualToString:account]);
}

- (void)testInitQueryForServiceAndAccount
{
    NSString *account = self.account;
    TWTRGenericKeychainQuery *query = [TWTRGenericKeychainQuery queryForService:self.service account:account];
    XCTAssert([query.service isEqualToString:self.service]);
    XCTAssert([query.account isEqualToString:account]);
}

- (void)testInitQueryForGenericValue
{
    NSString *generic = @"generic-value";
    TWTRGenericKeychainQuery *query = [TWTRGenericKeychainQuery queryForGenericValue:generic];
    XCTAssert(query.service.length == 0);
    XCTAssert(query.account.length == 0);
    XCTAssert([query.genericValue isEqualToString:generic]);
}

- (void)testInitQueryForAccessGroup
{
    NSString *ag = @"access-group";
    TWTRGenericKeychainQuery *query = [TWTRGenericKeychainQuery queryForAccessGroup:ag];
    XCTAssert(query.service.length == 0);
    XCTAssert(query.account.length == 0);
    XCTAssert([query.accessGroup isEqualToString:ag]);
}

- (void)testQueryForAllItems
{
    if (@available(iOS 10.0, *)) {
        OCMStub([self.secItemWrapperMock secItemAdd:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);
        OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);
    }

    TWTRGenericKeychainQuery *query = [TWTRGenericKeychainQuery queryForAllItems];
    NSInteger currentCount = [[TWTRGenericKeychainItem storedItemsMatchingQuery:query error:nil] count];

    TWTRGenericKeychainItem *item = [[TWTRGenericKeychainItem alloc] initWithService:self.service account:self.account secret:self.secretData];
    XCTAssertTrue([item storeInKeychain:nil]);

    if (@available(iOS 10.0, *)) {
        // Redefine class mock to override secItemCopyMatching stub
        self.secItemWrapperMock = OCMClassMock([TWTRSecItemWrapper class]);
        OCMStub([self.secItemWrapperMock secItemAdd:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);
        OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg setToValue:OCMOCK_VALUE(self.keychainResult)]]).andReturn(errSecSuccess).andForwardToRealObject;
    }

    NSInteger newCount = [[TWTRGenericKeychainItem storedItemsMatchingQuery:query error:nil] count];
    XCTAssert(newCount == currentCount + 1);
}

- (void)testQueryForService
{
    TWTRGenericKeychainQuery *query = [TWTRGenericKeychainQuery queryForService:self.service];
    NSInteger currentCount = [[TWTRGenericKeychainItem storedItemsMatchingQuery:query error:nil] count];

    OCMStub([self.secItemWrapperMock secItemAdd:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);

    TWTRGenericKeychainItem *item = [[TWTRGenericKeychainItem alloc] initWithService:self.service account:self.account secret:self.secretData];
    XCTAssertTrue([item storeInKeychain:nil]);

    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg setToValue:OCMOCK_VALUE(self.keychainResult)]]).andReturn(errSecSuccess).andForwardToRealObject;

    NSInteger newCount = [[TWTRGenericKeychainItem storedItemsMatchingQuery:query error:nil] count];
    XCTAssert(newCount == currentCount + 1);
}

- (void)testQueryForAccount
{
    TWTRGenericKeychainQuery *query = [TWTRGenericKeychainQuery queryForAccount:self.account];
    NSInteger currentCount = [[TWTRGenericKeychainItem storedItemsMatchingQuery:query error:nil] count];

    OCMStub([self.secItemWrapperMock secItemAdd:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);

    TWTRGenericKeychainItem *item = [[TWTRGenericKeychainItem alloc] initWithService:self.service account:query.account secret:self.secretData];
    XCTAssertTrue([item storeInKeychain:nil]);

    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg setToValue:OCMOCK_VALUE(self.keychainResult)]]).andReturn(errSecSuccess).andForwardToRealObject;

    NSInteger newCount = [[TWTRGenericKeychainItem storedItemsMatchingQuery:query error:nil] count];
    XCTAssert(newCount == currentCount + 1);
}

- (void)testQueryForServiceAndAccount
{
    TWTRGenericKeychainQuery *query = [TWTRGenericKeychainQuery queryForService:self.service account:self.account];
    NSInteger currentCount = [[TWTRGenericKeychainItem storedItemsMatchingQuery:query error:nil] count];

    OCMStub([self.secItemWrapperMock secItemAdd:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);

    TWTRGenericKeychainItem *item = [[TWTRGenericKeychainItem alloc] initWithService:self.service account:query.account secret:self.secretData];
    XCTAssertTrue([item storeInKeychain:nil]);

    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg setToValue:OCMOCK_VALUE(self.keychainResult)]]).andReturn(errSecSuccess).andForwardToRealObject;

    NSInteger newCount = [[TWTRGenericKeychainItem storedItemsMatchingQuery:query error:nil] count];
    XCTAssert(newCount == currentCount + 1);
}

- (void)testQueryForGenericValue
{
    TWTRGenericKeychainQuery *query = [TWTRGenericKeychainQuery queryForGenericValue:@"generic"];
    NSInteger currentCount = [[TWTRGenericKeychainItem storedItemsMatchingQuery:query error:nil] count];

    OCMStub([self.secItemWrapperMock secItemAdd:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);

    TWTRGenericKeychainItem *item = [[TWTRGenericKeychainItem alloc] initWithService:self.service account:self.account secret:self.secretData genericValue:query.genericValue accessGroup:nil];
    XCTAssertTrue([item storeInKeychain:nil]);
    
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg setToValue:OCMOCK_VALUE(self.keychainResult)]]).andReturn(errSecSuccess).andForwardToRealObject;

    NSInteger newCount = [[TWTRGenericKeychainItem storedItemsMatchingQuery:query error:nil] count];
    XCTAssert(newCount == currentCount + 1);
}

#pragma mark - Equality Tests
- (void)testEquality
{
    NSString *service = @"service";

    TWTRGenericKeychainItem *first = [[TWTRGenericKeychainItem alloc] initWithService:service account:self.account secret:self.secretData];
    TWTRGenericKeychainItem *second = [[TWTRGenericKeychainItem alloc] initWithService:service account:self.account secret:self.secretData];
    XCTAssertEqualObjects(first, second);
}

- (void)testEqualiltyWithExtendedAttributes
{
    NSString *service = @"service";
    NSString *generic = @"generic";
    NSString *accessGroup = @"accessGroup";

    TWTRGenericKeychainItem *first = [[TWTRGenericKeychainItem alloc] initWithService:service account:self.account secret:self.secretData genericValue:generic accessGroup:accessGroup];
    TWTRGenericKeychainItem *second = [[TWTRGenericKeychainItem alloc] initWithService:service account:self.account secret:self.secretData genericValue:generic accessGroup:accessGroup];
    XCTAssertEqualObjects(first, second);
}

- (void)testEqualiltyWithExtendedAttributesIgnoresAcessGroup
{
    /// We ignore the access group because you should not be able to access items with different access groups that you don't own.
    NSString *generic = @"generic";

    TWTRGenericKeychainItem *first = [[TWTRGenericKeychainItem alloc] initWithService:self.service account:self.account secret:self.secretData genericValue:generic accessGroup:@"AG1"];
    TWTRGenericKeychainItem *second = [[TWTRGenericKeychainItem alloc] initWithService:self.service account:self.account secret:self.secretData genericValue:generic accessGroup:@"AG2"];
    XCTAssertEqualObjects(first, second);
}

- (void)testEqualityArrayContains
{
    if (@available(iOS 10.0, *)) {
        OCMStub([self.secItemWrapperMock secItemAdd:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);
        OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);
    }

    TWTRGenericKeychainItem *item = [[TWTRGenericKeychainItem alloc] initWithService:self.service account:self.account secret:self.secretData];
    XCTAssertTrue([item storeInKeychain:nil]);

    if (@available(iOS 10.0, *)) {
        // Redefine class mock to override secItemCopyMatching stub.
        self.secItemWrapperMock = OCMClassMock([TWTRSecItemWrapper class]);
        OCMStub([self.secItemWrapperMock secItemAdd:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);

        NSDictionary *dict = @{
                               (__bridge id)kSecAttrService: self.service,
                               (__bridge id)kSecAttrAccount: self.account,
                               (__bridge id)kSecAttrModificationDate: [NSDate date],
                               (__bridge id)kSecValueData: self.secretData
                               };
        NSArray *array = @[dict];
        CFTypeRef result = CFBridgingRetain(array);
        OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg setToValue:OCMOCK_VALUE(result)]]).andReturn(errSecSuccess).andForwardToRealObject;
    }

    NSArray *items = [TWTRGenericKeychainItem storedItemsMatchingQuery:[TWTRGenericKeychainQuery queryForAllItems] error:nil];
    XCTAssertTrue([items containsObject:item]);
}

- (void)testInequality
{
    NSString *firstService = @"service";
    NSString *firstAccount = @"account";
    NSString *secondService = @"service2";
    NSString *secondAccount = @"account2";

    TWTRGenericKeychainItem *first = [[TWTRGenericKeychainItem alloc] initWithService:firstService account:firstAccount secret:self.secretData];
    TWTRGenericKeychainItem *second = [[TWTRGenericKeychainItem alloc] initWithService:secondService account:secondAccount secret:self.secretData];
    XCTAssertNotEqualObjects(first, second);
}

- (void)testInequalityDifferentClasses
{
    TWTRGenericKeychainItem *first = [[TWTRGenericKeychainItem alloc] initWithService:self.service account:self.account secret:self.secretData];
    NSString *second = @"second";

    XCTAssertNotEqualObjects(first, second);
}

- (void)testInequaliltyWithExtendedAttributes
{
    NSString *generic = @"generic";
    NSString *accessGroup = @"accessGroup";

    TWTRGenericKeychainItem *first = [[TWTRGenericKeychainItem alloc] initWithService:self.service account:self.account secret:self.secretData genericValue:generic accessGroup:accessGroup];
    TWTRGenericKeychainItem *second = [[TWTRGenericKeychainItem alloc] initWithService:self.service account:self.account secret:self.secretData];
    XCTAssertNotEqualObjects(first, second);
}

#pragma mark - Storage Tests

- (void)testStoreKeychainItem
{
    OCMStub([self.secItemWrapperMock secItemAdd:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);

    TWTRGenericKeychainItem *item = [[TWTRGenericKeychainItem alloc] initWithService:self.service account:self.account secret:self.secretData];

    NSError *error;
    BOOL result = [item storeInKeychain:&error];
    XCTAssertTrue(result);
}

- (void)testStoreMultipleAccountsOneService;
{
    NSArray *accounts = @[@"account1", @"account2"];

    OCMStub([self.secItemWrapperMock secItemAdd:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);

    TWTRGenericKeychainItem *item1 = [[TWTRGenericKeychainItem alloc] initWithService:self.service account:accounts[0] secret:self.secretData];
    TWTRGenericKeychainItem *item2 = [[TWTRGenericKeychainItem alloc] initWithService:self.service account:accounts[1] secret:self.secretData];

    XCTAssert([item1 storeInKeychain:nil]);
    XCTAssert([item2 storeInKeychain:nil]);
}

- (void)testStoreMultipleServicesOneAccount
{
    NSArray *services = @[@"service1", @"service2"];

    OCMStub([self.secItemWrapperMock secItemAdd:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);

    TWTRGenericKeychainItem *item1 = [[TWTRGenericKeychainItem alloc] initWithService:services[0] account:self.account secret:self.secretData];
    TWTRGenericKeychainItem *item2 = [[TWTRGenericKeychainItem alloc] initWithService:services[1] account:self.account secret:self.secretData];

    XCTAssert([item1 storeInKeychain:nil]);
    XCTAssert([item2 storeInKeychain:nil]);

    NSDictionary *result1 = @{
                              (__bridge id)kSecAttrService: services[0],
                              (__bridge id)kSecAttrAccount: self.account,
                              (__bridge id)kSecAttrModificationDate: [NSDate date],
                              (__bridge id)kSecValueData: self.secretData
                             };

    NSDictionary *result2 = @{
                              (__bridge id)kSecAttrService: services[1],
                              (__bridge id)kSecAttrAccount: self.account,
                              (__bridge id)kSecAttrModificationDate: [NSDate date],
                              (__bridge id)kSecValueData: self.secretData
                              };

    NSArray *array = @[result1, result2];
    CFTypeRef result = CFBridgingRetain(array);

    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg setToValue:OCMOCK_VALUE(result)]]).andReturn(errSecSuccess).andForwardToRealObject;

    TWTRGenericKeychainQuery *query = [TWTRGenericKeychainQuery queryForAccount:self.account];
    NSArray *items = [TWTRGenericKeychainItem storedItemsMatchingQuery:query error:nil];
    XCTAssert(items.count == 2);
}

- (void)testStoreReplacesExistingByDefault
{
    NSData *secret1 = [@"secret1" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *secret2 = [@"secret2" dataUsingEncoding:NSUTF8StringEncoding];

    OCMStub([self.secItemWrapperMock secItemAdd:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);

    TWTRGenericKeychainItem *firstItem = [[TWTRGenericKeychainItem alloc] initWithService:self.service account:self.account secret:secret1];
    XCTAssert([firstItem storeInKeychain:nil]);

    NSDictionary *dict1 = @{
                              (__bridge id)kSecAttrService: self.service,
                              (__bridge id)kSecAttrAccount: self.account,
                              (__bridge id)kSecAttrModificationDate: [NSDate date],
                              (__bridge id)kSecValueData: secret1
                              };
    NSArray *array1 = @[dict1];
    CFTypeRef result1 = CFBridgingRetain(array1);

    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg setToValue:OCMOCK_VALUE(result1)]]).andReturn(errSecSuccess).andForwardToRealObject;

    TWTRGenericKeychainQuery *query = [TWTRGenericKeychainQuery queryForService:self.service account:self.account];
    TWTRGenericKeychainItem *firstFetch = [[TWTRGenericKeychainItem storedItemsMatchingQuery:query error:nil] firstObject];
    XCTAssertEqualObjects(firstFetch.secret, secret1);

    // Mock return type to match the number of retain and releases
    CFTypeRef result2 = CFBridgingRetain(array1);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg setToValue:OCMOCK_VALUE(result2)]]).andReturn(errSecSuccess).andForwardToRealObject;

    TWTRGenericKeychainItem *secondItem = [[TWTRGenericKeychainItem alloc] initWithService:self.service account:self.account secret:secret2];
    XCTAssert([secondItem storeInKeychain:nil]);

    // Re-assign class mock to override the stub for secItemCopyMatching
    self.secItemWrapperMock = OCMClassMock([TWTRSecItemWrapper class]);
    NSDictionary *dict2 = @{
                            (__bridge id)kSecAttrService: self.service,
                            (__bridge id)kSecAttrAccount: self.account,
                            (__bridge id)kSecAttrModificationDate: [NSDate date],
                            (__bridge id)kSecValueData: secret2
                            };
    NSArray *array2 = @[dict2];
    CFTypeRef result3 = CFBridgingRetain(array2);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg setToValue:OCMOCK_VALUE(result3)]]).andReturn(errSecSuccess).andForwardToRealObject;

    TWTRGenericKeychainItem *secondFetch = [[TWTRGenericKeychainItem storedItemsMatchingQuery:query error:nil] firstObject];
    XCTAssertEqualObjects(secondFetch.secret, secret2);
}

- (void)testStoreWithoutReplacingSetsError
{
    NSData *secret1 = [@"secret1" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *secret2 = [@"secret2" dataUsingEncoding:NSUTF8StringEncoding];

    OCMStub([self.secItemWrapperMock secItemAdd:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);

    TWTRGenericKeychainItem *firstItem = [[TWTRGenericKeychainItem alloc] initWithService:self.service account:self.account secret:secret1];
    XCTAssert([firstItem storeInKeychain:nil]);

    // Redefine SecItemWrapperMock to override secItemCopyMatching and secItemAdd Stub
    self.secItemWrapperMock = OCMClassMock([TWTRSecItemWrapper class]);
    OCMStub([self.secItemWrapperMock secItemAdd:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecDuplicateItem);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecDuplicateItem);

    NSError *error;
    TWTRGenericKeychainItem *secondItem = [[TWTRGenericKeychainItem alloc] initWithService:self.service account:self.account secret:secret2];
    XCTAssertFalse([secondItem storeInKeychainReplacingExisting:NO error:&error]);
    XCTAssertNotNil(error);

    NSDictionary *dict = @{
                            (__bridge id)kSecAttrService: self.service,
                            (__bridge id)kSecAttrAccount: self.account,
                            (__bridge id)kSecAttrModificationDate: [NSDate date],
                            (__bridge id)kSecValueData: secret1
                            };
    NSArray *array = @[dict];
    CFTypeRef result = CFBridgingRetain(array);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg setToValue:OCMOCK_VALUE(result)]]).andReturn(errSecSuccess).andForwardToRealObject;

    TWTRGenericKeychainQuery *query = [TWTRGenericKeychainQuery queryForService:self.service account:self.account];
    TWTRGenericKeychainItem *fetched = [[TWTRGenericKeychainItem storedItemsMatchingQuery:query error:nil] firstObject];
    XCTAssertEqualObjects(fetched.secret, secret1);
}

- (void)testStoreOverridesPrevious
{
    NSData *secret1 = [@"secret1" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *secret2 = [@"secret2" dataUsingEncoding:NSUTF8StringEncoding];

    OCMStub([self.secItemWrapperMock secItemAdd:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);

    TWTRGenericKeychainItem *firstItem = [[TWTRGenericKeychainItem alloc] initWithService:self.service account:self.account secret:secret1];
    XCTAssert([firstItem storeInKeychain:nil]);

    NSDictionary *dict = @{
                           (__bridge id)kSecAttrService: self.service,
                           (__bridge id)kSecAttrAccount: self.account,
                           (__bridge id)kSecAttrModificationDate: [NSDate date],
                           (__bridge id)kSecValueData: secret1
                           };
    NSArray *array = @[dict];
    CFTypeRef result = CFBridgingRetain(array);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg setToValue:OCMOCK_VALUE(result)]]).andReturn(errSecSuccess).andForwardToRealObject;

    TWTRGenericKeychainQuery *query = [TWTRGenericKeychainQuery queryForService:self.service account:self.account];
    TWTRGenericKeychainItem *firstFetch = [[TWTRGenericKeychainItem storedItemsMatchingQuery:query error:nil] firstObject];
    XCTAssertEqualObjects(firstFetch.secret, secret1);

    // Mock return type to match the number of retain and releases
    CFTypeRef result2 = CFBridgingRetain(array);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg setToValue:OCMOCK_VALUE(result2)]]).andReturn(errSecSuccess).andForwardToRealObject;

    TWTRGenericKeychainItem *secondItem = [[TWTRGenericKeychainItem alloc] initWithService:self.service account:self.account secret:secret2];
    XCTAssert([secondItem storeInKeychain:nil]);

    self.secItemWrapperMock = OCMClassMock([TWTRSecItemWrapper class]);
    NSDictionary *dict2 = @{
                           (__bridge id)kSecAttrService: self.service,
                           (__bridge id)kSecAttrAccount: self.account,
                           (__bridge id)kSecAttrModificationDate: [NSDate date],
                           (__bridge id)kSecValueData: secret2
                           };
    NSArray *array2 = @[dict2];
    CFTypeRef result3 = CFBridgingRetain(array2);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg setToValue:OCMOCK_VALUE(result3)]]).andReturn(errSecSuccess).andForwardToRealObject;

    TWTRGenericKeychainItem *secondFetch = [[TWTRGenericKeychainItem storedItemsMatchingQuery:query error:nil] firstObject];
    XCTAssertEqualObjects(secondFetch.secret, secret2);
}

- (void)testStoreOverridesPreviousAndRemovesValues
{
    NSString *generic = @"generic";

    OCMStub([self.secItemWrapperMock secItemAdd:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);

    TWTRGenericKeychainItem *firstItem = [[TWTRGenericKeychainItem alloc] initWithService:self.service account:self.account secret:self.secretData genericValue:generic];
    XCTAssert([firstItem storeInKeychain:nil]);

    NSDictionary *dict = @{
                           (__bridge id)kSecAttrService: self.service,
                           (__bridge id)kSecAttrAccount: self.account,
                           (__bridge id)kSecAttrGeneric: generic,
                           (__bridge id)kSecAttrModificationDate: [NSDate date],
                           (__bridge id)kSecValueData: self.secretData
                           };
    NSArray *array = @[dict];
    CFTypeRef result = CFBridgingRetain(array);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg setToValue:OCMOCK_VALUE(result)]]).andReturn(errSecSuccess).andForwardToRealObject;

    TWTRGenericKeychainQuery *query = [TWTRGenericKeychainQuery queryForService:self.service account:self.account];
    TWTRGenericKeychainItem *firstFetch = [[TWTRGenericKeychainItem storedItemsMatchingQuery:query error:nil] firstObject];
    XCTAssertEqualObjects(firstFetch.genericValue, generic);

    // Mock return type to match the number of retain and releases
    CFTypeRef result2 = CFBridgingRetain(array);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg setToValue:OCMOCK_VALUE(result2)]]).andReturn(errSecSuccess).andForwardToRealObject;

    TWTRGenericKeychainItem *secondItem = [[TWTRGenericKeychainItem alloc] initWithService:self.service account:self.account secret:self.secretData];
    XCTAssert([secondItem storeInKeychain:nil]);

    self.secItemWrapperMock = OCMClassMock([TWTRSecItemWrapper class]);
    NSDictionary *dict2 = @{
                           (__bridge id)kSecAttrService: self.service,
                           (__bridge id)kSecAttrAccount: self.account,
                           (__bridge id)kSecAttrModificationDate: [NSDate date],
                           (__bridge id)kSecValueData: self.secretData
                           };
    NSArray *array2 = @[dict2];
    CFTypeRef result3 = CFBridgingRetain(array2);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg setToValue:OCMOCK_VALUE(result3)]]).andReturn(errSecSuccess).andForwardToRealObject;

    TWTRGenericKeychainItem *secondFetch = [[TWTRGenericKeychainItem storedItemsMatchingQuery:query error:nil] firstObject];
    XCTAssertNil(secondFetch.genericValue);
}

#pragma mark - Test Remove
- (void)testRemoveItem
{
    TWTRGenericKeychainItem *item = [[TWTRGenericKeychainItem alloc] initWithService:self.service account:self.account secret:self.secretData];

    OCMStub([self.secItemWrapperMock secItemAdd:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);

    XCTAssert([item storeInKeychain:nil]);

    NSDictionary *dict = @{
                           (__bridge id)kSecAttrService: self.service,
                           (__bridge id)kSecAttrAccount: self.account,
                           (__bridge id)kSecAttrModificationDate: [NSDate date],
                           (__bridge id)kSecValueData: self.secretData
                           };
    NSArray *array = @[dict];
    CFTypeRef result = CFBridgingRetain(array);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg setToValue:OCMOCK_VALUE(result)]]).andReturn(errSecSuccess).andForwardToRealObject;

    TWTRGenericKeychainQuery *query = [TWTRGenericKeychainQuery queryForService:self.service account:self.account];
    NSInteger count = [[TWTRGenericKeychainItem storedItemsMatchingQuery:query error:nil] count];

    OCMStub([self.secItemWrapperMock secItemDelete:[OCMArg anyPointer]]).andReturn(errSecSuccess);

    XCTAssert([item removeFromKeychain:nil]);

    // Reset SecItemWrapperMock to overrite stub for secItemCopyMatching
    self.secItemWrapperMock = OCMClassMock([TWTRSecItemWrapper class]);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);

    NSInteger newCount = [[TWTRGenericKeychainItem storedItemsMatchingQuery:query error:nil] count];
    XCTAssert(newCount == count - 1);
}

#pragma mark - Storage Tests
- (void)testCanStoreLargeDataBlob
{
    NSInteger count = 2000000;                    // 2 mil
    NSUInteger size = sizeof(NSInteger) * count;  // 2mb
    char *bytes = malloc(size);
    memset(bytes, 1, size);
    NSData *data = [NSData dataWithBytes:bytes length:size];

    TWTRGenericKeychainItem *item = [[TWTRGenericKeychainItem alloc] initWithService:self.service account:self.account secret:data];
    NSError *error = nil;

    OCMStub([self.secItemWrapperMock secItemAdd:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);
    OCMStub([self.secItemWrapperMock secItemDelete:[OCMArg anyPointer]]).andReturn(errSecSuccess);

    XCTAssert([item storeInKeychain:&error]);
    XCTAssertNil(error);
    free(bytes);
}

- (void)testCanSaveNSCodingCompliantObject
{
    NSString *name = @"name";
    NSString *UUID = [[NSUUID UUID] UUIDString];

    TWTRSimpleNSCodingObject *originalObject = [[TWTRSimpleNSCodingObject alloc] initWithName:name UUID:UUID];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:originalObject];

    OCMStub([self.secItemWrapperMock secItemAdd:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);

    TWTRGenericKeychainItem *item = [[TWTRGenericKeychainItem alloc] initWithService:self.service account:self.account secret:data];
    XCTAssert([item storeInKeychain:nil]);

    NSDictionary *keychainResultDict = @{
                                         (__bridge id)kSecAttrService: self.service,
                                         (__bridge id)kSecAttrAccount: self.account,
                                         (__bridge id)kSecAttrGeneric: @"",
                                         (__bridge id)kSecAttrAccessGroup: @"",
                                         (__bridge id)kSecAttrModificationDate: [NSDate date],
                                         (__bridge id)kSecValueData: data
                                         };
    NSArray *keychainResultArray = @[keychainResultDict];
    self.keychainResult = CFBridgingRetain(keychainResultArray);

    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg setToValue:OCMOCK_VALUE(self.keychainResult)]]).andReturn(errSecSuccess).andForwardToRealObject;

    TWTRGenericKeychainQuery *query = [TWTRGenericKeychainQuery queryForService:self.service account:self.account];
    TWTRGenericKeychainItem *fetchedItem = [[TWTRGenericKeychainItem storedItemsMatchingQuery:query error:nil] firstObject];

    XCTAssertNotNil(fetchedItem.secret);
    TWTRSimpleNSCodingObject *fetchedObject = [NSKeyedUnarchiver unarchiveObjectWithData:fetchedItem.secret];

    XCTAssertNotNil(fetchedObject);
    XCTAssertEqualObjects(fetchedObject.name, originalObject.name);
    XCTAssertEqualObjects(fetchedObject.UUID, originalObject.UUID);
}

#pragma mark - Modification Date tests
- (void)testLastSavedDate_NilOnInitialCreation
{
    TWTRGenericKeychainItem *item = [[TWTRGenericKeychainItem alloc] initWithService:self.service account:self.account secret:self.secretData];
    XCTAssertNil(item.lastSavedDate);
}

- (void)testLastSavedDate_NonNilOnSave
{
    OCMStub([self.secItemWrapperMock secItemAdd:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg setToValue:OCMOCK_VALUE(self.keychainResult)]]).andReturn(errSecSuccess).andForwardToRealObject;

    TWTRGenericKeychainItem *item = [[TWTRGenericKeychainItem alloc] initWithService:self.service account:self.account secret:self.secretData];
    XCTAssert([item storeInKeychain:nil]);
    XCTAssertNotNil(item.lastSavedDate);
}

- (void)testLastSavedDate_FetchFromKeychainReturnsObjectWithDate
{
    NSDictionary *keychainResultDict = @{
                                         (__bridge id)kSecAttrService: self.service,
                                         (__bridge id)kSecAttrAccount: self.account,
                                         (__bridge id)kSecAttrGeneric: @"",
                                         (__bridge id)kSecAttrAccessGroup: @"",
                                         (__bridge id)kSecAttrModificationDate: [NSDate date],
                                         (__bridge id)kSecValueData: self.secretData
                                         };
    NSArray *keychainResultArray = @[keychainResultDict];
    CFTypeRef result = CFBridgingRetain(keychainResultArray);

    OCMStub([self.secItemWrapperMock secItemAdd:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg setToValue:OCMOCK_VALUE(result)]]).andReturn(errSecSuccess).andForwardToRealObject;

    TWTRGenericKeychainItem *item = [[TWTRGenericKeychainItem alloc] initWithService:self.service account:self.account secret:self.secretData];
    XCTAssert([item storeInKeychain:nil]);

    CFTypeRef secondResult = CFBridgingRetain(keychainResultArray);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg setToValue:OCMOCK_VALUE(secondResult)]]).andReturn(errSecSuccess).andForwardToRealObject;

    TWTRGenericKeychainQuery *query = [TWTRGenericKeychainQuery queryForService:self.service account:self.account];
    TWTRGenericKeychainItem *fetchedItem = [[TWTRGenericKeychainItem storedItemsMatchingQuery:query error:nil] lastObject];
    XCTAssertNotNil(fetchedItem.lastSavedDate);
    XCTAssertEqualObjects(fetchedItem.lastSavedDate, item.lastSavedDate);
}

- (void)testLastSavedDate_UpdatesOnSaveSameObject
{
    NSMutableDictionary *keychainResultDict = [[NSMutableDictionary alloc] initWithDictionary:@{
                                         (__bridge id)kSecAttrService: self.service,
                                         (__bridge id)kSecAttrAccount: self.account,
                                         (__bridge id)kSecAttrGeneric: @"",
                                         (__bridge id)kSecAttrAccessGroup: @"",
                                         (__bridge id)kSecAttrModificationDate: [NSDate date],
                                         (__bridge id)kSecValueData: self.secretData
                                         }];
    
    NSArray *keychainResultArray = @[keychainResultDict];
    CFTypeRef result = CFBridgingRetain(keychainResultArray);

    OCMStub([self.secItemWrapperMock secItemAdd:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg setToValue:OCMOCK_VALUE(result)]]).andReturn(errSecSuccess).andForwardToRealObject;

    TWTRGenericKeychainItem *item = [[TWTRGenericKeychainItem alloc] initWithService:self.service account:self.account secret:self.secretData];
    XCTAssert([item storeInKeychain:nil]);

    NSDate *previousDate = item.lastSavedDate;  

    // Update keychain result to be a later date
    keychainResultDict[(__bridge id)kSecAttrModificationDate] = [NSDate distantFuture];
    CFTypeRef newResult = CFBridgingRetain(keychainResultArray);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg setToValue:OCMOCK_VALUE(newResult)]]).andReturn(errSecSuccess).andForwardToRealObject;

    XCTAssert([item storeInKeychain:nil]);
    XCTAssertNotNil(item.lastSavedDate);
    XCTAssertEqual([item.lastSavedDate compare:previousDate], NSOrderedDescending);
}

- (void)testLastSavedDate_UpdatesOnSaveFetchedObject
{
    NSMutableDictionary *keychainResultDict = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                (__bridge id)kSecAttrService: self.service,
                                                                                                (__bridge id)kSecAttrAccount: self.account,
                                                                                                (__bridge id)kSecAttrGeneric: @"",
                                                                                                (__bridge id)kSecAttrAccessGroup: @"",
                                                                                                (__bridge id)kSecAttrModificationDate: [NSDate date],
                                                                                                (__bridge id)kSecValueData: self.secretData
                                                                                                }];

    NSArray *keychainResultArray = @[keychainResultDict];
    CFTypeRef result = CFBridgingRetain(keychainResultArray);

    OCMStub([self.secItemWrapperMock secItemAdd:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg setToValue:OCMOCK_VALUE(result)]]).andReturn(errSecSuccess).andForwardToRealObject;

    TWTRGenericKeychainItem *item = [[TWTRGenericKeychainItem alloc] initWithService:self.service account:self.account secret:self.secretData];
    XCTAssert([item storeInKeychain:nil]);

    NSDate *previousDate = item.lastSavedDate;

    // Update keychain result to be a later date and to maintain retain count
    keychainResultDict[(__bridge id)kSecAttrModificationDate] = [NSDate distantFuture];
    CFTypeRef newResult = CFBridgingRetain(keychainResultArray);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg setToValue:OCMOCK_VALUE(newResult)]]).andReturn(errSecSuccess).andForwardToRealObject;
    XCTAssert([item storeInKeychain:nil]);

    // Mock return type to match the number of retain and releases
    CFTypeRef nextResult = CFBridgingRetain(keychainResultArray);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg setToValue:OCMOCK_VALUE(nextResult)]]).andReturn(errSecSuccess).andForwardToRealObject;
    
    TWTRGenericKeychainQuery *query = [TWTRGenericKeychainQuery queryForService:self.service account:self.account];
    TWTRGenericKeychainItem *fetchedItem = [[TWTRGenericKeychainItem storedItemsMatchingQuery:query error:nil] lastObject];

    XCTAssertNotNil(fetchedItem.lastSavedDate);
    XCTAssertEqual([fetchedItem.lastSavedDate compare:previousDate], NSOrderedDescending);
}

- (void)testLastSavedDate_SaveWithoutUpdateDoesNotModifyDate
{
    NSMutableDictionary *keychainResultDict = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                (__bridge id)kSecAttrService: self.service,
                                                                                                (__bridge id)kSecAttrAccount: self.account,
                                                                                                (__bridge id)kSecAttrGeneric: @"",
                                                                                                (__bridge id)kSecAttrAccessGroup: @"",
                                                                                                (__bridge id)kSecAttrModificationDate: [NSDate date],
                                                                                                (__bridge id)kSecValueData: self.secretData
                                                                                                }];

    NSArray *keychainResultArray = @[keychainResultDict];
    CFTypeRef result = CFBridgingRetain(keychainResultArray);

    OCMStub([self.secItemWrapperMock secItemAdd:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecSuccess);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg setToValue:OCMOCK_VALUE(result)]]).andReturn(errSecSuccess).andForwardToRealObject;

    TWTRGenericKeychainItem *item = [[TWTRGenericKeychainItem alloc] initWithService:self.service account:self.account secret:self.secretData];
    XCTAssert([item storeInKeychain:nil]);

    NSDate *previousDate = item.lastSavedDate;

    // Redefine class mock to override SecItemAdd stub.
    self.secItemWrapperMock = OCMClassMock([TWTRSecItemWrapper class]);
    // Mock return type to match the number of retain and releases
    CFTypeRef newResult = CFBridgingRetain(keychainResultArray);
    OCMStub([self.secItemWrapperMock secItemAdd:[OCMArg anyPointer] withResult:NULL]).andReturn(errSecDuplicateItem);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg setToValue:OCMOCK_VALUE(newResult)]]).andReturn(errSecSuccess).andForwardToRealObject;

    NSError *saveError;
    XCTAssertFalse([item storeInKeychainReplacingExisting:NO error:&saveError]);
    XCTAssertEqual(saveError.code, errSecDuplicateItem);

    // Mock return type to match the number of retain and releases
    CFTypeRef nextResult = CFBridgingRetain(keychainResultArray);
    OCMStub([self.secItemWrapperMock secItemCopyMatching:[OCMArg anyPointer] withResult:[OCMArg setToValue:OCMOCK_VALUE(nextResult)]]).andReturn(errSecSuccess).andForwardToRealObject;

    TWTRGenericKeychainQuery *query = [TWTRGenericKeychainQuery queryForService:self.service account:self.account];
    TWTRGenericKeychainItem *fetchedItem = [[TWTRGenericKeychainItem storedItemsMatchingQuery:query error:nil] lastObject];

    XCTAssertNotNil(fetchedItem.lastSavedDate);
    XCTAssertEqual([fetchedItem.lastSavedDate compare:previousDate], NSOrderedSame);
}

@end

@implementation TWTRSimpleNSCodingObject

- (instancetype)initWithName:(NSString *)name UUID:(NSString *)UUID
{
    self = [super init];
    if (self) {
        _name = [name copy];
        _UUID = [UUID copy];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    NSString *name = [coder decodeObjectForKey:@"name"];
    NSString *UUID = [coder decodeObjectForKey:@"UUID"];
    return [self initWithName:name UUID:UUID];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.UUID forKey:@"UUID"];
}

@end
