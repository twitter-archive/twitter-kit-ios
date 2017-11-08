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

#import "TWTRDictUtil.h"
#import "TWTRTestCase.h"

@interface TWTRDictUtilTests : TWTRTestCase

@property (nonatomic, strong) NSDictionary *dict;

@end

@implementation TWTRDictUtilTests

- (void)setUp
{
    [super setUp];

    NSDictionary *testDict = @{ @"null": [NSNull null], @"false": [NSNumber numberWithBool:NO], @"true": [NSNumber numberWithBool:YES], @"number": [NSNumber numberWithInt:42], @"string": @"foo", @"dict": @{@"foo": @"bar"}, @"array": @[@"baz"] };

    [self setDict:testDict];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNullValue
{
    NSDictionary *dict = [self dict];

    NSString *key = @"null";

    XCTAssertFalse([TWTRDictUtil boolForKey:key fromDict:dict]);
    XCTAssertEqual([TWTRDictUtil intForKey:key fromDict:dict], 0);
    XCTAssertEqual([TWTRDictUtil longlongForKey:key fromDict:dict], 0ll);
    XCTAssertNil([TWTRDictUtil stringForKey:key fromDict:dict]);
    XCTAssertNil([TWTRDictUtil dictForKey:key fromDict:dict]);
    XCTAssertNil([TWTRDictUtil arrayForKey:key fromDict:dict]);
}

- (void)testFalseValue
{
    NSDictionary *dict = [self dict];

    NSString *key = @"false";

    XCTAssertFalse([TWTRDictUtil boolForKey:key fromDict:dict]);
    XCTAssertEqual([TWTRDictUtil intForKey:key fromDict:dict], 0);
    XCTAssertEqual([TWTRDictUtil longlongForKey:key fromDict:dict], 0ll);
    XCTAssertNil([TWTRDictUtil stringForKey:key fromDict:dict]);
    XCTAssertNil([TWTRDictUtil dictForKey:key fromDict:dict]);
    XCTAssertNil([TWTRDictUtil arrayForKey:key fromDict:dict]);
}

- (void)testTrueValue
{
    NSDictionary *dict = [self dict];

    NSString *key = @"true";

    XCTAssertTrue([TWTRDictUtil boolForKey:key fromDict:dict]);
    XCTAssertEqual([TWTRDictUtil intForKey:key fromDict:dict], 1);
    XCTAssertEqual([TWTRDictUtil longlongForKey:key fromDict:dict], 1ll);
    XCTAssertNil([TWTRDictUtil stringForKey:key fromDict:dict]);
    XCTAssertNil([TWTRDictUtil dictForKey:key fromDict:dict]);
    XCTAssertNil([TWTRDictUtil arrayForKey:key fromDict:dict]);
}

- (void)testNumberValue
{
    NSDictionary *dict = [self dict];

    NSString *key = @"number";

    XCTAssertTrue([TWTRDictUtil boolForKey:key fromDict:dict]);
    XCTAssertEqual([TWTRDictUtil intForKey:key fromDict:dict], 42);
    XCTAssertEqual([TWTRDictUtil longlongForKey:key fromDict:dict], 42ll);
    XCTAssertNil([TWTRDictUtil stringForKey:key fromDict:dict]);
    XCTAssertNil([TWTRDictUtil dictForKey:key fromDict:dict]);
    XCTAssertNil([TWTRDictUtil arrayForKey:key fromDict:dict]);
}

- (void)testStringValue
{
    NSDictionary *dict = [self dict];

    NSString *key = @"string";

    XCTAssertFalse([TWTRDictUtil boolForKey:key fromDict:dict]);
    XCTAssertEqual([TWTRDictUtil intForKey:key fromDict:dict], 0);
    XCTAssertEqual([TWTRDictUtil longlongForKey:key fromDict:dict], 0ll);
    XCTAssertEqual([TWTRDictUtil stringForKey:key fromDict:dict], @"foo");
    XCTAssertNil([TWTRDictUtil dictForKey:key fromDict:dict]);
    XCTAssertNil([TWTRDictUtil arrayForKey:key fromDict:dict]);
}

- (void)testDictValue
{
    NSDictionary *dict = [self dict];

    NSString *key = @"dict";

    XCTAssertFalse([TWTRDictUtil boolForKey:key fromDict:dict]);
    XCTAssertEqual([TWTRDictUtil intForKey:key fromDict:dict], 0);
    XCTAssertEqual([TWTRDictUtil longlongForKey:key fromDict:dict], 0ll);
    XCTAssertNil([TWTRDictUtil stringForKey:key fromDict:dict]);
    XCTAssertEqualObjects([TWTRDictUtil dictForKey:key fromDict:dict], @{ @"foo": @"bar" });
    XCTAssertNil([TWTRDictUtil arrayForKey:key fromDict:dict]);
}

- (void)testArrayValue
{
    NSDictionary *dict = [self dict];

    NSString *key = @"array";

    XCTAssertFalse([TWTRDictUtil boolForKey:key fromDict:dict]);
    XCTAssertEqual([TWTRDictUtil intForKey:key fromDict:dict], 0);
    XCTAssertEqual([TWTRDictUtil longlongForKey:key fromDict:dict], 0ll);
    XCTAssertNil([TWTRDictUtil stringForKey:key fromDict:dict]);
    XCTAssertNil([TWTRDictUtil dictForKey:key fromDict:dict]);
    XCTAssertEqualObjects([TWTRDictUtil arrayForKey:key fromDict:dict], @[@"baz"]);
}

@end
