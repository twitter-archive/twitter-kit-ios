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

@import UIKit.UIView;

NS_ASSUME_NONNULL_BEGIN

@class TSETweet;
@class TSETweetTextViewContainer;

@protocol TSETweetTextViewContainerDelegate <NSObject>

- (void)tweetTextViewDidUpdateText:(nullable NSString *)updatedText textSelection:(NSRange)textSelection;

@end

@interface TSETweetTextViewContainer : UIView

- (void)configureWithTweet:(TSETweet *)tweet;

- (void)updateText:(NSString *)text;

@property (nonatomic) NSRange textSelection;
@property (nonatomic, readonly) CGFloat textViewHeight;

@property (nonatomic, weak, nullable) id<TSETweetTextViewContainerDelegate> delegate;

@property (nullable, readonly) NSUndoManager *undoManager;


@end

NS_ASSUME_NONNULL_END
