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
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Proxy class to abstract the logic of invoking (optionally linked) MoPub category methods
 *  invoked on a `UITableView` from TwitterKit classes. The MoPub category (`mp_*`) versions of
 *  `UITableView` methods e.g. `mp_reloadData` instead of `reloadData` should be invoked if and only
 *  if MoPub is linked.
 *
 *  @see https://dev.twitter.com/mopub/ios/native
 */
@interface TWTRTableViewProxy : NSProxy

/**
 *  Determines whether the proxy should proxy invocations. The default is `NO`.
 */
@property (nonatomic, getter=isEnabled) BOOL enabled;

/**
 *  Instantiates a new proxy object to determine whether the MoPub version of the `UITableView`
 *  methods should be invoked instead.
 *
 *  @param tableView        the associated `UITableView`
 *  @param selectorsToProxy String representations of the `UITableView` selectors to proxy
 *
 *  @return A fully instantiated proxy for the associating tableView proxying the specified selectors.
 */
- (instancetype)initWithTableView:(UITableView *)tableView selectorsToProxy:(NSArray<NSString *> *)selectors;

@end

NS_ASSUME_NONNULL_END
