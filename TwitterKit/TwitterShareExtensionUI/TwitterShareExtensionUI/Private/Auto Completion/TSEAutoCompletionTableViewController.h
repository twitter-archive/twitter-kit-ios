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

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@class TSEAutoCompletionTableViewController;
@protocol TSEAutoCompletion;
@protocol TSEAutoCompletionResult;
@protocol TSEImageDownloader;

@protocol TSEAutoCompletionTableViewControllerDelegate <NSObject>

- (void)autoCompletionTableViewController:(TSEAutoCompletionTableViewController *)autoCompletionTableViewController wantsAutoCompletionResultsVisible:(BOOL)visible;

- (void)autoCompletionTableViewController:(TSEAutoCompletionTableViewController *)autoCompletionTableViewController wantsToUpdateText:(NSString *)text proposedCursor:(NSRange)proposedCursor;

@end

@interface TSEAutoCompletionTableViewController : UIViewController

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithStyle:(UITableViewStyle)style NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

- (instancetype)initWithAutoCompletion:(id<TSEAutoCompletion>)autoCompletion imageDownloader:(id<TSEImageDownloader>)imageDownloader delegate:(id<TSEAutoCompletionTableViewControllerDelegate>)delegate NS_DESIGNATED_INITIALIZER;

@property (nonatomic, weak, nullable) id<TSEAutoCompletionTableViewControllerDelegate> delegate;
@property (nonatomic, readonly) UITableView *tableView;

- (void)updateResultsWithText:(NSString *)text textSelection:(NSRange)textSelection;

@end

NS_ASSUME_NONNULL_END
