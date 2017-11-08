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

#import <OCMock/OCMock.h>
#import "TWTRTableViewProxy.h"
#import "TWTRTestCase.h"

@interface TWTRTableViewProxyTests : TWTRTestCase

@property (nonatomic, readonly) id mockTableView;
@property (nonatomic, readonly) id proxy;

@end

@implementation TWTRTableViewProxyTests

- (void)setUp
{
    [super setUp];

    _mockTableView = OCMClassMock([UITableView class]);
    _proxy = [[TWTRTableViewProxy alloc] initWithTableView:_mockTableView selectorsToProxy:@[@"reloadData"]];
}

- (void)testDoesNotProxyWhenDisabled
{
    [[self.mockTableView expect] reloadData];
    [self.proxy reloadData];
    OCMVerifyAll(self.mockTableView);
}

- (void)testDoesProxyWhenEnabledAndRegistered
{
    TWTRTableViewProxy *proxy = self.proxy;
    proxy.enabled = YES;

    [[self.mockTableView reject] reloadData];
    [self.proxy reloadData];
    OCMVerifyAll(self.mockTableView);
}

- (void)testDoesNotProxyUnlessRegistered
{
    TWTRTableViewProxy *proxy = [[TWTRTableViewProxy alloc] initWithTableView:self.mockTableView selectorsToProxy:@[]];
    proxy.enabled = YES;

    [[self.mockTableView expect] reloadData];
    [self.proxy reloadData];
    OCMVerifyAll(self.mockTableView);
}

@end
