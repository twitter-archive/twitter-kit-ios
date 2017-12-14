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

/**
 This header is private to the Twitter Kit SDK and not exposed for public SDK consumption
 */

#import <TwitterCore/TWTRErrorLogger.h>
#import "TWTRScribeConstants.h"
#import "TWTRTimelineType.h"
#import "TWTRTweetView.h"

@class TWTRScribeService;
@class TWTRTweetMediaEntity;
@class TWTRVideoPlaybackConfiguration;
@protocol TWTRAuthSession;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Object other classes such as `UIView` and networking can call to notify a scribe-related event has
 *  occurred.
 */
@interface TWTRScribeSink : NSObject <TWTRErrorLogger>

- (instancetype)initWithScribeService:(TWTRScribeService *)scribeService;

- (instancetype)init NS_UNAVAILABLE;

#pragma mark - Impressions

- (void)didLoadTweetsWithIDs:(NSArray *)tweetIDs;
- (void)didShowTweetWithID:(NSString *)tweetID style:(TWTRTweetViewStyle)style showingActions:(BOOL)showingActions;
- (void)didShowQuoteTweetWithID:(NSString *)tweetID;

/**
 *  Log an impression for showing Tweet detail view.
 *
 *  @param tweetID The Tweet being shown.
 *  @param userID  ID of user viewing the Tweet.
 */
- (void)didShowTweetDetailWithTweetID:(NSString *)tweetID forUserID:(nullable NSString *)userID;

- (void)didShowQuoteTweetDetailWithTweetID:(NSString *)tweetID;
- (void)didShowTimelineOfType:(TWTRTimelineType)timelineType timelineID:(nullable NSString *)timelineID;

/**
 *  The 'Like' button was tapped.
 */
- (void)didLikeTweetWithID:(NSString *)tweetID forUserID:(NSString *)userID fromViewName:(TWTRScribeViewName)viewName;

/**
 *  Notify Twitter that a Tweet was unliked.
 */
- (void)didUnlikeTweetWithID:(NSString *)tweetID forUserID:(NSString *)userID fromViewName:(TWTRScribeViewName)viewName;

/**
 *  Notify Twitter that the 'Share' button was tapped.
 */
- (void)didShareTweetWithID:(NSString *)tweetID forUserID:(NSString *)userID fromViewName:(TWTRScribeViewName)viewName;

#pragma mark - Uniques

/**
 *  Only count TwitterKit uniques if user has seen Tweet views.
 */
- (void)didSeeTweetViewWithStyle:(NSString *)style showingActions:(NSString *)showingActions;

/**
 *  Only count Identity uniques if the user has clicked on login button. However, because we support
 *  custom login buttons, it's safer to count users if they started/have gone through OAuth flow.
 */
- (void)didStartOAuthLogin;

/**
 * Called when the verify_credentials call was successful.
 * This method counts successfully verified users.
 *
 * @param session the session that was verified.
 */
- (void)didVerifyCredentialsForSession:(id<TWTRAuthSession>)session;

#pragma mark - Errors

/**
 *  Scribe to the Twitter server that an error was encountered inside our SDK.
 *
 *  @param error        (required) An NSError object describing this error case.
 *  @param errorMessage (required) A message describing the error that occurred.
 */
- (void)didEncounterError:(NSError *)error withMessage:(NSString *)errorMessage;

#pragma mark - Composer

/**
 *  Scribes that the user has seen the composer.
 */
- (void)didOpenComposer;

/**
 *  Scribes that the user has seen the composer but tapped cancel without tweeting.
 */
- (void)didTapCancelFromComposerWithSelectedUserID:(NSString *)userID;

/**
 *  Scribes that the user has seen the composer and tapped the tweet button attempt tweeting.
 */
- (void)didTapSendFromComposerWithSelectedUserID:(NSString *)userID;

#pragma mark - Media Player

- (void)didShowMediaEntities:(NSArray<TWTRTweetMediaEntity *> *)mediaEntities inTweetID:(NSString *)tweetID publishedByOwnerID:(NSString *)ownerID;
- (void)didPlayPercentOfMedia:(NSUInteger)percentOfMedia fromPlaybackConfiguration:(TWTRVideoPlaybackConfiguration *)playbackConfiguration inTweetID:(NSString *)tweetID publishedByOwnerID:(NSString *)ownerID;
- (void)didBeginPlaybackFromPlaybackConfiguration:(TWTRVideoPlaybackConfiguration *)playbackConfiguration inTweetID:(NSString *)tweetID publishedByOwnerID:(NSString *)ownerID isInlinePlayback:(BOOL)isInlinePlayback;

/**
 *  The photo gallery was presented full-screen.
 */
- (void)didPresentPhotoGallery;

/**
 *  A particular image inside the photo gallery was seen.
 *
 *  @param mediaEntity The specifi media entity being viewed.
 *  @param tweetID     The Tweet ID of the parent Tweet
 */
- (void)didSeeMediaEntity:(TWTRTweetMediaEntity *)mediaEntity fromTweetID:(NSString *)tweetID;

/**
 *  The user swiped between images in the multi-photo gallery.
 */
- (void)didNavigateInsideGallery;

/**
 *  The full-screen photo gallery was dismissed.
 */
- (void)didDismissPhotoGallery;

#pragma mark - Filter

- (void)didFilterRequestedTweets:(NSUInteger)requestedTweets totalFilters:(NSUInteger)totalFilters totalFilteredTweets:(NSUInteger)totalFilteredTweets;
- (void)didFilterWithTweetsShown:(NSUInteger)totalFilters;

#pragma mark - Login

/*
 *  The app started a Mobile SSO login flow with a valid Twitter app.
 */
- (void)didStartSSOLogin;

/*
 *  The Mobile SSO login flow finished successfully.
 */
- (void)didFinishSSOLogin;

/*
 *  The Mobile SSO login flow was cancelled by the user after being
 *  directed to the Twitter iOS app.
 */
- (void)didCancelSSOLogin;

/*
 *  The Mobile SSO login flow failed.
 */
- (void)didFailSSOLogin;

/*
 *  The SFSafariViewController login flow started, finished, canceled, or failed.
 *  Similar as mobile SSO scribing logic
 */
- (void)didStartSafariLogin;
- (void)didFinishSafariLogin;
- (void)didCancelSafariLogin;
- (void)didFailSafariLogin;

/*
 *  The UIWebView login flow for started, finished, canceled, and failed.
 *  Similar as mobile SSO scribing logic
 */
- (void)didStartWebLogin;
- (void)didFinishWebLogin;
- (void)didCancelWebLogin;
- (void)didFailWebLogin;

#pragma mark - TOO iOS Events

// For later Scribe Audit:
/* Client:Page:Section:Component:Element:Action */

// iphone:gallery: :gallery:photo:dismiss
// iphone:gallery: :gallery:photo:navigate
// iphone:gallery: :gallery:photo:impression

// iphone:profile:photo_grid: :video_player:play
// iphone:profile:photo_grid: :video_player:show
// iphone:profile:photo_grid: :video_player:playback_start
// iphone:profile:photo_grid: :video_player:pause
// iphone:profile:photo_grid: :video_player:play_from_tap
// iphone:profile:photo_grid: :video_player:playback_25
// iphone:profile:photo_grid: :video_player:playback_50
// iphone:profile:photo_grid: :video_player:playback_75
// iphone:profile:photo_grid: :video_player:playback_complete
// iphone:profile:photo_grid: :video_player:scrub
// iphone:profile:photo_grid: :video_player:error

// iphone:profile:photo_grid: :gif_player:play
// iphone:profile:photo_grid: :gif_player:show
// iphone:profile:photo_grid: :gif_player:playback_start
// iphone:profile:photo_grid: :gif_player:playback_25

// iphone:profile:photo_grid: :vine_player:play
// iphone:profile:photo_grid: :vine_player:show
// iphone:profile:photo_grid: :vine_player:pause
// iphone:profile:photo_grid: :vine_layer:playback_start

@end

NS_ASSUME_NONNULL_END
