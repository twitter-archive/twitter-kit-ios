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
#import "TWTRFixtureLoader.h"
#import "TWTRNotificationCenter.h"
#import "TWTRNotificationConstants.h"
#import "TWTRTestCase.h"
#import "TWTRTweet.h"

@interface TWTRNotificationCenterTests : TWTRTestCase

@property (nonatomic, readonly) id notificationCenterObserver;
@property (nonatomic, readonly) TWTRTweet *tweet;

@end

@implementation TWTRNotificationCenterTests

- (void)setUp
{
    [super setUp];

    _tweet = [TWTRFixtureLoader obamaTweet];
    _notificationCenterObserver = OCMObserverMock();
    [[NSNotificationCenter defaultCenter] addMockObserver:_notificationCenterObserver name:nil object:nil];
}

- (void)tearDown
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.notificationCenterObserver];

    [super tearDown];
}

- (void)testNotificationWasPosted
{
    [[self.notificationCenterObserver expect] notificationWithName:OCMOCK_ANY object:nil userInfo:OCMOCK_ANY];
    [TWTRNotificationCenter postNotificationName:@"name" tweet:self.tweet userInfo:nil];
    [self.notificationCenterObserver verify];
}

- (void)testNotificationWasPostedWithCorrectName
{
    [[self.notificationCenterObserver expect] notificationWithName:[OCMArg checkWithBlock:^BOOL(NSString *notificationName) {
                                                  return [notificationName isEqualToString:@"name"];
                                              }]
                                                            object:nil
                                                          userInfo:OCMOCK_ANY];
    [TWTRNotificationCenter postNotificationName:@"name" tweet:self.tweet userInfo:nil];
    [self.notificationCenterObserver verify];
}

- (void)testNotificationWasBroadcasted
{
    [[self.notificationCenterObserver expect] notificationWithName:@"name" object:[OCMArg isNil] userInfo:OCMOCK_ANY];
    [TWTRNotificationCenter postNotificationName:@"name" tweet:self.tweet userInfo:nil];
    [self.notificationCenterObserver verify];
}

- (void)testNotificationWasPostedWithTweet
{
    [[self.notificationCenterObserver expect] notificationWithName:@"name" object:nil userInfo:[OCMArg checkWithBlock:^BOOL(NSDictionary *userInfo) {
                                                                                          TWTRTweet *tweet = userInfo[TWTRNotificationInfoTweet];
                                                                                          return tweet != nil && [tweet.tweetID isEqualToString:@"266031293945503744"];
                                                                                      }]];
    [TWTRNotificationCenter postNotificationName:@"name" tweet:self.tweet userInfo:nil];
    [self.notificationCenterObserver verify];
}

@end
