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
#import <TwitterCore/TWTRAppInstallationUUID.h>
#import <TwitterCore/TWTRAuthenticationConstants.h>
#import <TwitterCore/TWTRAuthenticator.h>
#import <TwitterCore/TWTRGuestSession.h>
#import <TwitterCore/TWTRSession.h>
#import <TwitterCore/TWTRSessionStore.h>
#import <TwitterCore/TWTRSessionStore_Private.h>
#import "TWTRAPIClient.h"
#import "TWTRAPIClient_Private.h"
#import "TWTRCookieStorageUtil.h"
#import "TWTRFixtureLoader.h"
#import "TWTRLoginURLParser.h"
#import "TWTRMobileSSO.h"
#import "TWTRMockURLSessionProtocol.h"
#import "TWTRNotificationConstants.h"
#import "TWTRStubMobileSSO.h"
#import "TWTRStubTwitterClient.h"
#import "TWTRTestCase.h"
#import "TWTRTestSessionStore.h"
#import "TWTRTwitter_Private.h"
#import "TWTRUser.h"

@interface TWTRTwitter ()
- (void)performWebBasedLogin:(UIViewController *)viewController completion:(TWTRLogInCompletion)completion;
@end

@interface TwitterTests : TWTRTestCase

@property (nonatomic, readonly) TWTRAuthClient *originalAuthClient;
@property (nonatomic, readonly) id<TWTRSessionStore_Private> sessionStore;
@property (nonatomic, readonly) TWTRTwitter *twitterKit;
@property (nonatomic, readonly) TWTRSession *session;
@property (nonatomic, readonly) TWTRGuestSession *guestSession;
@property (nonatomic, readonly) id mockLoginParser;
@property (nonatomic, readonly) id mockAPIClient;
@property (nonatomic, readonly) NSURLSession *mockURLSession;

@end

@implementation TwitterTests

- (void)setUp
{
    [super setUp];

    // Needs to be called before any Twitter related methods so we use the correct API Client stub.
    _mockURLSession = [TWTRAPIClient URLSessionForMockingWithProtocolClasses:@[[TWTRMockURLSessionProtocol class]]];
    _mockAPIClient = OCMClassMock([TWTRAPIClient class]);
    OCMStub([_mockAPIClient URLSession]).andReturn(_mockURLSession);

    // Mock login parser to pass valud URL scheme since it is tested in other file.
    _mockLoginParser = OCMClassMock([TWTRLoginURLParser class]);
    OCMStub([_mockLoginParser alloc]).andReturn(_mockLoginParser);
    OCMStub([_mockLoginParser initWithAuthConfig:OCMOCK_ANY]).andReturn(_mockLoginParser);
    OCMStub([_mockLoginParser hasValidURLScheme]).andReturn(YES);

    _twitterKit = [self createUniqueInstance];
    _session = [[TWTRSession alloc] initWithSessionDictionary:@{TWTRAuthOAuthTokenKey: @"token", TWTRAuthOAuthSecretKey: @"secret", TWTRAuthAppOAuthScreenNameKey: @"screenName", TWTRAuthAppOAuthUserIDKey: @"123"}];
    _guestSession = [[TWTRGuestSession alloc] initWithAccessToken:@"accessToken" guestToken:@"guestToken"];
    _sessionStore = [[TWTRTestSessionStore alloc] initWithUserSessions:@[_session] guestSession:nil];
}

- (void)tearDown
{
    XCTAssertTrue([TWTRMockURLSessionProtocol isEmpty]);  // if fails tests are broken.
    [self.mockAPIClient stopMocking];
    [self.mockLoginParser stopMocking];
    [super tearDown];
}

- (TWTRTwitter *)createUniqueInstance
{
    [TWTRTwitter resetSharedInstance];
    TWTRTwitter *twitter = [[TWTRTwitter alloc] init];
    [twitter startWithConsumerKey:@"k" consumerSecret:@"s"];
    XCTAssert([twitter class] == [TWTRTwitter class], @"Allocated Twitter object has class %@. If that class is an OCMock class, you probably need to call [twitterMock stopMocking] somewhere", [twitter class]);
    return twitter;
}

- (void)testResetSharedInstance
{
    TWTRTwitter *firstTwitter = [TWTRTwitter sharedInstance];
    [TWTRTwitter resetSharedInstance];
    TWTRTwitter *secondTwitter = [TWTRTwitter sharedInstance];
    XCTAssertNotEqual(firstTwitter, secondTwitter, @"sharedInstance returned pointer to old memory address after reseting");
}

- (void)testApplicationInstallID
{
    NSString *appID = [TWTRAppInstallationUUID appInstallationUUID];
    XCTAssertNotNil(appID);
    // get it a second time to check if we are able to get the same one back
    NSString *secondID = [TWTRAppInstallationUUID appInstallationUUID];
    XCTAssertEqualObjects(appID, secondID);
}

- (void)testLoginWithCompletion_callsLoginWithViewController
{
    TWTRLogInCompletion testCompletion = ^(TWTRSession *session, NSError *error) {
    };
    id mockTwitterKit = OCMPartialMock(self.twitterKit);
    OCMExpect([mockTwitterKit logInWithViewController:nil completion:testCompletion]);

    [mockTwitterKit logInWithCompletion:testCompletion];

    OCMVerifyAll(mockTwitterKit);
}

- (void)testLoginWithViewController_raisesException
{
    id mockLoginParserInstance = OCMClassMock([TWTRLoginURLParser class]);
    OCMStub([mockLoginParserInstance hasValidURLScheme]).andReturn(NO);

    id mockLoginParser = OCMClassMock([TWTRLoginURLParser class]);
    OCMStub([mockLoginParser alloc]).andReturn(mockLoginParserInstance);

    XCTAssertThrows([self.twitterKit logInWithCompletion:^(TWTRSession *_Nullable session, NSError *_Nullable error){
    }]);
}

- (void)testLoginWithViewController_callsAttemptAppLogin
{
    TWTRStubMobileSSO *stubMobileSSO = [[TWTRStubMobileSSO alloc] init];
    id mockMobileSSO = OCMClassMock([TWTRMobileSSO class]);
    OCMStub([mockMobileSSO alloc]).andReturn(stubMobileSSO);

    [self.twitterKit logInWithCompletion:^(TWTRSession *_Nullable session, NSError *_Nullable error){
    }];
    XCTAssert(stubMobileSSO.didAttemptAppLogin == YES);
}

- (void)testLoginWithViewController_performsWebBasedLoginOnError
{
    id mockTwitterKit = OCMPartialMock(self.twitterKit);
    OCMExpect([mockTwitterKit performWebBasedLogin:OCMOCK_ANY completion:OCMOCK_ANY]);
    [self.twitterKit logInWithCompletion:^(TWTRSession *_Nullable session, NSError *_Nullable error){
    }];
    OCMVerifyAll(mockTwitterKit);
}

- (void)testLoginWithViewController_releaseViewControllerAfterLogin
{
    UIViewController *viewController = [[UIViewController alloc] init];
    __weak typeof(viewController) weakViewController = viewController;
    [self.twitterKit logInWithViewController:viewController
                                  completion:^(TWTRSession *_Nullable session, NSError *_Nullable error){
                                  }];
    viewController = nil;
    XCTAssertNil(weakViewController);
}

- (void)testLogout_clearsWebViewCookies
{
    [self.twitterKit.sessionStore saveSession:self.session
                             withVerification:NO
                                   completion:^(id<TWTRAuthSession> _Nullable session, NSError *_Nullable error){
                                   }];

    id cookieUtilMock = [OCMockObject mockForClass:[TWTRCookieStorageUtil class]];
    [[cookieUtilMock expect] clearCookiesWithDomainSuffix:[OCMArg checkWithBlock:^BOOL(NSString *suffix) {
                                 return [suffix isEqualToString:@"twitter.com"];
                             }]];

    XCTAssertGreaterThanOrEqual([self.twitterKit.sessionStore existingUserSessions].count, 1);  // logout is a noop if there are no sessions.
    [self.twitterKit.sessionStore logOutUserID:self.session.userID];
    OCMVerifyAll(cookieUtilMock);
    [cookieUtilMock stopMocking];
}

- (void)testVersion
{
    XCTAssertNotNil([self.twitterKit version]);
}

- (void)testNotificationPostedWhenUserLoggedOut
{
    NSString *userID = [[NSUUID UUID] UUIDString];
    TWTRSession *session = [[TWTRSession alloc] initWithAuthToken:@"auth_toke" authTokenSecret:@"secret" userName:@"user" userID:userID];

    [[TWTRTwitter sharedInstance].sessionStore saveSession:session
                                          withVerification:NO
                                                completion:^(id a, id b){
                                                }];

    __block NSString *loggedOutID = nil;

    __weak __block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:TWTRUserDidLogOutNotification
                                                                                   object:nil
                                                                                    queue:[NSOperationQueue mainQueue]
                                                                               usingBlock:^(NSNotification *note) {
                                                                                   loggedOutID = note.userInfo[TWTRLoggedOutUserIDKey];
                                                                                   [[NSNotificationCenter defaultCenter] removeObserver:observer];
                                                                               }];

    [[TWTRTwitter sharedInstance].sessionStore logOutUserID:session.userID];
    XCTAssertEqualObjects(loggedOutID, session.userID);
}

#pragma mark - Mobile SSO

- (void)testMobileSSO_completesOnSuccess
{
    // Set up Mobile SSO to call completion synchronously
    TWTRSession *sampleSession = [[TWTRSession alloc] initWithAuthToken:@"token'" authTokenSecret:@"secret" userName:@"username" userID:@"9843"];
    id mockMobileSSO = OCMClassMock([TWTRMobileSSO class]);
    OCMStub([mockMobileSSO alloc]).andReturn(mockMobileSSO);
    OCMStub([mockMobileSSO initWithAuthConfig:OCMOCK_ANY]).andReturn(mockMobileSSO);

    OCMExpect([mockMobileSSO attemptAppLoginWithCompletion:[OCMArg checkWithBlock:^BOOL(TWTRLogInCompletion completion) {
                                 completion(sampleSession, nil);
                                 return YES;
                             }]]);

    XCTestExpectation *expectation = [self expectationWithDescription:@"completion called"];
    [self.twitterKit logInWithCompletion:^(TWTRSession *session, NSError *error) {
        NSLog(@"Done");
        [expectation fulfill];
    }];

    [self waitForExpectations:@[expectation] timeout:0.5];
    [mockMobileSSO stopMocking];
}

#pragma mark - Mocks
- (id<TWTRSessionStore_Private>)mockSessionStore
{
    return self.sessionStore;
}

- (BOOL)mockIsInitialized
{
    return YES;
}

@end
