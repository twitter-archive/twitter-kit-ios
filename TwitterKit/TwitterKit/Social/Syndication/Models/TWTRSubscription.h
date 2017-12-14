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

#import "TWTRSubscriber.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  An object representing one object, subscribing to changes to one property
 */
@interface TWTRSubscription : NSObject

/**
 *  A reference to the object desiring notifications. Weak reference to
 *  prevent retain cycles.
 */
@property (nonatomic, weak, readonly) id<TWTRSubscriber> subscriber;

/**
 *  The class of the object being observed.
 */
@property (nonatomic, copy, readonly) NSString *className;

/**
 *  A key describing the specific object ID that should be observed. This
 *  could be a Tweet ID if observing Tweets, a User ID if observing Users, etc.
 */
@property (nonatomic, copy, readonly) NSString *key;

/**
 *  Initialize with an object desiring to be notified when a particular object
 *  changes.
 *
 *  @param subscriber The object desiring to be notified.
 *  @param className  The name of the class of the object to observe.
 *  @param key        The key which to observe changes.
 *
 *  @return A fully initialized subscription object.
 */
- (instancetype)initWithSubscriber:(id<TWTRSubscriber>)subscriber className:(NSString *)className key:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
