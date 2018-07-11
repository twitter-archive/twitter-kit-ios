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

#import "TWTRSETweetComposerTableViewDataSource.h"
#import "TWTRSEConfigurationSelectionTableViewCell.h"
#import "TWTRSELocalizedString.h"
#import "TWTRSETweet.h"
#import "TWTRSETweetShareConfiguration.h"
#import "TWTRSETweetTextViewContainer.h"

@interface TWTRSETweetComposerTableViewDataSource ()

@property (nonatomic, nullable, readonly, copy) TWTRSETweet *initialTweet;
@property (readonly, nonatomic) BOOL allowsAccountSelection;
@property (readonly, nonatomic) BOOL allowsGeoTagging;

// Type: [NSNumber<TWTRSETweetComposerTableViewDataSourceCellType>]
@property (nonatomic) NSArray<NSNumber *> *cellTypes;

@property (nonatomic, nullable, weak) TWTRSEConfigurationSelectionTableViewCell *accountSelectionCell;
@property (nonatomic, nullable, weak) TWTRSEConfigurationSelectionTableViewCell *locationSelectionCell;

@end

@implementation TWTRSETweetComposerTableViewDataSource

- (instancetype)initWithConfiguration:(TWTRSETweetShareConfiguration *)config allowsGeoTagging:(BOOL)allowsGeoTagging
{
    NSParameterAssert(config);

    if ((self = [super init])) {
        _initialTweet = [config.initialTweet copy] ?: [TWTRSETweet emptyTweet];
        _composedTweet = [_initialTweet copy];
        _allowsAccountSelection = config.accounts.count > 1;
        _allowsGeoTagging = allowsGeoTagging;
        _locationStatus = TWTRSETweetComposerTableViewDataSourceLocationStatusUnknown;
        _textSelection = (NSRange){.location = NSNotFound, .length = 0};

        [self createCellTypes];
    }

    return self;
}

- (void)createCellTypes
{
    NSMutableArray *types = [NSMutableArray array];

    if (self.allowsAccountSelection) {
        [types addObject:@(TWTRSETweetComposerTableViewDataSourceCellTypeAccountSelector)];
    }

    if (self.allowsGeoTagging) {
        [types addObject:@(TWTRSETweetComposerTableViewDataSourceCellTypeLocationSelector)];
    }

    self.cellTypes = types;
}

- (TWTRSETweetComposerTableViewDataSourceCellType)cellTypeAtIndexPath:(NSIndexPath *)indexPath
{
    return (TWTRSETweetComposerTableViewDataSourceCellType)[self.cellTypes[(NSUInteger)indexPath.row] unsignedIntegerValue];
}

- (void)registerCellClassesInTableView:(UITableView *)tableView
{
    [tableView registerClass:[TWTRSEConfigurationSelectionTableViewCell class] forCellReuseIdentifier:TWTRSEConfigurationSelectionTableViewCell.reuseIdentifier];
}

- (void)configureAccountSelectionCell
{
    self.accountSelectionCell.configurationName = [TSELocalized localizedString:TSEUI_LOCALIZABLE_SHARE_EXT_ACCOUNT];
    self.accountSelectionCell.currentConfigurationValue = [NSString stringWithFormat:@"@%@", self.currentAccountUsername];
}

- (void)configureLocationSelectionCell
{
    NSString *locationNameToShow = nil;
    BOOL loading = NO;

    switch (self.locationStatus) {
        case TWTRSETweetComposerTableViewDataSourceLocationStatusUnknown:
        case TWTRSETweetComposerTableViewDataSourceLocationStatusNoPermission:
        case TWTRSETweetComposerTableViewDataSourceLocationStatusPermissionApproved:
            locationNameToShow = [TSELocalized localizedString:TSEUI_LOCALIZABLE_SHARE_EXT_NONE_VALUE];
            loading = NO;
            break;
        case TWTRSETweetComposerTableViewDataSourceLocationStatusAcquiringLocation:
            locationNameToShow = nil;
            loading = YES;
            break;
        case TWTRSETweetComposerTableViewDataSourceLocationStatusLocationAcquired:
            locationNameToShow = self.selectedLocationName ?: [TSELocalized localizedString:TSEUI_LOCALIZABLE_SHARE_EXT_NONE_VALUE];
            loading = NO;
            break;
    }

    self.locationSelectionCell.configurationName = [TSELocalized localizedString:TSEUI_LOCALIZABLE_SHARE_EXT_LOCATION];
    self.locationSelectionCell.currentConfigurationValue = locationNameToShow;
    self.locationSelectionCell.loading = loading;
}

- (void)setLocationStatus:(TWTRSETweetComposerTableViewDataSourceLocationStatus)locationStatus
{
    if (_locationStatus != locationStatus) {
        _locationStatus = locationStatus;

        [self configureLocationSelectionCell];
    }
}

- (void)setSelectedLocationName:(NSString *)selectedLocationName
{
    _selectedLocationName = [selectedLocationName copy];

    [self configureLocationSelectionCell];
}

- (void)setCurrentAccountUsername:(NSString *)currentAccountUsername
{
    _currentAccountUsername = [currentAccountUsername copy];

    [self configureAccountSelectionCell];
}

- (void)setTextSelection:(NSRange)textSelection
{
    if (!NSEqualRanges(textSelection, _textSelection)) {
        _textSelection = textSelection;

        _tweetTextViewContainer.textSelection = textSelection;
    }
}

- (BOOL)isSeparatorRequired
{
    return self.cellTypes.count > 1;
}

#pragma mark - Tweet Updates

- (void)_tseui_updateTweet:(void (^_Nonnull)(TWTRSETweet *tweet))updateTweet
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(composedTweet))];
    updateTweet(self.composedTweet);
    [self didChangeValueForKey:NSStringFromSelector(@selector(composedTweet))];

    [_tweetTextViewContainer updateText:self.composedTweet.text];
}

- (void)_tseui_updateTweetText:(NSString *)updatedText textSelection:(NSRange)textSelection allowUndo:(BOOL)allowUndo
{
    NSString *existingText = _composedTweet.text;
    if ((updatedText || existingText) && updatedText != existingText && ![updatedText isEqualToString:existingText]) {
        if (allowUndo) {
            [[_tweetTextViewContainer.undoManager prepareWithInvocationTarget:self] _tseui_updateTweetText:existingText textSelection:self.textSelection allowUndo:YES];
        }

        [self _tseui_updateTweet:^(TWTRSETweet *tweet) {
            tweet.text = updatedText;
        }];
    }

    self.textSelection = textSelection;
}

- (void)updateTweetText:(NSString *)updatedText textSelection:(NSRange)textSelection
{
    [self _tseui_updateTweetText:updatedText textSelection:textSelection allowUndo:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger)self.cellTypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([self cellTypeAtIndexPath:indexPath]) {
        case TWTRSETweetComposerTableViewDataSourceCellTypeAccountSelector: {
            TWTRSEConfigurationSelectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TWTRSEConfigurationSelectionTableViewCell.reuseIdentifier forIndexPath:indexPath];

            self.accountSelectionCell = cell;

            // Avoid `configureAccountSelectionCell` updating the wrong cell in case of cell reuse.
            // Edge-case considering the small number of cells in the table view.
            if (self.locationSelectionCell == cell) {
                self.locationSelectionCell = nil;
            }

            [self configureAccountSelectionCell];

            return cell;
        }

        case TWTRSETweetComposerTableViewDataSourceCellTypeLocationSelector: {
            TWTRSEConfigurationSelectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TWTRSEConfigurationSelectionTableViewCell.reuseIdentifier forIndexPath:indexPath];

            self.locationSelectionCell = cell;

            [self configureLocationSelectionCell];

            // Avoid `configureLocationSelectionCell` updating the wrong cell in case of cell reuse.
            // Edge-case considering the small number of cells in the table view.
            if (self.accountSelectionCell == cell) {
                self.accountSelectionCell = nil;
            }

            return cell;
        }
    }

    NSAssert(false, @"Invalid TWTRSETweetComposerTableViewDataSourceCellType");
    return nil;
}

#pragma mark - TWTRSETweetTextViewContainerDelegate

- (void)tweetTextViewDidUpdateText:(NSString *)updatedText textSelection:(NSRange)textSelection
{
    [self _tseui_updateTweetText:updatedText textSelection:textSelection allowUndo:NO];
}

@end
