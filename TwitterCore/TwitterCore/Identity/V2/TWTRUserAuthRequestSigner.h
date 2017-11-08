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

@class TWTRAuthConfig;
@protocol TWTRAuthSession;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Signer abstracting logic and type of user auth to sign a user authenticated network request.
 */
@interface TWTRUserAuthRequestSigner : NSObject

/**
 *  Signs the given request with the appropriate user authentication headers.
 *
 *  @param URLRequest URL request to sign
 *  @param authConfig The auth config containing the app's `consumerKey` and `consumerSecret`
 *  @param session    The authenticated user session
 *
 *  @return The signed URL request
 */
+ (NSURLRequest *)signedURLRequest:(NSURLRequest *)URLRequest authConfig:(TWTRAuthConfig *)authConfig session:(id<TWTRAuthSession>)session;

@end

NS_ASSUME_NONNULL_END
