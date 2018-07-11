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

#import "TWTRSESelectionTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TWTRSEAccount;
@protocol TWTRSEImageDownloader;
@protocol TWTRSENetworking;

@class TWTRSEAccountSelectionTableViewController;

@protocol TWTRSEAccountSelectionDelegate <NSObject>

/**
 Called on the main thread whenever the user changes the account selection.

 @param accountSelectionTableViewController The controller that's invoking this method.
 @param account The selected account. This will be one of the instances provided to `TWTRSEAccountSelectionTableViewController`.
 */
- (void)accountSelectionTableViewController:(TWTRSEAccountSelectionTableViewController *)accountSelectionTableViewController didSelectAccount:(id<TWTRSEAccount>)account;

@end

@interface TWTRSEAccountSelectionTableViewController : TWTRSESelectionTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style NS_UNAVAILABLE;

/**
 Instantiates a controller that shows the list of accounts provided for the user to choose from.

 @param accounts (required): The accounts to show on the list. Must not be empty.
 @param selectedAccount (required): The currently selected account to reflect that in the UI.
 @param imageDownloader (required): An object that can download images (used to retrieve user avatars).
 @param networking (required): An object that can request the avatar URL of users.
 @param delegate (required): The delegate that will be notified about changes in the account selection.
 */
- (instancetype)initWithAccounts:(NSArray<id<TWTRSEAccount>> *)accounts selectedAccount:(id<TWTRSEAccount>)selectedAccount imageDownloader:(id<TWTRSEImageDownloader>)imageDownloader networking:(id<TWTRSENetworking>)networking delegate:(id<TWTRSEAccountSelectionDelegate>)delegate;

@property (nonatomic, nullable, weak) id<TWTRSEAccountSelectionDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
