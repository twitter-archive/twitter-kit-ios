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

#import "TWTRSETweetTextViewContainer.h"

@class TWTRSETweetShareConfiguration;

typedef NS_ENUM(NSUInteger, TWTRSETweetComposerTableViewDataSourceCellType) { TWTRSETweetComposerTableViewDataSourceCellTypeAccountSelector = 1, TWTRSETweetComposerTableViewDataSourceCellTypeLocationSelector };

typedef NS_ENUM(NSUInteger, TWTRSETweetComposerTableViewDataSourceLocationStatus) { TWTRSETweetComposerTableViewDataSourceLocationStatusUnknown = 1, TWTRSETweetComposerTableViewDataSourceLocationStatusNoPermission, TWTRSETweetComposerTableViewDataSourceLocationStatusPermissionApproved, TWTRSETweetComposerTableViewDataSourceLocationStatusAcquiringLocation, TWTRSETweetComposerTableViewDataSourceLocationStatusLocationAcquired };

NS_ASSUME_NONNULL_BEGIN

@interface TWTRSETweetComposerTableViewDataSource : NSObject <TWTRSETweetTextViewContainerDelegate, UITableViewDataSource>

@property (nonatomic, nullable, weak) TWTRSETweetTextViewContainer *tweetTextViewContainer;

@property (nonatomic, copy, nullable) NSString *currentAccountUsername;
@property (nonatomic) TWTRSETweetComposerTableViewDataSourceLocationStatus locationStatus;
@property (nonatomic, copy, nullable) NSString *selectedLocationName;

/**
 Observable property of the changes to the composed tweet.
 */
@property (nonatomic, nonnull, readonly) TWTRSETweet *composedTweet;

/**
 Use this method to perform changes caused by autoCompletion to add undo support.
 */
- (void)updateTweetText:(NSString *)updatedText textSelection:(NSRange)textSelection;

@property (nonatomic, readonly) NSRange textSelection;
@property (nonatomic, readonly, getter=isSeparatorRequired) BOOL separatorRequired;

- (instancetype)init NS_UNAVAILABLE;

/**
 Creates a data source to be used with the composer table view.

 @param config (required): includes initialTweet, fonts, other information
 @param allowsGeoTagging Whether to show the location selection option in the table view.
 */
- (instancetype)initWithConfiguration:(TWTRSETweetShareConfiguration *)config allowsGeoTagging:(BOOL)allowsGeoTagging NS_DESIGNATED_INITIALIZER;

- (void)registerCellClassesInTableView:(UITableView *)tableView;

- (TWTRSETweetComposerTableViewDataSourceCellType)cellTypeAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
