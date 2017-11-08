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

NS_ASSUME_NONNULL_BEGIN

@protocol TSETwitterUser;

@protocol TSEAutoCompletionResult <NSObject>
@end

@interface TSEAutoCompletionResultHashtag : NSObject  <TSEAutoCompletionResult>

@property (nonatomic, nonnull, readonly, copy) NSString *hashtag;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithHashtag:(nonnull NSString *)hashtag;

@end

@interface TSEAutoCompletionResultUser : NSObject <TSEAutoCompletionResult>

@property (nonatomic, nonnull, readonly) id<TSETwitterUser> user;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithUser:(nonnull id<TSETwitterUser>)user;

@end

NS_ASSUME_NONNULL_END
