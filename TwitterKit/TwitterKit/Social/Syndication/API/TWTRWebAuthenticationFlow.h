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

/**
 This header is private to the Twitter Kit SDK and not exposed for public SDK consumption
 */

#import <TwitterCore/TWTRSession.h>
#import <UIKit/UIKit.h>
@class TWTRSessionStore;

NS_ASSUME_NONNULL_BEGIN

typedef void (^TWTRAuthenticationFlowControllerPresentation)(UIViewController *controller);

/**
 *  Completion block when Safari authentication flow calls back to this class
 *  with a verification token.
 *
 *  @param url The URL from the Twitter API containing a `verification_token`
 *             as one of its parameters.
 */
typedef void (^TWTRAuthRedirectCompletion)(NSURL *url);

/**
 * Presents a simple interface for performing 3 legged OAuth with Twitter. This
 * will choose automatically whether to use UIWebView or SFSafariViewController
 * based on class availability and the presence of a valid TwitterKit URL scheme.
 */
@interface TWTRWebAuthenticationFlow : NSObject

/**
 *  Initializes the flow with a given session store. If there is an existing TWTRSession
 *  we will skip over to UIWeb based login flow. Otherwise, SFSafariViewController will pop up.
 *
 *  @param sessionStore the sessionStore to save the session.
 *
 *  @return A fully initialized TWTRWebAuthenticationFlow
 */
- (instancetype)initWithSessionStore:(TWTRSessionStore *)sessionStore;

/**
 * Calling this method will begin the authentication flow.
 *
 * @param presentationBlock block in which the user can present the view
 *                          controller containing the webview.
 * @param completion        block to be invoked when the process completes.
 *
 * @note The `presentationBlock` will not be called if the process fails
 *       before needing to show the webview.
 *
 * A typical implementation would look something like this:

    [flow beginAuthenticationFlow:^(UIViewController *controller) {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:navController];
        [self showDetailViewController:controller sender:self];
    } completion:^(TWTRSession *session, NSError *error) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];

 */
- (void)beginAuthenticationFlow:(TWTRAuthenticationFlowControllerPresentation)presentationBlock completion:(TWTRLogInCompletion)completion;

/**
 *  Resume an in-progress authentication flow from the Safari
 *  view controller.
 *
 *  @param url The redirect URL from the Twitter API which
 *             contains a verification token to complete
 *             the auth loop.
 *
 *  @return Boolean specifying whether this URL was handled
 *          by Twitter Kit or not.
 */
- (BOOL)resumeAuthenticationWithRedirectURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
