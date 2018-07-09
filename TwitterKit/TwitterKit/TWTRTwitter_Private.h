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

#import <TwitterCore/TWTRNetworking.h>
#import <TwitterCore/TWTRUserSessionVerifier.h>
#import "TWTRImageLoader.h"
#import "TWTRTwitter.h"

@class TWTRAuthClient;
@class TWTRTweetRepository;
@class TWTRUserSessionVerifier;
@protocol TWTRAPIServiceConfig;

@interface TWTRTwitter () <TWTRUserSessionVerifierDelegate>

@property (nonatomic) NSDictionary *kitInfo;
@property (nonatomic, readonly) TWTRUserSessionVerifier *userSessionVerifier;
@property (nonatomic, readonly, getter=isInitialized) BOOL initialized;
@property (nonatomic) TWTRAuthConfig *authConfig;

@property (nonatomic, readonly) TWTRImageLoader *imageLoader;

/**
 *  Cause the next call to sharedInstance or alloc to create a new instance. Only for testing.
 *
 *  @warning Not thread safe. This can cause dispatch_once to not do it's job correctly if
 *           sharedInstance is called from multiple threads after calling this method.
 *
 *  Intended only for use in tests due to its un-threadsafe effects on +sharedInstance.
 */
+ (void)resetSharedInstance;

/**
 *  Set a new copy of the static sharedTwitter varible.
 *
 *  Only to be used for testing.
 */
+ (void)setSharedTwitter:(TWTRTwitter *)sharedTwitter;

- (void)userSessionVerifierNeedsSessionVerification:(TWTRUserSessionVerifier *)userSessionVerifier;

@end
