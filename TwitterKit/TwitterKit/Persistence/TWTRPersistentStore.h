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

/**
 This class is thread-safe so you should be able to get/set from multiple threads.
 */
@interface TWTRPersistentStore : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithPath:(NSString *)path maxSize:(NSUInteger)size;

- (BOOL)setObject:(id<NSCoding>)value forKey:(NSString *)key;
- (id)objectForKey:(NSString *)key;
- (BOOL)removeObjectForKey:(NSString *)key;
- (void)removeAllObjects;

@property (nonatomic, assign, readonly) uint64_t totalSize;

@end
