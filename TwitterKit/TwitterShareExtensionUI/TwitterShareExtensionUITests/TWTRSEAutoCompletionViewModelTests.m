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

#import "TWTRSEAutoCompletionViewModel.h"

@import TFSUtilities.NSString_TFSWordRange;
@import XCTest;

@interface TWTRSEAutoCompletionViewModelTests : XCTestCase

@property (nonatomic, nonnull, readonly) TWTRSEAutoCompletionViewModel *viewModel;

@end

@implementation TWTRSEAutoCompletionViewModelTests

+ (void)setUp
{
    [super setUp];
    (void)[@"" wordRangeIncludingUnderscoreForIndex:0];
}

- (void)setUp
{
    [super setUp];
    _viewModel = [[TWTRSEAutoCompletionViewModel alloc] init];
}

- (void)tearDown
{
    _viewModel = nil;
    [super tearDown];
}

- (void)testNilWord
{
    XCTAssertFalse([self.viewModel wordIsHashtag:nil]);
    XCTAssertFalse([self.viewModel wordIsUsername:nil]);
}

- (void)testNonHashtagOrUsernameWord
{
    XCTAssertFalse([self.viewModel wordIsHashtag:@"foo"]);
    XCTAssertFalse([self.viewModel wordIsUsername:@"foo"]);
}

- (void)testHashtagWord
{
    XCTAssertTrue([self.viewModel wordIsHashtag:@"#foo"]);
    XCTAssertFalse([self.viewModel wordIsUsername:@"#foo"]);
}

- (void)testUsernameWord
{
    XCTAssertFalse([self.viewModel wordIsHashtag:@"@foo"]);
    XCTAssertTrue([self.viewModel wordIsUsername:@"@foo"]);
}

- (void)testStripNonUsername
{
    XCTAssertEqualObjects(@"foo", [self.viewModel stripUsernameMarkersFromWord:@"foo"]);
    XCTAssertEqualObjects(@"foo@", [self.viewModel stripUsernameMarkersFromWord:@"foo@"]);
    XCTAssertEqualObjects(@"fo#o", [self.viewModel stripUsernameMarkersFromWord:@"fo#o"]);
}

- (void)testRemoveAtSign
{
    XCTAssertEqualObjects(@"foo", [self.viewModel stripUsernameMarkersFromWord:@"@foo"]);
}

#pragma mark - Word Lookup

- (void)testEmptyString
{
#if DEBUG
    XCTAssertThrows([self.viewModel wordAroundSelectedLocation:10 inText:nil]);
#else
    XCTAssertNil([self.viewModel wordAroundSelectedLocation:10 inText:nil]);
#endif
}

- (void)testLocationOutOfBounds
{
    XCTAssertNil([self.viewModel wordAroundSelectedLocation:10 inText:@"foo bar"]);
}

- (void)testLocationAtEndOfString
{
    XCTAssertEqualObjects(@"foo", [self.viewModel wordAroundSelectedLocation:22 inText:@"this is a sentence foo"]);
}

- (void)testNilAfterSpaceAtEndOfString
{
    XCTAssertNil([self.viewModel wordAroundSelectedLocation:23 inText:@"this is a sentence foo "]);
}

- (void)testNilInSpaceBeforeWord
{
    XCTAssertNil([self.viewModel wordAroundSelectedLocation:5 inText:@"this is a sentence foo"]);
}

- (void)testLocationInMiddleOfStringInMiddleOfWord
{
    XCTAssertEqualObjects(@"is", [self.viewModel wordAroundSelectedLocation:6 inText:@"this is a sentence foo"]);
}

- (void)testLocationInMiddleOfStringAtEndOfWord
{
    XCTAssertEqualObjects(@"is", [self.viewModel wordAroundSelectedLocation:7 inText:@"this is a sentence foo"]);
}

- (void)testLocationAtBeginningOfString
{
    XCTAssertEqualObjects(@"this", [self.viewModel wordAroundSelectedLocation:0 inText:@"this is a sentence foo"]);
}

#pragma mark - AutoCompletion insertion

- (void)testInsertingHashtagBeforeWord
{
    NSUInteger insertionEndLocation = NSNotFound;
    XCTAssertEqualObjects(@"Xcode 8#thisisfine #this", [self.viewModel insertAutoCompletionWord:@"#thisisfine" inWordAtLocation:8 inText:@"Xcode 8 #this" insertionEndLocation:&insertionEndLocation]);
    XCTAssertEqual(insertionEndLocation, 18U);
}

- (void)testInsertingHashtagAtMiddleOfWord
{
    NSUInteger insertionEndLocation = NSNotFound;
    XCTAssertEqualObjects(@"Xcode 8 #thisisfine ", [self.viewModel insertAutoCompletionWord:@"#thisisfine" inWordAtLocation:11 inText:@"Xcode 8 #this" insertionEndLocation:&insertionEndLocation]);
    XCTAssertEqual(insertionEndLocation, 20U);
}

- (void)testInsertingHashtagAtBeginningOfWord
{
    NSUInteger insertionEndLocation1 = NSNotFound;
    NSUInteger insertionEndLocation2 = NSNotFound;

    XCTAssertEqualObjects(@"Xcode 8 #thisisfine ", [self.viewModel insertAutoCompletionWord:@"#thisisfine" inWordAtLocation:9 inText:@"Xcode 8 #this" insertionEndLocation:&insertionEndLocation1]);
    XCTAssertEqualObjects(@"Xcode 8 #thisisfine ", [self.viewModel insertAutoCompletionWord:@"#thisisfine" inWordAtLocation:10 inText:@"Xcode 8 #this" insertionEndLocation:&insertionEndLocation2]);

    XCTAssertEqual(insertionEndLocation1, 20U);
    XCTAssertEqual(insertionEndLocation2, 20U);
}

- (void)testInsertingHashtagAtEndOfWord
{
    NSUInteger insertionEndLocation = NSNotFound;
    XCTAssertEqualObjects(@"Xcode 8 #thisisfine ", [self.viewModel insertAutoCompletionWord:@"#thisisfine" inWordAtLocation:13 inText:@"Xcode 8 #this" insertionEndLocation:&insertionEndLocation]);
    XCTAssertEqual(insertionEndLocation, 20U);
}

- (void)testInsertingUsernameAtMiddleOfWord
{
    NSUInteger insertionEndLocation = NSNotFound;
    XCTAssertEqualObjects(@"Xcode @Javi 8", [self.viewModel insertAutoCompletionWord:@"@Javi" inWordAtLocation:8 inText:@"Xcode @Ja 8" insertionEndLocation:&insertionEndLocation]);
    XCTAssertEqual(insertionEndLocation, 11U);
}

@end
