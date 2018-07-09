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

#import "TWTRTimelineViewController.h"
#import <TwitterCore/TWTRMultiThreadUtil.h>
#import <TwitterCore/TWTRSessionStore.h>
#import "TWTRCollectionTimelineDataSource.h"
#import "TWTRNotificationConstants.h"
#import "TWTRTableViewAdPlacer.h"
#import "TWTRTableViewProxy.h"
#import "TWTRTimelineCursor.h"
#import "TWTRTimelineDataSource.h"
#import "TWTRTimelineDelegate.h"
#import "TWTRTimelineFilter.h"
#import "TWTRTimelineMessageView.h"
#import "TWTRTranslationsUtil.h"
#import "TWTRTweet.h"
#import "TWTRTweetTableViewCell.h"
#import "TWTRTweetView.h"
#import "TWTRTwitter_Private.h"

static NSString *const TWTRCellReuseIdentifier = @"TweetCell";
static CGFloat const TWTREstimatedRowHeight = 150;

@interface TWTRTimelineViewController ()

@property (nonatomic) BOOL isCurrentlyLoading;
@property (nonatomic) TWTRTimelineCursor *currentCursor;
@property (nonatomic) NSMutableArray *tweets;
@property (nonatomic) UIColor *defaultBackgroundColor;
@property (nonatomic, readonly) NSArray *tweetNotificationObservers;
@property (nonatomic) TWTRTableViewAdPlacer *adPlacer;
@property (nonatomic) TWTRTimelineMessageView *messageView;

/**
 *  Proxy object that isolates logic behind checking for MoPub methods need to be called on the
 *  `tableView`.
 */
@property (nonatomic) id tableViewProxy;

@end

@implementation TWTRTimelineViewController

#pragma mark - TWTRTimelineViewController Init

- (void)commonInitWithDataSource:(id<TWTRTimelineDataSource>)dataSource adConfiguration:(TWTRMoPubAdConfiguration *)adConfiguration
{
    // Wrappers that optionally set up MoPub if possible and opted-in
    _adConfiguration = adConfiguration;
    _dataSource = dataSource;
    _showTweetActions = NO;
    _tweets = [NSMutableArray array];

    [self configureAdPlacer];
}

- (instancetype)initWithDataSource:(id<TWTRTimelineDataSource>)dataSource
{
    if (self = [super initWithNibName:nil bundle:nil]) {
        [self commonInitWithDataSource:dataSource adConfiguration:nil];
        _defaultBackgroundColor = [UIColor lightGrayColor];
    }
    return self;
}

- (instancetype)initWithDataSource:(id<TWTRTimelineDataSource>)dataSource adConfiguration:(TWTRMoPubAdConfiguration *)adConfiguration
{
    if (self = [super initWithNibName:nil bundle:nil]) {
        [self commonInitWithDataSource:dataSource adConfiguration:adConfiguration];
        _defaultBackgroundColor = [UIColor lightGrayColor];
    }
    return self;
}

#pragma mark - UITableViewController Init

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    return [self initWithDataSource:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithDataSource:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInitWithDataSource:nil adConfiguration:nil];
        _defaultBackgroundColor = nil;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // See https://dev.twitter.com/mopub/ios/native for add additional methods
    NSArray *tableViewSelectorsToProxy = @[@"reloadData", @"dequeueReusableCellWithIdentifier:forIndexPath:"];
    TWTRTableViewProxy *proxy = [[TWTRTableViewProxy alloc] initWithTableView:self.tableView selectorsToProxy:tableViewSelectorsToProxy];
    proxy.enabled = _adConfiguration ? YES : NO;
    _tableViewProxy = proxy;

    // Setup tableview
    self.tableView.estimatedRowHeight = TWTREstimatedRowHeight;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.allowsSelection = NO;
    self.tableView.separatorColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    // ideally call `registerClass:` on `self.tableViewProxy` but that results in unsuccessful
    // dequeuing of registered cell
    [self.tableView registerClass:[TWTRTweetTableViewCell class] forCellReuseIdentifier:TWTRCellReuseIdentifier];

    if (self.defaultBackgroundColor) {
        // Only set the background color if we are loaded from code. If we don't do this we will
        // replace what the user sets in interface builder.
        self.view.backgroundColor = self.defaultBackgroundColor;
    }

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];

    self.messageView = [[TWTRTimelineMessageView alloc] init];
    self.tableView.backgroundView = self.messageView;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self observeForTweetUpdates];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Don't bother loading more if we are already loading
    if ([self countOfTweets] || self.isCurrentlyLoading) {
        return;
    }

    if (self.dataSource) {
        NSString *timelineID = nil;
        if ([self.dataSource respondsToSelector:@selector(collectionID)]) {
            TWTRCollectionTimelineDataSource *collectionDataSource = (TWTRCollectionTimelineDataSource *)self.dataSource;
            timelineID = collectionDataSource.collectionID;
        }
    }
    [self loadNewestTweets];

    [self.adPlacer loadAdUnitIfConfigured];
}

- (void)dealloc
{
    [self.tweetNotificationObservers enumerateObjectsUsingBlock:^(id observer, NSUInteger idx, BOOL *_Nonnull stop) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer name:nil object:nil];
    }];
}

#pragma mark - Refresh

- (void)refresh
{
    [self loadNewestTweets];
}

#pragma mark - Public Tweet Access

- (NSUInteger)countOfTweets
{
    return self.tweets.count;
}

- (TWTRTweet *)tweetAtIndex:(NSInteger)index
{
    return self.tweets[index];
}

- (NSArray *)snapshotTweets
{
    return [self.tweets copy];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self countOfTweets];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TWTRTweet *tweet = [self tweetAtIndex:indexPath.row];
    TWTRTweetTableViewCell *cell = (TWTRTweetTableViewCell *)[self.tableViewProxy dequeueReusableCellWithIdentifier:TWTRCellReuseIdentifier];
    [cell configureWithTweet:tweet];
    cell.tweetView.delegate = self.tweetViewDelegate;
    cell.tweetView.showActionButtons = self.showTweetActions;
    cell.tweetView.presenterViewController = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self indexIsBottomCell:indexPath.row]) {
        [self loadPreviousTweets];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    TWTRTweetTableViewCell *tableViewCell = (TWTRTweetTableViewCell *)cell;
    [tableViewCell.tweetView pauseVideo];
}

#pragma mark - Tweet Updates

- (void)observeForTweetUpdates
{
    @weakify(self);
    id likeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:TWTRDidLikeTweetNotification
                                                                        object:nil
                                                                         queue:nil
                                                                    usingBlock:^(NSNotification *note) {
                                                                        @strongify(self);
                                                                        TWTRTweet *likedTweet = note.userInfo[TWTRNotificationInfoTweet];
                                                                        [self updateTweet:likedTweet];
                                                                    }];
    id unlikeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:TWTRDidUnlikeTweetNotification
                                                                          object:nil
                                                                           queue:nil
                                                                      usingBlock:^(NSNotification *note) {
                                                                          @strongify(self);
                                                                          TWTRTweet *unlikedTweet = note.userInfo[TWTRNotificationInfoTweet];
                                                                          [self updateTweet:unlikedTweet];
                                                                      }];
    _tweetNotificationObservers = @[likeObserver, unlikeObserver];
}

- (void)updateTweet:(TWTRTweet *)updatedTweet
{
    NSUInteger indexOfUpdatedTweet = [self.tweets indexOfObjectPassingTest:^BOOL(TWTRTweet *tweet, NSUInteger index, BOOL *stop) {
        if ([tweet.tweetID isEqualToString:updatedTweet.tweetID]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    if (indexOfUpdatedTweet != NSNotFound) {
        [self.tweets replaceObjectAtIndex:indexOfUpdatedTweet withObject:updatedTweet];
    }
}

#pragma mark - Internal Methods

- (BOOL)indexIsBottomCell:(NSUInteger)rowIndex
{
    return (rowIndex == ([self countOfTweets] - 1));
}

- (void)setDataSource:(id<TWTRTimelineDataSource>)dataSource
{
    [TWTRMultiThreadUtil assertMainThread];

    if (dataSource != _dataSource) {
        _dataSource = dataSource;

        // Reset all data to empty state
        [self.tweets removeAllObjects];
        self.currentCursor = nil;
        self.isCurrentlyLoading = NO;
        [self.tableViewProxy reloadData];

        // Load new Tweets on next runloop to allow developer
        // to set the .timelineDelegate property after the
        // .dataSource property
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadNewestTweets];
        });
    }
}

- (void)loadNewestTweets
{
    self.currentCursor = nil;
    [self loadTweetsAndReplaceExisting:YES];
}

- (void)loadPreviousTweets
{
    [self loadTweetsAndReplaceExisting:NO];
}

- (void)loadTweetsAndReplaceExisting:(BOOL)replaceExisting
{
    if (self.isCurrentlyLoading) {
        return;
    }
    self.isCurrentlyLoading = YES;

    // Notify users and developer
    [self.messageView beginLoading];
    if ([self.timelineDelegate respondsToSelector:@selector(timelineDidBeginLoading:)]) {
        [self.timelineDelegate timelineDidBeginLoading:self];
    }

    __weak typeof(self.dataSource) weakDataSource = self.dataSource;
    @weakify(self);
    [self.dataSource loadPreviousTweetsBeforePosition:self.currentCursor.minPosition
                                           completion:^(NSArray *tweets, TWTRTimelineCursor *cursor, NSError *error) {
                                               @strongify(self);

                                               // Notify users and developer
                                               [self.messageView endLoading];
                                               if ([self.refreshControl isRefreshing]) {
                                                   [self.refreshControl endRefreshing];
                                               }
                                               if ([self.timelineDelegate respondsToSelector:@selector(timeline:didFinishLoadingTweets:error:)]) {
                                                   [self.timelineDelegate timeline:self didFinishLoadingTweets:tweets error:error];
                                               }

                                               const BOOL dataSourceWasChangedWhileRequestInFlight = (weakDataSource != self.dataSource);
                                               if (dataSourceWasChangedWhileRequestInFlight) {
                                                   return;
                                               }

                                               self.isCurrentlyLoading = NO;
                                               if ([tweets count] > 0) {
                                                   if (replaceExisting) {
                                                       self.tweets = [NSMutableArray arrayWithArray:tweets];
                                                   } else {
                                                       [self.tweets addObjectsFromArray:tweets];
                                                   }
                                                   self.currentCursor = cursor;
                                                   [self.tableViewProxy reloadData];

                                               } else if (error) {
                                                   NSLog(@"[TwitterKit] Couldn't load Tweets from TWTRTimelineViewController: %@", error);
                                               } else if ([self countOfTweets] == 0) {
                                                   [self.messageView endLoadingWithMessage:TWTRLocalizedString(@"tw__empty_timeline")];
                                               }
                                           }];
}

#pragma mark - MoPub Helpers

/**
 *  Updates the `adConfiguration` and perform ad request to load ads.
 *  @warning This method can only be invoked once or a bug within MoPub SDK will cause it to crash.
 *
 *  @param adConfiguration The ad configuration to render ads with
 */
- (void)setAdConfiguration:(TWTRMoPubAdConfiguration *)adConfiguration
{
    if (_adConfiguration == nil) {
        _adConfiguration = adConfiguration;

        ((TWTRTableViewProxy *)self.tableViewProxy).enabled = adConfiguration ? YES : NO;

        [self configureAdPlacer];
        [self.adPlacer loadAdUnitIfConfigured];
        [self.tableViewProxy reloadData];
    }
}

- (void)configureAdPlacer
{
    if (_adConfiguration) {
        _adPlacer = [[TWTRTableViewAdPlacer alloc] initWithTableView:self.tableView viewController:self adConfiguration:_adConfiguration];
    } else {
        _adPlacer = nil;
    }
}

@end
