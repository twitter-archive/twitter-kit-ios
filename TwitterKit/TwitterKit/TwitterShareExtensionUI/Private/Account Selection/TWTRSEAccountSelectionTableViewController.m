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

#import "TWTRSEAccountSelectionTableViewController.h"
#import "TWTRSEAccount.h"
#import "TWTRSEAccountTableViewCell.h"
#import "TWTRSELocalizedString.h"

#pragma mark -

@interface TWTRSEAccountSelectionTableViewController ()

@property (nonatomic, readonly, copy) NSArray<id<TWTRSEAccount>> *accounts;

@property (nonatomic) id<TWTRSEAccount> selectedAccount;
@property (nonatomic, readonly) id<TWTRSEImageDownloader> imageDownloader;
@property (nonatomic, readonly) id<TWTRSENetworking> networking;

@end

@implementation TWTRSEAccountSelectionTableViewController

- (instancetype)initWithAccounts:(NSArray<id<TWTRSEAccount>> *)accounts selectedAccount:(id<TWTRSEAccount>)selectedAccount imageDownloader:(id<TWTRSEImageDownloader>)imageDownloader networking:(nonnull id<TWTRSENetworking>)networking delegate:(nonnull id<TWTRSEAccountSelectionDelegate>)delegate
{
    NSParameterAssert(accounts);
    NSParameterAssert(accounts.count > 0);
    NSParameterAssert(selectedAccount);
    NSParameterAssert(imageDownloader);
    NSParameterAssert(networking);
    NSParameterAssert(delegate);

    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        _accounts = [accounts copy];
        _selectedAccount = selectedAccount;
        _imageDownloader = imageDownloader;
        _networking = networking;
        _delegate = delegate;

        self.title = [TSELocalized localizedString:TSEUI_LOCALIZABLE_SHARE_EXT_ACCOUNT];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerClass:[TWTRSEAccountTableViewCell class] forCellReuseIdentifier:TWTRSEAccountTableViewCell.reuseIdentifier];
}

- (void)setSelectedAccount:(id<TWTRSEAccount>)selectedAccount
{
    if (selectedAccount != _selectedAccount) {
        _selectedAccount = selectedAccount;

        [self.delegate accountSelectionTableViewController:self didSelectAccount:selectedAccount];

        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger)self.accounts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<TWTRSEAccount> account = self.accounts[(NSUInteger)indexPath.row];

    TWTRSEAccountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TWTRSEAccountTableViewCell.reuseIdentifier forIndexPath:indexPath];

    [cell configureWithAccount:account isSelected:account == self.selectedAccount imageDownloader:self.imageDownloader networking:self.networking];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedAccount = self.accounts[(NSUInteger)indexPath.row];

    [self.delegate accountSelectionTableViewController:self didSelectAccount:self.selectedAccount];
}

@end
