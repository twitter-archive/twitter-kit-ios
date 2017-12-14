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

@class TWTRUser;
@class TWTRTweet;
@class TWTRAuthConfig;
@class TWTRGuestSession;
@protocol TWTRAuthSession;
@protocol TWTRSessionStore;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString *const TWTRTweetsNotLoadedKey;

/**
 *  @name Completion Block Types
 */

/**
 *  Completion block called when the load user request succeeds or fails.
 *
 *  @param user  The Twitter User.
 *  @param error Error that will be set if the API request failed.
 */
typedef void (^TWTRLoadUserCompletion)(TWTRUser *_Nullable user, NSError *_Nullable error);

/**
 *  Completion block called when the load Tweet request succeeds or fails.
 *
 *  @param tweet The Twitter Tweet.
 *  @param error Error that will be set if the API request failed.
 */
typedef void (^TWTRLoadTweetCompletion)(TWTRTweet *_Nullable tweet, NSError *_Nullable error);

/**
 *  Completion block called when the load Tweets request succeeds or fails.
 *
 *  @param tweets Tweets that were successfully retrieved.
 *  @param error  Error that will be set if the API request failed.
 */
typedef void (^TWTRLoadTweetsCompletion)(NSArray<TWTRTweet *> *_Nullable tweets, NSError *_Nullable error);

/**
 *  Completion block called when the network request succeeds or fails.
 *
 *  @param response        Metadata associated with the response to a URL load request.
 *  @param data            Content data of the response.
 *  @param connectionError Error object describing the network error that occurred.
 */
typedef void (^TWTRNetworkCompletion)(NSURLResponse *_Nullable response, NSData *_Nullable data, NSError *_Nullable connectionError);

/**
 *  Completion block called when a JSON request to the Twitter API succeeds or fails.
 *
 *  @param response       Metadata associated with the response to a URL load request.
 *  @param responseObject Content data of the response.
 *  @param error          Error object describing the network error that occurred.
 */
typedef void (^TWTRJSONRequestCompletion)(NSURLResponse *_Nullable response, id _Nullable responseObject, NSError *_Nullable error);

/**
 *  Completion block called when a Tweet action (favorite/retweet) is performed.
 *
 *  @param tweet    The Tweet object representing the new state of this Tweet from
 *                  the perspective of the currently-logged in user.
 *  @param error    Error object describing the error that occurred. This will be either a
 *                  network error or an NSError with an errorCode corresponding to
 *                  TWTRAPIErrorCodeAlreadyFavorited or TWTRAPIErrorCodeAlreadyRetweeted
 *                  for an attempted action that has already been taken from the servers
 *                  point of view for this logged-in user.
 */
typedef void (^TWTRTweetActionCompletion)(TWTRTweet *_Nullable tweet, NSError *_Nullable error);

/**
 *  Completion block called when a media upload request to the Twitter API succeeds or fails.
 *
 *  @param mediaID The media ID of the object that was uploaded which can be used when tweeting.
 *  @param error   Error object describing the network error that occurred.
 */
typedef void (^TWTRMediaUploadResponseCompletion)(NSString *_Nullable mediaID, NSError *_Nullable error);

/**
 *  Completion block called when the send Tweet request succeeds or fails.
 *
 *  @param tweet The Twitter Tweet created.
 *  @param error Error that will be set if the API request failed.
 */
typedef void (^TWTRSendTweetCompletion)(TWTRTweet *_Nullable tweet, NSError *_Nullable error);

/**
 *  Completion block called when a request for the user's email succeeds or fails.
 *
 *  @param email The email of the user
 *  @param error Error object describing the error that occurred.
 */
typedef void (^TWTRRequestEmailCompletion)(NSString *_Nullable email, NSError *_Nullable error);

/**
 *  Client for consuming the Twitter REST API. Provides methods for common API requests, as well as the ability to create and send custom requests.
 */
@interface TWTRAPIClient : NSObject

/**
 *  The Twitter user ID this client is making API requests on behalf of or
 *  nil if it is a guest user.
 */
@property (nonatomic, copy, readonly, nullable) NSString *userID;

/**
 *  Constructs a `TWTRAPIClient` object to perform authenticated API requests with user authentication.
 *
 *  @param userID (optional) ID of the user to make requests on behalf of. If the ID is nil requests will be made using guest authentication.
 *
 *  @return Fully initialized API client to make authenticated requests against the Twitter REST API.
 */
- (instancetype)initWithUserID:(nullable NSString *)userID;

/**
 *  Constructs a `TWTRAPIClient` with the last logged-in user. If no user has been
 *  logged in yet this falls back to Guest authentication.
 *
 *  @return Fully initialized API client to make Guest or User authenticated requests to the Twitter REST API.
 */
+ (instancetype)clientWithCurrentUser;

/**
 *  @name Making Requests
 */

/**
 *  Returns a signed URL request.
 *
 *  @param method     Request method, GET, POST, PUT, DELETE, etc.
 *  @param URLString  Request URL. This is the full Twitter API URL. E.g. https://api.twitter.com/1.1/statuses/user_timeline.json
 *  @param parameters Request parameters.
 *  @param error      Error that will be set if there was an error signing the request.
 *
 *  @note If the request is not sent with the -[TWTRAPIClient sendTwitterRequest:completion:] method it is the developers responsibility to ensure that there is a valid guest session before this method is called.
 */
- (NSURLRequest *)URLRequestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(nullable NSDictionary *)parameters error:(NSError **)error;

/**
 *  Sends a Twitter request.
 *
 *  @param request    The request that will be sent asynchronously.
 *  @param completion Completion block to be called on response. Called on main queue.
 *  @return an NSProgress object which can be used to cancel the request.
 */
- (NSProgress *)sendTwitterRequest:(NSURLRequest *)request completion:(TWTRNetworkCompletion)completion;

/**
 *  @name Common API Actions
 */

/**
 *  Loads a Twitter User.
 *
 *  @param userID       (required) The Twitter user ID of the desired user.
 *  @param completion   Completion block to be called on response. Called on main queue.
 */
- (void)loadUserWithID:(NSString *)userID completion:(TWTRLoadUserCompletion)completion;

/**
 *  Loads a single Tweet from the network or cache.
 *
 *  @param tweetID      (required) The ID of the desired Tweet.
 *  @param completion   Completion bock to be called on response. Called on main queue.
 */
- (void)loadTweetWithID:(NSString *)tweetID completion:(TWTRLoadTweetCompletion)completion;

/**
 *  Loads a series of Tweets in a batch. The completion block will be passed an array of zero or more
 *  Tweets that loaded successfully. If some Tweets fail to load the array will contain less Tweets than
 *  number of requested IDs. If any Tweets fail to load, the IDs of the Tweets that did not load will
 *  be provided in the userInfo dictionary property of the error parameter under `TWTRTweetsNotLoadedKey`.
 *
 *  @param tweetIDStrings (required) An array of Tweet IDs.
 *  @param completion     Completion block to be called on response. Called on main queue.
 */
- (void)loadTweetsWithIDs:(NSArray *)tweetIDStrings completion:(TWTRLoadTweetsCompletion)completion;

/**
 *  Uploads media to the media server. Returns a media ID to be used when tweeting.
 *
 *  @param media       The media to upload
 *  @param contentType The HTTP content type of the media that you are uploading.
 *  @param completion  The completion handler to invoke.
 */
- (void)uploadMedia:(NSData *)media contentType:(NSString *)contentType completion:(TWTRMediaUploadResponseCompletion)completion;

/**
 *  Create and send a Tweet.
 *
 *  @param tweetText    (required) The text for a Tweet
 *  @param completion   Completion block to be called on response. Called on main queue.
 */
- (void)sendTweetWithText:(NSString *)tweetText completion:(TWTRSendTweetCompletion)completion;

/**
 *  Upload media and create a Tweet. Returns TWTRTweet to be used when debugging.
 *
 *  @param tweetText   The text for a Tweet
 *  @param image       UIImage to upload
 *  @param completion  The completion handler to invoke.
 */
- (void)sendTweetWithText:(NSString *)tweetText image:(UIImage *)image completion:(TWTRSendTweetCompletion)completion;

/**
 *  Create a Tweet with a video. Returns TWTRTweet to be used when debugging.
 *
 *  Note: there are several requirements of the video being uploaded:
 *  - Duration should be between 0.5 seconds and 30 seconds
 *  - File size should not exceed 15 mb
 *  - Dimensions should be between 32x32 and 1280x1024
 *  - Aspect ratio should be between 1:3 and 3:1
 *  - Frame rate should be 40fps or less
 *
 *  @param tweetText   The text for a Tweet
 *  @param videoData   The video to be uploaded. Please follow guideline https://dev.twitter.com/rest/media/uploading-media
 *  @param completion  The completion handler to invoke.
 */
- (void)sendTweetWithText:(NSString *)tweetText videoData:(NSData *)videoData completion:(TWTRSendTweetCompletion)completion;

/**
 *  Requests the email for the user id which the API client was instantiated with.
 *  This method requires that you are using an API Client which was instantiated with
 *  a logged in user otherwise you will receive a "Request failed: forbidden (403)" error.
 *
 *  @param completion A completion block to invoke when the request completes. The email address may
 *                    be a nil if the user does not have an email address, the email address
 *                    is unverified or you do not have the correct permissions to request the email address.
 *
 *  @note Requesting a user’s email address requires your application to be whitelisted by Twitter.
 *  To request access, please visit the "Permissions" section for your app at https://apps.twitter.com/
 */
- (void)requestEmailForCurrentUser:(TWTRRequestEmailCompletion)completion;

@end

NS_ASSUME_NONNULL_END
