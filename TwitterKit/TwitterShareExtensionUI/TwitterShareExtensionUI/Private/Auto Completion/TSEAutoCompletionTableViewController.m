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

#import "NSArray+Helpers.h"
#import "TSEAccount.h"
#import "TSEAccountTableViewCell.h"
#import "TSEAutoCompletion.h"
#import "TSEAutoCompletionResult.h"
#import "TSEAutoCompletionTableViewController.h"
#import "TSEAutoCompletionViewModel.h"
#import "TSEColors.h"
#import "TSEFonts.h"
#import "TSELoadingTableViewCell.h"
#import "TSELocalizedString.h"
#import "TSESimpleTextTableViewCell.h"
#import "TSEThrottledProperty.h"
#import "TSETweet.h"
#import "TSETwitterUser.h"

typedef NS_ENUM(NSUInteger, TSEAutoCompletionState) {
    TSEAutoCompletionStateWaiting = 1,
    TSEAutoCompletionStateLoading,
    TSEAutoCompletionStateFailed,
};

static const NSTimeInterval kAutoCompletionTypingThrottleInterval = 0.3;

@interface TSEAutoCompletionTableViewController () <UITableViewDelegate, UITableViewDataSource, TSEThrottledPropertyObserver>

@property (nonatomic, nonnull, readonly) id<TSEAutoCompletion> autoCompletion;
@property (nonatomic, readonly, nonnull) id<TSEImageDownloader> imageDownloader;
@property (nonatomic, nonnull, readonly) TSEAutoCompletionViewModel *viewModel;

@property (nonatomic, nonnull, readonly) TSEThrottledProperty<NSString *> *wordAroundSelectionProperty;

@property (nonatomic, nullable, copy) NSArray<id<TSEAutoCompletionResult>> *latestResults;

@property (nonatomic, readonly) UIView *separatorLine;

@property (nonatomic, nullable, copy) NSString *tweetText;
@property (nonatomic) NSRange cursor;
@property (nonatomic, nullable, copy) NSString *wordAroundSelection;
@property (nonatomic, nullable, copy) NSString *lastRequestedWord;
@property (nonatomic) TSEAutoCompletionState autoCompletionState;

@end

@implementation TSEAutoCompletionTableViewController

- (instancetype)initWithAutoCompletion:(id<TSEAutoCompletion>)autoCompletion imageDownloader:(id<TSEImageDownloader>)imageDownloader delegate:(nonnull id<TSEAutoCompletionTableViewControllerDelegate>)delegate
{
    NSParameterAssert(autoCompletion);
    NSParameterAssert(imageDownloader);
    NSParameterAssert(delegate);

    if ((self = [super initWithNibName:nil bundle:nil])) {
        _autoCompletion = autoCompletion;
        _imageDownloader = imageDownloader;
        _delegate = delegate;

        _viewModel = [[TSEAutoCompletionViewModel alloc] init];

        _wordAroundSelectionProperty = [[TSEThrottledProperty alloc] initWithThottleInterval:kAutoCompletionTypingThrottleInterval observer:self];
        _cursor = (NSRange){ .location = NSNotFound, .length = 0 };
        _autoCompletionState = TSEAutoCompletionStateWaiting;

        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    return self;
}

- (void)loadView
{
    UIView *rootView = [[UIView alloc] init];

    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [rootView addSubview:self.tableView];

    _separatorLine = [[UIView alloc] init];
    self.separatorLine.backgroundColor = [UIColor colorWithWhite:0 alpha:(CGFloat)0.3];
    [rootView addSubview:self.separatorLine];

    self.view = rootView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = [TSEFonts composerTextFont].pointSize * 2;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    const CGRect hairlineRect = {CGPointZero, {0, 1/[UIScreen mainScreen].scale}};
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:hairlineRect];
    self.tableView.tableHeaderView.backgroundColor = self.tableView.separatorColor;
    // Remove ugly cell separators in empty cells
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self.tableView registerClass:[TSELoadingTableViewCell class] forCellReuseIdentifier:TSELoadingTableViewCell.reuseIdentifier];
    [self.tableView registerClass:[TSEAccountTableViewCell class] forCellReuseIdentifier:TSEAccountTableViewCell.reuseIdentifier];
    [self.tableView registerClass:[TSESimpleTextTableViewCell class] forCellReuseIdentifier:TSESimpleTextTableViewCell.reuseIdentifier];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.separatorLine.frame = CGRectMake(0, 0, self.view.bounds.size.width, (CGFloat)1.0 / [UIScreen mainScreen].scale);
    self.tableView.frame = CGRectMake(0, 1, self.view.bounds.size.width, self.view.bounds.size.height - (CGFloat)1.0);
}

- (void)updateResultsWithText:(NSString *)text textSelection:(NSRange)textSelection
{
    self.tweetText = text;
    self.cursor = textSelection;

    BOOL calculateWord = (0 == textSelection.length || NSNotFound == [text rangeOfString:@" " options:NSLiteralSearch range:textSelection].location);
    self.wordAroundSelection = (calculateWord) ? [self.viewModel wordAroundSelectedLocation:textSelection.location inText:text] : nil;
}

- (void)setWordAroundSelection:(NSString *)wordAroundSelection
{
    if (wordAroundSelection == _wordAroundSelection || [wordAroundSelection isEqualToString:_wordAroundSelection]) {
        return;
    }

    _wordAroundSelection = [wordAroundSelection copy];
    self.wordAroundSelectionProperty.lastValue = wordAroundSelection;

    [self updateVisibilityWithWordAroundSelection:wordAroundSelection];
}

- (void)setLatestResults:(NSArray<id<TSEAutoCompletionResult>> *)latestResults
{
    _latestResults = [latestResults copy];

    [self.tableView reloadData];
}

- (void)setAutoCompletionState:(TSEAutoCompletionState)autoCompletionState
{
    if (autoCompletionState != _autoCompletionState) {
        _autoCompletionState = autoCompletionState;

        [self.tableView reloadData];
    }
}

- (void)updateVisibilityWithWordAroundSelection:(NSString *)wordAroundSelection
{
    const BOOL isHashtag = [self.viewModel wordIsHashtag:wordAroundSelection];
    const BOOL isUsername = [self.viewModel wordIsUsername:wordAroundSelection];

    const BOOL showAutoCompletionResults =  isHashtag || isUsername;

    [self.delegate autoCompletionTableViewController:self wantsAutoCompletionResultsVisible:showAutoCompletionResults];
}

#pragma mark - TSEThrottledPropertyObserver

- (void)throttledProperty:(TSEThrottledProperty *)throttledProperty didChangeValue:(nullable NSString *)wordAroundSelection
{
    self.latestResults = nil;
    self.autoCompletionState = TSEAutoCompletionStateWaiting;

    if (wordAroundSelection == nil) {
        return;
    }

    NSString *strippedWord = [self.viewModel stripUsernameMarkersFromWord:wordAroundSelection];
    self.lastRequestedWord = strippedWord;

    __weak typeof(self) weakSelf = self;

    if ([self.viewModel wordIsHashtag:wordAroundSelection]) {
        self.autoCompletionState = TSEAutoCompletionStateLoading;
        [self.autoCompletion loadAutoCompletionResultsForHashtag:strippedWord callback:^(NSArray<NSString *> * _Nullable results, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                typeof(self) strongSelf = weakSelf;

                if (!strongSelf) {
                    return;
                }

                /// This is a request for a previous word. Ignore.
                if (![strongSelf.lastRequestedWord isEqualToString:strippedWord]) {
                    return;
                }

                strongSelf.autoCompletionState = TSEAutoCompletionStateWaiting;

                if (results) {
                    strongSelf.latestResults = tse_map(results, ^TSEAutoCompletionResultHashtag * _Nonnull(NSString * _Nonnull element) {
                        return [[TSEAutoCompletionResultHashtag alloc] initWithHashtag:element];
                    });
                } else {
                    strongSelf.autoCompletionState = TSEAutoCompletionStateFailed;
                }
            });
        }];
    } else if ([self.viewModel wordIsUsername:wordAroundSelection]) {
        self.autoCompletionState = TSEAutoCompletionStateLoading;
        [self.autoCompletion loadAutoCompletionResultsForUsername:strippedWord callback:^(NSArray<id<TSETwitterUser>> * _Nullable results, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                typeof(self) strongSelf = weakSelf;

                if (!strongSelf) {
                    return;
                }

                /// This is a request for a previous word. Ignore.
                if (![strongSelf.lastRequestedWord isEqualToString:strippedWord]) {
                    return;
                }

                strongSelf.autoCompletionState = TSEAutoCompletionStateWaiting;

                if (results) {
                    strongSelf.latestResults = tse_map(results, ^TSEAutoCompletionResultUser * _Nonnull(id<TSETwitterUser> _Nonnull element) {
                        return [[TSEAutoCompletionResultUser alloc] initWithUser:element];
                    });
                } else {
                    strongSelf.autoCompletionState = TSEAutoCompletionStateFailed;
                }
            });
        }];
    }
}

#pragma mark -

- (nullable id<TSEAutoCompletionResult>)autoCompletionResultAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.autoCompletionState) {
        case TSEAutoCompletionStateWaiting:
            return self.latestResults[(NSUInteger)indexPath.row];
        case TSEAutoCompletionStateLoading:
        case TSEAutoCompletionStateFailed:
            return nil;
    }
}

- (void)reportTweetTextUpdateAndDismissWithEnteredText:(NSString *)enteredText
{
    NSUInteger insertionEndLocation = NSMaxRange(self.cursor);

    NSString *textAfterInsertingText = [self.viewModel insertAutoCompletionWord:enteredText inWordAtLocation:self.cursor.location inText:self.tweetText insertionEndLocation:&insertionEndLocation];

    [self.delegate autoCompletionTableViewController:self wantsToUpdateText:textAfterInsertingText proposedCursor:(NSRange){ .location = insertionEndLocation, .length = 0 }];
    [self.delegate autoCompletionTableViewController:self wantsAutoCompletionResultsVisible:NO];
}

- (void)assertUnknownAutoCompletionResultClass:(Class)class
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unknown TSEAutoCompletionResult type" userInfo:@{@"ClassName" : NSStringFromClass(class)}];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (self.autoCompletionState) {
        case TSEAutoCompletionStateWaiting:
            return (NSInteger)self.latestResults.count;
        case TSEAutoCompletionStateLoading:
        case TSEAutoCompletionStateFailed:
            return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.autoCompletionState) {
        case TSEAutoCompletionStateWaiting:
        {
            id<TSEAutoCompletionResult> result = [self autoCompletionResultAtIndexPath:indexPath];

            if ([result isKindOfClass:[TSEAutoCompletionResultHashtag class]]) {
                TSEAutoCompletionResultHashtag *hashtagResult = result;

                TSESimpleTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TSESimpleTextTableViewCell.reuseIdentifier forIndexPath:indexPath];
                cell.textLabel.text = hashtagResult.hashtag;

                return cell;
            } else if ([result isKindOfClass:[TSEAutoCompletionResultUser class]]) {
                TSEAutoCompletionResultUser *userResult = result;

                TSEAccountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TSEAccountTableViewCell.reuseIdentifier forIndexPath:indexPath];

                [cell configureWithHydratedUser:userResult.user isSelected:NO imageDownloader:self.imageDownloader];

                return cell;
            } else {
                [self assertUnknownAutoCompletionResultClass:[result class]];
                return nil;
            }
        }

        case TSEAutoCompletionStateFailed:
        {
            TSESimpleTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TSESimpleTextTableViewCell.reuseIdentifier forIndexPath:indexPath];
            cell.textLabel.text = [TSELocalized localizedString:TSEUI_LOCALIZABLE_SHARE_EXT_NONE_VALUE];

            return cell;
        }

        case TSEAutoCompletionStateLoading:
             return [tableView dequeueReusableCellWithIdentifier:TSELoadingTableViewCell.reuseIdentifier forIndexPath:indexPath];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<TSEAutoCompletionResult> result = [self autoCompletionResultAtIndexPath:indexPath];

    if (!result) {
        return;
    }

    NSString *word = nil;

    if ([result isKindOfClass:[TSEAutoCompletionResultHashtag class]]) {
        TSEAutoCompletionResultHashtag *hashtagResult = (TSEAutoCompletionResultHashtag *)result;

        word = hashtagResult.hashtag;
    } else if ([result isKindOfClass:[TSEAutoCompletionResultUser class]]) {
        TSEAutoCompletionResultUser *userResult = (TSEAutoCompletionResultUser *)result;

        word = TSEDisplayUsername(userResult.user.username);
    } else {
        [self assertUnknownAutoCompletionResultClass:[result class]];
    }

    [self reportTweetTextUpdateAndDismissWithEnteredText:word];
}

@end
