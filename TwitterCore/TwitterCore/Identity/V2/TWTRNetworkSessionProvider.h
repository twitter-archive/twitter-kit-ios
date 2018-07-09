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
 This header is private to the Twitter Core SDK and not exposed for public SDK consumption
 */

@class TWTRAuthConfig;
@class TWTRGuestSession;
@class TWTRSession;
@protocol TWTRAuthSession;
@protocol TWTRAPIServiceConfig;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Completion block called when user authenticaiton succeeds or fails.
 *
 *  @param userSession The logged in user session
 *  @param error       Non nil error if user authentication fails
 */
typedef void (^TWTRNetworkSessionProviderUserLogInCompletion)(TWTRSession *_Nullable userSession, NSError *_Nullable error);

/**
 *  Completion block called when app authentication succeeds or fails.
 *
 *  @param accessToken  The bearer access token for guest auth.
 *  @param error        Non nil error if app authentication fails.
 */
typedef void (^TWTRNetworkSessionProviderAppLogInCompletion)(NSString *_Nullable accessToken, NSError *_Nullable error);

/**
 *  Completion block called when guest authentication succeeds or fails.
 *
 *  @param guestSession The logged in guest session
 *  @param error        Non nil error if guest authentication fails
 */
typedef void (^TWTRNetworkSessionProviderGuestLogInCompletion)(TWTRGuestSession *_Nullable guestSession, NSError *_Nullable error);

/**
 *  Protocol for wrapper methods to retrieving Twitter sessions.
 */
@protocol TWTRNetworkSessionProvider <NSObject>

+ (void)userSessionWithAuthConfig:(TWTRAuthConfig *)authConfig APIServiceConfig:(id<TWTRAPIServiceConfig>)APIServiceConfig completion:(TWTRNetworkSessionProviderUserLogInCompletion)completion __TVOS_UNAVAILABLE;

+ (void)verifyUserSession:(id<TWTRAuthSession>)userSession withAuthConfig:(TWTRAuthConfig *)authConfig APIServiceConfig:(id<TWTRAPIServiceConfig>)APIServiceConfig URLSession:(NSURLSession *)URLSession completion:(TWTRNetworkSessionProviderUserLogInCompletion)completion;

+ (void)verifySessionWithAuthToken:(NSString *)authToken authSecret:(NSString *)authTokenSecret withAuthConfig:(TWTRAuthConfig *)authConfig APIServiceConfig:(id<TWTRAPIServiceConfig>)APIServiceConfig URLSession:(NSURLSession *)URLSession completion:(TWTRNetworkSessionProviderUserLogInCompletion)completion;

+ (void)guestSessionWithAuthConfig:(TWTRAuthConfig *)authConfig APIServiceConfig:(id<TWTRAPIServiceConfig>)APIServiceConfig URLSession:(NSURLSession *)URLSession accessToken:(NSString *_Nullable)accessToken completion:(TWTRNetworkSessionProviderGuestLogInCompletion)completion;

@end

/**
 *  Concrete implementation of <TWTRNetworkSessionProvider>.
 */
@interface TWTRNetworkSessionProvider : NSObject <TWTRNetworkSessionProvider>

@end

NS_ASSUME_NONNULL_END
