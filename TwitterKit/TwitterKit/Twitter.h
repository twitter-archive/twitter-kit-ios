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

#import <TwitterCore/TWTRSession.h>
#import <TwitterCore/TWTRSessionStore.h>
#import <UIKit/UIKit.h>
#import "TWTRAPIClient.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  The central class of the Twitter Kit.
 *  @note This class can only be used from the main thread.
 */
@interface Twitter : NSObject

/**
 *  Returns the Twitter singleton.
 *
 *  @return The Twitter singleton.
 */
+ (Twitter *)sharedInstance;

/**
 *  Start Twitter with your consumer key and secret. These will override any credentials
 *  present in your applications Info.plist.
 *
 *  @param consumerKey    Your Twitter application's consumer key.
 *  @param consumerSecret Your Twitter application's consumer secret.
 */
- (void)startWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret;

/**
 *  Start Twitter with a consumer key, secret, and keychain access group. See -[Twitter startWithConsumerKey:consumerSecret:]
 *
 *  @param consumerKey    Your Twitter application's consumer key.
 *  @param consumerSecret Your Twitter application's consumer secret.
 *  @param accessGroup    An optional keychain access group to apply to session objects stored in the keychain.
 *
 *  @note In the majority of situations applications will not need to specify an access group to use with Twitter sessions.
 *  This value is only needed if you plan to share credentials with another application that you control or if you are
 *  using TwitterKit with an app extension.
 */
- (void)startWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret accessGroup:(nullable NSString *)accessGroup;

/**
 *  The current version of this kit.
 */
@property (nonatomic, copy, readonly) NSString *version;

/**
 *  Authentication configuration details. Encapsulates the `consumerKey` and `consumerSecret` credentials required to authenticate a Twitter application.
 */
@property (nonatomic, readonly) TWTRAuthConfig *authConfig;

/**
 *  Session store exposing methods to fetch and manage active sessions. Applications that need to manage
 *  multiple users should use the session store to authenticate and log out users.
 */
@property (nonatomic, readonly) TWTRSessionStore *sessionStore;

/**
 *  Triggers user authentication with Twitter.
 *
 *  This method will present UI to allow the user to log in if there are no saved Twitter login credentials.
 *  This method is equivalent to calling loginWithMethods:completion: with TWTRLoginMethodAll.
 *
 *  @param completion The completion block will be called after authentication is successful or if there is an error.
 *  @warning This method requires that you have set up your `consumerKey` and `consumerSecret`.
 */
- (void)logInWithCompletion:(TWTRLogInCompletion)completion;

/**
 *  Triggers user authentication with Twitter. Allows the developer to specify the presenting view controller.
 *
 *  This method will present UI to allow the user to log in if there are no saved Twitter login credentials.
 *
 *  @param viewController The view controller that will be used to present the authentication view.
 *  @param completion The completion block will be called after authentication is successful or if there is an error.
 *  @warning This method requires that you have set up your `consumerKey` and `consumerSecret`.
 */
- (void)logInWithViewController:(nullable UIViewController *)viewController completion:(TWTRLogInCompletion)completion;

/**
 *  Finish the `SFSafariViewController` authentication loop. This method should
 *  be called from application:openURL:options inside the application delegate.
 *
 *  This method will verify an authentication token sent by the Twitter API to
 *  finish the web-based authentication flow.
 *
 *  @param application  The `UIApplication` instance received as a parameter.
 *  @param url          The `NSURL` instance received as a parameter.
 *  @param options      The options dictionary received as a parameter.
 *
 *  @return Boolean specifying whether this URL was handled
 *          by Twitter Kit or not.
 */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary *)options;

@end

NS_ASSUME_NONNULL_END
