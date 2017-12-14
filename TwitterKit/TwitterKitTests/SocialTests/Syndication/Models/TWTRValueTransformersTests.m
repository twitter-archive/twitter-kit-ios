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

#import <XCTest/XCTest.h>
#import "TWTRJSONConvertible.h"
#import "TWTRValueTransformers.h"

@interface TWTRConvertibleTestObject : NSObject <TWTRJSONConvertible>
@property (nonatomic) NSString *name;
@end

@implementation TWTRConvertibleTestObject

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary
{
    NSString *name = dictionary[@"name"];
    if (![name isKindOfClass:[NSString class]]) {
        return nil;
    }

    self = [super init];
    if (self) {
        _name = [name copy];
    }
    return self;
}

@end

@interface TWTRValueTransformersTests : XCTestCase
@property (nonatomic) NSValueTransformer *serverDateTransformer;
@property (nonatomic) NSValueTransformer *myRetweetIDTransformer;
@property (nonatomic) NSValueTransformer *URLTransformer;
@property (nonatomic) NSValueTransformer *aspectRatioTransfomer;
@property (nonatomic) NSValueTransformer *JSONConvertibleTransformer;
@property (nonatomic) NSDictionary *currentUserRetweetDictionary;
@property (nonatomic) NSDictionary *simpleJSON;
@property (nonatomic) NSString *myRetweetID;

@end

@implementation TWTRValueTransformersTests

- (void)setUp
{
    [super setUp];
    self.serverDateTransformer = [NSValueTransformer valueTransformerForName:TWTRServerDateValueTransformerName];
    self.myRetweetIDTransformer = [NSValueTransformer valueTransformerForName:TWTRMyRetweetIDValueTransformerName];
    self.URLTransformer = [NSValueTransformer valueTransformerForName:TWTRNSURLValueTransformerName];
    self.aspectRatioTransfomer = [NSValueTransformer valueTransformerForName:TWTRAspectRatioArrayTransformerName];
    self.JSONConvertibleTransformer = [TWTRJSONConvertibleTransformer transformerWithTargetClass:[TWTRConvertibleTestObject class]];

    self.myRetweetID = @"492812034954637312";
    self.currentUserRetweetDictionary = @{ @"id": @492812034954637312, @"id_str": self.myRetweetID };
    self.simpleJSON = @{ @"name": @"twitter" };
}

- (void)tearDown
{
    [super tearDown];
}

#pragma mark - Date String Transformer
- (void)testServerDateStringTransformer_validFormat
{
    NSString *string = @"Tue Jul 01 03:04:23 +0000 2014";
    XCTAssertNotNil([self.serverDateTransformer transformedValue:string]);
}

- (void)testServerDateStringTransformer_invalidFormat
{
    NSString *string = @"Tue Jul 01 030423 +0000 2014";
    XCTAssertNil([self.serverDateTransformer transformedValue:string]);
}

- (void)testServerDateStringTransformer_nilInput
{
    NSString *string = @"Tue Jul 01 030423 +0000 2014";
    XCTAssertNil([self.serverDateTransformer transformedValue:string]);
}

#pragma mark - TWTRMyRetweetIDValueTransformer Tests
- (void)testMyRetweetIDValueTransformer_validDictionary
{
    XCTAssertEqualObjects([self.myRetweetIDTransformer transformedValue:self.currentUserRetweetDictionary], self.myRetweetID);
}

- (void)testMyRetweetIDValueTransformer_invalidDictionary
{
    XCTAssertNil([self.myRetweetIDTransformer transformedValue:@{ @"id_str": @123 }]);
}

- (void)testMyRetweetIDValueTransformer_invalidClass
{
    XCTAssertNil([self.myRetweetIDTransformer transformedValue:@[@"id_str"]]);
}

#pragma mark - URL value transformer
- (void)testURLTransformer_validURLString
{
    NSString *string = @"http://www.twitter.com";
    NSURL *expected = [[NSURL alloc] initWithString:string];

    XCTAssertEqualObjects(expected, [self.URLTransformer transformedValue:string]);
}

- (void)testURLTransformer_nilInput
{
    XCTAssertNil([self.URLTransformer transformedValue:nil]);
}

- (void)testURLTransformer_wrongClass
{
    XCTAssertNil([self.URLTransformer transformedValue:@1]);
}

#pragma mark - TWTRAspectRatioArrayTransformer
- (void)testAspectRatioTransformer_correctInput
{
    id value = [self.aspectRatioTransfomer transformedValue:@[@2, @1]];
    XCTAssertEqualObjects(value, @2);
}

- (void)testAspectRatioTransformer_nilInput
{
    XCTAssertNil([self.aspectRatioTransfomer transformedValue:nil]);
}

- (void)testAspectRatioTransformer_invalidCountInput_3
{
    id value = [self.aspectRatioTransfomer transformedValue:@[@1, @2, @3]];
    XCTAssertNil(value);
}

- (void)testAspectRatioTransformer_invalidCountInput_1
{
    XCTAssertNil([self.aspectRatioTransfomer transformedValue:@[@1]]);
}

- (void)testAspectRatioTransformer_wrongClass
{
    XCTAssertNil([self.aspectRatioTransfomer transformedValue:@1]);
}

#pragma mark - TWTRJSONConvertibleTransformer
- (void)testJSONConvertibleTransformer_singleObject
{
    TWTRConvertibleTestObject *obj = [self.JSONConvertibleTransformer transformedValue:self.simpleJSON];

    XCTAssertEqualObjects(obj.name, @"twitter");
}

- (void)testJSONConvertibleTransformer_arrayOfObjects
{
    NSArray<TWTRConvertibleTestObject *> *objs = [self.JSONConvertibleTransformer transformedValue:@[@{ @"name": @"twitter" }]];

    XCTAssertEqual(objs.count, 1);
    XCTAssertEqualObjects(objs[0].name, @"twitter");
}

- (void)testJSONConvertibleTransformer_failIfNil
{
    XCTAssertNil([self.JSONConvertibleTransformer transformedValue:nil]);
}

- (void)testJSONConvertibleTransformer_failIfConversionFails
{
    NSDictionary *badJSON = @{ @"abc": @"xyz" };
    XCTAssertNil([self.JSONConvertibleTransformer transformedValue:badJSON]);
}

- (void)testJSONConvertibleTransformer_failIfConversionFails_collection
{
    NSArray *badJSON = @[@{ @"abc": @"xyz" }];
    XCTAssertNil([self.JSONConvertibleTransformer transformedValue:badJSON]);
}

@end
