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

#import "TWTRAppAuthProvider.h"
#import <TwitterCore/TWTRAssertionMacros.h>
#import "TWTRAPIServiceConfig.h"
#import "TWTRAuthConfig.h"
#import "TWTRAuthenticationConstants.h"
#import "TWTRAuthenticationProvider_Private.h"
#import "TWTRNetworking.h"
#import "TWTRNetworkingConstants.h"
#import "TWTRUtils.h"

@interface TWTRAppAuthProvider ()

@property (nonatomic, readonly) TWTRAuthConfig *authConfig;
@property (nonatomic, readonly) id<TWTRAPIServiceConfig> apiServiceConfig;
@property (nonatomic) TWTRNetworking *networkingClient;

@end

static NSString *const TWTRMissingConsumerKeyMsg = @"consumer key is nil or zero length";
static NSString *const TWTRMissingConsumerSecretMsg = @"consumer secret is nil or zero length";

@implementation TWTRAppAuthProvider

#pragma mark - Init

- (instancetype)initWithAuthConfig:(TWTRAuthConfig *)authConfig apiServiceConfig:(id<TWTRAPIServiceConfig>)apiServiceConfig
{
    NSAssert(authConfig.consumerKey.length > 0, TWTRMissingConsumerKeyMsg);
    NSAssert(authConfig.consumerSecret.length > 0, TWTRMissingConsumerSecretMsg);

    if (self = [super init]) {
        _authConfig = authConfig;
        _apiServiceConfig = apiServiceConfig;
        _networkingClient = [[TWTRNetworking alloc] initWithAuthConfig:authConfig];
    }
    return self;
}

#pragma mark - Authenticate

- (void)authenticateWithCompletion:(TWTRAuthenticationProviderCompletion)completion
{
    TWTRParameterAssertOrReturn(completion);

    NSURLRequest *request = [self appAuthTokenRequest];
    [self.networkingClient sendAsynchronousRequest:request
                                        completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                            [[self class] validateResponseWithResponse:response data:data connectionError:connectionError completion:completion];
                                        }];
}

#pragma mark - Helpers

- (NSURLRequest *)appAuthTokenRequest
{
    NSURL *url = TWTRAPIURLWithPath(self.apiServiceConfig, TWTRAppAuthTokenPath);
    NSDictionary *params = @{@"grant_type": @"client_credentials"};
    NSMutableURLRequest *request = [[self.networkingClient URLRequestWithMethod:@"POST" URLString:url.absoluteString parameters:params] mutableCopy];
    [request setValue:[self base64EncodedBasicAuthHeader] forHTTPHeaderField:TWTRAuthorizationHeaderField];
    [request setValue:TWTRContentTypeURLEncoded forHTTPHeaderField:TWTRContentTypeHeaderField];
    [request setValue:TWTRAcceptEncodingGzip forHTTPHeaderField:TWTRAcceptEncodingHeaderField];
    return request;
}

- (NSString *)base64EncodedBasicAuthHeader
{
    NSString *encodedConsumerKey = [TWTRUtils urlEncodedStringForString:self.authConfig.consumerKey];
    NSString *encodedConsumerSecret = [TWTRUtils urlEncodedStringForString:self.authConfig.consumerSecret];
    NSString *consumerKeyAndSecret = [NSString stringWithFormat:@"%@:%@", encodedConsumerKey, encodedConsumerSecret];
    NSData *consumerKeyAndSecretData = [consumerKeyAndSecret dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64ConsumerKeyAndSecret = [TWTRUtils base64EncodedStringWithData:consumerKeyAndSecretData];
    return [NSString stringWithFormat:@"Basic %@", base64ConsumerKeyAndSecret];
}

@end
