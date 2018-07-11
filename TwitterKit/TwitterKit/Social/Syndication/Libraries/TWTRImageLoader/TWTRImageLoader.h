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

#import <UIKit/UIKit.h>
#import "TWTRImageLoaderCache.h"
#import "TWTRImageLoaderTaskManager.h"
#import "TWTRSEImageDownloader.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Completion block called when the fetch request succeeds or fails
 *
 *  @param image the fetched image if the request succeeded
 *  @param error error that is non nil if the request failed
 */
typedef void (^TWTRImageLoaderFetchCompletion)(UIImage *_Nullable image, NSError *_Nullable error);

@protocol TWTRImageLoader <NSObject>

/**
 *  Fetches the image at the given URL asynchronously. The request is started automatically.
 *  This method should only be called on the main thread.
 *
 *  @param url        (required) URL of the image to fetch
 *  @param completion (required) completion block to call when the request succeeds or fails. The
 *                    block will run on the main queue.
 *
 *  @return identifier that uniquely identifies the fetch request and can be used to cancel the
 *          request if necessary
 */
- (id<NSCopying>)fetchImageWithURL:(NSURL *)url completion:(TWTRImageLoaderFetchCompletion)completion;

/**
 *  Cancels the request given the identifier. This does not affect other in-flight requests to the same
 *  URL. This method is idempotent.
 *
 *  @param requestID (required) Identifier of the request to cancel
 */
- (void)cancelImageWithRequestID:(id<NSCopying>)requestID;

@end

/**
 Concrete implementation of <TWTRImageLoader> used to load images asynchronously. This class is thread-safe.
 */
@interface TWTRImageLoader : NSObject <TWTRImageLoader, TWTRSEImageDownloader>

- (instancetype)init __attribute__((unavailable("Use -initWithSession:cache:")));

/**
 *  `TWTRImageLoader` offers asynchronous fetching of images and caching the fetched images.
 *
 *  @param session (required) session for fetching images
 *  @param cache   (optional) cache store for caching fetched images. Nil if the fetched images should
 *                            not be cached
 *  @param taskManager (required) task manager to manage network requests
 *
 *  @return new instance of the `TWTRImageLoader` using the session for fetching images and cache
 *  for caching the fetched images.
 */
- (instancetype)initWithSession:(NSURLSession *)session cache:(nullable id<TWTRImageLoaderCache>)cache taskManager:(id<TWTRImageLoaderTaskManager>)taskManager;

@end

NS_ASSUME_NONNULL_END
