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

#import "TWTRAPINetworkErrorsShim.h"
#import "TWTRNetworkingConstants.h"
#import "TWTRTestCase.h"

@interface TWTRAPINetworkingErrorsShimTests : TWTRTestCase

@property (nonatomic, strong) NSHTTPURLResponse *response;

@end

@implementation TWTRAPINetworkingErrorsShimTests

- (void)setUp
{
    [super setUp];
    NSURL *URL = [[NSURL alloc] initWithString:@"http://twitter.com"];
    self.response = [[NSHTTPURLResponse alloc] initWithURL:URL statusCode:200 HTTPVersion:@"" headerFields:@{}];
}

- (void)testNoErrrorWhenNoData
{
    NSData *data = nil;
    TWTRAPINetworkErrorsShim *shim = [[TWTRAPINetworkErrorsShim alloc] initWithHTTPResponse:self.response responseData:data];
    XCTAssertNil([shim validate]);
}

- (void)testNoError
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{} options:0 error:nil];
    TWTRAPINetworkErrorsShim *shim = [[TWTRAPINetworkErrorsShim alloc] initWithHTTPResponse:self.response responseData:data];
    NSError *validationError = [shim validate];
    XCTAssertNil(validationError);
}

- (void)testGenericAPIError
{
    NSArray *errors = @[@{ @"message": @"foo", @"code": @123 }];
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{ @"errors": errors } options:0 error:nil];
    TWTRAPINetworkErrorsShim *shim = [[TWTRAPINetworkErrorsShim alloc] initWithHTTPResponse:self.response responseData:data];
    NSError *validationError = [shim validate];

    XCTAssert(validationError.code == 123);
    XCTAssertEqualObjects(validationError.userInfo[@"NSLocalizedFailureReason"], @"Twitter API error : foo (code 123)");
}

- (void)testStatusCodePopulation
{
    NSArray *errors = @[@{ @"message": @"foo", @"code": @123 }];
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{ @"errors": errors } options:0 error:nil];
    TWTRAPINetworkErrorsShim *shim = [[TWTRAPINetworkErrorsShim alloc] initWithHTTPResponse:self.response responseData:data];
    NSError *validationError = [shim validate];

    XCTAssert([validationError.userInfo[TWTRNetworkingStatusCodeKey] integerValue] == 200);
}

- (void)testAlreadyFavoritedError
{
    NSArray *errors = @[@{ @"message": @"You have already favorited this status.", @"code": @139 }];
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{ @"errors": errors } options:0 error:nil];
    TWTRAPINetworkErrorsShim *shim = [[TWTRAPINetworkErrorsShim alloc] initWithHTTPResponse:self.response responseData:data];
    NSError *validationError = [shim validate];

    XCTAssert(validationError.code == 139);
    XCTAssertEqualObjects(validationError.userInfo[@"NSLocalizedFailureReason"], @"Twitter API error : You have already favorited this status. (code 139)");
}

- (void)testAlreadyRetweetedError
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{ @"errors": @"sharing is not permissible for this status (Share validations failed)" } options:0 error:nil];
    TWTRAPINetworkErrorsShim *shim = [[TWTRAPINetworkErrorsShim alloc] initWithHTTPResponse:self.response responseData:data];
    NSError *validationError = [shim validate];

    XCTAssert(validationError.code == 327);
    XCTAssertEqualObjects(validationError.userInfo[@"NSLocalizedFailureReason"], @"Twitter API error : sharing is not permissible for this status (Share validations failed) (code 327)");
}

- (void)testResponseValidatorSetsErrorReturnsNO
{
    NSArray *errors = @[@{ @"message": @"You have already favorited this status.", @"code": @139 }];
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{ @"errors": errors } options:0 error:nil];

    TWTRAPIResponseValidator *valiator = [[TWTRAPIResponseValidator alloc] init];
    NSError *error;

    BOOL valid = [valiator validateResponse:self.response data:data error:&error];

    XCTAssertFalse(valid);
    XCTAssertNotNil(error);
}

- (void)testResponseValidatorHandlesNilError
{
    NSArray *errors = @[@{ @"message": @"You have already favorited this status.", @"code": @139 }];
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{ @"errors": errors } options:0 error:nil];

    TWTRAPIResponseValidator *valiator = [[TWTRAPIResponseValidator alloc] init];

    XCTAssertNoThrow([valiator validateResponse:self.response data:data error:nil]);
}

- (void)testResponseValidatorReturnsYESWhenNoError
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{} options:0 error:nil];

    TWTRAPIResponseValidator *valiator = [[TWTRAPIResponseValidator alloc] init];

    NSError *error;
    XCTAssertTrue([valiator validateResponse:self.response data:data error:&error]);
    XCTAssertNil(error);
}

@end
