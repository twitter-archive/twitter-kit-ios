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

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

typedef void (^TWTRSEImageDownloadCompletion)(UIImage *_Nullable image, NSError *_Nullable error);

@protocol TWTRSEImageDownloader <NSObject>

/**
 Download the image from the provided URL.
 This method may be called multiple times for the same URL, so consider implementing a cache.

 @param URL The URL of the image to download.
 @param completion To be invoked on any thread.
 @return A token that identifies this download to be used to call `-cancelImageDownloadWithToken:`.
 */
- (id)downloadImageFromURL:(NSURL *)URL completion:(TWTRSEImageDownloadCompletion)completion;

- (void)cancelImageDownloadWithToken:(id)previousDownloadToken;

@end

NS_ASSUME_NONNULL_END
