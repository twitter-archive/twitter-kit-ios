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

#import <TwitterCore/TWTRAuthConfig.h>
#import <TwitterCore/TWTRAuthSession.h>
#import <TwitterCore/TWTRAuthenticationConstants.h>
#import "TWTRAuthenticationTestUtil.h"
#import "TWTROAuth1aAuthRequestSigner.h"
#import "TWTRSession.h"
#import "TWTRTestCase.h"

@interface TWTROAuth1aAuthRequestSignerTests : TWTRTestCase

@property (nonatomic, strong, readonly) NSURLRequest *request;
@property (nonatomic, strong, readonly) TWTRAuthConfig *authConfig;
@property (nonatomic, strong, readonly) id<TWTRAuthSession> authSession;
@property (nonatomic, strong, readonly) NSURLRequest *signedRequest;

@end

@implementation TWTROAuth1aAuthRequestSignerTests

- (void)setUp
{
    [super setUp];

    _request = [self mutableTwitterRequest];

    _authSession = [[TWTRSession alloc] initWithSessionDictionary:@{ TWTRAuthOAuthTokenKey: @"token", TWTRAuthOAuthSecretKey: @"secret", TWTRAuthAppOAuthScreenNameKey: @"screenname", TWTRAuthAppOAuthUserIDKey: @"1" }];
    _authConfig = [[TWTRAuthConfig alloc] initWithConsumerKey:@"consumerKey" consumerSecret:@"consumerSecret"];
    _signedRequest = [TWTROAuth1aAuthRequestSigner signedURLRequest:_request authConfig:_authConfig session:_authSession];
}

- (void)testSignedRequestWithUserSession_copiedExistingHeader
{
    XCTAssertTrue([TWTRAuthenticationTestUtil URLRequest:self.signedRequest header:@"X-Test-Header" equalsExpectedValue:@"value"]);
}

- (void)testSignedRequestWithUserSession_containsOAuthNonce
{
    NSString *oauthNonce = [TWTROAuth1aAuthRequestSignerTests authorizationHeader:@"oauth_nonce" fromURLRequest:self.signedRequest];
    XCTAssertNotNil(oauthNonce);
}

- (void)testSignedRequestWithUserSession_OAuthNonceIsUnique
{
    NSString *oauthNonce1 = [TWTROAuth1aAuthRequestSignerTests authorizationHeader:@"oauth_nonce" fromURLRequest:self.signedRequest];
    NSURLRequest *signedRequest2 = [TWTROAuth1aAuthRequestSigner signedURLRequest:_request authConfig:self.authConfig session:_authSession];
    NSString *oauthNonce2 = [TWTROAuth1aAuthRequestSignerTests authorizationHeader:@"oauth_nonce" fromURLRequest:signedRequest2];
    XCTAssertNotEqualObjects(oauthNonce1, oauthNonce2);
}

- (void)testSignedRequestWithUserSession_containsOAuthConsumerKey
{
    NSString *consumerKey = [TWTROAuth1aAuthRequestSignerTests authorizationHeader:@"oauth_consumer_key" fromURLRequest:self.signedRequest];
    XCTAssertEqualObjects(consumerKey, @"consumerKey");
}

- (void)testSignedRequestWithUserSession_containsOAuthConsumerSignature
{
    NSString *signature = [TWTROAuth1aAuthRequestSignerTests authorizationHeader:@"oauth_signature" fromURLRequest:self.signedRequest];
    XCTAssertNotNil(signature);
}

- (void)testSignedRequestWithUserSession_oauthMethodHMAC
{
    NSString *method = [TWTROAuth1aAuthRequestSignerTests authorizationHeader:@"oauth_signature_method" fromURLRequest:self.signedRequest];
    XCTAssertEqualObjects(method, @"HMAC-SHA1");
}

- (void)testSignedRequestWithUserSession_containsOAuthToken
{
    NSString *token = [TWTROAuth1aAuthRequestSignerTests authorizationHeader:@"oauth_token" fromURLRequest:self.signedRequest];
    XCTAssertEqualObjects(token, @"token");
}

- (void)testSignedRequestWithUserSession_containsOAuthVersion
{
    NSString *version = [TWTROAuth1aAuthRequestSignerTests authorizationHeader:@"oauth_version" fromURLRequest:self.signedRequest];
    XCTAssertEqualObjects(version, @"1.0");
}

#pragma mark - Multipart form

- (void)testOAuth1ASignerDoesNotRemoveMultipartBody
{
    NSMutableURLRequest *request = [self mutableTwitterRequest];
    request.HTTPBody = [self multipartFormBody];
    [request setValue:@"multipart/form-data; boundary=B" forHTTPHeaderField:@"Content-Type"];

    NSURLRequest *signedRequest = [TWTROAuth1aAuthRequestSigner signedURLRequest:request authConfig:self.authConfig session:self.authSession];

    XCTAssertEqualObjects(request.HTTPBody, signedRequest.HTTPBody);
}

- (void)testOAuth1ASignerDoesNotRemoveMultipartBody_WithMixedCase
{
    NSMutableURLRequest *request = [self mutableTwitterRequest];
    request.HTTPBody = [self multipartFormBody];
    [request setValue:@"multiPart/form-Data; boundary=B" forHTTPHeaderField:@"Content-Type"];

    NSURLRequest *signedRequest = [TWTROAuth1aAuthRequestSigner signedURLRequest:request authConfig:self.authConfig session:self.authSession];

    XCTAssertEqualObjects(request.HTTPBody, signedRequest.HTTPBody);
}

- (NSData *)multipartFormBody
{
    NSString *body = @"--B\r\n"
                     @"Content-Disposition: form-data; name=\"text\""
                     @"some textual data here\n"
                     @"--B--\r\n";
    return [body dataUsingEncoding:NSUTF8StringEncoding];
    ;
}

#pragma mark - JSON request

- (void)testOAuth1ASignerDoesNotRemoveJSONBody
{
    NSMutableURLRequest *request = [self mutableTwitterRequest];
    request.HTTPBody = [self jsonBody];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSURLRequest *signedRequest = [TWTROAuth1aAuthRequestSigner signedURLRequest:request authConfig:self.authConfig session:self.authSession];

    XCTAssertEqualObjects(request.HTTPBody, signedRequest.HTTPBody);
}

- (void)testOAuth1ASignerDoesNotRemoveJSONBody_WithMixedCase
{
    NSMutableURLRequest *request = [self mutableTwitterRequest];
    request.HTTPBody = [self jsonBody];
    [request setValue:@"APPLicaTION/jsON" forHTTPHeaderField:@"Content-Type"];

    NSURLRequest *signedRequest = [TWTROAuth1aAuthRequestSigner signedURLRequest:request authConfig:self.authConfig session:self.authSession];

    XCTAssertEqualObjects(request.HTTPBody, signedRequest.HTTPBody);
}

- (NSData *)jsonBody
{
    NSString *body = @"{\"test\": [\"value 1\", \"value 2\"]}";
    return [body dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - Helpers

+ (NSString *)authorizationHeader:(NSString *)header fromURLRequest:(NSURLRequest *)URLRequest
{
    NSDictionary *headers = [URLRequest allHTTPHeaderFields];
    /**
     Example: https://dev.twitter.com/oauth/overview/authorizing-requests

     Authorization:
        OAuth oauth_consumer_key="xvz1evFS4wEEPTGEFPHBog",
            oauth_nonce="kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg",
            oauth_signature="tnnArxj06cWHq44gCs1OSKk%2FjLY%3D",
            oauth_signature_method="HMAC-SHA1",
            oauth_timestamp="1318622958",
            oauth_token="370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb",
            oauth_version="1.0"
     */
    NSString *authorizationHeader = headers[@"Authorization"];
    NSRegularExpressionOptions options = NSRegularExpressionCaseInsensitive;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\w+=\"[\\w\\d%-\\.]+\"" options:options error:nil];
    NSArray *matches = [regex matchesInString:authorizationHeader options:0 range:NSMakeRange(0, [authorizationHeader length])];
    for (NSTextCheckingResult *match in matches) {
        NSString *oauthHeaderPair = [authorizationHeader substringWithRange:match.range];
        NSArray *oauthHeader = [oauthHeaderPair componentsSeparatedByString:@"="];
        if ([[oauthHeader firstObject] isEqualToString:header]) {
            NSString *value = [oauthHeader lastObject];
            return [value stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        }
    }
    return nil;
}

- (NSMutableURLRequest *)mutableTwitterRequest
{
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/endpoint"];
    NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:url];
    [mutableRequest setValue:@"value" forHTTPHeaderField:@"X-Test-Header"];
    return mutableRequest;
}

@end
