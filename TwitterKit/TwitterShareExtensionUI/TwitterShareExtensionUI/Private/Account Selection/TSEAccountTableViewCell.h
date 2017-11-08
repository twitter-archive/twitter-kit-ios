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

#import "TSEBaseTableViewCell.h"

@protocol TSEAccount;
@protocol TSEImageDownloader;
@protocol TSENetworking;
@protocol TSETwitterUser;

NS_ASSUME_NONNULL_BEGIN

@interface TSEAccountTableViewCell : TSEBaseTableViewCell

- (void)configureWithAccount:(id<TSEAccount>)account isSelected:(BOOL)isSelected imageDownloader:(id<TSEImageDownloader>)imageDownloader networking:(id<TSENetworking>)networking;

- (void)configureWithHydratedUser:(id<TSETwitterUser>)user isSelected:(BOOL)isSelected imageDownloader:(id<TSEImageDownloader>)imageDownloader;

@end

NS_ASSUME_NONNULL_END
