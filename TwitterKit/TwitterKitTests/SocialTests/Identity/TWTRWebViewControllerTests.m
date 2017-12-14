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

#import <UIKit/UIKit.h>
#import "TWTRTestCase.h"
#import "TWTRWebViewController.h"

@interface TWTRWebViewController ()

@property (nonatomic, readonly) UIWebView *webView;

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;

@end

@interface TWTRWebViewControllerTests : TWTRTestCase

@property (nonatomic) TWTRWebViewController *webVC;

@end

@implementation TWTRWebViewControllerTests

- (void)setUp
{
    [super setUp];
    TWTRWebViewControllerShouldLoadCompletion shouldLoadCompletion = ^BOOL(UIViewController *controller, NSURLRequest *urlRequest, UIWebViewNavigationType navType) {
        return YES;
    };
    self.webVC = [[TWTRWebViewController alloc] init];
    [self.webVC setShouldStartLoadWithRequest:shouldLoadCompletion];
}

- (void)testShouldStartLoadWithRequest_returnsYESForWhitelistedDomain
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://twitter.com/test"]];
    XCTAssert([self.webVC webView:nil shouldStartLoadWithRequest:request navigationType:0]);
}

- (void)testShouldStartLoadWithRequest_returnsYESForWhitelistedSubDomain
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://lol.twitter.com/test"]];
    XCTAssert([self.webVC webView:nil shouldStartLoadWithRequest:request navigationType:0]);
}

- (void)testShouldStartLoadWithRequest_returnsYESForWhitelistedScheme
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"twittersdk://callback"]];
    XCTAssert([self.webVC webView:nil shouldStartLoadWithRequest:request navigationType:0]);
}

- (void)testShouldStartLoadWithRequest_returnsNOForHackySchemeInQuery
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://lolp0wnedtwitter.com/twittersdk://callback"]];
    XCTAssertFalse([self.webVC webView:nil shouldStartLoadWithRequest:request navigationType:0]);
}

- (void)testShouldStartLoadWithRequest_returnsNOForHackyScheme
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"abctwittersdk://callback"]];
    XCTAssertFalse([self.webVC webView:nil shouldStartLoadWithRequest:request navigationType:0]);
}

- (void)testShouldStartLoadWithRequest_returnsNOForHackyCleverLOLDomain
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://lolp0wnedtwitter.com/test"]];
    XCTAssertFalse([self.webVC webView:nil shouldStartLoadWithRequest:request navigationType:0]);
}

- (void)testShouldStartLoadWithRequest_returnsYESForWhitelistedDomainButHackyQuery
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://twitter.com/test?query=twitter.com"]];
    XCTAssert([self.webVC webView:nil shouldStartLoadWithRequest:request navigationType:0]);
}

- (void)testShouldStartLoadWithRequest_returnsNOForNonWhitelistedDomain
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://google.com/test"]];
    XCTAssertFalse([self.webVC webView:nil shouldStartLoadWithRequest:request navigationType:0]);
}
@end
