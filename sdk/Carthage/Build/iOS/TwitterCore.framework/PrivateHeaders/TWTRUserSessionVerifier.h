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
 This header is private to the Twitter Core SDK and not exposed for public SDK consumption
 */

@class TWTRUserSessionVerifier;

@protocol TWTRUserSessionVerifierDelegate <NSObject>

- (void)userSessionVerifierNeedsSessionVerification:(TWTRUserSessionVerifier *)userSessionVerifier;

@end

FOUNDATION_EXTERN NSTimeInterval const TWTRUserSessionVerifierIntervalDaily;
FOUNDATION_EXTERN NSTimeInterval const TWTRUserSessionVerifierDefaultDelay;

/**
 *  Manages verifying stored user sessions on a daily basis. This class depends on the Kit lifecycle
 *  and `UIApplicationWillEnterForegroundNotification` event and checks whether the last verified
 *  time has exceeded a day based on UTC date boundaries. Note that this does not mean we will aggressively
 *  verify the second day of someone that started using the app at 11:59P and continues past 12:00A
 *  due to 1) avoiding load spike to backend and 2) there is no good reliable way to randomize the
 *  scheduling of the second verification due to constraints of iOS. Last verified time is only stored in memory
 *  to minimize overhead on the host application. Verification is done on a best effort basis and we
 *  will not retry if the network call fails for whatever reason.
 */
@interface TWTRUserSessionVerifier : NSObject

- (instancetype)init NS_UNAVAILABLE;

/**
 *  Initializes a verifier for the current consumer application.
 *
 *  @param delegate           An object that will handle the verification of the session when necessary
 *  @param maxDesiredInterval maximum desireable interval for how frequently a verify call should be made while
 *                            the host app is active. Calls might be made more frequently if the app is used
 *                            during the previous and current interval boundaries or we cannot not tell when
 *                            the last call was made. The latter will be de-dup on the backend.
 */
- (instancetype)initWithDelegate:(id<TWTRUserSessionVerifierDelegate>)delegate maxDesiredInterval:(NSTimeInterval)maxDesiredInterval __attribute__((nonnull(1)))NS_DESIGNATED_INITIALIZER;

/**
 *  Makes a verify call immediately (delayed slightly to minimize app startup impact) and then
 *  subscribes to `UIApplicationWillEnterForegroundNotification` to check for the next time we should
 *  be making a verify call.
 *
 *  @param delay The minimum time before which the message is sent. Specifying a delay of 0 does not
 *               necessarily cause the selector to be performed immediately. The first verification is
 *               still queued on the thread’s run loop and performed as soon as possible.
 */
- (void)startVerificationAfterDelay:(NSTimeInterval)delay;

@end
