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
#import "TWTRScribeSerializable.h"

FOUNDATION_EXTERN NSString *const TWTRScribeClientEventNamespaceEmptyValue;

/**
 *  Model object for describing any client events at Twitter.
 *  @see https://confluence.twitter.biz/display/ANALYTICS/client_event+Namespacing
 */
@interface TWTRScribeClientEventNamespace : NSObject <TWTRScribeSerializable>

/**
 *  The client application logging the event.
 */
@property (nonatomic, copy, readonly) NSString *client;

/**
 *  The page or functional grouping where the event occurred
 */
@property (nonatomic, copy, readonly) NSString *page;

/**
 *  A stream or tab on a page.
 */
@property (nonatomic, copy, readonly) NSString *section;

/**
 *  The actual page component, object, or objects where the event occurred.
 */
@property (nonatomic, copy, readonly) NSString *component;

/**
 *  A UI element within the component that can be interacted with.
 */
@property (nonatomic, copy, readonly) NSString *element;

/**
 *  The action the user or application took.
 */
@property (nonatomic, copy, readonly) NSString *action;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithClient:(NSString *)client page:(NSString *)page section:(NSString *)section component:(NSString *)component element:(NSString *)element action:(NSString *)action __attribute__((nonnull));

#pragma mark - Errors

/**
 *  Describes generic errors encounted inside Twitter Kits.
 */
+ (instancetype)errorNamespace;

@end
