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
#import <TwitterKit/TWTRTwitter.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  A Button which launches the sign in to Twitter flow when tapped.
 */
@interface TWTRLogInButton : UIButton

/**
 *  The completion block to be called with a `TWTRSession` if successful,
 *  and a `NSError` if logging in failed or was canceled.
 */
@property (nonatomic, copy) TWTRLogInCompletion logInCompletion;

/**
 *  Returns a new log in button which launches Twitter log in when tapped and
 *  calls `completion` when logging in succeeds or fails.
 *
 *  Internally, this button simply calls `-[TWTRTwitter logInWithCompletion:]`.
 *
 *  @param completion The completion to be called with a `TWTRSession` if successful,
 *         and a `NSError` if logging in failed or was canceled.
 *  @return An initialized `TWTRLogInButton`.
 */
+ (instancetype)buttonWithLogInCompletion:(TWTRLogInCompletion)completion;

@end

NS_ASSUME_NONNULL_END
