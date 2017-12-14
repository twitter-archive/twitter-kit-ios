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

#import <XCTest/XCTest.h>
#import "TWTRTimelineMessageView.h"

@interface TWTRTimelineMessageViewTests : XCTestCase

@property (nonatomic) TWTRTimelineMessageView *messageView;

@end

@interface TWTRTimelineMessageView ()

@property (nonatomic) UILabel *messageLabel;
@property (nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation TWTRTimelineMessageViewTests

- (void)setUp
{
    [super setUp];

    self.messageView = [[TWTRTimelineMessageView alloc] init];
}

- (void)testLoading_showsSpinner
{
    [self.messageView beginLoading];

    XCTAssertEqual(self.messageView.activityIndicator.hidden, NO);
    XCTAssertEqual(self.messageView.activityIndicator.isAnimating, YES);
    XCTAssertEqual(self.messageView.messageLabel.hidden, YES);
}

- (void)testNotLoading_hidesSpinner
{
    [self.messageView endLoading];

    XCTAssertEqual(self.messageView.activityIndicator.hidden, YES);
    XCTAssertEqual(self.messageView.activityIndicator.isAnimating, NO);
}

- (void)testMessage_showsMessage
{
    [self.messageView endLoadingWithMessage:@"No tweets found"];

    XCTAssertEqual(self.messageView.messageLabel.hidden, NO);
    XCTAssertEqualObjects(self.messageView.messageLabel.text, @"No tweets found");
}

@end
