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
                if (!success) {
                    completion(nil, [TWTRErrors noTwitterAppError]);
                }
            }];

    } else {
        if ([[UIApplication sharedApplication] canOpenURL:twitterAuthURL]) {
            [[UIApplication sharedApplication] openURL:twitterAuthURL];
        } else {
            completion(nil, [TWTRErrors noTwitterAppError]);
        }
    }
}

- (BOOL)isSSOWithSourceApplication:(NSString *)sourceApplication
{
    // If using auth with web view, check that the source application bundle identifier is the same as the app bundle identifier.
    return [sourceApplication hasPrefix:@"com.twitter"] || [sourceApplication hasPrefix:@"com.atebits"];
}

- (BOOL)isWebWithSourceApplication:(NSString *)sourceApplication
{
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    return [sourceApplication hasPrefix:@"com.apple"] || [sourceApplication isEqualToString:bundleID];
}

- (void)triggerInvalidSourceError
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.completion(nil, [TWTRErrors invalidSourceApplicationError]);
    });
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
            self.completion(nil, [TWTRErrors mobileSSOCancelError]);
        });
        return YES;
    } else if ([self.loginURLParser isMobileSSOSuccessURL:url]) {
        // The user finished the flow, the Twitter app gave us valid tokens
        NSDictionary *parameters = [self.loginURLParser parametersForSSOURL:url];
        TWTRSession *newSession = [[TWTRSession alloc] initWithSSOResponse:parameters];
        TWTRSessionStore *store = [TWTRTwitter sharedInstance].sessionStore;
        [store saveSession:newSession
                completion:^(id<TWTRAuthSession> session, NSError *error) {
                    self.completion(session, error);
                }];
        return YES;
    }

    return NO;
}

@end
