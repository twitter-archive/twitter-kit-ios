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

#import "TWTRPersistentStore.h"
#import "TWTRTestCase.h"

#define StoreSize 65536
#define KeyOne (@"aString")
#define ValueOne (@"1value")
#define KeyTwo (@"bString")
#define ValueTwo (@"2value")
#define HugeKey                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    \
    (@"1010101010010101001010101010100101101010101001010100101010101010010110101010100101010010101010101001011010101010010101001010101010100101101010101001010100101010101010010110101010100101010010101010101001011010101010010101001010101010100101101010101001010100101010101010010110101010100101010010101010101001011010101010010101001010101010100101101010101001010100101010101010010110101010100101010010101010101001011010101010010101001010101010100101101010101001010100101010101010010110101010100101" \
     @"010010101010101001011010101010010101001010101010100101101010101001010100101010101010010110101010100101010010101010101001011010101010010101001010101010100101101010101001010100101010101010010110101010100101010010101010101001011010101010010101001010101010100101101010101001010100101010101010010110101010100101010010101010101001011010101010010101001010101010100101101010101001010100101010101010010110101010100101010010101010101001011010101010010101001010101010100101101010101001010100101010101"  \
     @"010010110101010100101010010101010101001011010101010010101001010101010100101")

@interface TWTRPersistentStoreTest : TWTRTestCase

@property (nonatomic, strong) TWTRPersistentStore *store;
@property (nonatomic, strong) NSString *path;

@end

@implementation TWTRPersistentStoreTest

- (void)setUp
{
    [super setUp];

    NSString *hostDir = [NSTemporaryDirectory() stringByAppendingPathComponent:@"TWTRPersistentStoreTest"];
    [[NSFileManager defaultManager] removeItemAtPath:hostDir error:nil];

    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:hostDir withIntermediateDirectories:YES attributes:nil error:&error]) {
        XCTFail(@"Could not create container dir, error %@", error);
    }

    NSString *path = [hostDir stringByAppendingPathComponent:@"store"];
    [self setPath:path];

    TWTRPersistentStore *store = [[TWTRPersistentStore alloc] initWithPath:path maxSize:StoreSize];
    [self setStore:store];
}

- (void)tearDown
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath:[self path] isDirectory:NULL]) {
        NSError *error = nil;
        if (![fileManager removeItemAtPath:[self path] error:&error]) {
            XCTFail(@"Could not remove temp store file, error %@", error);
        }

        if (![fileManager removeItemAtPath:[[self path] stringByDeletingLastPathComponent] error:&error]) {
            XCTFail(@"Could not remove temp store dir, error %@", error);
        }
    }

    [self setPath:nil];
    [self setStore:nil];

    [super tearDown];
}

- (void)testInit
{
    XCTAssertNotNil([self store]);
}

- (void)testInitWithNilPath
{
    TWTRPersistentStore *store = [[TWTRPersistentStore alloc] initWithPath:nil maxSize:1];
    XCTAssertNil(store);
}

- (void)testSetValue
{
    BOOL success = [[self store] setObject:ValueOne forKey:KeyOne];
    XCTAssertTrue(success);
    XCTAssertNotNil([[self store] objectForKey:KeyOne]);
}

- (void)testModDateOnReadValue
{
    BOOL success = [[self store] setObject:ValueOne forKey:KeyOne];
    XCTAssertTrue(success);

    NSString *path = [[self path] stringByAppendingPathComponent:KeyOne];
    NSDictionary *beforeReadValues = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];

    sleep(1);
    XCTAssertNotNil([[self store] objectForKey:KeyOne]);

    NSDictionary *afterReadeValues = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];

    XCTAssertFalse([[beforeReadValues objectForKey:@"NSFileModificationDate"] isEqualToDate:[afterReadeValues objectForKey:@"NSFileModificationDate"]]);
}

- (void)testSetValueReadFromNewInstance
{
    BOOL success = [[self store] setObject:ValueOne forKey:KeyOne];
    XCTAssertTrue(success);
    XCTAssertNotNil([[self store] objectForKey:KeyOne]);

    TWTRPersistentStore *store = [[TWTRPersistentStore alloc] initWithPath:[self path] maxSize:StoreSize];
    NSString *str = [store objectForKey:KeyOne];
    XCTAssertEqualObjects(str, ValueOne);
}

- (void)testSetNonNSCodingValue
{
    NSObject *obj = [[NSObject alloc] init];
    BOOL success = [[self store] setObject:(id)obj forKey:KeyTwo];
    XCTAssertFalse(success);
    XCTAssertNil([[self store] objectForKey:ValueTwo], @"");
}

- (void)testRemoveCorruptItems
{
    BOOL success = [[self store] setObject:ValueOne forKey:KeyOne];
    XCTAssertTrue(success);

    NSString *path = [[self path] stringByAppendingPathComponent:KeyOne];
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:path];
    [handle truncateFileAtOffset:1];

    XCTAssertNil([[self store] objectForKey:KeyOne], @"");
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:path], @"");
}

- (void)testRemoveObject
{
    BOOL success = [[self store] setObject:ValueOne forKey:KeyOne];
    XCTAssertTrue(success);
    XCTAssertNotNil([[self store] objectForKey:KeyOne], @"");

    [[self store] removeObjectForKey:KeyOne];

    XCTAssertNil([[self store] objectForKey:KeyOne], @"");
}

- (void)testRemoveAllObjects
{
    BOOL success = [[self store] setObject:ValueOne forKey:KeyOne];
    XCTAssertTrue(success);
    success = [[self store] setObject:ValueTwo forKey:KeyTwo];
    XCTAssertTrue(success);

    [[self store] removeAllObjects];

    XCTAssertNil([[self store] objectForKey:KeyOne], @"");
    XCTAssertNil([[self store] objectForKey:KeyTwo], @"");
}

- (void)testUpdateKeyValue
{
    BOOL success = [[self store] setObject:ValueOne forKey:KeyOne];
    XCTAssertTrue(success);

    NSArray *array = @[@"1", @"2"];
    success = [[self store] setObject:array forKey:KeyOne];
    XCTAssertTrue(success);
    XCTAssertEqualObjects(array, [[self store] objectForKey:KeyOne], @"");
}

- (void)testSetObjectNilKey
{
    BOOL success = [[self store] setObject:ValueOne forKey:nil];
    XCTAssertFalse(success);
}

- (void)testSetObjectNilValue
{
    BOOL success = [[self store] setObject:nil forKey:KeyOne];
    XCTAssertFalse(success);
}

- (void)testSetObjectHugePath
{
    BOOL success = [[self store] setObject:ValueOne forKey:HugeKey];
    XCTAssertFalse(success);
}

- (void)testTestLRU
{
    for (int idx = 0; idx < 600; idx++) {
        BOOL success = [[self store] setObject:ValueOne forKey:[[NSNumber numberWithInt:idx] stringValue]];
        XCTAssertTrue(success);
    }

    BOOL success = [[self store] setObject:ValueOne forKey:KeyOne];
    XCTAssertTrue(success);

    XCTAssertTrue([[self store] totalSize] < StoreSize);
    XCTAssertNotNil([[self store] objectForKey:@"599"]);
    XCTAssertNil([[self store] objectForKey:@"0"]);
    XCTAssertNotNil([[self store] objectForKey:KeyOne]);
}

- (void)testNilReturnForPathWithoutWritePermissions
{
    TWTRPersistentStore *store = [[TWTRPersistentStore alloc] initWithPath:@"/System/Library/store" maxSize:StoreSize];
    XCTAssertNil(store);
}

- (void)testCustomMaxSize
{
    NSString *hostDir = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"TWTRPersistentStoreTest"] stringByAppendingPathComponent:@"store2"];
    NSInteger maxSize = 1000;

    TWTRPersistentStore *store = [[TWTRPersistentStore alloc] initWithPath:hostDir maxSize:maxSize];
    XCTAssertNotNil(store);

    NSInteger iterations = 80;
    for (int idx = 0; idx < iterations; idx++) {
        BOOL success = [store setObject:ValueOne forKey:[[NSNumber numberWithInt:idx] stringValue]];
        XCTAssertTrue(success);
    }

    XCTAssertTrue([store totalSize] < maxSize);
    XCTAssertNotNil([store objectForKey:[@(iterations - 1) stringValue]]);
    XCTAssertNil([store objectForKey:@"0"]);

    [[NSFileManager defaultManager] removeItemAtPath:hostDir error:nil];
}

- (void)testEvictionLogic
{
    NSString *hostDir = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"TWTRPersistentStoreTest"] stringByAppendingPathComponent:@"store2"];

    TWTRPersistentStore *store = [[TWTRPersistentStore alloc] initWithPath:hostDir maxSize:1390];
    XCTAssertNotNil(store, );

    for (int idx = 0; idx < 10; idx++) {
        BOOL success = [store setObject:@"0" forKey:[[NSNumber numberWithInt:idx] stringValue]];
        XCTAssertTrue(success);
    }

    BOOL success = [store setObject:@"01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789" forKey:KeyOne];
    XCTAssertTrue(success);

    XCTAssertTrue([store totalSize] <= 1390);
    XCTAssertNotNil([store objectForKey:KeyOne]);
    XCTAssertNotNil([store objectForKey:@"9"]);
    XCTAssertNil([store objectForKey:@"0"]);
    XCTAssertNil([store objectForKey:@"2"]);

    [[NSFileManager defaultManager] removeItemAtPath:hostDir error:nil];
}

- (void)testTotalSizeParsingOnInit
{
    for (int idx = 0; idx < 600; idx++) {
        BOOL success = [[self store] setObject:ValueOne forKey:[[NSNumber numberWithInt:idx] stringValue]];
        XCTAssertTrue(success);
    }

    TWTRPersistentStore *store = [[TWTRPersistentStore alloc] initWithPath:[self path] maxSize:StoreSize];
    uint64_t expectedSize = 65520;
    XCTAssertTrue([store totalSize] > 0);
    XCTAssertEqual([store totalSize], expectedSize);
}

@end
