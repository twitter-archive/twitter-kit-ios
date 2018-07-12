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

//
// This code was started in one direction; design requirements have shifted, such that the following
// new requirements must be accounted for:
//
// a) only the size necessary when possible (thus resizable based upon tweet content)
// b) scrollable as a single unit without any other bits that scroll
//
// This class was previously a UITableViewController subclass; later phases of design changes call for
// a layout that is a single TextView entry surrounded by a frame of decorations for the items that now
// appear in other tableView cells, and since there was a collision with the manner in which the cell
// would be sized to meet requirements (a) & (b) above as a tableview cell, i chose to continue with
// AutoLayout and refactor with that in mind.
//
// I chose the following hierarchy
// TWTRETweetComposerViewController.view
//  -> ScrollView
//      -> ContentView
//          -> TextViewContainer
//              -> TextView
//              -> PlaceholderLabel
//              -> Character Count Label
//              -> AttachmentView
//                  -> Underlying Attachment View
//                      -> UIImageView
//                      -> URL Card View
//          -> TableView
//              -> Account Cell
//              -> Location Cell
//
// the need for re-sizing is necessary in both planes
// - vertical sizing and vertical scrolling are the primary concerns; changes in the amount of text
//   will cause the textView to grow/shrink, and the amount of text on different devices will require
//   the need for vertical scrolling sooner or later
// - horizontal sizing can generally be fixed; there is never vertical scrolling, though the horizontal
//   size can change with device rotation (and this includes animation) and iPad multitasking layout
//
// in order to properly use Autolayout, it's necessary for all constraints to be self-consistent with
// those that they relate to.  the approach i took was to pass width down the hierarchy from the top,
// scale items such as the UIImageView or TextView based upon available with and grow them vertially as
// necessary, then pass the required height back up the hierarchy to the point that the containing
// rootViewController (this VC!) can now how large to draw itself.
//
// the biggest glitch is the problem presented by the UIScrollView that is the container held by
// this VC.  the problem is explained in detail in the following Apple tech note.
//
// https://developer.apple.com/library/content/technotes/tn2154/_index.html
//
// In Depth Explanation
//
//    In general, Auto Layout considers the top, left, bottom, and right edges of a view to be the
//    visible edges. That is, if you pin a view to the left edge of its superview, you’re really pinning
//    it to the minimum x-value of the superview’s bounds. Changing the bounds origin of the superview
//    does not change the position of the view.
//
//    The UIScrollView class scrolls its content by changing the origin of its bounds. To make this work
//    with Auto Layout, the top, left, bottom, and right edges within a scroll view now mean the edges
//    of its content view.
//
//    The constraints on the subviews of the scroll view must result in a size to fill, which is then
//    interpreted as the content size of the scroll view. (This should not be confused with the
//    intrinsicContentSize method used for Auto Layout.) To size the scroll view’s frame with Auto
//    Layout, constraints must either be explicit regarding the width and height of the scroll view, or
//    the edges of the scroll view must be tied to views outside of its subtree.
//
//    Note that you can make a subview of the scroll view appear to float (not scroll) over the other
//    scrolling content by creating constraints between the view and a view outside the scroll view’s
//    subtree, such as the scroll view’s superview
//
// as can be seen below, i have chosen an alternate mixed approach; the _contentView indeed relies on
// the top, leading, and width anchors of the scrollView to act as the edges of the content view as
// described in the technical note.  however, unlike their mixed approach, i've set the
// translatesAutoresizingMaskIntoConstraints to NO because i want Autolayout resizing of the content
// height where possible.  so far, this eems to work mostly appropriately up and down the chain ...
// with some glitches of second rotations worked out in viewWillTransitionToSize:...: (see below) ...

#pragma mark imports

#import "TWTRSETweetComposerViewController.h"
#import "TWTRBirdView.h"
#import "TWTRSEAccount.h"
#import "TWTRSEAccountSelectionTableViewController.h"
#import "TWTRSEAutoCompletionTableViewController.h"
#import "TWTRSEFonts.h"
#import "TWTRSEFrameworkLazyLoading.h"
#import "TWTRSEGeoPlace.h"
#import "TWTRSELocalizedString.h"
#import "TWTRSELocationSelectionTableViewController.h"
#import "TWTRSENetworking.h"
#import "TWTRSETweet.h"
#import "TWTRSETweetAttachment.h"
#import "TWTRSETweetComposerTableViewDataSource.h"
#import "TWTRSETweetShareConfiguration.h"
#import "TWTRSETweetShareViewControllerDelegate.h"
#import "TWTRSETweetTextViewContainer.h"
#import "TWTRSEUIBundle.h"
#import "UIView+TSEExtensions.h"

#import <TwitterCore/TWTRColorUtil.h>

@import CoreLocation;

#pragma mark - static const definitions

static const CGFloat kEnoughRowsToImplyScrollableTable = (CGFloat)1.85;
static const CGFloat kTwoTableViewRows = (CGFloat)2.0;

#pragma mark -

@interface TWTRSETweetComposerViewController () <UITableViewDelegate, TWTRSEAccountSelectionDelegate, CLLocationManagerDelegate, TWTRSELocationSelectionDelegate, TWTRSEAutoCompletionTableViewControllerDelegate>

@property (nonatomic, nonnull, readonly) UIScrollView *scrollView;
@property (nonatomic, nonnull, readonly) UIView *contentView;

@property (nonatomic, nonnull) NSLayoutConstraint *contentViewWidthConstraint;
@property (nonatomic, nonnull) NSLayoutConstraint *contentViewHeightConstraint;
@property (nonatomic, nonnull) NSLayoutConstraint *scrollViewTopConstraint NS_AVAILABLE_IOS(11_0);
@property (nonatomic, nonnull) NSLayoutConstraint *tableViewHeightConstraint;

@property (nonatomic, nonnull, readonly) TWTRSETweetTextViewContainer *tweetTextViewContainer;
@property (nonatomic, nonnull, readonly) UITableView *tableView;

@property (nonatomic, weak, readonly) TWTRSETweetShareConfiguration *configuration;

@property (nonatomic, nonnull, readonly) TWTRSETweetComposerTableViewDataSource *dataSource;
@property (nonatomic, nonnull, readonly) UIBarButtonItem *cancelBarButtonItem;
@property (nonatomic, nonnull, readonly) UIBarButtonItem *tweetBarButtonItem;
@property (nonatomic, nonnull, readonly) UIBarButtonItem *spinnerBarButtonItem;
@property (nonatomic, nonnull) id<TWTRSEAccount> selectedAccount;
@property (nonatomic, nullable, readonly) CLLocationManager *locationManager;
@property (nonatomic, nullable) CLLocation *mostRecentLocation;
@property (nonatomic, readonly, getter=isAutoCompletionResultsDisplayAllowed) BOOL autoCompletionResultsDisplayAllowed;
@property (nonatomic) BOOL disallowAutocompletionVisible;
@property (nonatomic) BOOL waitingForLocation;
@property (nonatomic, nullable) id<TWTRSEGeoPlace> selectedGeoPlace;
@property (nonatomic) TWTRSETweetComposerTableViewDataSourceLocationStatus locationStatus;

@property (nonatomic) BOOL autoCompletionResultsVisible;
@property (nonatomic, nullable, readonly) TWTRSEAutoCompletionTableViewController *autoCompletionResultsViewController;
@property (nonatomic, readonly) CGRect autoCompletionResultsViewControllerCalculatedFrame;

@property (nonatomic, readonly) CGFloat contentViewHeight;

@property (nonatomic) BOOL isSendingTweet;

@property (nonatomic) BOOL registeredForTweetTextViewContainerBoundsSizeKVO;
@property (nonatomic) BOOL registeredForTableViewContentSizeKVO;
@property (nonatomic) BOOL registeredForLastTypedWordKVO;
@property (nonatomic) BOOL registeredForTweetTextKVO;

@end

static void *TWTRSETweetTextViewContainerBoundsSizeKVOContext = &TWTRSETweetTextViewContainerBoundsSizeKVOContext;
static void *TWTRSETableViewContentSizeKVOContext = &TWTRSETableViewContentSizeKVOContext;
static void *TWTRSEDataSourceCursorSelectionKVOCOntext = &TWTRSEDataSourceCursorSelectionKVOCOntext;
static void *TSETweetTextKVOCOntext = &TSETweetTextKVOCOntext;

@implementation TWTRSETweetComposerViewController {
    dispatch_once_t _updateViewConstraintsToken;
}

- (CGRect)autoCompletionResultsViewControllerCalculatedFrame
{
    const CGFloat twoRowsIsh = _autoCompletionResultsViewController.tableView.estimatedRowHeight * kEnoughRowsToImplyScrollableTable;
    const CGFloat textViewHeightMinusCharCounterCenterYIsh = CGRectGetHeight(_scrollView.bounds) - _tweetTextViewContainer.textViewHeight - twoRowsIsh / kTwoTableViewRows;
    const CGFloat autoCompletionResultsHeight = MAX(twoRowsIsh, textViewHeightMinusCharCounterCenterYIsh);
    const CGFloat autoCompletionResultsVerticalOrigin = CGRectGetMaxY(_scrollView.frame) - ((_autoCompletionResultsVisible) ? autoCompletionResultsHeight : 0);
    const CGRect frame = {
        .origin = {.x = 0, .y = autoCompletionResultsVerticalOrigin}, .size = {.width = _tableView.contentSize.width, .height = autoCompletionResultsHeight},
    };
    return frame;
}

- (CGFloat)contentViewHeight
{
    return _tweetTextViewContainer.bounds.size.height + _tableView.contentSize.height;
}

- (instancetype)initWithConfiguration:(nonnull TWTRSETweetShareConfiguration *)configuration
{
    NSParameterAssert(configuration);

    if ((self = [super initWithNibName:nil bundle:nil])) {
        twtr_ensureFrameworksLoadedAtRuntime();

        _configuration = configuration;

        _dataSource = [[TWTRSETweetComposerTableViewDataSource alloc] initWithConfiguration:configuration allowsGeoTagging:[self isLocationSelectionAvailable]];

        _tweetTextViewContainer = [[TWTRSETweetTextViewContainer alloc] init];
        _tweetTextViewContainer.delegate = _dataSource;
        _dataSource.tweetTextViewContainer = _tweetTextViewContainer;

        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;

        _cancelBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[TSELocalized localizedString:TSEUI_LOCALIZABLE_CANCEL_ACTION_LABEL] style:UIBarButtonItemStylePlain target:self action:@selector(_tseui_cancelButtonTapped)];
        self.navigationItem.leftBarButtonItem = _cancelBarButtonItem;

        _tweetBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[TSELocalized localizedString:TSEUI_LOCALIZABLE_SENT_TWEET_ACTION_LABEL] style:UIBarButtonItemStyleDone target:self action:@selector(_tseui_tweetButtonTapped)];
        self.navigationItem.rightBarButtonItem = _tweetBarButtonItem;

        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        _spinnerBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];

        if ([self isLocationSelectionAvailable]) {
            _locationManager = [[CLLocationManager alloc] init];
            _locationManager.delegate = self;
        }

        _locationStatus = TWTRSETweetComposerTableViewDataSourceLocationStatusUnknown;

        if ([self isAutoCompletionAvailable]) {
            _autoCompletionResultsViewController = [[TWTRSEAutoCompletionTableViewController alloc] initWithAutoCompletion:configuration.autoCompletion imageDownloader:configuration.imageDownloader delegate:self];
        }

        self.title = [TSELocalized localizedString:TSEUI_LOCALIZABLE_SHARE_EXT_TWITTER_TITLE];

        _contentView = [[UIView alloc] init];
        [_contentView addSubview:_tableView];
        [_contentView addSubview:_tweetTextViewContainer];
        _scrollView = [[UIScrollView alloc] init];
        [_scrollView addSubview:_contentView];
        [self.view addSubview:_scrollView];
    }

    return self;
}

- (void)dealloc
{
    if (self.registeredForTweetTextViewContainerBoundsSizeKVO) {
        [self.tweetTextViewContainer removeObserver:self forKeyPath:NSStringFromSelector(@selector(bounds)) context:TWTRSETweetTextViewContainerBoundsSizeKVOContext];
    }

    if (self.registeredForTableViewContentSizeKVO) {
        [self.tableView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) context:TWTRSETableViewContentSizeKVOContext];
    }

    if (self.registeredForLastTypedWordKVO) {
        [self.dataSource removeObserver:self forKeyPath:NSStringFromSelector(@selector(textSelection)) context:TWTRSEDataSourceCursorSelectionKVOCOntext];
    }

    if (self.registeredForTweetTextKVO) {
        [self.dataSource removeObserver:self forKeyPath:[NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(composedTweet)), NSStringFromSelector(@selector(text))]];
    }
}

- (BOOL)isLocationSelectionAvailable
{
    return _configuration.geoTagging != nil;
}

- (BOOL)isAutoCompletionAvailable
{
    return _configuration.autoCompletion != nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    TWTRBirdView *twitterLogo = [TWTRBirdView mediumBird];
    twitterLogo.birdColor = [TWTRColorUtil blueColor];
    self.navigationItem.titleView = twitterLogo;

    self.selectedAccount = _configuration.initiallySelectedAccount ?: _configuration.accounts.firstObject;

    self.scrollView.alwaysBounceVertical = YES;

    self.tableView.bounces = NO;

    self.tableView.dataSource = self.dataSource;

    self.tableView.rowHeight = 44;
    self.tableView.estimatedRowHeight = 44;

    self.tableView.separatorInset = UIEdgeInsetsZero;

    const CGRect hairlineRect = {CGPointZero, {0, 1 / [UIScreen mainScreen].scale}};
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:hairlineRect];
    self.tableView.tableHeaderView.backgroundColor = self.tableView.separatorColor;

    if (![self.dataSource isSeparatorRequired]) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }

    [_tweetTextViewContainer configureWithTweet:self.dataSource.composedTweet];

    [self.dataSource registerCellClassesInTableView:self.tableView];
}

- (void)updateViewConstraints
{
    dispatch_once(&_updateViewConstraintsToken, ^{
        self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;

        tse_requireContentCompressionResistanceAndHuggingPriority(self.scrollView);

        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
// TODO: drop-iOS-10: remove #if/#endif and all code within
#if __IPHONE_11_0 > __IPHONE_OS_VERSION_MIN_REQUIRED
        // for iOS 10, we can rely on the topAnchor being right for the scrollView;
        // starting in iOS 11, we attach the topAnchor to the bottom of the navBar
        if (!TWTRSEUIIsIOS11OrGreater()) {
            [self.scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
        }
#endif
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;

        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;

        [self.contentView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor].active = YES;
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor].active = YES;
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor].active = YES;

        self.tableView.translatesAutoresizingMaskIntoConstraints = NO;

        tse_requireContentCompressionResistanceAndHuggingPriority(self.tableView);

        [self.tweetTextViewContainer.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor].active = YES;
        [self.tweetTextViewContainer.topAnchor constraintEqualToAnchor:self.contentView.topAnchor].active = YES;
        [self.tweetTextViewContainer.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor].active = YES;

        [self.tableView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor].active = YES;
        [self.tableView.topAnchor constraintEqualToAnchor:self.tweetTextViewContainer.bottomAnchor].active = YES;
        [self.tableView.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor].active = YES;

        [self.tweetTextViewContainer addObserver:self forKeyPath:NSStringFromSelector(@selector(bounds)) options:NSKeyValueObservingOptionNew context:TWTRSETweetTextViewContainerBoundsSizeKVOContext];
        self.registeredForTweetTextViewContainerBoundsSizeKVO = YES;

        [self.tableView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) options:NSKeyValueObservingOptionNew context:TWTRSETableViewContentSizeKVOContext];
        self.registeredForTableViewContentSizeKVO = YES;

        [self.dataSource addObserver:self forKeyPath:[NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(composedTweet)), NSStringFromSelector(@selector(text))] options:0 context:TSETweetTextKVOCOntext];
        self.registeredForTweetTextKVO = YES;

        if ([self isAutoCompletionAvailable]) {
            [self.dataSource addObserver:self forKeyPath:NSStringFromSelector(@selector(textSelection)) options:NSKeyValueObservingOptionNew context:TWTRSEDataSourceCursorSelectionKVOCOntext];
            self.registeredForLastTypedWordKVO = YES;
        }
    });
    [super updateViewConstraints];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    // this ensures the first position of the contentView & contentOffset in scrollView
    [self _tseui_updateContentConstraintsWithSize:self.view.bounds.size];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _disallowAutocompletionVisible = NO;
    if (_configuration.accounts.count == 0) {
        [self _tseui_presentNoAccountsErrorAlert];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    // Hide the keyboard if it's up.
    // This is a nice UX touch, but also works-around a layout bug with the size of the pop-up sheet and UINavigationController.
    [self.view endEditing:YES];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    // let's not try to leave autocompletionResults visible through a rotation.
    self.autoCompletionResultsVisible = NO;

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // this ensures the scrolling during rotation is relatively smooth
        [self _tseui_updateContentConstraintsWithSize:size];
        [self->_tweetTextViewContainer updateConstraints];

    }
        completion:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
            // this ensures the final position of the contentView & contentOffset in scrollView
            [self _tseui_updateContentConstraintsWithSize:self.view.bounds.size];
        }];
}

- (void)_tseui_updateContentConstraintsWithSize:(CGSize)size
{
    _contentViewWidthConstraint.active = NO;
    _contentViewHeightConstraint.active = NO;
    if (@available(iOS 11.0, *)) {
        _scrollViewTopConstraint.active = NO;
        _scrollViewTopConstraint = [_scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:self.navigationController.navigationBar.frame.size.height];
        _scrollViewTopConstraint.active = YES;
    }
    _tableViewHeightConstraint.active = NO;

    _tableViewHeightConstraint = [_tableView.heightAnchor constraintEqualToConstant:_tableView.contentSize.height];
    _contentViewWidthConstraint = [_contentView.widthAnchor constraintEqualToConstant:size.width];
    _contentViewHeightConstraint = [_contentView.heightAnchor constraintEqualToConstant:self.contentViewHeight];

    _tableViewHeightConstraint.active = YES;
    _contentViewWidthConstraint.active = YES;
    _contentViewHeightConstraint.active = YES;

    // reset the content size to be only the existing width and the new height of the content
    _scrollView.contentSize = (CGSize){.width = _scrollView.bounds.size.width, .height = self.contentViewHeight};
}

- (void)_tseui_presentNoAccountsErrorAlert
{
    NSString *noAccountsMessage = TWTRSEUIIsIOS11OrGreater() ? TSEUI_LOCALIZABLE_SHARE_EXT_NO_ACCOUNTS_SIGN_IN_MESSAGE : TSEUI_LOCALIZABLE_SHARE_EXT_NO_ACCOUNTS_MESSAGE;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[TSELocalized localizedString:TSEUI_LOCALIZABLE_SHARE_EXT_NO_ACCOUNTS_TITLE] message:[TSELocalized localizedString:noAccountsMessage] preferredStyle:UIAlertControllerStyleAlert];

    TWTRSETweetShareConfiguration *configuration = _configuration;
    [alertController addAction:[UIAlertAction actionWithTitle:[TSELocalized localizedString:TSEUI_LOCALIZABLE_OK_ACTION_LABEL]
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                          [configuration.delegate shareViewControllerPresentedWithNoAccounts];
                                                      }]];

    [self presentViewController:alertController animated:true completion:nil];
}

- (void)setSelectedAccount:(id<TWTRSEAccount>)selectedAccount
{
    if (selectedAccount != _selectedAccount) {
        _selectedAccount = selectedAccount;
        self.dataSource.currentAccountUsername = selectedAccount.username;

        if ([_configuration.delegate respondsToSelector:@selector(shareViewControllerDidSelectAccount:)]) {
            [_configuration.delegate shareViewControllerDidSelectAccount:selectedAccount];
        }
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context
{
    if (context == TWTRSETableViewContentSizeKVOContext || context == TWTRSETweetTextViewContainerBoundsSizeKVOContext) {
        self.preferredContentSize = (CGSize){.width = _tweetTextViewContainer.bounds.size.width, .height = self.contentViewHeight};

        // this ensures that when typing expands the bounds of the text view or
        // an attachment view replaces the spinner, everything is positioned correctly
        [self _tseui_updateContentConstraintsWithSize:self.view.bounds.size];
    } else if (context == TWTRSEDataSourceCursorSelectionKVOCOntext) {
        [self _tseui_updateAutoCompletion];
    } else if (context == TSETweetTextKVOCOntext) {
        [self _tseui_tweetContentsChanged];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Tweet

- (void)_tseui_tweetContentsChanged
{
    [self _tseui_updateTweetButtonEnableState];
}

- (void)setIsSendingTweet:(BOOL)isSendingTweet
{
    if (isSendingTweet != _isSendingTweet) {
        _isSendingTweet = isSendingTweet;

        [self _tseui_updateTweetButtonEnableState];
        self.cancelBarButtonItem.enabled = !isSendingTweet;
        self.view.userInteractionEnabled = !isSendingTweet;
    }
}

- (void)_tseui_presentTweetPostRequestErrorAlert
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[TSELocalized localizedString:TSEUI_LOCALIZABLE_SHARE_EXT_TWEET_FAILED_TITLE] message:[TSELocalized localizedString:TSEUI_LOCALIZABLE_COMPOSITION_SEND_TWEET_ERROR_LABEL] preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:[TSELocalized localizedString:TSEUI_LOCALIZABLE_OK_ACTION_LABEL]
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                          [alertController dismissViewControllerAnimated:true completion:nil];
                                                      }]];

    [self presentViewController:alertController animated:true completion:nil];
}

#pragma mark - Location State Machine

- (void)setSelectedGeoPlace:(id<TWTRSEGeoPlace>)selectedGeoPlace
{
    if (selectedGeoPlace != _selectedGeoPlace) {
        _selectedGeoPlace = selectedGeoPlace;

        self.dataSource.composedTweet.place = selectedGeoPlace;
        self.dataSource.selectedLocationName = selectedGeoPlace.name;
    }
}

- (void)setMostRecentLocation:(CLLocation *)mostRecentLocation
{
    _mostRecentLocation = mostRecentLocation;

    [self updateLocationStatus];
}

- (void)setWaitingForLocation:(BOOL)waitingForLocation
{
    if (waitingForLocation != _waitingForLocation) {
        _waitingForLocation = waitingForLocation;

        [self updateLocationStatus];
    }
}

- (void)setLocationStatus:(TWTRSETweetComposerTableViewDataSourceLocationStatus)locationStatus
{
    if (locationStatus != _locationStatus) {
        const TWTRSETweetComposerTableViewDataSourceLocationStatus previousLocationStatus = self.locationStatus;

        _locationStatus = locationStatus;

        self.dataSource.locationStatus = locationStatus;

        const BOOL justAcquiredLocation = previousLocationStatus == TWTRSETweetComposerTableViewDataSourceLocationStatusAcquiringLocation && locationStatus == TWTRSETweetComposerTableViewDataSourceLocationStatusLocationAcquired;

        if (justAcquiredLocation && self.waitingForLocation) {
            [self pushLocationSelectionViewController];
        }
    }
}

- (void)updateLocationStatus
{
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusNotDetermined:
            self.locationStatus = TWTRSETweetComposerTableViewDataSourceLocationStatusUnknown;
            break;
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            self.locationStatus = TWTRSETweetComposerTableViewDataSourceLocationStatusNoPermission;
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            if (self.mostRecentLocation != nil) {
                self.locationStatus = TWTRSETweetComposerTableViewDataSourceLocationStatusLocationAcquired;
            } else {
                self.locationStatus = self.waitingForLocation ? TWTRSETweetComposerTableViewDataSourceLocationStatusAcquiringLocation : TWTRSETweetComposerTableViewDataSourceLocationStatusPermissionApproved;
            }
            break;
    }
}

- (void)_tseui_requestLocation
{
    self.waitingForLocation = YES;
    [self.locationManager requestLocation];
}

- (void)_tseui_requestLocationPermission
{
    NSAssert([[self class] _tseui_applicationHasLocationUsageReasonInInfoPlist], @"NSLocationWhenInUseUsageDescription key must be set in Info.plist file for location to work. TODO: Figure out what to do for Fabric.");

    [self.locationManager requestWhenInUseAuthorization];
}

+ (BOOL)_tseui_applicationHasLocationUsageReasonInInfoPlist
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"] != nil;
}

- (void)_tseui_presentNoLocationPermissionAlert
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[TSELocalized localizedString:TSEUI_LOCALIZABLE_LOCATION_SERVICES_ACCESS_DENIED_ALERT_TITLE] message:[TSELocalized localizedString:TSEUI_LOCALIZABLE_LOCATION_SERVICES_ACCESS_DENIED_ALERT_MESSAGE] preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:[TSELocalized localizedString:TSEUI_LOCALIZABLE_OK_ACTION_LABEL]
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                          [alertController dismissViewControllerAnimated:true completion:nil];
                                                      }]];

    [self presentViewController:alertController animated:true completion:nil];
}

- (void)pushLocationSelectionViewController
{
    self.disallowAutocompletionVisible = YES;
    TWTRSELocationSelectionTableViewController *locationSelectionViewController = [[TWTRSELocationSelectionTableViewController alloc] initWithCurrentLocation:self.mostRecentLocation geoTagging:_configuration.geoTagging currentlySelectedPlace:self.selectedGeoPlace delegate:self];

    [self.navigationController showViewController:locationSelectionViewController sender:self];
}

#pragma mark - AutoCompletion

- (BOOL)isAutoCompletionResultsDisplayAllowed
{
    return !_disallowAutocompletionVisible && !_waitingForLocation;
}

- (void)setAutoCompletionResultsVisible:(BOOL)visible
{
    NSParameterAssert([self isAutoCompletionAvailable]);

    if ([self isAutoCompletionResultsDisplayAllowed] && visible != _autoCompletionResultsVisible) {
        // self.autoCompletionResultsViewControllerCalculatedFrame relies on _autocompletionResultsVisible,
        // so call the method to calculate the frame before animation before the var it relies on changes
        self.autoCompletionResultsViewController.view.frame = self.autoCompletionResultsViewControllerCalculatedFrame;

        _autoCompletionResultsVisible = visible;

        // now that _autoCompletionResultsVisible is set, re-calculate the frame for animation completion
        CGRect autoCompletionResultsFrame = self.autoCompletionResultsViewControllerCalculatedFrame;

        [self.autoCompletionResultsViewController beginAppearanceTransition:visible animated:NO];

        if (visible) {
            [self.navigationController addChildViewController:self.autoCompletionResultsViewController];
            [self.navigationController.view addSubview:self.autoCompletionResultsViewController.view];
            [self.navigationController.view bringSubviewToFront:self.autoCompletionResultsViewController.view];
            [self.autoCompletionResultsViewController didMoveToParentViewController:self];
        }
        [UIView animateWithDuration:(visible) ? 0.4 : 0.2
            delay:0.01
            options:UIViewAnimationOptionBeginFromCurrentState
            animations:^{
                self.autoCompletionResultsViewController.view.frame = autoCompletionResultsFrame;
            }
            completion:^(BOOL finished) {
                if (finished) {
                    if (!visible) {
                        [self.autoCompletionResultsViewController willMoveToParentViewController:nil];
                        [self.autoCompletionResultsViewController.view removeFromSuperview];
                        [self.autoCompletionResultsViewController removeFromParentViewController];
                    }
                    [self.autoCompletionResultsViewController endAppearanceTransition];
                }
            }];
    }
}

- (void)_tseui_updateAutoCompletion
{
    [self.autoCompletionResultsViewController updateResultsWithText:self.dataSource.composedTweet.text textSelection:self.dataSource.textSelection];
}

#pragma mark - Buttons

- (void)_tseui_updateTweetButtonEnableState
{
    self.tweetBarButtonItem.enabled = !self.isSendingTweet && [self.dataSource.composedTweet isWithinCharacterLimit];

    self.navigationItem.rightBarButtonItem = self.isSendingTweet ? self.spinnerBarButtonItem : self.tweetBarButtonItem;
}

- (void)_tseui_cancelButtonTapped
{
    [_configuration.delegate shareViewControllerWantsToCancelComposerWithPartiallyComposedTweet:[self.dataSource.composedTweet copy]];
}

- (void)_tseui_tweetButtonTapped
{
    if (self.isSendingTweet) {
        return;
    }

    [self.view endEditing:YES];
    self.isSendingTweet = YES;

    __weak typeof(self) weakSelf = self;
    [_configuration.networking sendTweet:[self.dataSource.composedTweet copy]
                             fromAccount:self.selectedAccount
                              completion:^(TWTRSENetworkingResult result) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      typeof(self) strongSelf = weakSelf;

                                      if (!strongSelf) {
                                          return;
                                      }

                                      strongSelf.isSendingTweet = NO;

                                      switch (result) {
                                          case TWTRSENetworkingResultSuccess:
                                          case TWTRSENetworkingResultWillPostAsynchronously:
                                              [strongSelf.configuration.delegate shareViewControllerDidFinishSendingTweet];
                                              break;
                                          case TWTRSENetworkingResultError:
                                              [strongSelf _tseui_presentTweetPostRequestErrorAlert];
                                              break;
                                      }
                                  });
                              }];
}

- (void)_tseui_handleAccountSelectionRowTap
{
    self.waitingForLocation = NO;
    TWTRSEAccountSelectionTableViewController *accountSelectionViewController = [[TWTRSEAccountSelectionTableViewController alloc] initWithAccounts:_configuration.accounts selectedAccount:self.selectedAccount imageDownloader:_configuration.imageDownloader networking:_configuration.networking delegate:self];

    [self.navigationController showViewController:accountSelectionViewController sender:self];
}

- (void)_tseui_handleLocationSelectionRowTap
{
    if (self.mostRecentLocation != nil) {
        [self pushLocationSelectionViewController];
    } else {
        switch (self.locationStatus) {
            case TWTRSETweetComposerTableViewDataSourceLocationStatusUnknown:
                [self _tseui_requestLocationPermission];
                break;
            case TWTRSETweetComposerTableViewDataSourceLocationStatusNoPermission:
                [self _tseui_presentNoLocationPermissionAlert];
                break;
            case TWTRSETweetComposerTableViewDataSourceLocationStatusPermissionApproved:
                [self _tseui_requestLocation];
                break;
            case TWTRSETweetComposerTableViewDataSourceLocationStatusAcquiringLocation:
                break;
            case TWTRSETweetComposerTableViewDataSourceLocationStatusLocationAcquired:
                NSAssert(false, @"The impossible happened. self.mostRecentLocation shouldn't be nil");
                break;
        }
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch ([self.dataSource cellTypeAtIndexPath:indexPath]) {
        case TWTRSETweetComposerTableViewDataSourceCellTypeAccountSelector: {
            [self _tseui_handleAccountSelectionRowTap];

            return;
        }

        case TWTRSETweetComposerTableViewDataSourceCellTypeLocationSelector: {
            [self _tseui_handleLocationSelectionRowTap];
            [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];

            return;
        }
    }

    NSAssert(false, @"Invalid TWTRSETweetComposerTableViewDataSourceCellType");
}

#pragma mark - TWTRSEAccountSelectionDelegate

- (void)accountSelectionTableViewController:(TWTRSEAccountSelectionTableViewController *)accountSelectionTableViewController didSelectAccount:(id<TWTRSEAccount>)account
{
    BOOL isChangedAccount = (account.userID != self.selectedAccount.userID);
    if (isChangedAccount) {
        self.selectedAccount = account;
    }

    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - TWTRSELocationSelectionDelegate

- (void)locationSelectionTableViewController:(TWTRSELocationSelectionTableViewController *)locationSelectionTableViewController didSelectLocation:(id<TWTRSEGeoPlace>)location
{
    BOOL isChangedLocation = (!location.placeID && self.selectedGeoPlace.placeID) || (location.placeID && ![self.selectedGeoPlace.placeID isEqualToString:location.placeID]);
    if (isChangedLocation) {
        self.selectedGeoPlace = location;
    }

    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [self updateLocationStatus];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *lastLocation = locations.lastObject;

    self.mostRecentLocation = lastLocation;

    if (self.mostRecentLocation != nil && self.waitingForLocation) {
        self.waitingForLocation = NO;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // TODO: Pipe logs outside of the framework?
    NSLog(@"Location Manager error: %@", error);

    _disallowAutocompletionVisible = NO;
    _waitingForLocation = NO;
}

#pragma mark - TWTRSEAutoCompletionTableViewControllerDelegate

- (void)autoCompletionTableViewController:(TWTRSEAutoCompletionTableViewController *)autoCompletionTableViewController wantsAutoCompletionResultsVisible:(BOOL)visible
{
    self.autoCompletionResultsVisible = visible;
}

- (void)autoCompletionTableViewController:(TWTRSEAutoCompletionTableViewController *)autoCompletionTableViewController wantsToUpdateText:(NSString *)text proposedCursor:(NSRange)proposedCursor
{
    [self.dataSource updateTweetText:text textSelection:proposedCursor];
}

@end
