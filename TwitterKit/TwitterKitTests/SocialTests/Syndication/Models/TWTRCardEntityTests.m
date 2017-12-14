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
#import "TWTRCardEntity+Subclasses.h"
#import "TWTRCardEntity.h"

@interface TWTRCardEntity ()

/// Exposed for testing
+ (void)registerClass:(Class)entityClass;
+ (void)unregisterClass:(Class)entityClass;

@end

@interface TWTRPassingCardEntity : TWTRCardEntity <TWTRJSONConvertible>
@end
@interface TWTRFailingCardEntity : TWTRCardEntity <TWTRJSONConvertible>
@end

@interface TWTRCardEntityTests : XCTestCase

@end

@implementation TWTRCardEntityTests

- (void)testLoadFromDictionary_unknownCard
{
    TWTRCardEntity *entity = [TWTRCardEntity cardEntityFromJSONDictionary:@{}];
    XCTAssertNil(entity);
}

- (void)testRegisterClass_initsForPassingClass
{
    [TWTRCardEntity registerClass:[TWTRPassingCardEntity class]];

    TWTRCardEntity *entity = [TWTRCardEntity cardEntityFromJSONDictionary:@{}];
    XCTAssertTrue([entity isKindOfClass:[TWTRPassingCardEntity class]]);

    [TWTRCardEntity unregisterClass:[TWTRPassingCardEntity class]];
}

- (void)testRegisterClass_doesNotInitForFailingClass
{
    [TWTRCardEntity registerClass:[TWTRFailingCardEntity class]];

    TWTRCardEntity *entity = [TWTRCardEntity cardEntityFromJSONDictionary:@{}];
    XCTAssertNil(entity);

    [TWTRCardEntity unregisterClass:[TWTRFailingCardEntity class]];
}

@end

@implementation TWTRPassingCardEntity

+ (BOOL)canInitWithJSONDictionary:(NSDictionary<NSString *, id> *)JSONDictionary
{
    return YES;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary
{
    return [super init];
}

@end

@implementation TWTRFailingCardEntity

+ (BOOL)canInitWithJSONDictionary:(NSDictionary<NSString *, id> *)JSONDictionary
{
    return NO;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary
{
    return [super init];
}

@end
