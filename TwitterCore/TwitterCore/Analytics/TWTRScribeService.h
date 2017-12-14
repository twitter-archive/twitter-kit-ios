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

@class TFSScribe;
@class TWTRScribeEvent;
@class TWTRAPIClient;
@class TWTRAuthConfig;
@class TWTRGuestSession;
@class TWTRNetworkingPipeline;
@class TWTRSessionStore;
@class TWTRNetworking;
@protocol TWTRAuthSession;
@protocol TWTRAPIServiceConfig;

NS_ASSUME_NONNULL_BEGIN

@interface TWTRScribeService : NSObject

- (instancetype)initWithScribe:(TFSScribe *)scribe scribeAPIServiceConfig:(id<TWTRAPIServiceConfig>)APIserviceConfig;

- (instancetype)init NS_UNAVAILABLE;

/**
 This method must be called before the scribe attempts to enqueue any network requests.
 */
- (void)setSessionStore:(TWTRSessionStore *)sessionStore networkingPipeline:(TWTRNetworkingPipeline *)pipeline;

- (void)enqueueEvent:(nullable TWTRScribeEvent *)event;
- (void)enqueueEvents:(nullable NSArray *)events;

@end

NS_ASSUME_NONNULL_END
