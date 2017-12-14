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

    XCTAssertFalse([TWTRDictUtil twtr_boolForKey:key inDict:dict]);
    XCTAssertEqual([TWTRDictUtil twtr_intForKey:key inDict:dict], 0);
    XCTAssertEqual([TWTRDictUtil twtr_longlongForKey:key inDict:dict], 0ll);
    XCTAssertNil([TWTRDictUtil twtr_stringForKey:key inDict:dict]);
    XCTAssertNil([TWTRDictUtil twtr_dictForKey:key inDict:dict]);
    XCTAssertNil([TWTRDictUtil twtr_arrayForKey:key inDict:dict]);
}

- (void)testFalseValue
{
    NSDictionary *dict = [self dict];

    NSString *key = @"false";

    XCTAssertFalse([TWTRDictUtil twtr_boolForKey:key inDict:dict]);
    XCTAssertEqual([TWTRDictUtil twtr_intForKey:key inDict:dict], 0);
    XCTAssertEqual([TWTRDictUtil twtr_longlongForKey:key inDict:dict], 0ll);
    XCTAssertNil([TWTRDictUtil twtr_stringForKey:key inDict:dict]);
    XCTAssertNil([TWTRDictUtil twtr_dictForKey:key inDict:dict]);
    XCTAssertNil([TWTRDictUtil twtr_arrayForKey:key inDict:dict]);
}

- (void)testTrueValue
{
    NSDictionary *dict = [self dict];

    NSString *key = @"true";

    XCTAssertTrue([TWTRDictUtil twtr_boolForKey:key inDict:dict]);
    XCTAssertEqual([TWTRDictUtil twtr_intForKey:key inDict:dict], 1);
    XCTAssertEqual([TWTRDictUtil twtr_longlongForKey:key inDict:dict], 1ll);
    XCTAssertNil([TWTRDictUtil twtr_stringForKey:key inDict:dict]);
    XCTAssertNil([TWTRDictUtil twtr_dictForKey:key inDict:dict]);
    XCTAssertNil([TWTRDictUtil twtr_arrayForKey:key inDict:dict]);
}

- (void)testNumberValue
{
    NSDictionary *dict = [self dict];

    NSString *key = @"number";

    XCTAssertTrue([TWTRDictUtil twtr_boolForKey:key inDict:dict]);
    XCTAssertEqual([TWTRDictUtil twtr_intForKey:key inDict:dict], 42);
    XCTAssertEqual([TWTRDictUtil twtr_longlongForKey:key inDict:dict], 42ll);
    XCTAssertNil([TWTRDictUtil twtr_stringForKey:key inDict:dict]);
    XCTAssertNil([TWTRDictUtil twtr_dictForKey:key inDict:dict]);
    XCTAssertNil([TWTRDictUtil twtr_arrayForKey:key inDict:dict]);
}

- (void)testStringValue
{
    NSDictionary *dict = [self dict];

    NSString *key = @"string";

    XCTAssertFalse([TWTRDictUtil twtr_boolForKey:key inDict:dict]);
    XCTAssertEqual([TWTRDictUtil twtr_intForKey:key inDict:dict], 0);
    XCTAssertEqual([TWTRDictUtil twtr_longlongForKey:key inDict:dict], 0ll);
    XCTAssertEqual([TWTRDictUtil twtr_stringForKey:key inDict:dict], @"foo");
    XCTAssertNil([TWTRDictUtil twtr_dictForKey:key inDict:dict]);
    XCTAssertNil([TWTRDictUtil twtr_arrayForKey:key inDict:dict]);
}

- (void)testDictValue
{
    NSDictionary *dict = [self dict];

    NSString *key = @"dict";

    XCTAssertFalse([TWTRDictUtil twtr_boolForKey:key inDict:dict]);
    XCTAssertEqual([TWTRDictUtil twtr_intForKey:key inDict:dict], 0);
    XCTAssertEqual([TWTRDictUtil twtr_longlongForKey:key inDict:dict], 0ll);
    XCTAssertNil([TWTRDictUtil twtr_stringForKey:key inDict:dict]);
    XCTAssertEqualObjects([TWTRDictUtil twtr_dictForKey:key inDict:dict], @{@"foo": @"bar"});
    XCTAssertNil([TWTRDictUtil twtr_arrayForKey:key inDict:dict]);
}

- (void)testArrayValue
{
    NSDictionary *dict = [self dict];

    NSString *key = @"array";

    XCTAssertFalse([TWTRDictUtil twtr_boolForKey:key inDict:dict]);
    XCTAssertEqual([TWTRDictUtil twtr_intForKey:key inDict:dict], 0);
    XCTAssertEqual([TWTRDictUtil twtr_longlongForKey:key inDict:dict], 0ll);
    XCTAssertNil([TWTRDictUtil twtr_stringForKey:key inDict:dict]);
    XCTAssertNil([TWTRDictUtil twtr_dictForKey:key inDict:dict]);
    XCTAssertEqualObjects([TWTRDictUtil twtr_arrayForKey:key inDict:dict], @[@"baz"]);
}

@end
