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

#import "TWTRSEBaseTableViewCell.h"

@protocol TWTRSEAccount;
@protocol TWTRSEImageDownloader;
@protocol TWTRSENetworking;
@protocol TWTRSETwitterUser;

NS_ASSUME_NONNULL_BEGIN

@interface TWTRSEAccountTableViewCell : TWTRSEBaseTableViewCell

- (void)configureWithAccount:(id<TWTRSEAccount>)account isSelected:(BOOL)isSelected imageDownloader:(id<TWTRSEImageDownloader>)imageDownloader networking:(id<TWTRSENetworking>)networking;

- (void)configureWithHydratedUser:(id<TWTRSETwitterUser>)user isSelected:(BOOL)isSelected imageDownloader:(id<TWTRSEImageDownloader>)imageDownloader;

@end

NS_ASSUME_NONNULL_END
