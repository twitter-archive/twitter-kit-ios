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
#import "TWTRAuthenticationConstants.h"
#import "TWTRAuthenticator.h"
#import "TWTRAuthenticator_Private.h"
#import "TWTRKeychainWrapper.h"
#import "TWTRKeychainWrapper_Private.h"
#import "TWTRTestCase.h"

@interface TWTRAuthenticator ()

+ (NSString *)keychainAccountStringForAuthType:(NSString *)authType;
+ (void)saveAuthenticationWithDictionary:(NSDictionary *)authDict forAuthType:(TWTRAuthType)authType;

@end

@interface TWTRAuthenticatorTests : TWTRTestCase

@end

@implementation TWTRAuthenticatorTests

- (void)testAuthenticationResponseForAuthType_successfullyRetrievesSavedGuestToken
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

    if (@available(iOS 10.0, *)) {
        TWTRKeychainWrapper *keychainWrapper = [TWTRAuthenticator keychainWrapperForAuthType:TWTRAuthTypeGuest];
        id keychainWrapperMock = OCMPartialMock(keychainWrapper);
        OCMStub([keychainWrapperMock writeToKeychain]).andReturn(YES);

        id authenticatorMock = OCMClassMock([TWTRAuthenticator class]);
        OCMStub([authenticatorMock keychainWrapperForAuthType:TWTRAuthTypeGuest]).andReturn(keychainWrapperMock);
    }

    [TWTRAuthenticator saveAuthenticationWithDictionary:@{ TWTRAuthAppOAuthTokenKey: @"app", TWTRGuestAuthOAuthTokenKey: @"guest" } forAuthType:TWTRAuthTypeGuest error:nil];
    NSDictionary *guestResponseDict = [TWTRAuthenticator authenticationResponseForAuthType:TWTRAuthTypeGuest];
    XCTAssertEqualObjects(@"app", guestResponseDict[TWTRAuthAppOAuthTokenKey]);
    XCTAssertEqualObjects(@"guest", guestResponseDict[TWTRGuestAuthOAuthTokenKey]);
    [TWTRAuthenticator logoutAuthType:TWTRAuthTypeGuest];
#pragma clang diagnostic pop
}

@end
