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
#import <TwitterCore/TWTRUtils.h>
#import <XCTest/XCTest.h>
#import "TWTRFixtureLoader.h"
#import "TWTRNotificationCenter.h"
#import "TWTRShareButton.h"
#import "TWTRTweet.h"
#import "TWTRTweetShareItemProvider.h"
#import "TWTRTweetView.h"
#import "TWTRTweetView_Private.h"
#import "TWTRTwitter_Private.h"

static TWTRTweet *testTweet;

@interface TWTRShareButtonTests : XCTestCase

@property (nonatomic, readonly) id mockTweetViewDelegate;
@property (nonatomic, readonly) TWTRTweetView *tweetView;
@property (nonatomic, readonly) id mockNotificationCenter;
@property (nonatomic, strong) UIViewController *presenterViewController;

@end

@interface TWTRShareButton ()
- (BOOL)shouldPresentShareSheetUsingPopover;
- (void)shareButtonTapped;
@end

// Stub ActivityViewController (calls completion immediately)
@interface StubActivityViewController : UIActivityViewController
@property (nonatomic, assign) BOOL shouldSucceed;
@end
@implementation StubActivityViewController
- (void)setCompletionWithItemsHandler:(UIActivityViewControllerCompletionWithItemsHandler)completionHandler
{
    completionHandler(@"mailActivity", self.shouldSucceed, nil, nil);
}
@end

void imitateDevice(UIUserInterfaceIdiom idiom)
{
    id mockCurrentDevice = OCMPartialMock([UIDevice currentDevice]);
    id mockDeviceClass = OCMClassMock([UIDevice class]);
    OCMStub([mockDeviceClass currentDevice]).andReturn(mockCurrentDevice);
    OCMStub([mockCurrentDevice userInterfaceIdiom]).andReturn(idiom);
}

@implementation TWTRShareButtonTests

+ (void)setUp
{
    testTweet = [TWTRFixtureLoader obamaTweet];
}

- (void)setUp
{
    [super setUp];

    _mockTweetViewDelegate = [OCMockObject niceMockForProtocol:@protocol(TWTRTweetViewDelegate)];
    _mockNotificationCenter = OCMClassMock([TWTRNotificationCenter class]);
    _tweetView = [[TWTRTweetView alloc] initWithTweet:testTweet];
    _tweetView.delegate = _mockTweetViewDelegate;
}

- (void)tearDown
{
    [self.mockNotificationCenter stopMocking];
    [self.mockTweetViewDelegate stopMocking];
    [super tearDown];
}

#pragma mark - Delegate Methods

- (void)testShareTweet_postsWillShareNotification
{
    OCMExpect([self.mockNotificationCenter postNotificationName:@"TWTRWillShareTweetNotification" tweet:testTweet userInfo:nil]);
    [self.tweetView.shareButton shareButtonTapped];
    [self.mockNotificationCenter verify];
}

- (void)testShareTweet_postsDidShareNotification
{
    OCMExpect([self.mockNotificationCenter postNotificationName:@"TWTRDidShareTweetNotification" tweet:testTweet userInfo:nil]);
    id mockUIActivityViewController = [OCMockObject niceMockForClass:[UIActivityViewController class]];
    StubActivityViewController *stubActivity = [[StubActivityViewController alloc] initWithActivityItems:@[] applicationActivities:nil];
    stubActivity.shouldSucceed = YES;
    [[[mockUIActivityViewController expect] andReturn:stubActivity] alloc];

    [self.tweetView.shareButton shareButtonTapped];
    [self.mockNotificationCenter verify];
}

- (void)testShareTweet_callsDidCancel
{
    OCMExpect([self.mockNotificationCenter postNotificationName:@"TWTRCancelledShareTweetNotification" tweet:testTweet userInfo:nil]);

    StubActivityViewController *stubActivity = [[StubActivityViewController alloc] initWithActivityItems:@[] applicationActivities:nil];

    id mockUIActivityViewController = [OCMockObject niceMockForClass:[UIActivityViewController class]];
    [[[mockUIActivityViewController expect] andReturn:stubActivity] alloc];

    [self.tweetView.shareButton shareButtonTapped];
    [self.mockNotificationCenter verify];
}

#pragma mark - Should Present in Popover

- (void)testShouldPresentWithPopover_returnsYesForPad
{
    imitateDevice(UIUserInterfaceIdiomPad);

    BOOL shouldPresent = [self.tweetView.shareButton shouldPresentShareSheetUsingPopover];
    XCTAssertEqual(shouldPresent, YES);
}

- (void)testShouldPresentWithPopover_returnsNoForPhone
{
    imitateDevice(UIUserInterfaceIdiomPhone);

    BOOL shouldPresent = [self.tweetView.shareButton shouldPresentShareSheetUsingPopover];
    XCTAssertEqual(shouldPresent, NO);
}

#pragma mark - Share Items

- (void)testShareTweet_usesTheProperItemProviderWithTweet
{
    id mockUIActivityViewController = [OCMockObject niceMockForClass:[UIActivityViewController class]];
    [[[mockUIActivityViewController expect] andReturn:mockUIActivityViewController] alloc];
    // For some reason, it's confused when you try to invoke init* and warns
    // on "Expression result unused". Casting to void fixes this.
    (void)[[[mockUIActivityViewController expect] andReturn:mockUIActivityViewController] initWithActivityItems:[OCMArg checkWithBlock:^BOOL(NSArray *activityItems) {
                                                                                              TWTRTweetShareItemProvider *itemProvider = [activityItems firstObject];
                                                                                              return itemProvider && itemProvider.tweet == testTweet;
                                                                                          }]
                                                                                          applicationActivities:nil];

    [self.tweetView.shareButton shareButtonTapped];

    [mockUIActivityViewController verify];
    [mockUIActivityViewController stopMocking];
}

#pragma mark - Present

- (void)testShareTweet_usesPopover
{
    // Can't create a UIPopoverController on iPhone
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return;
    }

    self.presenterViewController = [[UIViewController alloc] init];

    id mockPresenter = OCMPartialMock(self.presenterViewController);
    self.tweetView.shareButton.presenterViewController = mockPresenter;
    OCMExpect([mockPresenter presentViewController:[OCMArg checkWithBlock:^BOOL(id obj) {
                                 UIActivityViewController *controller = obj;
                                 return (controller.modalPresentationStyle == UIModalPresentationPopover);
                             }]
                                          animated:YES
                                        completion:OCMOCK_ANY]);

    [self.tweetView.shareButton shareButtonTapped];
    OCMVerifyAll(mockPresenter);
}

- (void)testShareTweet_usesTopViewController
{
    imitateDevice(UIUserInterfaceIdiomPhone);

    id mockUtils = OCMClassMock([TWTRUtils class]);
    id mockTopViewController = OCMClassMock([UIViewController class]);
    OCMExpect([mockTopViewController presentViewController:[OCMArg checkWithBlock:^BOOL(id obj) {
                                         NSLog(@"Object: %@", obj);
                                         return [obj isKindOfClass:[UIActivityViewController class]];
                                     }]
                                                  animated:YES
                                                completion:nil]);
    OCMStub([mockUtils topViewController]).andReturn(mockTopViewController);

    TWTRTweetView *tweetView = [[TWTRTweetView alloc] initWithTweet:testTweet];
    [tweetView.shareButton shareButtonTapped];
    OCMVerifyAll(mockTopViewController);
}

- (void)testShareTweet_usesPresentationControllerWhenSet
{
    imitateDevice(UIUserInterfaceIdiomPhone);

    id mockPresenter = OCMClassMock([UIViewController class]);
    OCMExpect([mockPresenter presentViewController:[OCMArg checkWithBlock:^BOOL(id obj) {
                                 return [obj isKindOfClass:[UIActivityViewController class]];
                             }]
                                          animated:YES
                                        completion:nil]);
    self.tweetView.presenterViewController = mockPresenter;

    [self.tweetView.shareButton shareButtonTapped];
    OCMVerifyAll(mockPresenter);
}

@end
