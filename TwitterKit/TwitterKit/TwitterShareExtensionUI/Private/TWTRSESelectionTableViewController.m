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

#pragma mark imports

#import "TWTRSESelectionTableViewController.h"

@import UIKit;

#pragma mark -

@implementation TWTRSESelectionTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.estimatedRowHeight = 64;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (@available(iOS 11.0, *)) {
        CGRect tableViewFrame = self.tableView.frame;
        if (0 == tableViewFrame.origin.y) {
            CGFloat navBarHeight = self.navigationController.navigationBar.bounds.size.height;
            tableViewFrame.origin.y = navBarHeight;
            tableViewFrame.size.height -= navBarHeight;
            self.tableView.frame = tableViewFrame;
        }
    }
}

@end
