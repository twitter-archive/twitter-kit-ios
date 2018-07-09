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

#import "TWTRLikeButton.h"
#import <TwitterCore/TWTRAPIErrorCode.h>
#import <TwitterCore/TWTRSessionStore.h>
#import <TwitterCore/TWTRUtils.h>
#import "TWTRAPIClient_Private.h"
#import "TWTRAnimatableImageView.h"
#import "TWTRButtonAnimator.h"
#import "TWTRFrameSheet.h"
#import "TWTRImageSequenceConfiguration.h"
#import "TWTRImages.h"
#import "TWTRNotificationCenter.h"
#import "TWTRNotificationConstants.h"
#import "TWTRStore.h"
#import "TWTRTranslationsUtil.h"
#import "TWTRTweet.h"
#import "TWTRTweetRepository.h"
#import "TWTRTweet_Private.h"
#import "TWTRTwitter.h"
#import "TWTRTwitter_Private.h"
#import "TWTRViewUtil.h"

typedef void (^TWTRTweetActionAPIClientCompletion)(TWTRAPIClient *_Nullable APIClient, NSError *_Nullable error);

@interface TWTRLikeButton ()

@property (nonatomic) BOOL isLiked;
@property (nonatomic) UIImageView *localImageView;  // replaces the default `imageView`
@property (nonatomic) TWTRTweet *tweet;
@property (nonatomic) TWTRAPIClient *apiClient;
@property (nonatomic) TWTRLikeButtonSize likeButtonSize;

@end

@implementation TWTRLikeButton

#pragma mark - Init

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _likeButtonSize = TWTRLikeButtonSizeRegular;
        [self likeButtonCommonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame likeButtonSize:TWTRLikeButtonSizeRegular];
}

- (instancetype)initWithLikeButtonSize:(TWTRLikeButtonSize)size
{
    return [self initWithFrame:CGRectZero likeButtonSize:size];
}

- (instancetype)initWithFrame:(CGRect)frame likeButtonSize:(TWTRLikeButtonSize)size
{
    self = [super initWithFrame:frame];
    if (self) {
        _likeButtonSize = size;
        [self likeButtonCommonInit];
    }
    return self;
}

- (void)likeButtonCommonInit
{
    [self createImageViewIfNil];
    [TWTRViewUtil centerViewInSuperview:self.imageView];
    [self updateImageToLiked:NO animated:NO];
    [self addTarget:self action:@selector(likeTapped) forControlEvents:UIControlEventTouchUpInside];
    self.accessibilityLabel = TWTRLocalizedString(@"tw__tweet_like_button");
}

- (void)configureWithTweet:(TWTRTweet *)tweet
{
    BOOL isSameTweetAsBefore = [tweet.tweetID isEqualToString:self.tweet.tweetID];
    BOOL isTransitioningToLiked = !self.tweet.isLiked && tweet.isLiked;
    BOOL shouldAnimateLikeStateChange = isSameTweetAsBefore && isTransitioningToLiked;

    self.tweet = tweet;

    [self updateImageToLiked:self.tweet.isLiked animated:shouldAnimateLikeStateChange];
}

- (void)updateImageToLiked:(BOOL)isLiked animated:(BOOL)animated
{
    _isLiked = isLiked;

    if (isLiked) {
        if (animated) {
            [self updateToLikedStateWithAnimation];
            return;
        }

        [self updateToLikedState];
    } else {
        [self updateToUnlikedState];
    }
}

#pragma mark -

- (UIImageView *)imageView
{
    return self.localImageView;
}

- (void)setPresenterViewController:(UIViewController *)presenterViewController
{
    _presenterViewController = presenterViewController ?: [TWTRUtils topViewController];
}

#pragma mark - Liking

- (void)likeTapped
{
    if (!self.tweet) {
        return;
    }

    TWTRTweet *originalTweet = self.tweet;  // We may need to revert to this Tweet
    NSString *tweetID = self.tweet.tweetID;
    BOOL attemptingToLike = !self.tweet.isLiked;
    TWTRTweet *tweetWithLikeToggled = [originalTweet tweetWithLikeToggled];  // This is our desired outcome
    [self configureWithTweet:tweetWithLikeToggled];                          // Optimistically update UI

    TWTRTweetActionAPIClientCompletion clientRequestCompletion = ^(TWTRAPIClient *client, NSError *error) {

        /// This block definition needs to be inside of the clientRequestCompletion block definition because we
        /// need to capture the returned client's user id. The user id is required to cache the updated Tweet or revert
        /// the optimistically cached version from the perspective of the logged-in user as specified by the working TWTRAPIClient.
        TWTRTweetActionCompletion requestCompletion = ^(TWTRTweet *tweet, NSError *likeError) {
            const BOOL alreadyLiked = [self isAlreadyLikedError:likeError];

            // Is state we thought
            if (tweet || alreadyLiked) {
                NSString *notificationName = attemptingToLike ? TWTRDidLikeTweetNotification : TWTRDidUnlikeTweetNotification;
                [TWTRNotificationCenter postNotificationName:notificationName tweet:tweet userInfo:nil];

            } else {  // Must revert assumed state
                [self configureWithTweet:originalTweet];
                [[TWTRTweetRepository sharedInstance] cacheTweet:originalTweet perspective:client.userID];
                NSLog(@"[TwitterKit] Error attempting to %@: %@", attemptingToLike ? @"like" : @"unlike", [likeError localizedDescription]);
            }
        };

        if (client) {
            TWTRTweet *tweetForOptimisticCache = [tweetWithLikeToggled tweetWithPerspectivalUserID:client.userID];
            [[TWTRTweetRepository sharedInstance] cacheTweet:tweetForOptimisticCache perspective:client.userID];
            if (attemptingToLike) {
                [client likeTweetWithID:tweetID completion:requestCompletion];
            } else {
                [client unlikeTweetWithID:tweetID completion:requestCompletion];
            }
        } else {
            requestCompletion(nil, error);
        }
    };

    [self APIClientFromTwitterWithCompletion:clientRequestCompletion];
}

#pragma mark - APIClient Helpers

- (BOOL)isAlreadyLikedError:(NSError *)error
{
    if ([error.domain isEqualToString:TWTRAPIErrorDomain] && (error.code == TWTRAPIErrorCodeAlreadyFavorited)) {
        return YES;
    } else {
        return NO;
    }
}

/**
 *  Gets the API client Twitter shared instance as a way to make supporting Tweet actions
 *  more seamless. This should only be called if the developer does not implement the
 *  delegate method to provide a user session.
 *
 *  @warning This method has to be called on the main thread because of `+[TWTRTwitter sharedInstance]`
 */
- (void)APIClientFromTwitterWithCompletion:(TWTRTweetActionAPIClientCompletion)completion
{
    TWTRAPIClient *client;
    if (self.apiClient) {
        completion(self.apiClient, nil);
        return;
    }

    NSString *perspectivalUserID = self.tweet.perspectivalUserID;
    if (perspectivalUserID && [[TWTRTwitter sharedInstance].sessionStore sessionForUserID:perspectivalUserID] != nil) {
        client = [[TWTRAPIClient alloc] initWithUserID:perspectivalUserID];
        completion(client, nil);
    } else {
        BOOL isLoggedIn = ([TWTRTwitter sharedInstance].sessionStore.session.userID != nil);

        if (isLoggedIn) {
            client = [TWTRAPIClient clientWithCurrentUser];
            completion(client, nil);
        } else {
            [[TWTRTwitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
                if (session) {
                    completion([[TWTRAPIClient alloc] initWithUserID:session.userID], nil);
                } else {
                    NSError *unauthenticatedError = [NSError errorWithDomain:TWTRAPIErrorDomain code:TWTRAPIErrorCodeNotAuthorizedForEndpoint userInfo:@{NSLocalizedDescriptionKey: @"Endpoint requires user context. Please see -[TWTRTwitter logInWithCompletion:]."}];
                    completion(nil, unauthenticatedError);
                }
            }];
        }
    }
}

#pragma mark - Helper

- (void)updateToLikedState
{
    switch (self.likeButtonSize) {
        case TWTRLikeButtonSizeRegular:
            self.imageView.image = [TWTRImages likeOn];
            break;
        case TWTRLikeButtonSizeLarge:
            self.imageView.image = [TWTRImages likeOnLarge];
            break;
    }
    self.accessibilityValue = TWTRLocalizedString(@"tw__tweet_liked_state");
}

- (void)updateToUnlikedState
{
    switch (self.likeButtonSize) {
        case TWTRLikeButtonSizeRegular:
            self.imageView.image = [TWTRImages likeOff];
            break;
        case TWTRLikeButtonSizeLarge:
            self.imageView.image = [TWTRImages likeOffLarge];
            break;
    }
    self.accessibilityValue = TWTRLocalizedString(@"tw__tweet_not_liked_state");
}

- (void)updateToLikedStateWithAnimation
{
    TWTRButtonAnimationType type;
    switch (self.likeButtonSize) {
        case TWTRLikeButtonSizeRegular:
            type = TWTRButtonAnimationTypeActionBarHeartSequence;
            break;
        case TWTRLikeButtonSizeLarge:
            type = TWTRButtonAnimationTypeActionBarHeartSequenceLarge;
            break;
    }

    [TWTRButtonAnimator performAnimationType:type
                                    onButton:self
                                  completion:^{
                                      [self updateToLikedState];
                                  }];
}

- (void)createImageViewIfNil
{
    if (!self.localImageView) {
        TWTRAnimatableImageView *localImageView = [[TWTRAnimatableImageView alloc] initWithFrame:CGRectZero];
        localImageView.translatesAutoresizingMaskIntoConstraints = NO;
        localImageView.contentMode = UIViewContentModeCenter;
        localImageView.tintColor = nil;
        [self addSubview:localImageView];
        self.localImageView = localImageView;
    }
}

@end
