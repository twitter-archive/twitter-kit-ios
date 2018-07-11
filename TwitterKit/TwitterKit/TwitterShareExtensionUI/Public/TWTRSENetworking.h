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

@import Foundation;

@class TWTRSETweet;
@class TWTRSETweetURLAttachmentMetadata;
@protocol TWTRSEAccount;
@protocol TWTRSETwitterUser;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TWTRSENetworkingResult) { TWTRSENetworkingResultSuccess = 1, TWTRSENetworkingResultError, TWTRSENetworkingResultWillPostAsynchronously };

typedef void (^TWTRSENetworkingTweetSendCompletion)(TWTRSENetworkingResult result);
typedef void (^TWTRSENetworkingHydratedTwitterUserLoadCompletion)(id<TWTRSETwitterUser> _Nullable hydratedUser);

@protocol TWTRSENetworking <NSObject>

- (void)sendTweet:(TWTRSETweet *)tweet fromAccount:(id<TWTRSEAccount>)account completion:(TWTRSENetworkingTweetSendCompletion)completion;

- (void)loadHydratedTwitterUserForAccount:(id<TWTRSEAccount>)account completion:(TWTRSENetworkingHydratedTwitterUserLoadCompletion)completion;

@end

NS_ASSUME_NONNULL_END
