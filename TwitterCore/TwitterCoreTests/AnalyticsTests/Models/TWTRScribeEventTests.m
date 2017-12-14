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
#import "TWTRScribeEvent.h"

@interface TWTRScribeEventTests : XCTestCase

@property (nonatomic, readonly) TWTRErrorScribeEvent *errorScribeEvent;
@property (nonatomic, readonly) NSError *error;

@end

@implementation TWTRScribeEventTests

- (void)setUp
{
    [super setUp];

    _error = [NSError errorWithDomain:@"com.fakedomain" code:888 userInfo:@{ NSLocalizedDescriptionKey: @"Localized desc" }];
    _errorScribeEvent = [[TWTRErrorScribeEvent alloc] initWithError:_error message:@"Error loading network stuff."];
}

#pragma mark - Error Scribe Object

- (void)testScribeError_HasProperNamespace
{
    XCTAssertEqualObjects(self.errorScribeEvent.eventNamespace, [TWTRScribeClientEventNamespace errorNamespace]);
}

- (void)testScribeError_HasCorrectProperties
{
    XCTAssertEqualObjects(self.errorScribeEvent.error, self.error);
    XCTAssertEqualObjects(self.errorScribeEvent.errorMessage, @"Error loading network stuff.");
}

- (void)testScribeError_ShowsErrorDomainAndCodeInDescription
{
    NSDictionary *representation = [self.errorScribeEvent dictionaryRepresentation];
    XCTAssertEqualObjects(representation[@"message"], @"Error loading network stuff.");
    NSArray *errors = representation[@"items"];
    NSDictionary *errorDetails = [errors firstObject];
    XCTAssert([errorDetails[@"description"] containsString:@"Domain=com.fakedomain"]);
    XCTAssert([errorDetails[@"description"] containsString:@"Error Code=888"]);
    XCTAssert([errorDetails[@"description"] containsString:@"Description=Localized desc"]);
}

- (void)testScribeError_PutsNestedErrorsIntoItemsArray
{
    NSError *insideError = [NSError errorWithDomain:@"com.innerdomain" code:444 userInfo:nil];
    NSError *outerError = [NSError errorWithDomain:@"com.outerdomain" code:222 userInfo:@{NSUnderlyingErrorKey: insideError}];

    TWTRErrorScribeEvent *scribe = [[TWTRErrorScribeEvent alloc] initWithError:outerError message:@"Error loading network stuff."];

    NSDictionary *representation = [scribe dictionaryRepresentation];
    NSArray *errors = representation[@"items"];
    NSDictionary *firstDetails = errors[0];
    NSDictionary *secondDetails = errors[1];

    XCTAssertEqual([errors count], 2);
    XCTAssert([firstDetails[@"description"] containsString:@"Domain=com.outerdomain"]);
    XCTAssert([secondDetails[@"description"] containsString:@"Domain=com.innerdomain"]);
}

@end
