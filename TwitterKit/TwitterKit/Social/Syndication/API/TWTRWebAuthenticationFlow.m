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

#import "TWTRWebAuthenticationFlow.h"
#import <TwitterCore/TWTRAssertionMacros.h>
#import <TwitterCore/TWTRSessionStore.h>
#import <TwitterCore/TWTRSessionStore_Private.h>
#import "TWTRLoginURLParser.h"
#import "TWTRTwitter.h"
#import "TWTRWebAuthenticationTokenRequestor.h"
#import "TWTRWebAuthenticationViewController.h"

@interface TWTRWebAuthenticationFlow ()

@property (nonatomic, readonly) TWTRSessionStore *sessionStore;
@property (nonatomic, copy) TWTRAuthenticationFlowControllerPresentation controllerPresentation;
@property (nonatomic, copy) TWTRLogInCompletion completion;
@property (nonatomic, copy) TWTRAuthRedirectCompletion redirectCompletionBlock;
@property (nonatomic, readonly) TWTRLoginURLParser *loginURLParser;

@end

@implementation TWTRWebAuthenticationFlow

- (instancetype)initWithSessionStore:(TWTRSessionStore *)sessionStore;
{
    TWTRParameterAssertOrReturnValue(sessionStore, nil);

    self = [super init];
    if (self) {
        _sessionStore = sessionStore;
        _loginURLParser = [[TWTRLoginURLParser alloc] initWithAuthConfig:self.sessionStore.authConfig];
    }
    return self;
}

- (void)beginAuthenticationFlow:(TWTRAuthenticationFlowControllerPresentation)presentationBlock completion:(TWTRLogInCompletion)completion
{
    TWTRParameterAssertOrReturn(completion);
    TWTRCheckArgumentWithCompletion2(presentationBlock, completion);

    self.controllerPresentation = presentationBlock;
    self.completion = completion;

    [self requestAuthenticationToken:^(NSString *token) {
        [[[TWTRTwitter sharedInstance] sessionStore] saveOauthToken:token];
        [self presentWebAuthenticationViewController:token];
    }];
}

- (BOOL)resumeAuthenticationWithRedirectURL:(NSURL *)url
{
    if ([self.loginURLParser isTwitterKitRedirectURL:url]) {
        if (self.redirectCompletionBlock) {
            self.redirectCompletionBlock(url);
        }
        return YES;
    } else {
        return NO;
    }
}

- (void)requestAuthenticationToken:(void (^)(NSString *token))completion
{
    TWTRParameterAssertOrReturn(completion);

    TWTRWebAuthenticationTokenRequestor *tokenRequestor = [[TWTRWebAuthenticationTokenRequestor alloc] initWithAuthConfig:self.sessionStore.authConfig serviceConfig:self.sessionStore.APIServiceConfig];
    [tokenRequestor requestAuthenticationToken:^(NSString *token, NSError *error) {
        if (token) {
            completion(token);
        } else {
            [self failWithError:error];
        }
    }];
}

- (void)presentWebAuthenticationViewController:(NSString *)token
{
    // If needs web, present web

    // Otherwise present Safari

    TWTRWebAuthenticationViewController *controller = [[TWTRWebAuthenticationViewController alloc] initWithAuthenticationToken:token authConfig:self.sessionStore.authConfig APIServiceConfig:self.sessionStore.APIServiceConfig hasExistingSession:self.sessionStore.hasLoggedInUsers];

    controller.completion = ^(TWTRSession *session, NSError *error) {
        if (session) {
            [self saveSession:session];
        } else {
            [self failWithError:error];
        }
    };

    // For coming back from SFSafariViewController
    self.redirectCompletionBlock = ^(NSURL *url) {
        [controller handleAuthResponseWithURL:url];
    };

    if (self.controllerPresentation) {
        self.controllerPresentation(controller);
    }
}

- (void)saveSession:(TWTRSession *)session
{
    [self.sessionStore saveSession:session completion:^(id<TWTRAuthSession> savedSession, NSError *error) {
        if (savedSession) {
            [self succeedWithSession:savedSession];
        } else {
            [self failWithError:error];
        }
    }];
}

- (void)failWithError:(NSError *)error
{
    if (self.completion) {
        self.completion(nil, error);
    }
}

- (void)succeedWithSession:(TWTRSession *)session
{
    if (self.completion) {
        self.completion(session, nil);
    }
}

@end
