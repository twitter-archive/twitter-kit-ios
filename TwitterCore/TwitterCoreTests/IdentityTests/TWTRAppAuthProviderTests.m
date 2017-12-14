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

#import <OCMock/OCMock.h>
#import <TwitterCore/TWTRAuthConfig.h>
#import "TWTRAppAuthProvider.h"
#import "TWTRAppAuthProvider_Private.h"
#import "TWTRAuthenticationConstants.h"
#import "TWTRFakeAPIServiceConfig.h"
#import "TWTRNetworking.h"
#import "TWTRTestCase.h"

@interface TWTRAppAuthProvider ()

@property (nonatomic) TWTRNetworking *networkingClient;

@end

@interface TWTRAppAuthProviderTests : TWTRTestCase

@property (nonatomic, readonly) TWTRAppAuthProvider *appAuthProvider;
@property (nonatomic, readonly) NSString *consumerKey;
@property (nonatomic, readonly) NSString *consumerSecret;
@property (nonatomic, readonly) TWTRNetworking *httpClient;
@property (nonatomic, readonly) TWTRFakeAPIServiceConfig *apiServiceConfig;

@end

@implementation TWTRAppAuthProviderTests

- (void)setUp
{
    [super setUp];
    _apiServiceConfig = [[TWTRFakeAPIServiceConfig alloc] init];
    _consumerKey = @"keykeykey";
    _consumerSecret = @"secret";
    TWTRAuthConfig *authConfig = [[TWTRAuthConfig alloc] initWithConsumerKey:self.consumerKey consumerSecret:self.consumerSecret];
    _apiServiceConfig = [[TWTRFakeAPIServiceConfig alloc] init];

    _httpClient = [[TWTRNetworking alloc] initWithAuthConfig:authConfig];
    _appAuthProvider = [[TWTRAppAuthProvider alloc] initWithAuthConfig:authConfig apiServiceConfig:self.apiServiceConfig];
}

- (void)testInitWithConsumerKeyConsumerSecret_KeyAndSecret
{
    XCTAssertTrue([[self appAuthProvider] isKindOfClass:[TWTRAppAuthProvider class]]);
}

- (void)testAuthenticateWithCompletion_Success
{
    NSDictionary *mockResponseDict = @{TWTRAuthAppOAuthTokenKey: @"tokentoken", TWTRAuthTokenTypeKey: @"bearer"};
    NSData *mockResponseBodyData = [NSJSONSerialization dataWithJSONObject:mockResponseDict options:0 error:nil];

    id apiClientMock = [OCMockObject partialMockForObject:self.appAuthProvider.networkingClient];
    [[[apiClientMock stub] andDo:^(NSInvocation *invocation) {
        TWTRTwitterNetworkCompletion completionBlock;
        [invocation getArgument:&completionBlock atIndex:invocation.methodSignature.numberOfArguments - 1];
        completionBlock(nil, mockResponseBodyData, nil);
    }] sendAsynchronousRequest:OCMOCK_ANY
                     completion:OCMOCK_ANY];

    self.appAuthProvider.networkingClient = apiClientMock;

    [self.appAuthProvider authenticateWithCompletion:^(NSDictionary *responseDict, NSError *error) {
        NSString *token = responseDict[TWTRAuthAppOAuthTokenKey];
        XCTAssertNotNil(token);
        XCTAssert([token length] > 0, @"Token length is 0");
        XCTAssertEqualObjects(responseDict[TWTRAuthTokenTypeKey], @"bearer");
        XCTAssertNil(error, @"Authentication error in success test");
        [self setAsyncComplete:YES];
    }];

    [self waitForCompletion];

    [apiClientMock stopMocking];
}

- (void)testAppAuthTokenRequest
{
    NSURLRequest *request = [[self appAuthProvider] appAuthTokenRequest];
    NSString *HTTPMethod = [request HTTPMethod];
    XCTAssertEqualObjects(HTTPMethod, @"POST");
    NSString *authHeader = [request valueForHTTPHeaderField:TWTRAuthorizationHeaderField];
    XCTAssertEqualObjects(authHeader, @"Basic a2V5a2V5a2V5OnNlY3JldA==", @"Authorization header does not equal 'Basic ' followed by 'keykeykey:secret' base 64 encoded");
    NSString *postData = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
    XCTAssertTrue([postData isEqualToString:@"grant_type=client_credentials"]);
}

@end
