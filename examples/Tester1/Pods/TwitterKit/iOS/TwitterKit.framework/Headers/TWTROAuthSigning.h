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

#import <TwitterCore/TWTRCoreOAuthSigning.h>

@class TWTRAuthConfig;
@class TWTRSession;

NS_ASSUME_NONNULL_BEGIN

/**
 *  This class provides tools to generate OAuth signatures.
 */
@interface TWTROAuthSigning : NSObject <TWTRCoreOAuthSigning>

/**
 *  @name Initialization
 */

/**
 *  Instantiate a `TWTROAuthSigning` object with the parameters it needs to generate the OAuth signatures.
 *
 *  @param authConfig       (required) Encapsulates credentials required to authenticate a Twitter application.
 *  @param authSession      (required) Encapsulated credentials associated with a user session.
 *
 *  @return An initialized `TWTROAuthSigning` object or nil if any of the parameters are missing.
 *
 *  @note If you want to generate OAuth Echo headers to verify Digits' credentials, see `DGTOAuthSigning`.
 *
 *  @see TWTRAuthConfig
 *  @see TWTRSession
 */
- (instancetype)initWithAuthConfig:(TWTRAuthConfig *)authConfig authSession:(TWTRSession *)authSession NS_DESIGNATED_INITIALIZER;

/**
 *  Unavailable. Use `-initWithAuthConfig:authSession:` instead.
 */
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
