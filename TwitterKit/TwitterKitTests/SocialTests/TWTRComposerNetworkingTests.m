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
#import <XCTest/XCTest.h>
#import "TWTRComposerAccount.h"
#import "TWTRComposerNetworking.h"
#import "TWTRFixtureLoader.h"
#import "TWTRImages.h"
#import "TWTRSharedComposerWrapper.h"
#import "TWTRStubTwitterClient.h"

@interface TWTRComposerNetworking ()

@property (nonatomic) TWTRAPIClient *client;

- (TWTRAPIClient *)clientWithAccount:(TWTRComposerAccount *)account;
- (NSString *)textForTweet:(TWTRSETweet *)tweet;
- (UIImage *)imageForTweet:(TWTRSETweet *)tweet;

@end

@interface TWTRComposerNetworkingTests : XCTestCase

@property (nonatomic) TWTRComposerNetworking *networking;
@property (nonatomic) TWTRStubTwitterClient *stubClient;
@property (nonatomic) TWTRSETweet *fakeTweet;
@property (nonatomic) TWTRComposerAccount *fakeAccount;

@end

@implementation TWTRComposerNetworkingTests

- (void)setUp
{
    [super setUp];

    self.stubClient = [TWTRStubTwitterClient stubTwitterClient];
    self.networking = [[TWTRComposerNetworking alloc] init];
    self.networking.client = self.stubClient;

    self.fakeTweet = [[TWTRSETweet alloc] initWithInReplyToTweetID:nil text:@"Tweet text" attachment:nil place:nil usernames:nil hashtags:nil];
    self.fakeAccount = [[TWTRComposerAccount alloc] init];
}

+ (void)setUp
{
    // Shouldn't have to do this, but the APIServiceConfigRegistry needs to be set up before valid URLs are created
    [[TWTRTwitter sharedInstance] startWithConsumerKey:@"key" consumerSecret:@"secret"];
}

#pragma mark - Account

- (void)testAccount_usesExistingPropertyWhenSet
{
    TWTRAPIClient *client = [[TWTRAPIClient alloc] init];
    self.networking.client = client;

    XCTAssertEqualObjects([self.networking clientWithAccount:self.fakeAccount], client);
}

- (void)testAccount_createsNewAPIClient
{
    TWTRComposerNetworking *networking = [[TWTRComposerNetworking alloc] init];
    TWTRComposerAccount *account = [[TWTRComposerAccount alloc] init];
    account.userID = 23098;

    TWTRAPIClient *createdClient = [networking clientWithAccount:account];
    XCTAssertEqualObjects(createdClient.userID, @"23098");
}

#pragma mark - Text for Tweet

- (void)testTextForTweet_returnsTextWithNoAttachment
{
    XCTAssertEqualObjects([self.networking textForTweet:self.fakeTweet], @"Tweet text");
}

- (void)testTextForTweet_addsURLToTweetText
{
    TWTRSETweetAttachmentURL *attachment = [[TWTRSETweetAttachmentURL alloc] initWithTitle:@"URL Title" URL:[NSURL URLWithString:@"http://www.fakeurl.com"] previewImage:[[UIImage alloc] init]];
    TWTRSETweet *tweet = [[TWTRSETweet alloc] initWithInReplyToTweetID:nil text:@"Tweet text" attachment:attachment place:nil usernames:nil hashtags:nil];

    NSString *received = [self.networking textForTweet:tweet];
    NSString *expected = @"Tweet text http://www.fakeurl.com";

    XCTAssertEqualObjects(expected, received);
}

#pragma mark - Image for Tweet

- (void)testImageForTweet_returnsImageIfExists
{
    UIImage *image = [TWTRImages verifiedIcon];
    TWTRSETweet *tweetWithImage = [[TWTRSETweet alloc] initWithInReplyToTweetID:nil text:@"Tweet text" attachment:[[TWTRSETweetAttachmentImage alloc] initWithImage:image] place:nil usernames:nil hashtags:nil];

    UIImage *receivedImage = [self.networking imageForTweet:tweetWithImage];
    XCTAssertEqualObjects(receivedImage, image);
}

- (void)testImageForTweet_returnsNilIfNoImage
{
    XCTAssertNil([self.networking imageForTweet:self.fakeTweet]);
}

#pragma mark - Send Tweet

- (void)testSendTweet_sendsTweetText
{
    id mockClient = OCMPartialMock(self.stubClient);
    OCMExpect([mockClient sendTweetWithText:@"Tweet text" completion:OCMOCK_ANY]);

    [self.networking sendTweet:self.fakeTweet
                   fromAccount:[TWTRComposerAccount new]
                    completion:^(TWTRSENetworkingResult result){
                    }];

    OCMVerifyAll(mockClient);
}

- (void)testSendTweet_sendsTweetImage
{
    TWTRSETweet *tweetWithImage = [[TWTRSETweet alloc] initWithInReplyToTweetID:nil text:@"Tweet text" attachment:[[TWTRSETweetAttachmentImage alloc] initWithImage:[TWTRImages verifiedIcon]] place:nil usernames:nil hashtags:nil];

    [self.networking sendTweet:tweetWithImage
                   fromAccount:[TWTRComposerAccount new]
                    completion:^(TWTRSENetworkingResult result){
                    }];

    NSString *sentBody = [self.stubClient sentHTTPBodyString];
    NSString *expectedBody = @"media_ids=982389&status=Tweet%20text";

    XCTAssertEqualObjects(sentBody, expectedBody);
}

- (void)testSendTweet_sendsURLInText
{
    TWTRSETweetAttachmentURL *attachment = [[TWTRSETweetAttachmentURL alloc] initWithTitle:@"URL Title" URL:[NSURL URLWithString:@"http://www.fakeurl.com"] previewImage:[[UIImage alloc] init]];
    TWTRSETweet *tweet = [[TWTRSETweet alloc] initWithInReplyToTweetID:nil text:@"Tweet text" attachment:attachment place:nil usernames:nil hashtags:nil];

    [self.networking sendTweet:tweet
                   fromAccount:[TWTRComposerAccount new]
                    completion:^(TWTRSENetworkingResult result){
                    }];

    NSString *sentBody = [self.stubClient sentHTTPBodyString];

    XCTAssertEqualObjects(sentBody, @"status=Tweet%20text%20http%3A%2F%2Fwww.fakeurl.com");
}

- (void)testSendTweet_cancelsPendingVideoUpload
{
    id mockNetworking = OCMPartialMock(self.networking);
    OCMExpect([mockNetworking cancelPendingVideoUpload]);

    [self.networking sendTweet:self.fakeTweet
                   fromAccount:self.fakeAccount
                    completion:^(TWTRSENetworkingResult result){
                    }];

    OCMVerifyAll(mockNetworking);
}

#pragma mark - Delegate Methods

- (void)testSendTweet_notifiesDelegateSuccess
{
    // Completion block should see Tweet data as success
    self.stubClient.responseData = [TWTRFixtureLoader obamaTweetData];

    id stubDelegate = OCMClassMock([TWTRSharedComposerWrapper class]);
    self.networking.delegate = stubDelegate;
    OCMExpect([stubDelegate didFinishSendingTweet:[OCMArg checkWithBlock:^BOOL(TWTRTweet *tweet) {
                                return [tweet isEqual:[TWTRFixtureLoader obamaTweet]];
                            }]]);

    [self.networking sendTweet:self.fakeTweet
                   fromAccount:[TWTRComposerAccount new]
                    completion:^(TWTRSENetworkingResult result){
                    }];

    OCMVerifyAllWithDelay(stubDelegate, 0.1);
}

- (void)testSendTweet_notifiesDelegateFailure
{
    NSError *fakeError = [NSError errorWithDomain:TWTRErrorDomain code:0 userInfo:@{@"description": @"Couldn't load Tweet."}];
    // Completion block should see error when attempting to load Tweet
    self.stubClient.responseError = fakeError;

    id stubDelegate = OCMClassMock([TWTRSharedComposerWrapper class]);
    self.networking.delegate = stubDelegate;
    OCMExpect([stubDelegate didAbortSendingTweetWithError:[OCMArg checkWithBlock:^BOOL(NSError *error) {
                                return [error isEqual:fakeError];
                            }]]);

    [self.networking sendTweet:self.fakeTweet
                   fromAccount:[TWTRComposerAccount new]
                    completion:^(TWTRSENetworkingResult result){
                    }];

    OCMVerifyAllWithDelay(stubDelegate, 0.1);
}

- (void)testSendTweet_callCompletionSuccess
{
    self.stubClient.responseData = [TWTRFixtureLoader obamaTweetData];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Called completion"];
    [self.networking sendTweet:self.fakeTweet
                   fromAccount:[TWTRComposerAccount new]
                    completion:^(TWTRSENetworkingResult result) {
                        if (result == TWTRSENetworkingResultSuccess) {
                            [expectation fulfill];
                        }
                    }];

    [self waitForExpectations:@[expectation] timeout:0.1];
}

- (void)testSendTweet_callCompletionFailure
{
    NSError *fakeError = [NSError errorWithDomain:TWTRErrorDomain code:0 userInfo:@{@"description": @"Couldn't load Tweet."}];
    // Completion block should see error when attempting to load Tweet
    self.stubClient.responseError = fakeError;

    XCTestExpectation *expectation = [self expectationWithDescription:@"Called completion"];
    [self.networking sendTweet:self.fakeTweet
                   fromAccount:[TWTRComposerAccount new]
                    completion:^(TWTRSENetworkingResult result) {
                        if (result == TWTRSENetworkingResultError) {
                            [expectation fulfill];
                        }
                    }];

    [self waitForExpectations:@[expectation] timeout:0.1];
}

#pragma mark - Load User

@end
