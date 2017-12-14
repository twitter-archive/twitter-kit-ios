//
//  DemoAppTests.m
//  DemoAppTests
//
//  Created by Steven Hepting on 4/5/17.
//  Copyright © 2017 Twitter. All rights reserved.
//

#import <EarlGrey/EarlGrey.h>
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

id<GREYMatcher> matcher(NSString *name, Class class)
{
    return grey_allOf(grey_accessibilityLabel(name), grey_kindOfClass(class), grey_sufficientlyVisible(), nil);
}

id<GREYMatcher> cellMatcher(NSString *name)
{
    id<GREYMatcher> matcher = grey_allOf(grey_accessibilityLabel(name), nil);
    return matcher;
}

void selectTab(NSString *tabName)
{
    [[EarlGrey selectElementWithMatcher:matcher(tabName, NSClassFromString(@"UITabBarButton"))] performAction:grey_tap()];
}

void selectButton(NSString *name)
{
    [[EarlGrey selectElementWithMatcher:grey_buttonTitle(name)] performAction:grey_tap()];
}
void selectView(NSString *name)
{
    [[EarlGrey selectElementWithMatcher:grey_accessibilityLabel(name)] performAction:grey_tap()];
}

void inputText(NSString *labelName, NSString *text)
{
    [[EarlGrey selectElementWithMatcher:grey_accessibilityLabel(labelName)] performAction:grey_typeText(text)];
}

void assertView(NSString *name)
{
    [[EarlGrey selectElementWithMatcher:grey_accessibilityLabel(name)] assertWithMatcher:grey_sufficientlyVisible()];
}

void waitForViewWithAccessibility(NSString *view)
{
    NSError *error;
    [[EarlGrey selectElementWithMatcher:grey_firstResponder()] assertWithMatcher:grey_text(view) error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
    }
}

@interface DemoAppTests : XCTestCase <GREYFailureHandler>

@end

@implementation DemoAppTests

- (void)handleException:(GREYFrameworkException *)exception details:(NSString *)details
{
    // Log the failure and state of the app if required.
    // Call thru to XCTFail() with an appropriate error message.
    NSLog(@"Failed test %@", exception);
}

- (void)setInvocationFile:(NSString *)fileName andInvocationLine:(NSUInteger)lineNumber
{
    // Record the file name and line number of the statement which was executing before the
    // failure occurred.
    NSLog(@"Failed %@ at %lu", fileName, (unsigned long)lineNumber);
}

- (void)setUp
{
    [EarlGrey setFailureHandler:self];
}

#pragma mark - Tabs

- (void)testTabBar_demoControllers
{
    selectTab(@"Demo");
    //    assertView(@"Action Buttons");
}

- (void)testTabBar_authPage
{
    selectTab(@"OAuth");
    //    assertView(@"Log in with Twitter");
}

- (void)testTabBar_teamPage
{
    selectTab(@"Team");
}

#pragma mark - OAuth Tab

- (void)testLoginButton
{
    selectTab(@"OAuth");
    selectView(@"Clear Test Account");
    selectView(@"Log in with Twitter");
    selectView(@"Cancel");

    // TODO: Add tab first item if accounts exist
}

- (void)testCustomLoginButton
{
    selectTab(@"OAuth");
    selectButton(@"Login with Custom Button");

    GREYCondition *waitForWebView = [GREYCondition conditionWithName:@"wait for web view" block:^BOOL {
        return [[EarlGrey selectElementWithMatcher:grey_accessibilityLabel(@"Username or email")] assertWithMatcher:grey_notNil()];
    }];

    GREYAssertTrue([waitForWebView waitWithTimeout:3], @"Wait for web view");
}

- (void)testAuth_RemoveAccount
{
    selectTab(@"OAuth");
    selectView(@"Clear Test Account");
    [[EarlGrey selectElementWithMatcher:grey_accessibilityLabel(@"Accounts in current session")] assertWithMatcher:grey_text(@"")];
}

#pragma mark - Compact Tweets

- (void)testTweets_compact
{
    selectTab(@"Demo");
    selectView(@"Compact Tweets");
    selectView(@"Image Attachment");
    selectView(@"Close");
}

#pragma mark - Regular Tweets

- (void)testTweets_regular
{
    selectTab(@"Demo");
    selectView(@"Regular Tweets");
    selectView(@"Like");

    // TODO: May need to add cancel for multiple account for user engagement
}

@end
