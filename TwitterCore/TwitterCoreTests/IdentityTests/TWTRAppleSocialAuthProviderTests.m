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

#if !TARGET_OS_TV

#import <Accounts/Accounts.h>
#import <OCMock/OCMock.h>
#import <TwitterCore/TWTRConstants.h>
#import <TwitterCore/TWTRUtils.h>
#import "TWTRAPIServiceConfig.h"
#import "TWTRAppleSocialAuthenticaticationProvider.h"
#import "TWTRAppleSocialAuthenticaticationProvider_Private.h"
#import "TWTRSession.h"
#import "TWTRTestCase.h"

@interface TWTRAppleSocialAuthProviderTests : TWTRTestCase

@property (nonatomic, readonly) TWTRAppleSocialAuthenticaticationProvider *appleSocialProvider;

@end

@interface TWTRAppleSocialAuthenticaticationProvider ()

- (void)requestAccessForTwitterAccountsWithCompletion:(ACAccountStoreRequestAccessCompletionHandler)completion;
- (void)getTwitterAccounts;
- (void)getAuthTokenWithAccount:(ACAccount *)account completion:(TWTRAuthenticationProviderCompletion)completion;
- (void)showActionSheetWithCompletion:(TWTRAuthenticationProviderCompletion)completion;

@end

@implementation TWTRAppleSocialAuthProviderTests

- (void)setUp
{
    [super setUp];

    TWTRAuthConfig *authConfig = [[TWTRAuthConfig alloc] initWithConsumerKey:@"test" consumerSecret:@"test"];
    id<TWTRAPIServiceConfig> apiServiceConfig = OCMProtocolMock(@protocol(TWTRAPIServiceConfig));

    _appleSocialProvider = [[TWTRAppleSocialAuthenticaticationProvider alloc] initWithAuthConfig:authConfig apiServiceConfig:apiServiceConfig];
}

- (void)testSocialAppAuthWith2Accounts
{
    id partialMockForSocialProvider = [OCMockObject partialMockForObject:self.appleSocialProvider];
    [[[partialMockForSocialProvider stub] andCall:@selector(mockRequestAccessForTwitterAccountsWithCompletion:) onObject:self] requestAccessForTwitterAccountsWithCompletion:[OCMArg any]];
    [[[partialMockForSocialProvider stub] andCall:@selector(mockGetTwitterAccounts2Account) onObject:self] getTwitterAccounts];
    [[[partialMockForSocialProvider stub] andCall:@selector(mockShowActionSheetWithCompletion:) onObject:self] showActionSheetWithCompletion:[OCMArg any]];
    [self.appleSocialProvider authenticateWithCompletion:^(NSDictionary *responseObject, NSError *error) {
        XCTAssertNotNil(responseObject);
        XCTAssertNil(error);
        [self setAsyncComplete:YES];
    }];
    [self waitForCompletion];
}

- (void)testSocialProvider1Account
{
    id partialMockForSocialProvider = [OCMockObject partialMockForObject:self.appleSocialProvider];
    [[[partialMockForSocialProvider stub] andCall:@selector(mockRequestAccessForTwitterAccountsWithCompletion:) onObject:self] requestAccessForTwitterAccountsWithCompletion:[OCMArg any]];
    [[[partialMockForSocialProvider stub] andCall:@selector(mockGetTwitterAccounts1Account) onObject:self] getTwitterAccounts];
    [[[partialMockForSocialProvider stub] andCall:@selector(mockGetAuthTokenWithAccount:completion:) onObject:self] getAuthTokenWithAccount:[OCMArg any] completion:[OCMArg any]];
    [self.appleSocialProvider authenticateWithCompletion:^(NSDictionary *responseObject, NSError *error) {
        XCTAssertNotNil(responseObject);
        XCTAssertNil(error);
        [self setAsyncComplete:YES];
    }];
    [self waitForCompletion];
}

- (void)testSocialProviderAccessNotGranted
{
    id partialMockForSocialProvider = [OCMockObject partialMockForObject:self.appleSocialProvider];
    [[[partialMockForSocialProvider stub] andCall:@selector(mockRequestAccessForTwitterAccountsNotGrantedWithCompletion:) onObject:self] requestAccessForTwitterAccountsWithCompletion:[OCMArg any]];
    [self.appleSocialProvider authenticateWithCompletion:^(NSDictionary *responseObject, NSError *error) {
        XCTAssertNil(responseObject);
        XCTAssertNotNil(error);
        XCTAssertEqual([error code], TWTRLogInErrorCodeDenied);
        [self setAsyncComplete:YES];
    }];
    [self waitForCompletion];
}

- (void)testSocialProviderNoTwitterAccounts
{
    id partialMockForSocialProvider = [OCMockObject partialMockForObject:self.appleSocialProvider];
    [[[partialMockForSocialProvider stub] andCall:@selector(mockRequestAccessForTwitterAccountsWithCompletion:) onObject:self] requestAccessForTwitterAccountsWithCompletion:[OCMArg any]];
    [[[partialMockForSocialProvider stub] andCall:@selector(mockGetTwitterAccountsNoAccounts) onObject:self] getTwitterAccounts];
    [self.appleSocialProvider authenticateWithCompletion:^(NSDictionary *responseObject, NSError *error) {
        XCTAssertNil(responseObject);
        XCTAssertNotNil(error);
        XCTAssertEqual([error code], TWTRLogInErrorCodeNoAccounts);
        [self setAsyncComplete:YES];
    }];
    [self waitForCompletion];
}

- (void)mockRequestAccessForTwitterAccountsNotGrantedWithCompletion:(ACAccountStoreRequestAccessCompletionHandler)completion
{
    completion(NO, nil);
}

- (void)mockRequestAccessForTwitterAccountsWithCompletion:(ACAccountStoreRequestAccessCompletionHandler)completion
{
    completion(YES, nil);
}

- (NSArray *)mockGetTwitterAccountsNoAccounts
{
    return @[];
}

- (NSArray *)mockGetTwitterAccounts1Account
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterAccount = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    ACAccount *account1 = [[ACAccount alloc] initWithAccountType:twitterAccount];
    return @[account1];
}

- (NSArray *)mockGetTwitterAccounts2Account
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterAccount = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    ACAccount *account1 = [[ACAccount alloc] initWithAccountType:twitterAccount];
    ACAccount *account2 = [[ACAccount alloc] initWithAccountType:twitterAccount];
    return @[account1, account2];
}

- (void)mockGetAuthTokenWithAccount:(ACAccount *)account completion:(TWTRAuthenticationProviderCompletion)completion
{
    completion([NSDictionary dictionary], nil);
}

- (void)mockShowActionSheetWithCompletion:(TWTRAuthenticationProviderCompletion)completion
{
    completion([NSDictionary dictionary], nil);
}

@end

#endif
