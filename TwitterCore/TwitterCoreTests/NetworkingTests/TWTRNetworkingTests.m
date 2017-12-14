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
#import "TWTRFakeAuthenticationChallengeSender.h"
#import "TWTRNetworking.h"
#import "TWTRServerTrustEvaluator.h"
#import "TWTRTestCase.h"
#import "TWTRUserAPIClient.h"

@interface TWTRNetworkingTests : TWTRTestCase

@property (nonatomic, readonly) TWTRAuthConfig *authConfig;
@property (nonatomic, readonly) TWTRNetworking *networking;
@property (nonatomic, readonly) TWTRUserAPIClient *userNetworking;
@property (nonatomic, strong) TWTRFakeAuthenticationChallengeSender *fakeSender;

@end

@interface TWTRNetworking ()

+ (NSString *)userAgentString;

@end

@implementation TWTRNetworkingTests

- (void)setUp
{
    [super setUp];

    _authConfig = [[TWTRAuthConfig alloc] initWithConsumerKey:@"consumerKey" consumerSecret:@"consumerSecret"];
    _networking = [[TWTRNetworking alloc] initWithAuthConfig:self.authConfig];

    _userNetworking = [[TWTRUserAPIClient alloc] initWithAuthConfig:self.authConfig authToken:@"authToken" authTokenSecret:@"authTokenSecret"];

    [self setFakeSender:[[TWTRFakeAuthenticationChallengeSender alloc] init]];
}

- (void)testGetRequest
{
    NSURLRequest *getReq = [self.networking URLRequestForGETMethodWithURLString:@"https://google.com" parameters:@{@"2": @"4 5"}];
    NSString *resultURL = @"https://google.com?2=4%205";
    XCTAssert(getReq != nil, @"");
    XCTAssert([resultURL isEqualToString:[[getReq URL] absoluteString]], @"");
}

- (void)testGetRequestNoParams
{
    NSURLRequest *getReq = [self.networking URLRequestForGETMethodWithURLString:@"https://google.com" parameters:nil];
    NSString *resultURL = @"https://google.com";
    XCTAssert(getReq != nil, @"");
    XCTAssert([resultURL isEqualToString:[[getReq URL] absoluteString]], @"");
}

- (void)testPostRequest
{
    NSString *originalURL = @"https://google.com";
    NSURLRequest *postReq = [self.networking URLRequestForPOSTMethodWithURLString:originalURL parameters:@{@"2": @"4 5"}];
    XCTAssertNotNil(postReq);
    XCTAssert([originalURL isEqualToString:[[postReq URL] absoluteString]]);
    XCTAssertEqualObjects([postReq HTTPMethod], @"POST");
    NSString *postData = [[NSString alloc] initWithData:[postReq HTTPBody] encoding:NSUTF8StringEncoding];
    XCTAssert([postData isEqualToString:@"2=4%205"]);
}

- (void)testDeleteRequest
{
    NSURLRequest *deleteReq = [self.networking URLRequestForDELETEMethodWithURLString:@"https://google.com?1=2" parameters:@{@"2": @"4 5"}];

    NSString *resultURL = @"https://google.com?1=2&2=4%205";
    XCTAssertNotNil(deleteReq);
    XCTAssert([resultURL isEqualToString:[[deleteReq URL] absoluteString]]);
    XCTAssertEqualObjects([deleteReq HTTPMethod], @"DELETE");
}

- (void)testTwitterGETRequest
{
    NSURLRequest *getReq = [self.userNetworking URLRequestWithMethod:@"GET" URLString:@"https://api.twitter.com" parameters:@{@"2": @"4 5"}];
    NSString *resultURL = @"https://api.twitter.com?2=4%205";
    XCTAssert(getReq != nil, @"");
    XCTAssert([resultURL isEqualToString:[[getReq URL] absoluteString]], @"");
    NSDictionary *headers = [getReq allHTTPHeaderFields];
    __block BOOL isAuthHeaderPresent = NO;
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        if ([key isEqualToString:@"Authorization"]) {
            isAuthHeaderPresent = YES;
            XCTAssert([obj rangeOfString:@"OAuth"].location != NSNotFound, @"");
        }
    }];
    XCTAssertTrue(isAuthHeaderPresent, @"");
}

#pragma mark - Mocks

- (NSURLProtectionSpace *)mockprotectionSpace
{
    NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc] initWithHost:@"test.com" port:80 protocol:@"https" realm:@"test realm" authenticationMethod:NSURLAuthenticationMethodServerTrust];
    return protectionSpace;
}

- (NSURLProtectionSpace *)mockprotectionSpaceHTTPBasic
{
    NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc] initWithHost:@"test.com" port:80 protocol:@"https" realm:@"test realm" authenticationMethod:NSURLAuthenticationMethodHTTPBasic];
    return protectionSpace;
}

- (BOOL)mockYesEvaluateServerTrust:(SecTrustRef)serverTrust forDomain:(NSString *)domain
{
    return YES;
}

- (BOOL)mockNoEvaluateServerTrust:(SecTrustRef)serverTrust forDomain:(NSString *)domain
{
    return NO;
}

- (NSURLRequest *)mockcurrentRequest
{
    return [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://test.com"]];
}

- (id<NSURLAuthenticationChallengeSender>)mockSender
{
    return [self fakeSender];
}

@end
