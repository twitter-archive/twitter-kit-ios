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

#import "TWTRSEAutoCompletionTableViewController.h"
#import "NSArray+Helpers.h"
#import "TWTRSEAccount.h"
#import "TWTRSEAccountTableViewCell.h"
#import "TWTRSEAutoCompletion.h"
#import "TWTRSEAutoCompletionResult.h"
#import "TWTRSEAutoCompletionViewModel.h"
#import "TWTRSEColors.h"
#import "TWTRSEFonts.h"
#import "TWTRSELoadingTableViewCell.h"
#import "TWTRSELocalizedString.h"
#import "TWTRSESimpleTextTableViewCell.h"
#import "TWTRSEThrottledProperty.h"
#import "TWTRSETweet.h"
#import "TWTRSETwitterUser.h"

typedef NS_ENUM(NSUInteger, TWTRSEAutoCompletionState) {
    TWTRSEAutoCompletionStateWaiting = 1,
    TWTRSEAutoCompletionStateLoading,
    TWTRSEAutoCompletionStateFailed,
};

static const NSTimeInterval kAutoCompletionTypingThrottleInterval = 0.3;

@interface TWTRSEAutoCompletionTableViewController () <UITableViewDelegate, UITableViewDataSource, TWTRSEThrottledPropertyObserver>

@property (nonatomic, nonnull, readonly) id<TWTRSEAutoCompletion> autoCompletion;
@property (nonatomic, readonly, nonnull) id<TWTRSEImageDownloader> imageDownloader;
@property (nonatomic, nonnull, readonly) TWTRSEAutoCompletionViewModel *viewModel;

@property (nonatomic, nonnull, readonly) TWTRSEThrottledProperty<NSString *> *wordAroundSelectionProperty;

@property (nonatomic, nullable, copy) NSArray<id<TWTRSEAutoCompletionResult>> *latestResults;

@property (nonatomic, readonly) UIView *separatorLine;

@property (nonatomic, nullable, copy) NSString *tweetText;
@property (nonatomic) NSRange cursor;
@property (nonatomic, nullable, copy) NSString *wordAroundSelection;
@property (nonatomic, nullable, copy) NSString *lastRequestedWord;
@property (nonatomic) TWTRSEAutoCompletionState autoCompletionState;

@end

@implementation TWTRSEAutoCompletionTableViewController

- (instancetype)initWithAutoCompletion:(id<TWTRSEAutoCompletion>)autoCompletion imageDownloader:(id<TWTRSEImageDownloader>)imageDownloader delegate:(nonnull id<TWTRSEAutoCompletionTableViewControllerDelegate>)delegate
{
    NSParameterAssert(autoCompletion);
    NSParameterAssert(imageDownloader);
    NSParameterAssert(delegate);

    if ((self = [super initWithNibName:nil bundle:nil])) {
        _autoCompletion = autoCompletion;
        _imageDownloader = imageDownloader;
        _delegate = delegate;

        _viewModel = [[TWTRSEAutoCompletionViewModel alloc] init];

        _wordAroundSelectionProperty = [[TWTRSEThrottledProperty alloc] initWithThottleInterval:kAutoCompletionTypingThrottleInterval observer:self];
        _cursor = (NSRange){.location = NSNotFound, .length = 0};
        _autoCompletionState = TWTRSEAutoCompletionStateWaiting;

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
    self.tableView.estimatedRowHeight = [TWTRSEFonts composerTextFont].pointSize * 2;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    const CGRect hairlineRect = {CGPointZero, {0, 1 / [UIScreen mainScreen].scale}};
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:hairlineRect];
    self.tableView.tableHeaderView.backgroundColor = self.tableView.separatorColor;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self.tableView registerClass:[TWTRSELoadingTableViewCell class] forCellReuseIdentifier:TWTRSELoadingTableViewCell.reuseIdentifier];
    [self.tableView registerClass:[TWTRSEAccountTableViewCell class] forCellReuseIdentifier:TWTRSEAccountTableViewCell.reuseIdentifier];
    [self.tableView registerClass:[TWTRSESimpleTextTableViewCell class] forCellReuseIdentifier:TWTRSESimpleTextTableViewCell.reuseIdentifier];
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

- (void)setLatestResults:(NSArray<id<TWTRSEAutoCompletionResult>> *)latestResults
{
    _latestResults = [latestResults copy];

    [self.tableView reloadData];
}

- (void)setAutoCompletionState:(TWTRSEAutoCompletionState)autoCompletionState
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

    const BOOL showAutoCompletionResults = isHashtag || isUsername;

    [self.delegate autoCompletionTableViewController:self wantsAutoCompletionResultsVisible:showAutoCompletionResults];
}

#pragma mark - TWTRSEThrottledPropertyObserver

- (void)throttledProperty:(TWTRSEThrottledProperty *)throttledProperty didChangeValue:(nullable NSString *)wordAroundSelection
{
    self.latestResults = nil;
    self.autoCompletionState = TWTRSEAutoCompletionStateWaiting;

    if (wordAroundSelection == nil) {
        return;
    }

    NSString *strippedWord = [self.viewModel stripUsernameMarkersFromWord:wordAroundSelection];
    self.lastRequestedWord = strippedWord;

    __weak typeof(self) weakSelf = self;

    if ([self.viewModel wordIsHashtag:wordAroundSelection]) {
        self.autoCompletionState = TWTRSEAutoCompletionStateLoading;
        [self.autoCompletion loadAutoCompletionResultsForHashtag:strippedWord
                                                        callback:^(NSArray<NSString *> *_Nullable results, NSError *_Nullable error) {
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                typeof(self) strongSelf = weakSelf;

                                                                if (!strongSelf) {
                                                                    return;
                                                                }

                                                                /// This is a request for a previous word. Ignore.
                                                                if (![strongSelf.lastRequestedWord isEqualToString:strippedWord]) {
                                                                    return;
                                                                }

                                                                strongSelf.autoCompletionState = TWTRSEAutoCompletionStateWaiting;

                                                                if (results) {
                                                                    strongSelf.latestResults = tse_map(results, ^TWTRSEAutoCompletionResultHashtag *_Nonnull(NSString *_Nonnull element) {
                                                                        return [[TWTRSEAutoCompletionResultHashtag alloc] initWithHashtag:element];
                                                                    });
                                                                } else {
                                                                    strongSelf.autoCompletionState = TWTRSEAutoCompletionStateFailed;
                                                                }
                                                            });
                                                        }];
    } else if ([self.viewModel wordIsUsername:wordAroundSelection]) {
        self.autoCompletionState = TWTRSEAutoCompletionStateLoading;
        [self.autoCompletion loadAutoCompletionResultsForUsername:strippedWord
                                                         callback:^(NSArray<id<TWTRSETwitterUser>> *_Nullable results, NSError *_Nullable error) {
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 typeof(self) strongSelf = weakSelf;

                                                                 if (!strongSelf) {
                                                                     return;
                                                                 }

                                                                 /// This is a request for a previous word. Ignore.
                                                                 if (![strongSelf.lastRequestedWord isEqualToString:strippedWord]) {
                                                                     return;
                                                                 }

                                                                 strongSelf.autoCompletionState = TWTRSEAutoCompletionStateWaiting;

                                                                 if (results) {
                                                                     strongSelf.latestResults = tse_map(results, ^TWTRSEAutoCompletionResultUser *_Nonnull(id<TWTRSETwitterUser> _Nonnull element) {
                                                                         return [[TWTRSEAutoCompletionResultUser alloc] initWithUser:element];
                                                                     });
                                                                 } else {
                                                                     strongSelf.autoCompletionState = TWTRSEAutoCompletionStateFailed;
                                                                 }
                                                             });
                                                         }];
    }
}

#pragma mark -

- (nullable id<TWTRSEAutoCompletionResult>)autoCompletionResultAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.autoCompletionState) {
        case TWTRSEAutoCompletionStateWaiting:
            return self.latestResults[(NSUInteger)indexPath.row];
        case TWTRSEAutoCompletionStateLoading:
        case TWTRSEAutoCompletionStateFailed:
            return nil;
    }
}

- (void)reportTweetTextUpdateAndDismissWithEnteredText:(NSString *)enteredText
{
    NSUInteger insertionEndLocation = NSMaxRange(self.cursor);

    NSString *textAfterInsertingText = [self.viewModel insertAutoCompletionWord:enteredText inWordAtLocation:self.cursor.location inText:self.tweetText insertionEndLocation:&insertionEndLocation];

    [self.delegate autoCompletionTableViewController:self wantsToUpdateText:textAfterInsertingText proposedCursor:(NSRange){.location = insertionEndLocation, .length = 0}];
    [self.delegate autoCompletionTableViewController:self wantsAutoCompletionResultsVisible:NO];
}

- (void)assertUnknownAutoCompletionResultClass:(Class) class
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unknown TWTRSEAutoCompletionResult type" userInfo:@{@"ClassName": NSStringFromClass(class)}];
}

#pragma mark - UITableViewDataSource

    - (NSInteger)tableView : (UITableView *)tableView numberOfRowsInSection : (NSInteger)section
{
    switch (self.autoCompletionState) {
        case TWTRSEAutoCompletionStateWaiting:
            return (NSInteger)self.latestResults.count;
        case TWTRSEAutoCompletionStateLoading:
        case TWTRSEAutoCompletionStateFailed:
            return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.autoCompletionState) {
        case TWTRSEAutoCompletionStateWaiting: {
            id<TWTRSEAutoCompletionResult> result = [self autoCompletionResultAtIndexPath:indexPath];

            if ([result isKindOfClass:[TWTRSEAutoCompletionResultHashtag class]]) {
                TWTRSEAutoCompletionResultHashtag *hashtagResult = result;

                TWTRSESimpleTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TWTRSESimpleTextTableViewCell.reuseIdentifier forIndexPath:indexPath];
                cell.textLabel.text = hashtagResult.hashtag;

                return cell;
            } else if ([result isKindOfClass:[TWTRSEAutoCompletionResultUser class]]) {
                TWTRSEAutoCompletionResultUser *userResult = result;

                TWTRSEAccountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TWTRSEAccountTableViewCell.reuseIdentifier forIndexPath:indexPath];

                [cell configureWithHydratedUser:userResult.user isSelected:NO imageDownloader:self.imageDownloader];

                return cell;
            } else {
                [self assertUnknownAutoCompletionResultClass:[result class]];
                return nil;
            }
        }

        case TWTRSEAutoCompletionStateFailed: {
            TWTRSESimpleTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TWTRSESimpleTextTableViewCell.reuseIdentifier forIndexPath:indexPath];
            cell.textLabel.text = [TSELocalized localizedString:TSEUI_LOCALIZABLE_SHARE_EXT_NONE_VALUE];

            return cell;
        }

        case TWTRSEAutoCompletionStateLoading:
            return [tableView dequeueReusableCellWithIdentifier:TWTRSELoadingTableViewCell.reuseIdentifier forIndexPath:indexPath];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<TWTRSEAutoCompletionResult> result = [self autoCompletionResultAtIndexPath:indexPath];

    if (!result) {
        return;
    }

    NSString *word = nil;

    if ([result isKindOfClass:[TWTRSEAutoCompletionResultHashtag class]]) {
        TWTRSEAutoCompletionResultHashtag *hashtagResult = (TWTRSEAutoCompletionResultHashtag *)result;

        word = hashtagResult.hashtag;
    } else if ([result isKindOfClass:[TWTRSEAutoCompletionResultUser class]]) {
        TWTRSEAutoCompletionResultUser *userResult = (TWTRSEAutoCompletionResultUser *)result;

        word = TWTRSEDisplayUsername(userResult.user.username);
    } else {
        [self assertUnknownAutoCompletionResultClass:[result class]];
    }

    [self reportTweetTextUpdateAndDismissWithEnteredText:word];
}

@end
