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

#import "TWTRWebViewController.h"
#import <TwitterCore/TWTRAuthenticationConstants.h>

@interface TWTRWebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, assign) BOOL showCancelButton;
@property (nonatomic, copy) TWTRWebViewControllerCancelCompletion cancelCompletion;

@end

@implementation TWTRWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:@"Twitter"];
    if ([self showCancelButton]) {
        [[self navigationItem] setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)]];
    }
    [self load];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Interface implementations

- (void)load
{
    [[self webView] loadRequest:[self request]];
}

#pragma mark - View controller lifecycle

- (void)loadView
{
    [self setWebView:[[UIWebView alloc] init]];
    [[self webView] setScalesPageToFit:YES];
    [[self webView] setDelegate:self];
    [self setView:[self webView]];
}

#pragma mark - UIWebview delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (![self whitelistedDomain:request]) {
        // Open in Safari if request is not whitelisted
        NSLog(@"Opening link in Safari browser, as the host is not whitelisted: %@", request.URL);
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    if ([self shouldStartLoadWithRequest]) {
        return [self shouldStartLoadWithRequest](self, request, navigationType);
    }
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (self.errorHandler) {
        self.errorHandler(error);
        self.errorHandler = nil;
    }
}

#pragma mark - Internal methods

- (BOOL)whitelistedDomain:(NSURLRequest *)request
{
    NSString *whitelistedHostWildcard = [@"." stringByAppendingString:TWTRTwitterDomain];
    NSURL *url = request.URL;
    NSString *host = url.host;
    return ([host isEqualToString:TWTRTwitterDomain] || [host hasSuffix:whitelistedHostWildcard] || ([TWTRSDKScheme isEqualToString:url.scheme] && [TWTRSDKRedirectHost isEqualToString:host]));
}

- (void)cancel
{
    if ([self cancelCompletion]) {
        [self cancelCompletion](self);
        self.cancelCompletion = nil;
    }
}

- (void)enableCancelButtonWithCancelCompletion:(TWTRWebViewControllerCancelCompletion)cancelCompletion
{
    NSAssert([self isViewLoaded] == NO, @"This method must be called before the view controller is presented");
    [self setShowCancelButton:YES];
    [self setCancelCompletion:cancelCompletion];
}

@end
