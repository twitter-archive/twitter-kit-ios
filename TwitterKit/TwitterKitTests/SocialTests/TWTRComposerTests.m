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
#import <TwitterCore/TWTRAuthenticationConstants.h>
#import <TwitterCore/TWTRSessionStore_Private.h>
#import <XCTest/XCTest.h>
#import <XCTest/XCTestCase+AsynchronousTesting.h>
#import "TWTRComposer.h"
#import "TWTRComposerViewController.h"
#import "TWTRImages.h"
#import "TWTRSharedComposerWrapper.h"
#import "TWTRTweet.h"
#import "TWTRTwitter.h"
#import "TWTRTwitter_Private.h"

@interface TWTRComposer () <TWTRComposerViewControllerDelegate>
@end

@interface TWTRComposerTests : XCTestCase

@end

@implementation TWTRComposerTests

- (void)setUp
{
    [[TWTRTwitter sharedInstance] startWithConsumerKey:@"key" consumerSecret:@"secret"];

    TWTRSession *userSession = [[TWTRSession alloc] initWithSessionDictionary:@{TWTRAuthOAuthTokenKey: @"token", TWTRAuthOAuthSecretKey: @"secret", TWTRAuthAppOAuthScreenNameKey: @"screenname", TWTRAuthAppOAuthUserIDKey: @"555"}];
    [[TWTRTwitter sharedInstance].sessionStore saveSession:userSession
                                          withVerification:NO
                                                completion:^(id<TWTRAuthSession> session, NSError *error){
                                                }];
}

- (void)tearDown
{
    [TWTRTwitter resetSharedInstance];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

- (void)testComposer_notNil
{
    TWTRComposer *composer = [[TWTRComposer alloc] init];
    XCTAssertNotNil(composer);
}

#pragma mark - Initial Properties

- (void)testComposer_usesText
{
    TWTRComposer *composer = [[TWTRComposer alloc] init];
    [composer setText:@"Initial"];

    // Set up mock hierarchy
    id mockController = OCMClassMock([TWTRComposerViewController class]);
    OCMStub([mockController alloc]).andReturn(mockController);

    // Expect that the text is passed along
    OCMExpect([mockController initWithInitialText:@"Initial" image:OCMOCK_ANY videoURL:nil]).andReturn([TWTRComposerViewController emptyComposer]);

    // Verify
    [composer showFromViewController:[[UIViewController alloc] init]
                          completion:^(TWTRComposerResult result){
                          }];
    OCMVerifyAll(mockController);
    [mockController stopMocking];
}

- (void)testComposer_usesURL
{
    TWTRComposer *composer = [[TWTRComposer alloc] init];
    [composer setURL:[NSURL URLWithString:@"http://test.com"]];

    id mockController = OCMClassMock([TWTRComposerViewController class]);
    OCMStub([mockController alloc]).andReturn(mockController);

    OCMExpect([mockController initWithInitialText:@"http://test.com" image:OCMOCK_ANY videoURL:nil]).andReturn([TWTRComposerViewController emptyComposer]);

    [composer showFromViewController:[[UIViewController alloc] init]
                          completion:^(TWTRComposerResult result){
                          }];

    OCMVerifyAll(mockController);
    [mockController stopMocking];
}

- (void)testComposer_usesTextAndURL
{
    TWTRComposer *composer = [[TWTRComposer alloc] init];
    [composer setURL:[NSURL URLWithString:@"http://test.com"]];
    [composer setText:@"Initial"];

    id mockController = OCMClassMock([TWTRComposerViewController class]);
    OCMStub([mockController alloc]).andReturn(mockController);

    OCMExpect([mockController initWithInitialText:@"Initial http://test.com" image:OCMOCK_ANY videoURL:nil]).andReturn([TWTRComposerViewController emptyComposer]);

    [composer showFromViewController:[[UIViewController alloc] init]
                          completion:^(TWTRComposerResult result){
                          }];

    OCMVerifyAll(mockController);
    [mockController stopMocking];
}

- (void)testComposer_usesImage
{
    TWTRComposer *composer = [[TWTRComposer alloc] init];
    [composer setImage:[TWTRImages verifiedIcon]];

    id mockController = OCMClassMock([TWTRComposerViewController class]);
    OCMStub([mockController alloc]).andReturn(mockController);

    OCMExpect([mockController initWithInitialText:OCMOCK_ANY image:[TWTRImages verifiedIcon] videoURL:nil]).andReturn([TWTRComposerViewController emptyComposer]);

    [composer showFromViewController:[[UIViewController alloc] init]
                          completion:^(TWTRComposerResult result){
                          }];

    OCMVerifyAll(mockController);
    [mockController stopMocking];
}

- (void)testComposer_noPresentValues
{
    TWTRComposer *composer = [[TWTRComposer alloc] init];

    id mockController = OCMClassMock([TWTRComposerViewController class]);
    OCMStub([mockController alloc]).andReturn(mockController);

    OCMExpect([mockController initWithInitialText:nil image:nil videoURL:nil]).andReturn([TWTRComposerViewController emptyComposer]);

    [composer showFromViewController:[[UIViewController alloc] init]
                          completion:^(TWTRComposerResult result){
                          }];

    OCMVerifyAll(mockController);
    [mockController stopMocking];
}

#pragma mark - Show From View Controller

- (void)testShowFromViewController_presentsFromController
{
    id mockFromController = OCMPartialMock([[UIViewController alloc] init]);
    // Should call present
    OCMExpect([mockFromController presentViewController:OCMOCK_ANY animated:YES completion:OCMOCK_ANY]);

    TWTRComposer *composer = [[TWTRComposer alloc] init];
    [composer showFromViewController:mockFromController
                          completion:^(TWTRComposerResult result){
                          }];

    OCMVerifyAll(mockFromController);
}

- (void)testShowFromViewController_presentsCorrectClass
{
    id mockFromController = OCMPartialMock([[UIViewController alloc] init]);

    // Should call present, and it should be the correct class
    OCMExpect([mockFromController presentViewController:[OCMArg checkWithBlock:^BOOL(TWTRComposerViewController *composer) {
                                      return [composer isKindOfClass:[TWTRSharedComposerWrapper class]];
                                  }]
                                               animated:YES
                                             completion:OCMOCK_ANY]);

    TWTRComposer *composer = [[TWTRComposer alloc] init];
    [composer showFromViewController:mockFromController
                          completion:^(TWTRComposerResult result){
                          }];

    OCMVerifyAll(mockFromController);
}

- (void)testShowFromViewController_attemptsLogin
{
    // Should be no user, so composer will attempt login
    [[TWTRTwitter sharedInstance].sessionStore logOutUserID:@"555"];

    // Expect that login will be called
    id mockTwitter = OCMPartialMock([TWTRTwitter sharedInstance]);
    OCMExpect([mockTwitter logInWithCompletion:OCMOCK_ANY]);
    [TWTRTwitter setSharedTwitter:mockTwitter];

    // Invoke login call
    TWTRComposer *composer = [[TWTRComposer alloc] init];
    [composer showFromViewController:[UIViewController new]
                          completion:^(TWTRComposerResult result){
                          }];

    // Verify
    OCMVerifyAll(mockTwitter);
}

#pragma mark - Completion Delegate Methods

- (void)testComposer_callsSucceed
{
    TWTRComposer *composer = [[TWTRComposer alloc] init];

    // Expect that the completion block will be called with a Done result
    XCTestExpectation *expectation = [self expectationWithDescription:@"Completion"];
    [composer showFromViewController:[[UIViewController alloc] init]
                          completion:^(TWTRComposerResult result) {
                              XCTAssertEqual(result, TWTRComposerResultDone);
                              [expectation fulfill];
                          }];

    // Run the action
    [composer composerDidSucceed:[TWTRComposerViewController new] withTweet:[TWTRTweet new]];

    [self waitForExpectations:@[expectation] timeout:0];
}

- (void)testComposer_callsCancel
{
    TWTRComposer *composer = [[TWTRComposer alloc] init];

    // Expect that the completion block will be called with a Cancelled result
    XCTestExpectation *expectation = [self expectationWithDescription:@"Completion"];
    [composer showFromViewController:[[UIViewController alloc] init]
                          completion:^(TWTRComposerResult result) {
                              XCTAssertEqual(result, TWTRComposerResultCancelled);
                              [expectation fulfill];
                          }];

    // Run the action
    [composer composerDidCancel:[TWTRComposerViewController new]];

    [self waitForExpectations:@[expectation] timeout:0];
}

- (void)testComposer_callsFail
{
    TWTRComposer *composer = [[TWTRComposer alloc] init];

    // Expect that the completion block will be called with a Cancelled result
    XCTestExpectation *expectation = [self expectationWithDescription:@"Completion"];
    [composer showFromViewController:[[UIViewController alloc] init]
                          completion:^(TWTRComposerResult result) {
                              XCTAssertEqual(result, TWTRComposerResultCancelled);
                              [expectation fulfill];
                          }];

    // Run the action
    [composer composerDidFail:[TWTRComposerViewController new] withError:[NSError errorWithDomain:@"domain" code:0 userInfo:nil]];

    [self waitForExpectations:@[expectation] timeout:0];
}

#pragma clang diagnostic pop
@end
