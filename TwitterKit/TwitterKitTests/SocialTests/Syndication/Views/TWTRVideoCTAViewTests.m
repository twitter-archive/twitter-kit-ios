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
#import "TWTRVideoCTAView.h"
#import "TWTRVideoDeeplinkConfiguration.h"

@interface TWTRVideoCTAViewTestsDelegate : NSObject <TWTRVideoCTAViewDelegate>
@property (nonatomic, readonly) BOOL didGetCalled;
@end

@interface TWTRVideoCTAView ()
// exposed for testing
- (void)handleDeeplinkButton;
@property (nonatomic, readonly) UIButton *CTAButton;
@end

@interface TWTRVideoCTAViewTests : XCTestCase

@property (nonatomic, readonly) TWTRVideoCTAViewTestsDelegate *delegateMock;
@property (nonatomic, readonly) TWTRVideoCTAView *CTAView;
@property (nonatomic, readonly) TWTRVideoDeeplinkConfiguration *deeplinkConfig;

@end

@implementation TWTRVideoCTAViewTests

- (void)setUp
{
    [super setUp];
    _delegateMock = [[TWTRVideoCTAViewTestsDelegate alloc] init];

    NSURL *targetURL = [NSURL URLWithString:@"https://vine.co"];
    NSURL *metricsURL = [NSURL URLWithString:@"https://t.co/nothing"];
    _deeplinkConfig = [[TWTRVideoDeeplinkConfiguration alloc] initWithDisplayText:@"text" targetURL:targetURL metricsURL:metricsURL];
    _CTAView = [[TWTRVideoCTAView alloc] initWithFrame:CGRectZero deeplinkConfiguration:_deeplinkConfig];
    _CTAView.delegate = self.delegateMock;
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testTextSetOnButton
{
    XCTAssertEqualObjects(self.CTAView.CTAButton.currentTitle, self.deeplinkConfig.displayText);
}

- (void)testDelegateCalledOnDeeplink
{
    XCTAssertFalse(self.delegateMock.didGetCalled);
    [self.CTAView handleDeeplinkButton];
    XCTAssertTrue(self.delegateMock.didGetCalled);
}

@end

@implementation TWTRVideoCTAViewTestsDelegate

- (void)videoCTAView:(TWTRVideoCTAView *)CTAView willDeeplinkToTargetURL:(NSURL *)targetURL
{
    _didGetCalled = YES;
}

@end
