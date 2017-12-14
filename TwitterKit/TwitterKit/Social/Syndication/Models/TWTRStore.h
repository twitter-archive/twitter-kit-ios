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

//  This object holds on to the list of subscribers for being notified of changes
//  of state inside of TwitterKit.

#import "TWTRSubscriber.h"

NS_ASSUME_NONNULL_BEGIN

@interface TWTRStore : NSObject

/**
 *  Shared store object.
 */
+ (instancetype)sharedInstance;

#pragma mark - Subscription Methods

/**
 *  Subscribe to changes for a single object (Tweet, User, Collection, etc).
 *  This runs asynchronously on an internal serial queue.
 *
 *  @param subscriber  The object desiring updates upon changes.
 *  @param objectClass The class of the object to observe.
 *  @param objectID    The specific ID of the object (Tweet ID, User ID, etc).
 *
 *  @note This method must be called from the main thread.
 */
- (void)subscribeSubscriber:(id<TWTRSubscriber>)subscriber toClass:(nullable Class)objectClass objectID:(nullable NSString *)objectID;

/**
 *  Unsubscribe from notifications. The subscription object will not longer
 *  be retained. This runs asynchronously on an internal serial queue.
 *
 *  @param subscriber  The object previously registered for updates.
 *  @param objectClass The class of the object previously registered.
 *  @param objectID    The object's unique id.
 *
 *  @note This method must be called from the main thread.
 */
- (void)unsubscribeSubscriber:(id<TWTRSubscriber>)subscriber fromClass:(nullable Class)objectClass objectID:(nullable NSString *)objectID;

#pragma mark - Notification

/**
 *  Notify subscribers of changes to an object. This calls the
 *  `objectUpdated:` method on all `TWTRSubscriber` objects that
 *  have registered to receive updates when that particular object
 *  class and objectID have changed.
 *
 *  This runs asynchronously on an internal serial queue, but calls out to
 *  subscribers on the main thread.
 *
 *  Note: Ideally, this logic will happen internally when this class handles
 *  dispatching actions and storing state as well.
 *
 *  @param object   The object itself that has changed.
 *  @param objectID The object ID.
 *
 *  @note This method must be called from the main thread.
 */
- (void)notifySubscribersOfChangesToObject:(id)object withID:(NSString *)objectID;

@end

NS_ASSUME_NONNULL_END
