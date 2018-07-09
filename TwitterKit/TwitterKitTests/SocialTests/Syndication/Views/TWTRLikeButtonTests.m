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
#import "TWTRAPIClient.h"
#import "TWTRAPIClient_Private.h"
#import "TWTRFixtureLoader.h"
#import "TWTRImages.h"
#import "TWTRLikeButton.h"
#import "TWTRLoginURLParser.h"
#import "TWTRStubTwitterClient.h"
#import "TWTRTestCase.h"

@interface TWTRLikeButtonTests : TWTRTestCase

@property (nonatomic) TWTRLikeButton *likeButton;
@property (nonatomic) TWTRStubTwitterClient *stubClient;
@property (nonatomic) TWTRTweet *tweet;
@property (nonatomic) TWTRTweet *likedTweet;
@property (nonatomic) id delegate;
@property (nonatomic) BOOL wasCalled;
@property (nonatomic) id mockLoginParser;

@end

@interface TWTRLikeButton ()
@property (nonatomic) TWTRAPIClient *apiClient;
- (void)likeTapped;
- (void)updateImageToLiked:(BOOL)isLiked animated:(BOOL)animated;
@end

@implementation TWTRLikeButtonTests

- (void)setUp
{
    [super setUp];
    self.likeButton = [[TWTRLikeButton alloc] init];
    self.stubClient = [TWTRStubTwitterClient stubTwitterClient];
    self.stubClient.responseData = [TWTRFixtureLoader singleTweetData];
    self.tweet = [TWTRFixtureLoader gatesTweet];
    [self.likeButton configureWithTweet:self.tweet];
    self.likeButton.apiClient = self.stubClient;
    self.likedTweet = [self.tweet tweetWithLikeToggled];

    // Mock login parser to loginWithCompletion that is used in [TWTRLikeButton likeTapped]
    self.mockLoginParser = OCMClassMock([TWTRLoginURLParser class]);
    OCMStub([self.mockLoginParser alloc]).andReturn(self.mockLoginParser);
    OCMStub([self.mockLoginParser initWithAuthConfig:OCMOCK_ANY]).andReturn(self.mockLoginParser);
    OCMStub([self.mockLoginParser hasValidURLScheme]).andReturn(YES);

    _wasCalled = NO;
}

- (void)tearDown
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.mockLoginParser stopMocking];
}

- (void)testSetup
{
    XCTAssert(self.tweet.isLiked == NO);
    XCTAssert(self.likedTweet.isLiked == YES);
}

- (void)testFavoriteButton_startsWithNoImage
{
    BOOL liked = [self.likeButton.imageView.image isEqual:[TWTRImages likeOff]];
    XCTAssert(liked);
}

#pragma mark - Update Images

- (void)testUpdateImage_setsOnImage
{
    [self.likeButton updateImageToLiked:YES animated:NO];

    XCTAssertEqualObjects(self.likeButton.imageView.image, [TWTRImages likeOn]);
}

- (void)testUpdateImage_setsOffImage
{
    [self.likeButton updateImageToLiked:NO animated:NO];

    XCTAssertEqualObjects(self.likeButton.imageView.image, [TWTRImages likeOff]);
}

#pragma mark - Likes

- (void)testLikeTweet_likes
{
    id mockClient = OCMPartialMock(self.stubClient);
    OCMExpect([mockClient likeTweetWithID:@"468722941975592960" completion:OCMOCK_ANY]);
    self.likeButton.apiClient = mockClient;

    [self.likeButton likeTapped];

    OCMVerifyAll(mockClient);
}

- (void)testLikeTweet_unlikes
{
    id mockClient = OCMPartialMock(self.stubClient);
    [self.likeButton configureWithTweet:self.likedTweet];

    OCMExpect([mockClient unlikeTweetWithID:@"468722941975592960" completion:OCMOCK_ANY]);
    self.likeButton.apiClient = mockClient;

    [self.likeButton likeTapped];

    OCMVerifyAll(mockClient);
}

#pragma mark - Notifications

- (void)testLikeTweet_sendsLikeNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setWasCalled:) name:@"TWTRDidLikeTweetNotification" object:nil];

    self.stubClient.responseData = [TWTRFixtureLoader likedTweetData];

    [self.likeButton likeTapped];
    [self waitForCompletionWithTimeout:1.0 check:^BOOL {
        return self.wasCalled;
    }];
}

- (void)testLikeTweet_alreadyLikedSendsLikeNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setWasCalled:) name:@"TWTRDidLikeTweetNotification" object:nil];
    self.stubClient.responseError = [NSError errorWithDomain:TWTRAPIErrorDomain code:TWTRAPIErrorCodeAlreadyFavorited userInfo:nil];

    [self.likeButton likeTapped];
    [self waitForCompletionWithTimeout:1.0 check:^BOOL {
        return self.wasCalled;
    }];
}

- (void)testLikeTweet_sendsUnlikeNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setWasCalled:) name:@"TWTRDidUnlikeTweetNotification" object:nil];
    [self.likeButton configureWithTweet:self.likedTweet];
    self.stubClient.responseData = [TWTRFixtureLoader likedTweetData];

    [self.likeButton likeTapped];
    [self waitForCompletionWithTimeout:1.0 check:^BOOL {
        return self.wasCalled;
    }];
}

#pragma mark - Helpers

// For testing notifications
- (void)setWasCalled:(BOOL)wasCalled
{
    _wasCalled = YES;
}

@end
