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

#import "TWTRWebAuthenticationViewController.h"
#import <SafariServices/SafariServices.h>
#import <TwitterCore/TWTRAPIServiceConfig.h>
#import <TwitterCore/TWTRAPIServiceConfigRegistry.h>
#import <TwitterCore/TWTRAssertionMacros.h>
#import <TwitterCore/TWTRAuthConfig.h>
#import <TwitterCore/TWTRAuthenticationConstants.h>
#import <TwitterCore/TWTRSession.h>
#import <TwitterCore/TWTRSession_Private.h>
#import <TwitterCore/TWTRUserAPIClient.h>
#import <TwitterCore/TWTRUtils.h>
#import "TWTRErrors.h"
#import "TWTRLoginURLParser.h"
#import "TWTRTwitter_Private.h"
#import "TWTRWebViewController.h"

@interface TWTRWebAuthenticationViewController () <SFSafariViewControllerDelegate>

@property (nonatomic, copy, readonly) NSString *authenticationToken;
@property (nonatomic, readonly) TWTRUserAPIClient *APIClient;
@property (nonatomic, readonly) id<TWTRAPIServiceConfig> APIServiceConfig;
@property (nonatomic, readonly) NSURL *authURL;
@property (nonatomic, readonly) TWTRLoginURLParser *loginURLParser;
@property (nonatomic, readonly) BOOL useWebFlow;

@end

@implementation TWTRWebAuthenticationViewController

- (instancetype)initWithAuthenticationToken:(NSString *)token authConfig:(TWTRAuthConfig *)authConfig APIServiceConfig:(id<TWTRAPIServiceConfig>)serviceConfig hasExistingSession:(BOOL)hasExistingSession
{
    TWTRParameterAssertOrReturnValue(token, nil);
    TWTRParameterAssertOrReturnValue(authConfig, nil);
    TWTRParameterAssertOrReturnValue(serviceConfig, nil);

    self = [super init];
    if (self) {
        _authenticationToken = [token copy];
        _APIClient = [[TWTRUserAPIClient alloc] initWithAuthConfig:authConfig authToken:token authTokenSecret:nil];
        _APIServiceConfig = serviceConfig;
        _loginURLParser = [[TWTRLoginURLParser alloc] initWithAuthConfig:authConfig];

        // If TWTRSession exist, we use UIWeb flow that does force login. Otherwise, we don't have to
        NSDictionary *queryDict = @{TWTRAuthOAuthTokenKey: token, @"force_login": hasExistingSession ? @"true" : @"false"};
        _authURL = TWTRAPIURLWithParams(serviceConfig, TWTRTwitterAuthorizePath, queryDict);
        _useWebFlow = hasExistingSession;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self embedViewController:[self webController]];
    self.title = @"Twitter";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(handleCancelButton)];
}

#pragma mark - Web Controllers

- (UIViewController *)webController
{
    if (_useWebFlow) {
        return [self webViewController];
    } else {
        [self.navigationController setNavigationBarHidden:YES];
        return [self safariViewController];
    }
}

- (SFSafariViewController *)safariViewController
{
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:self.authURL];
    safariVC.delegate = self;
    return safariVC;
}

- (TWTRWebViewController *)webViewController
{
    TWTRWebViewController *webVC = [[TWTRWebViewController alloc] init];
    webVC.request = [NSURLRequest requestWithURL:self.authURL];

    @weakify(self) webVC.errorHandler = ^(NSError *error) {
        @strongify(self)[self failWithError:error];
    };

    webVC.shouldStartLoadWithRequest = ^BOOL(UIViewController *controller, NSURLRequest *request, UIWebViewNavigationType navType) {
        @strongify(self) NSURL *URL = request.URL;
        if ([TWTRSDKScheme isEqualToString:URL.scheme] && [TWTRSDKRedirectHost isEqualToString:URL.host]) {
            [self handleTwitterRedirectRequest:request];
            return NO;
        }
        return YES;
    };

    return webVC;
}

- (void)embedViewController:(UIViewController *)controller
{
    controller.view.frame = self.view.bounds;
    controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self addChildViewController:controller];
    [self.view addSubview:controller.view];

    [controller didMoveToParentViewController:self];
}

#pragma mark - Networking

- (void)handleTwitterRedirectRequest:(NSURLRequest *)request
{
    [self handleAuthResponseWithURL:request.URL];
}

- (void)handleAuthResponseWithURL:(NSURL *)url
{
    NSDictionary *authenticationResponse = [TWTRUtils dictionaryWithQueryString:url.query];

    NSError *localError;
    if (authenticationResponse[TWTRAuthAppOAuthDeniedKey]) {
        localError = [NSError errorWithDomain:TWTRLogInErrorDomain code:TWTRLogInErrorCodeDenied userInfo:authenticationResponse];
    } else if (authenticationResponse[TWTRAuthAppOAuthVerifierKey] == nil) {
        localError = [NSError errorWithDomain:TWTRLogInErrorDomain code:TWTRLogInErrorCodeUnknown userInfo:authenticationResponse];
    }

    if (localError) {
        [self failWithError:localError];
    } else {
        [self requestAccessTokenWithVerifier:authenticationResponse[TWTRAuthAppOAuthVerifierKey]];
    }
}

- (void)requestAccessTokenWithVerifier:(NSString *)verifier
{
    NSDictionary *parameters = @{TWTRAuthAppOAuthVerifierKey: verifier};
    NSURL *postURL = TWTRAPIURLWithPath(self.APIServiceConfig, TWTRTwitterAccessTokenPath);

    NSURLRequest *request = [self.APIClient URLRequestWithMethod:@"POST" URLString:postURL.absoluteString parameters:parameters];
    [self.APIClient sendAsynchronousRequest:request
                                 completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                     NSError *parseError = nil;
                                     TWTRSession *session = nil;

                                     if (data) {
                                         NSString *queryString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                         NSDictionary *responseDictionary = [TWTRUtils dictionaryWithQueryString:queryString];

                                         if ([TWTRSession isValidSessionDictionary:responseDictionary]) {
                                             session = [[TWTRSession alloc] initWithSessionDictionary:responseDictionary];
                                         } else {
                                             parseError = [NSError errorWithDomain:TWTRLogInErrorDomain code:TWTRErrorCodeWebViewError userInfo:@{NSLocalizedDescriptionKey: @"There was an error retreiving the required tokens from the webview"}];
                                         }
                                     }

                                     if (session) {
                                         [self succeedWithSession:session];
                                     } else if (connectionError) {
                                         [self failWithError:connectionError];
                                     } else if (parseError) {
                                         [self failWithError:parseError];
                                     } else {
                                         NSError *unknownError = [NSError errorWithDomain:TWTRLogInErrorDomain code:TWTRLogInErrorCodeUnknown userInfo:@{NSLocalizedDescriptionKey: @"An unknown error has occurred while trying to login with the webview"}];
                                         [self failWithError:unknownError];
                                     }
                                 }];
}

#pragma mark - Actions

- (void)handleCancelButton
{
    [self failWithError:[TWTRErrors webCancelError]];
}

#pragma mark - SFSafariViewControllerDelegate
- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller
{
    [self failWithError:[TWTRErrors webCancelError]];
}

#pragma mark - Completion Handlers

- (void)succeedWithSession:(TWTRSession *)session
{
    if (self.completion) {
        self.completion(session, nil);
    }
}

- (void)failWithError:(NSError *)error
{
    if (self.completion) {
        self.completion(nil, error);
    }
}

@end
