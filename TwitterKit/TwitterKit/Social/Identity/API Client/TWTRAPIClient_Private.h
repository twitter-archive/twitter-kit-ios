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

#import "TWTRAPIClient.h"
#import "TWTRTimelineDataSource.h"

@class TWTRNetworking;
@class TWTRCardConfiguration;
@class TWTRNetworkingPipeline;
@class TWTRTimelineCursor;
@class TWTRTimelineFilterManager;
@class TWTRTwitterAPIConfiguration;
@protocol TWTRAuthSession;
@protocol TWTRSessionStore;
@protocol TWTRSessionStore_Private;

NS_ASSUME_NONNULL_BEGIN

typedef void (^TWTRGenericResponseCompletion)(id _Nullable object, NSError *_Nullable error);
typedef void (^TWTRAPIConfigurationResponseCompletion)(TWTRTwitterAPIConfiguration *_Nullable APIConfiguration, NSError *_Nullable error);
typedef void (^TWTRCreateCardResponseCompletion)(NSString *_Nullable cardID, NSError *_Nullable error);
typedef void (^TWTRCreateTweetResponseCompletion)(TWTRTweet *_Nullable tweet, NSError *_Nullable error);

@interface TWTRAPIClient ()

/**
 *  Networking client that is mostly deprecated but is still used to generate `NSURLRequest` given the public
 *  HTTP methods.
 */
@property (nonatomic, readonly) TWTRNetworking *networkingClient;

/**
 *  Configuration encapsulating the application consumer key and secret.
 */
@property (nonatomic, readonly) TWTRAuthConfig *authConfig;

/**
 *  Store object where all sessions are managed.
 */
@property (nonatomic, readonly) id<TWTRSessionStore_Private> sessionStore;

/**
 *  The Twitter user ID this client is making API requests on behalf of or
 *  nil if it is a guest user.
 *
 *  @warning This should only be changed when used in combination with -[TWTRTwitter logInWithCompletion:]
 *  and [TWTRTwitter logOut]; for backwards compatibility.
 */
@property (nonatomic, copy, readwrite, nullable) NSString *userID;

/**
 *  Constructs a `TWTRAPIClient` object to perform authenticated API requests with user authentication.
 *
 *  @param sessionStore (required) The store to fetch sessions and make API requests with.
 *  @param userID       (optional) ID of the user to make requests on behalf of.
 *
 *  @return Fully initialized API client to make authenticated requests against the Twitter REST API.
 */
- (instancetype)initWithSessionStore:(id<TWTRSessionStore_Private>)sessionStore userID:(nullable NSString *)userID;

/**
 * This method should be called from the main thread before any are instantiated. If there is a
 * session store registered the initWithUserID: method will use this session store.
 * @note this method is not thread safe.
 */
+ (void)registerSharedSessionStore:(id<TWTRSessionStore_Private>)sessionStore;

/**
 *  Pipeline used to batch and gate API requests requiring authentication.
 */
+ (TWTRNetworkingPipeline *)networkingPipeline;

/**
 * The shared URLSession used by all API client instances.
 */
+ (NSURLSession *)URLSession;

/**
 *  Convenience method to check if client is authenticated as a Twitter user.
 *
 *  @return YES if this client is authenticated as a user as indicated by `userID`
 */
- (BOOL)isLoggedIn;

/**
 *  Sends verify credential request for the working session.
 *
 *  @param completion (optional) The completion block which will be called with a valid user dictionary. May pass `nil` if this information is not required.
 *
 *  @see `TWTRUserSessionVerifier` for more on session verification
 */
- (void)verifySessionWithCompletion:(TWTRGenericResponseCompletion)completion;

typedef id _Nonnull (^TWTRDataParsingHandler)(NSData *data, NSError *parseError);
typedef NSArray *_Nonnull (^TWTRTimelineParsedResponseHandler)(id parsedResponse);

#pragma mark - API: General

/**
 *  Sends a Twitter request.
 *
 *  @param request    The request that will be sent asynchronously.
 *  @param queue      The queue to dispatch response to.
 *  @param completion Completion block to be called on response in the specified queue.
 */
- (NSProgress *)sendTwitterRequest:(NSURLRequest *)request queue:(dispatch_queue_t)queue completion:(TWTRNetworkCompletion)completion;

#pragma mark - API: Timelines

/**
 *  Load Tweets from a given collection.
 *
 *  @param collectionID (required) The ID of the collection
 *  @param params       (optional) Additional parameters to fetch timeline with
 *  @param completion   (required) Completion block to be called on response on the main queue.
 */
- (void)loadTweetsForCollectionID:(NSString *)collectionID parameters:(nullable NSDictionary *)params timelineFilterManager:(nullable TWTRTimelineFilterManager *)timelineFilterManager completion:(TWTRLoadTimelineCompletion)completion;

/**
 *  Load Tweets for a search query.
 *
 *  @param query                 (required) The search query
 *  @param params                (optional) Additional parameters to fetch timeline with
 *  @param timelineFilterManager (optional) An object responsible that filters tweets based on the filters provided by the user.
 *  @param completion            (required) Completion block to be called on response on the main queue.
 */
- (void)loadTweetsForSearchQuery:(NSString *)query parameters:(nullable NSDictionary *)params timelineFilterManager:(nullable TWTRTimelineFilterManager *)timelineFilterManager completion:(TWTRLoadTimelineCompletion)completion;

/**
 *  Load Tweets for a given list.
 *
 *  @param listID     (required) The ID of the list
 *  @param params     (optional) Additional parameters to fetch timeline with
 *  @param completion (required) Completion block to be called on response on the main queue.
 */
- (void)loadTweetsForListID:(NSString *)listID parameters:(nullable NSDictionary *)params timelineFilterManager:(nullable TWTRTimelineFilterManager *)timelineFilterManager completion:(TWTRLoadTimelineCompletion)completion;

/**
 *  Load Tweets for a given list.
 *
 *  @param listSlug            (required) The slug of the list.
 *  @param listOwnerScreenName (required) The list owner's screen name.
 *  @param params              (optional) Additional parameters to fetch timeline with
 *  @param completion          (required) Completion block to be called on response on the main queue.
 */
- (void)loadTweetsForListSlug:(NSString *)listSlug listOwnerScreenName:(NSString *)listOwnerScreenName parameters:(nullable NSDictionary *)params timelineFilterManager:(nullable TWTRTimelineFilterManager *)timelineFilterManager completion:(TWTRLoadTimelineCompletion)completion;

/**
 *  Load Tweets from a user's timeline.
 *
 *  @param screenName (optional) Twitter user's screen name
 *  @param userID     (optional) Twitter user's userID
 *  @param params     (optional) Additional parameters to fetch timeline with
 *  @param completion (required) Completion block to be called on response on the main queue.
 *
 *  @note either the userID or the screenName must be supplied
 */
- (void)loadTweetsForUserTimeline:(nullable NSString *)screenName userID:(nullable NSString *)userID parameters:(nullable NSDictionary *)params timelineFilterManager:(nullable TWTRTimelineFilterManager *)timelineFilterManager completion:(TWTRLoadTimelineCompletion)completion;

/**
 * Loads a JSON dictionary at the given path.
 */
- (void)loadJSONDictionaryFromAPIPath:(NSString *)apiPath parameters:(nullable NSDictionary *)parameters completion:(TWTRJSONRequestCompletion)completion;

/**
 * Loads a JSON array at the given path.
 */
- (void)loadJSONArrayFromAPIPath:(NSString *)apiPath parameters:(nullable NSDictionary *)parameters completion:(TWTRJSONRequestCompletion)completion;

#pragma mark - API: Tweet Actions

/**
 *  Favorites a single Tweet. Returns the new likedd version of Tweet from the perspective of
 *  the currently logged-in API user.
 *
 *  @param tweet      (required) The Tweet ID to like.
 *  @param completion Completion block to be called on response. Called on the main queue.
 */
- (void)likeTweetWithID:(NSString *)tweetID completion:(TWTRTweetActionCompletion)completion;

/**
 *  Unfavorites a single Tweet. Returns the new liked version of Tweet from the perspective of
 *  the currently logged-in API user.
 *
 *  @param tweet      (required) The Tweet ID to unlike.
 *  @param completion Completion block to be called on response. Called on the main queue.
 */
- (void)unlikeTweetWithID:(NSString *)tweetID completion:(TWTRTweetActionCompletion)completion;

/**
 *  Retweets a single Tweet. Returns the new retweeted version of Tweet from the perspective of
 *  the currently logged-in API user.
 *
 *  @param tweet      (required) The Tweet ID to retweet.
 *  @param completion Completion block to be called on response. Called on the main queue.
 */
- (void)retweetTweetWithID:(NSString *)tweetID completion:(TWTRTweetActionCompletion)completion;

/**
 *  Unretweets a single Tweet. Returns the new unretweeted version of Tweet from the perspective of
 *  the currently logged-in API user.
 *
 *  @param tweet      (required) The Tweet ID to unretweet.
 *  @param completion Completion block to be called on response. Called on the main queue.
 */
- (void)unretweetTweetWithID:(NSString *)tweetID completion:(TWTRTweetActionCompletion)completion;

/**
 *  Upload a media (video)
 *  Return the same mediaID, or error if fails.
 *
 *  @param videoData   (required) NSData of video to be uploaded.
 *  @param completion  The completion handler to invoke.
 */
- (void)uploadVideoWithVideoData:(nonnull NSData *)videoData completion:(TWTRMediaUploadResponseCompletion)completion;

/**
 *  Create and send a Tweet given a text and media ID. Returns either a TWTRTweet or an NSError.
 *
 *  @param text        The text for a Tweet
 *  @param mediaID     (required) The media ID of the object that was uploaded to be attached to this Tweet.
 *  @param completion  The completion handler to invoke.
 */
- (void)sendTweetWithText:(NSString *)tweetText mediaID:(nonnull NSString *)mediaID completion:(TWTRSendTweetCompletion)completion;

@end

NS_ASSUME_NONNULL_END
