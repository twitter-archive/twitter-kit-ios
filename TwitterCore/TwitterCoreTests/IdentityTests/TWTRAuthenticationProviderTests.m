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

#import "TWTRTestCase.h"

#import "TWTRAuthenticationProvider.h"
#import "TWTRAuthenticationProvider_Private.h"

@interface TWTRAuthenticationProviderTests : TWTRTestCase

@end

@implementation TWTRAuthenticationProviderTests

- (void)testValidateResponseWithResponse_Success
{
    NSData *data = [@"{ \"key\": \"testvalue\" }" dataUsingEncoding:NSUTF8StringEncoding];
    [TWTRAuthenticationProvider validateResponseWithResponse:nil data:data connectionError:nil completion:^(NSDictionary *responseObject, NSError *error) {
        XCTAssertNotNil(responseObject);
        XCTAssertEqualObjects(responseObject[@"key"], @"testvalue");
        XCTAssertNil(error);
        [self setAsyncComplete:YES];
    }];
    [self waitForCompletion];
}

- (void)testValidateResponseWithResponse_ConnectionError
{
    NSData *data = [@"{ invalid json" dataUsingEncoding:NSUTF8StringEncoding];
    NSError *connectionError = [NSError errorWithDomain:@"TestDomain" code:1 userInfo:nil];
    [TWTRAuthenticationProvider validateResponseWithResponse:nil data:data connectionError:connectionError completion:^(NSDictionary *responseObject, NSError *error) {
        XCTAssertNil(responseObject);
        XCTAssertNotNil(error);
        NSString *errorDomain = [error domain];
        XCTAssertEqualObjects(errorDomain, @"TestDomain");
        [self setAsyncComplete:YES];
    }];
    [self waitForCompletion];
}

- (void)testValidateResponseWithResponse_InvalidJson
{
    NSData *data = [@"{ invalid json" dataUsingEncoding:NSUTF8StringEncoding];
    [TWTRAuthenticationProvider validateResponseWithResponse:nil data:data connectionError:nil completion:^(NSDictionary *responseObject, NSError *error) {
        XCTAssertNil(responseObject);
        XCTAssertNotNil(error);
        [self setAsyncComplete:YES];
    }];
    [self waitForCompletion];
}

- (void)testValidateResponseWithResponse_TopLevelJSONObjectNotDictionary
{
    NSData *data = [@"[ \"not a dictionary\" ]" dataUsingEncoding:NSUTF8StringEncoding];
    [TWTRAuthenticationProvider validateResponseWithResponse:nil data:data connectionError:nil completion:^(NSDictionary *responseObject, NSError *error) {
        XCTAssertNil(responseObject);
        XCTAssertNotNil(error);
        [self setAsyncComplete:YES];
    }];
    [self waitForCompletion];
}

@end
