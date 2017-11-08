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

#import "TSESelectionTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TSEAccount;
@protocol TSEImageDownloader;
@protocol TSENetworking;

@class TSEAccountSelectionTableViewController;

@protocol TSEAccountSelectionDelegate <NSObject>

/**
 Called on the main thread whenever the user changes the account selection.

 @param accountSelectionTableViewController The controller that's invoking this method.
 @param account The selected account. This will be one of the instances provided to `TSEAccountSelectionTableViewController`.
 */
- (void)accountSelectionTableViewController:(TSEAccountSelectionTableViewController *)accountSelectionTableViewController didSelectAccount:(id<TSEAccount>)account;

@end

@interface TSEAccountSelectionTableViewController : TSESelectionTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style NS_UNAVAILABLE;

/**
 Instantiates a controller that shows the list of accounts provided for the user to choose from.

 @param accounts (required): The accounts to show on the list. Must not be empty.
 @param selectedAccount (required): The currently selected account to reflect that in the UI.
 @param imageDownloader (required): An object that can download images (used to retrieve user avatars).
 @param networking (required): An object that can request the avatar URL of users.
 @param delegate (required): The delegate that will be notified about changes in the account selection.
 */
- (instancetype)initWithAccounts:(NSArray<id<TSEAccount>> *)accounts selectedAccount:(id<TSEAccount>)selectedAccount imageDownloader:(id<TSEImageDownloader>)imageDownloader networking:(id<TSENetworking>)networking delegate:(id<TSEAccountSelectionDelegate>)delegate;

@property (nullable, weak) id<TSEAccountSelectionDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
