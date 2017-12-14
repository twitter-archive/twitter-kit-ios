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

//  Internally this class keeps track of state and subscribers. Objects
//  can register to receive notifications based on object ID and class.
//
//  If an object tries to subscribe to a new object, it should usubscribe
//  from the previous object first.
//
//  e.g.   {@"TWTRTweet":
//                  {@"34890723", [tweetSubscriber9, tweetSubscriber3],
//                   @"19872398", [tweetSubscriber5],
//                   @"871629437",[tweetSubs1, tweetSubs89, tweetSubs3},
//          @"TWTRUser":
//                  {@"8732", [userSubscriber32, userSubscriber8],
//                   @"312", [userSubscriber2]}
//

#import "TWTRStore.h"
#import <TwitterCore/TWTRMultiThreadUtil.h>
#import "TWTRSubscriber.h"
#import "TWTRSubscription.h"
#import "TWTRTweet.h"

@interface TWTRStore ()

@property (nonatomic) NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, NSMutableArray<TWTRSubscription *> *> *> *subscriptions;

@end

@implementation TWTRStore

+ (instancetype)sharedInstance
{
    static TWTRStore *store;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[TWTRStore alloc] init];
    });
    return store;
}

- (instancetype)init
{
    if (self = [super init]) {
        _subscriptions = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Subscription

- (void)subscribeSubscriber:(id<TWTRSubscriber>)subscriber toClass:(Class)objectClass objectID:(NSString *)objectID
{
    [TWTRMultiThreadUtil assertMainThread];

    if (objectClass == nil || objectID == nil) {
        return;
    }

    [self unsafeAddSubscriber:subscriber className:NSStringFromClass(objectClass) key:objectID];
}

- (void)unsubscribeSubscriber:(id<TWTRSubscriber>)subscriber fromClass:(nullable Class)objectClass objectID:(nullable NSString *)objectID
{
    [TWTRMultiThreadUtil assertMainThread];

    if (objectClass == nil || objectID == nil) {
        return;
    }

    [self unsafeUnsubscribeSubscriber:subscriber className:NSStringFromClass(objectClass) objectID:objectID];
}

- (void)notifySubscribersOfChangesToObject:(id)object withID:(NSString *)objectID
{
    [TWTRMultiThreadUtil assertMainThread];

    NSString *className = NSStringFromClass([object class]);

    NSArray<TWTRSubscription *> *subscriptions = [self subscriptionsForClassName:className objectID:objectID];
    [subscriptions enumerateObjectsUsingBlock:^(TWTRSubscription *subscription, NSUInteger idx, BOOL *stop) {
        BOOL keyMatches = [subscription.key isEqualToString:objectID];
        BOOL classMatches = [subscription.className isEqual:className];
        if (keyMatches && classMatches) {
            [subscription.subscriber objectUpdated:object];
        }
    }];
}

#pragma mark - Unsafe Mutating Methods

- (void)unsafeAddSubscriber:(id<TWTRSubscriber>)subscriber className:(NSString *)className key:(NSString *)key
{
    TWTRSubscription *subscription = [[TWTRSubscription alloc] initWithSubscriber:subscriber className:className key:key];
    NSMutableArray *subscriptions = [self subscriptionsForClassName:className objectID:key];
    [subscriptions addObject:subscription];
}

- (void)unsafeUnsubscribeSubscriber:(id<TWTRSubscriber>)subscriber className:(NSString *)className objectID:(NSString *)objectID
{
    NSMutableArray *subscriptions = [self subscriptionsForClassName:className objectID:objectID];
    NSIndexSet *indexes = [subscriptions indexesOfObjectsPassingTest:^BOOL(TWTRSubscription *subscription, NSUInteger idx, BOOL *stop) {
        return [subscription.subscriber isEqual:subscriber];
    }];
    [subscriptions removeObjectsAtIndexes:indexes];
}

#pragma mark - Helpers

/**
 *  Return an array of all the subscriptions that exist for this class/objectID pair
 *
 *  e.g. [subscriber1, subscriber2]
 */
- (NSMutableArray<TWTRSubscription *> *)subscriptionsForClassName:(NSString *)className objectID:(nonnull NSString *)objectID
{
    if ([self subscriptionsForClassName:className][objectID] == nil) {
        self.subscriptions[className][objectID] = [NSMutableArray array];
    }

    return self.subscriptions[className][objectID];
}

/**
 *  Return the dictionary of subscribers.
 *
 *  e.g.   {@"34890723", [subscriber1, subscriber2],
 *          @"19872398", [subscriber2, subscriber3]}
 */
- (NSMutableDictionary<NSString *, NSMutableArray<TWTRSubscription *> *> *)subscriptionsForClassName:(NSString *)className
{
    if (self.subscriptions[className] == nil) {
        NSMutableDictionary<NSString *, NSMutableArray<TWTRSubscription *> *> *subscriptionsByObjectID = [NSMutableDictionary dictionary];
        self.subscriptions[className] = subscriptionsByObjectID;
    }

    return self.subscriptions[className];
}

@end
