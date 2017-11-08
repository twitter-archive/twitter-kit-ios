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

#import <TwitterCore/TWTRSessionStore.h>
#import "TWTRNetworkingPipeline.h"

NS_ASSUME_NONNULL_BEGIN

@interface TWTRNetworkingPipelinePackage : NSObject <NSCopying>

/**
 * The URL request object that will be executed by this package.
 */
@property (nonatomic, copy, readonly) NSURLRequest *request;

/**
 * The session store that will be used by the package to provide session information.
 */
@property (nonatomic, readonly) id<TWTRSessionStore> sessionStore;

/**
 * The userID associated with this package or nil to signify that
 * the guest session should be used.
 */
@property (nonatomic, copy, readonly, nullable) NSString *userID;

/**
 The calback block to execute when the request is finished or fails.
 */
@property (nonatomic, copy, readonly, nullable) TWTRNetworkingPipelineCallback callback;

/**
 A counter to track the attempts (with retries) of the request operation associated with the this package. It can be useful
 to avoid retrying a request indefinitely (stop after certain threshold). It starts with 1
 */
@property (nonatomic, readonly) NSInteger attemptCounter;

/**
 * A UUI associated with this package.
 */
@property (nonatomic, readonly) NSUUID *UUID;

- (instancetype)initWithRequest:(NSURLRequest *)request sessionStore:(id<TWTRSessionStore>)sessionStore userID:(nullable NSString *)userID completion:(nullable TWTRNetworkingPipelineCallback)callback NS_DESIGNATED_INITIALIZER;

+ (instancetype)packageWithRequest:(NSURLRequest *)request sessionStore:(id<TWTRSessionStore>)sessionStore userID:(nullable NSString *)userID completion:(nullable TWTRNetworkingPipelineCallback)callback;

/*
  Create a copy of current package instance with attemptCounter being added by one. current package object remain unchanged.
 */
- (instancetype)copyForRetry;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
