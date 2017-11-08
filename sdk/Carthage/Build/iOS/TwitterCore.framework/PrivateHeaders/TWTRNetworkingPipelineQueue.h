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

#import <Foundation/Foundation.h>
#import <TwitterCore/TWTRNetworkingPipeline.h>

@class TWTRNetworkingPipelinePackage;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TWTRNetworkingPipelineQueueType) {
    /**
     * Queues that depend on having a valid guest session
     */
    TWTRNetworkingPipelineQueueTypeGuest,

    /**
     * Queues that depend on having a valid user session
     */
    TWTRNetworkingPipelineQueueTypeUser
};

@interface TWTRNetworkingPipelineQueue : NSObject

/**
 * Returns the type that this queue was initialized with.
 */
@property (nonatomic, readonly) TWTRNetworkingPipelineQueueType queueType;

/**
 * A response validator to use to validate network responses.
 */
@property (nonatomic, readonly, nullable) id<TWTRNetworkingResponseValidating> responseValidator;

/**
 * Initializes the queue witht the given type.
 *
 * @param type The type of queue to initialize
 * @param session The NSURLSession to send requests with
 * @param responseValidator The response validator to use for this queue
 */
- (instancetype)initWithType:(TWTRNetworkingPipelineQueueType)type URLSession:(NSURLSession *)session responseValidator:(nullable id<TWTRNetworkingResponseValidating>)responseValidator NS_DESIGNATED_INITIALIZER;

/**
 * Convenience initializer to make a new guest pipeline.
 */
+ (instancetype)guestPipelineQueueWithURLSession:(NSURLSession *)session responseValidator:(nullable id<TWTRNetworkingResponseValidating>)responseValidator;

/**
 * Convenience initializer to make a new user pipeline.
 */
+ (instancetype)userPipelineQueueWithURLSession:(NSURLSession *)session responseValidator:(nullable id<TWTRNetworkingResponseValidating>)responseValidator;

/**
 * Enqueues a package for processing.
 * @return an NSProgress object which can be used to cancel the request.
 */
- (NSProgress *)enqueuePipelinePackage:(TWTRNetworkingPipelinePackage *)package;

/**
 * Use -[TWTRNetworkingPipelineQueue initWithType:URLSession:] instead.
 */
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
