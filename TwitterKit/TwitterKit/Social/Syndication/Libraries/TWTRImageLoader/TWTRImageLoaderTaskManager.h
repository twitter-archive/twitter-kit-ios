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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Manages internal image fetch tasks.
 */
@protocol TWTRImageLoaderTaskManager <NSObject>

/**
 *  Adds the task to the list of tracked in-flight tasks.
 *
 *  @param task (required) task to track
 *
 */
- (void)addTask:(NSURLSessionTask *)task withRequestID:(id<NSCopying>)requestID;

/**
 *  Removes the task matching the given identifier from the list of in-flight tasks.
 *
 *  @param requestID (required) identifier of the task to remove
 *
 *  @return taskOrNil matching the `requestID`
 */
- (nullable NSURLSessionTask *)removeTaskWithRequestID:(id<NSCopying>)requestID;

@end

/**
 *  Manages in-flight tasks. This class is _not_ thread-safe.
 */
@interface TWTRImageLoaderTaskManager : NSObject <TWTRImageLoaderTaskManager>

@end

NS_ASSUME_NONNULL_END
