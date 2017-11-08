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
#import "TWTRNetworkingPipelinePackage.h"
#import "TWTRPipelineSessionMock.h"

@interface TWTRNetworkingPipelinePackageTests : XCTestCase
@property (nonatomic) NSURLRequest *request;
@property (nonatomic) TWTRPipelineSessionMock *sessionStore;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) TWTRNetworkingPipelineCallback callback;

@end

@implementation TWTRNetworkingPipelinePackageTests

- (void)setUp
{
    [super setUp];

    self.request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.twitter.com"]];
    self.sessionStore = [[TWTRPipelineSessionMock alloc] init];
    self.userID = @"user";
    self.callback = ^(NSData *data, NSURLResponse *response, NSError *error) {
    };
}

- (void)testInitializerSetsProperties
{
    TWTRNetworkingPipelinePackage *package = [[TWTRNetworkingPipelinePackage alloc] initWithRequest:self.request sessionStore:self.sessionStore userID:self.userID completion:self.callback];

    XCTAssertEqualObjects(self.request, package.request);
    XCTAssertEqualObjects(self.sessionStore, package.sessionStore);
    XCTAssertEqualObjects(self.userID, package.userID);
    XCTAssertEqualObjects(self.callback, package.callback);
}

- (void)testConvenienceInitializer
{
    TWTRNetworkingPipelinePackage *package1 = [TWTRNetworkingPipelinePackage packageWithRequest:self.request sessionStore:self.sessionStore userID:self.userID completion:self.callback];
    TWTRNetworkingPipelinePackage *package2 = [[TWTRNetworkingPipelinePackage alloc] initWithRequest:self.request sessionStore:self.sessionStore userID:self.userID completion:self.callback];

    XCTAssertEqualObjects(package1.request, package2.request);
    XCTAssertEqualObjects(package1.sessionStore, package2.sessionStore);
    XCTAssertEqualObjects(package1.userID, package2.userID);
    XCTAssertEqualObjects(package1.callback, package2.callback);
}

- (void)testCopyReturnsSameUUID
{
    TWTRNetworkingPipelinePackage *package = [[TWTRNetworkingPipelinePackage alloc] initWithRequest:self.request sessionStore:self.sessionStore userID:self.userID completion:self.callback];
    TWTRNetworkingPipelinePackage *packageCopy = [package copy];
    TWTRNetworkingPipelinePackage *retryCopy = [package copyForRetry];

    XCTAssertEqualObjects(package.UUID, packageCopy.UUID);
    XCTAssertEqualObjects(package.UUID, retryCopy.UUID);
}

- (void)testAttemptCounter;
{
    TWTRNetworkingPipelinePackage *package = [[TWTRNetworkingPipelinePackage alloc] initWithRequest:self.request sessionStore:self.sessionStore userID:self.userID completion:self.callback];

    // attemptCounter starts with 1 always
    XCTAssertEqual(package.attemptCounter, 1);
    TWTRNetworkingPipelinePackage *retryPackage = [package copyForRetry];
    XCTAssertEqual(retryPackage.attemptCounter, 2);
}

@end
