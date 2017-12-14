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

#import "TWTRScribeClientEventNamespace.h"
#import "TWTRScribeClientEventNamespace_Private.h"
#import "TWTRScribeEvent.h"
#import "TWTRTestCase.h"

@interface TWTRScribeClientEventNamespaceTests : TWTRTestCase

@property (nonatomic, strong) TWTRScribeClientEventNamespace *namespace;

@end

@implementation TWTRScribeClientEventNamespaceTests

- (void)setUp
{
    [super setUp];

    _namespace = [[TWTRScribeClientEventNamespace alloc] initWithClient:@"client" page:@"page" section:@"section" component:@"component" element:@"element" action:@"action"];
}

- (void)testInit
{
    XCTAssertEqualObjects(self.namespace.client, @"client");
    XCTAssertEqualObjects(self.namespace.page, @"page");
    XCTAssertEqualObjects(self.namespace.section, @"section");
    XCTAssertEqualObjects(self.namespace.component, @"component");
    XCTAssertEqualObjects(self.namespace.element, @"element");
    XCTAssertEqualObjects(self.namespace.action, @"action");
}

- (void)testScribeKey
{
    NSString *key = [TWTRScribeClientEventNamespace scribeKey];
    XCTAssertEqualObjects(key, @"event_namespace");
}

- (void)testDictionaryRepresentation
{
    NSDictionary *dictionaryRepresentation = [self.namespace dictionaryRepresentation];

    XCTAssertEqualObjects(dictionaryRepresentation[TWTRScribeClientEventNamespaceClientKey], @"client");
    XCTAssertEqualObjects(dictionaryRepresentation[TWTRScribeClientEventNamespacePageKey], @"page");
    XCTAssertEqualObjects(dictionaryRepresentation[TWTRScribeClientEventNamespaceSectionKey], @"section");
    XCTAssertEqualObjects(dictionaryRepresentation[TWTRScribeClientEventNamespaceComponentKey], @"component");
    XCTAssertEqualObjects(dictionaryRepresentation[TWTRScribeClientEventNamespaceElementKey], @"element");
    XCTAssertEqualObjects(dictionaryRepresentation[TWTRScribeClientEventNamespaceActionKey], @"action");
}

- (void)testErrorNameSpaceValues
{
    TWTRScribeClientEventNamespace *namespace = [TWTRScribeClientEventNamespace errorNamespace];

    XCTAssertEqualObjects(namespace.client, @"tfw");
    XCTAssertEqualObjects(namespace.page, @"iOS");
    XCTAssertEqualObjects(namespace.section, @"timeline");
    XCTAssertEqualObjects(namespace.component, @"authentication");
    XCTAssertEqualObjects(namespace.element, @"credentials");
    XCTAssertEqualObjects(namespace.action, @"error");
}

- (void)validateTwitterKitUsageNamespacesWithNamespace:(TWTRScribeClientEventNamespace *)namespace expectedPage:(NSString *)expectedPage
{
    XCTAssertEqualObjects(namespace.client, TWTRScribeEventUniquesClient);
    XCTAssertEqualObjects(namespace.page, expectedPage);
    XCTAssertEqualObjects(namespace.section, TWTRScribeClientEventNamespaceEmptyValue);
    XCTAssertEqualObjects(namespace.component, TWTRScribeClientEventNamespaceEmptyValue);
    XCTAssertEqualObjects(namespace.element, TWTRScribeClientEventNamespaceEmptyValue);
    XCTAssertEqualObjects(namespace.action, TWTRScribeEventUniquesAction);
}

@end
