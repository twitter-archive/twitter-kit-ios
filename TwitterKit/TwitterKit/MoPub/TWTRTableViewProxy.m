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

#import "TWTRTableViewProxy.h"

static NSString *const TWTRMoPubCategoryMethodsPrefix = @"mp_";

@interface TWTRTableViewProxy ()

@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, copy, readonly) NSArray<NSString *> *selectorsToProxy;
@property (nonatomic, readonly) BOOL isEnabled;

@end

@implementation TWTRTableViewProxy

- (instancetype)initWithTableView:(UITableView *)tableView selectorsToProxy:(NSArray<NSString *> *)selectorsToProxy
{
    _tableView = tableView;
    _selectorsToProxy = [selectorsToProxy copy];
    _isEnabled = NO;

    return self;
}

#pragma mark - NSProxy

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    return [self.tableView methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    if (self.isEnabled) {
        NSString *selectorString = NSStringFromSelector(invocation.selector);
        NSString *mopubSelectorString = [NSString stringWithFormat:@"%@%@", TWTRMoPubCategoryMethodsPrefix, NSStringFromSelector(invocation.selector)];
        SEL mopubSelector = NSSelectorFromString(mopubSelectorString);
        const BOOL selectorIsRegistered = [self.selectorsToProxy containsObject:selectorString];
        const BOOL canInvokeMopubMethods = [self.tableView respondsToSelector:mopubSelector];
        const BOOL shouldProxySelector = selectorIsRegistered && canInvokeMopubMethods;

        if (shouldProxySelector) {
            invocation.selector = mopubSelector;
        }
    }
    [invocation invokeWithTarget:self.tableView];
}

@end
