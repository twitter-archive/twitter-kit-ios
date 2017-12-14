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

@protocol TWTRVersionedCacheable <NSObject, NSCoding>

/**
 *  Returns the versioned key for instances of the class to read and write this cacheable object into the cache store.
 *  This depends on +[Class<NSObject> version]. Version (default = 0) should be bumped every time we
 *  support a new or update an existing property of the concrete class.
 *
 *  @param IDString     (Required) ID of the instance of the cacheable class
 *  @param perspective  This is typically the currently authenticated user
 *                      but could be any key that differentiates views of the
 *                      data. `nil` means there's only one view.
 */
+ (NSString *)versionedCacheKeyWithID:(NSString *)IDString perspective:(NSString *)perspective __attribute__((nonnull(1)));

@end
