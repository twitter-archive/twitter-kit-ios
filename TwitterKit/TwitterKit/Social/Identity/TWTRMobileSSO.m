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

#import "TWTRMobileSSO.h"
#import <TwitterCore/TWTRSession.h>
#import <TwitterCore/TWTRSessionStore.h>
#import "TWTRErrors.h"
#import "TWTRLoginURLParser.h"
#import "TWTRScribeSink.h"
#import "TWTRTwitter.h"
#import "TWTRTwitter_Private.h"

@implementation TWTRMobileSSO

- (instancetype)initWithAuthConfig:(TWTRAuthConfig *)authConfig
{
    if (self = [super init]) {
        self.authConfig = authConfig;
        self.loginURLParser = [[TWTRLoginURLParser alloc] initWithAuthConfig:authConfig];
    }

    return self;
}

- (void)attemptAppLoginWithCompletion:(TWTRLogInCompletion)completion
{
    self.completion = [completion copy];

    NSURL *twitterAuthURL = [self.loginURLParser twitterAuthorizeURL];

    BOOL iOS10 = [[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)];

    // Attempt to open Twitter app with Mobile SSO URL
    if (iOS10) {
        [[UIApplication sharedApplication] openURL:twitterAuthURL
            options:@{}
            completionHandler:^(BOOL success) {
                if (success) {
                    // The Twitter app with the twitterauth:// scheme is installed,
                    // scribe that we are starting the flow
                    [[TWTRTwitter sharedInstance].scribeSink didStartSSOLogin];
                } else {
                    completion(nil, [TWTRErrors noTwitterAppError]);
                }
            }];

    } else {
        if ([[UIApplication sharedApplication] canOpenURL:twitterAuthURL]) {
            [[UIApplication sharedApplication] openURL:twitterAuthURL];
            [[TWTRTwitter sharedInstance].scribeSink didStartSSOLogin];
        } else {
            completion(nil, [TWTRErrors noTwitterAppError]);
        }
    }
}

- (BOOL)verifySourceApplication:(NSString *)sourceApplication
{
    // If using auth with web view, check that the source application bundle identifier is the same as the app bundle identifier.
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    BOOL isExpectedSourceApplication = [sourceApplication hasPrefix:@"com.twitter"] || [sourceApplication hasPrefix:@"com.apple"] || [sourceApplication hasPrefix:@"com.atebits"] || [sourceApplication isEqualToString:bundleID];
    if (!isExpectedSourceApplication) {
        // The source application for Mobile SSO is not from a valid bundle id
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TWTRTwitter sharedInstance].scribeSink didFailSSOLogin];
            self.completion(nil, [TWTRErrors invalidSourceApplicationError]);
        });

        return NO;
    } else {
        return YES;
    }
}

- (BOOL)verifyOauthTokenResponsefromURL:(NSURL *)url
{
    return [self.loginURLParser isOauthTokenVerifiedFromURL:url];
}

- (BOOL)processRedirectURL:(NSURL *)url
{
    if ([self.loginURLParser isMobileSSOCancelURL:url]) {
        // The user cancelled the Twitter SSO flow
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TWTRTwitter sharedInstance].scribeSink didCancelSSOLogin];
            self.completion(nil, [TWTRErrors mobileSSOCancelError]);
        });
        return YES;
    } else if ([self.loginURLParser isMobileSSOSuccessURL:url]) {
        // The user finished the flow, the Twitter app gave us valid tokens
        [[TWTRTwitter sharedInstance].scribeSink didFinishSSOLogin];
        NSDictionary *parameters = [self.loginURLParser parametersForSSOURL:url];
        TWTRSession *newSession = [[TWTRSession alloc] initWithSSOResponse:parameters];
        TWTRSessionStore *store = [TWTRTwitter sharedInstance].sessionStore;
        [store saveSession:newSession
                completion:^(id<TWTRAuthSession> session, NSError *error) {
                    if (error) {
                        [[TWTRTwitter sharedInstance].scribeSink didEncounterError:error withMessage:@"Failed to save session"];
                    }
                    self.completion(session, error);
                }];
        return YES;
    }

    return NO;
}

@end
