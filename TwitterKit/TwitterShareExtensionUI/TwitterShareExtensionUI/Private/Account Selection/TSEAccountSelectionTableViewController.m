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

#import "TSEAccount.h"
#import "TSEAccountSelectionTableViewController.h"
#import "TSEAccountTableViewCell.h"
#import "TSELocalizedString.h"


#pragma mark -

@interface TSEAccountSelectionTableViewController ()

@property (nonatomic, readonly, copy) NSArray<id<TSEAccount>> *accounts;

@property (nonatomic) id<TSEAccount> selectedAccount;
@property (nonatomic, readonly) id<TSEImageDownloader> imageDownloader;
@property (nonatomic, readonly) id<TSENetworking> networking;

@end

@implementation TSEAccountSelectionTableViewController

- (instancetype)initWithAccounts:(NSArray<id<TSEAccount>> *)accounts selectedAccount:(id<TSEAccount>)selectedAccount imageDownloader:(id<TSEImageDownloader>)imageDownloader networking:(nonnull id<TSENetworking>)networking delegate:(nonnull id<TSEAccountSelectionDelegate>)delegate
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

    [self.tableView registerClass:[TSEAccountTableViewCell class] forCellReuseIdentifier:TSEAccountTableViewCell.reuseIdentifier];
}

- (void)setSelectedAccount:(id<TSEAccount>)selectedAccount
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
    id<TSEAccount> account = self.accounts[(NSUInteger)indexPath.row];

    TSEAccountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TSEAccountTableViewCell.reuseIdentifier forIndexPath:indexPath];

    [cell configureWithAccount:account isSelected:account == self.selectedAccount imageDownloader:self.imageDownloader networking:self.networking];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedAccount = self.accounts[(NSUInteger)indexPath.row];

    [self.delegate accountSelectionTableViewController:self didSelectAccount:self.selectedAccount];
}

@end
