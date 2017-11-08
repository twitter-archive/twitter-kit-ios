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

@class TWTRGuestSession;
@class TWTRNetworkingPipelinePackage;
@class TWTRSession;

NS_ASSUME_NONNULL_BEGIN

/**
 * The block that is executed after the request is signed.
 */
typedef void (^TWTRRequestSigningSuccessBlock)(NSURLRequest *signedRequest);

/**
 * The block that is executed if the operation is cancelled.
 */
typedef void (^TWTRRequestSigningCancelBlock)(void);

typedef TWTRGuestSession *_Nonnull (^TWTRGuestSessionProvider)(void);
typedef TWTRSession *_Nonnull (^TWTRUserSessionProvider)(void);

/**
 * Do not instantiate this operation directly. Use one of the concrete
 * subclasses instead.
 */
@interface TWTRRequestSigningOperation : NSOperation

@property (nonatomic, readonly) TWTRNetworkingPipelinePackage *networkingPackage;

/**
 * Creates a signing operation.
 *
 * @param package the pipeline package that holds the request to sign
 * @param successBlock a block to execute when the package is signed.
 * @param cancelBlock a block to execute when the operation is cancelled.
 *
 * @note the callback blocks will execute on arbitrary queues.
 */
- (instancetype)initWithPackage:(TWTRNetworkingPipelinePackage *)package success:(nullable TWTRRequestSigningSuccessBlock)successBlock cancel:(nullable TWTRRequestSigningCancelBlock)cancelBlock;

- (instancetype)init NS_UNAVAILABLE;

/**
 * Subclasses must implement this method to return the signed request.
 */
- (NSURLRequest *)signRequest:(NSURLRequest *)request;

@end

@interface TWTRGuestRequestSigningOperation : TWTRRequestSigningOperation

/**
 * Creates a guest signing operation.
 *
 * @param package the pipeline package that holds the request to sign.
 * @param sessionProvider a block that will execute to provide the session at invocation time.
 * @param successBlock a block to execute when the package is signed.
 * @param cancelBlock a block to execute when the operation is cancelled.
 *
 * @note the callback blocks will execute on arbitrary queues.
 */
- (instancetype)initWithPackage:(TWTRNetworkingPipelinePackage *)package sessionProvider:(TWTRGuestSessionProvider)sessionProvider success:(nullable TWTRRequestSigningSuccessBlock)successBlock cancel:(nullable TWTRRequestSigningCancelBlock)cancelBlock;

@end

@interface TWTRUserRequestSigningOperation : TWTRRequestSigningOperation

/**
 * Creates a user signing operation.
 *
 * @param package the pipeline package that holds the request to sign.
 * @param sessionProvider a block that will execute to provide the session at invocation time.
 * @param successBlock a block to execute when the package is signed.
 * @param cancelBlock a block to execute when the operation is cancelled.
 *
 * @note the callback blocks will execute on arbitrary queues.
 */
- (instancetype)initWithPackage:(TWTRNetworkingPipelinePackage *)package sessionProvider:(TWTRUserSessionProvider)sessionProvider success:(nullable TWTRRequestSigningSuccessBlock)successBlock cancel:(nullable TWTRRequestSigningCancelBlock)cancelBlock;

@end

NS_ASSUME_NONNULL_END
