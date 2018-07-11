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

@protocol TWTRSETwitterUser;

NS_ASSUME_NONNULL_BEGIN

typedef void (^TWTRSEHashtagAutoCompletionCallback)(NSArray<NSString *> *_Nullable results, NSError *_Nullable error);
typedef void (^TWTRSEUserAutoCompletionCallback)(NSArray<id<TWTRSETwitterUser>> *_Nullable results, NSError *_Nullable error);

/**
 When a request for autoCompletion is received, a previous, unfinished one should be considered abandoned and
 the request can be cancelled.
 */
@protocol TWTRSEAutoCompletion <NSObject>

/**
 Implement this method to provide auto-completion results for hashtags.
 This method will be called on the main thread.

 @param hashtag The hashtag (starting with #) to use to search for similar ones.
 @param callback Must be called at most once, on any queue, with the results of the hashtag autoCompletion to be shown.
 */
- (void)loadAutoCompletionResultsForHashtag:(NSString *)hashtag callback:(TWTRSEHashtagAutoCompletionCallback)callback;

/**
 Implement this method to provide auto-completion results for users.
 This method will be called on the main thread.

 @param username The username (not starting with @) to use to search for matching users.
 @param callback Must be called at most once, on any queue, with the results of the user autoCompletion to be shown.
 */
- (void)loadAutoCompletionResultsForUsername:(NSString *)username callback:(TWTRSEUserAutoCompletionCallback)callback;

@end

NS_ASSUME_NONNULL_END
