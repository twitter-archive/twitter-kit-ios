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

NS_ASSUME_NONNULL_BEGIN

@protocol TWTRImageLoaderCache <NSObject>

/**
 *  Sets the image with the given key.
 *
 *  @param image image to add to the cache
 *  @param key   ID associated with this image
 */
- (void)setImage:(UIImage *)image forKey:(NSString *)key;

/**
 *  Sets the image data with the given key.
 *
 *  @param imageData underlying data of the image
 *  @param key       ID associated with this image
 */
- (void)setImageData:(NSData *)imageData forKey:(NSString *)key;

/**
 *  Fetches image from cache given the key.
 *
 *  TODO:
 *  - add the ability to specify format of the image you want to fetch e.g. thumbnail vs. main
 *  - resizing/cropping/decoding/sampling for quality
 *
 *  @param key        ID of the image
 *  @param completion completion block to call when it's done fetching
 */
- (nullable UIImage *)fetchImageForKey:(NSString *)key;

/**
 *  Removes image associated with the given key. No-op if no image is found.
 *
 *  @param key ID of the image
 *
 *  @return the deleted imageOrNil associated with the given key
 */
- (nullable UIImage *)removeImageForKey:(NSString *)key;

/**
 *  Removes all images from the cache.
 */
- (void)removeAllImages;

@end

/**
 Dummy cache class that never caches anything. Use this if you do not want to persist to cache wherever
 a cache store is required. This class is thread-safe.
 */
@interface TWTRImageLoaderNilCache : NSObject <TWTRImageLoaderCache>

@end

/**
 Persistent disk cache for images. Simple wrapper around `TWTRPersistentStore`. This class is thread-safe
 but blocking because of `TWTRPersistentStore`.
 */
@interface TWTRImageLoaderDiskCache : NSObject <TWTRImageLoaderCache>

- (instancetype)init NS_UNAVAILABLE;

/**
 *  Initializes a disk cache with the given path.
 *
 *  @param path     path where cached items are stored
 *  @param maxSize  max size of the disk cache. Older images will be evicted when this limit is reached.
 *
 *  @return new instance of cacheOrNil at the given path
 */
- (nullable instancetype)initWithPath:(NSString *)path maxSize:(NSUInteger)size;

@end

NS_ASSUME_NONNULL_END
