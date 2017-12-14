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

#import "TWTRNetworking.h"

@class TWTRAuthConfig;

/**
 An Twitter Social HTTP API client for use with an Application only access token.
 Application only auth allows for an app to access some Twitter content without a logged in user.
 To obtain an app only access token use TWTRAuthClient.
 For more about application only auth see https://dev.twitter.com/docs/auth/application-only-auth .

 If you have a logged in user, use TwitterUserAPIClient.
 */
@interface TWTRAppAPIClient : TWTRNetworking

// The application only access token
@property (nonatomic, copy, readonly) NSString *accessToken;

/**
 Designated initializer. Returns nil if access token is missing.
 @param accessToken An application only access token.
 */
- (instancetype)initWithAuthConfig:(TWTRAuthConfig *)authConfig accessToken:(NSString *)accessToken;
- (instancetype)initWithAuthConfig:(TWTRAuthConfig *)authConfig NS_UNAVAILABLE;

@end
