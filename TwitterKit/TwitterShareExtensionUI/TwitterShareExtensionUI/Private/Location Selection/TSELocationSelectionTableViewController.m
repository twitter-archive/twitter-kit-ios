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

#import "NSArray+Helpers.h"
#import "TSEFonts.h"
#import "TSEFoursquareLogoTableViewCell.h"
#import "TSEGeoPlace.h"
#import "TSEGeoPlaceTableViewCell.h"
#import "TSEGeoTagging.h"
#import "TSELoadingTableViewCell.h"
#import "TSELocalizedString.h"
#import "TSELocationMapTableViewHeaderView.h"
#import "TSELocationSelectionTableViewController.h"
#import "UIView+TSEExtensions.h"

@import MapKit;


#pragma mark -

static const CGFloat kMapViewHeaderHeight = 125.0;

@interface TSELocationSelectionTableViewController ()

@property (nonatomic, readonly, nonnull) CLLocation *location;
@property (nonatomic, readonly, nonnull) id<TSEGeoTagging> geoTagging;
@property (nonatomic, readonly, nonnull) TSELocationMapTableViewHeaderView *headerMapView;

@property (nonatomic) BOOL loading;
@property (nonatomic, nullable) NSArray<id<TSEGeoPlace>> *places;
@property (nonatomic, nullable) id<TSEGeoPlace> selectedPlace;

@property (nonatomic) BOOL shouldShowFoursquareLogo;

@end

@implementation TSELocationSelectionTableViewController

- (instancetype)initWithCurrentLocation:(CLLocation *)location geoTagging:(id<TSEGeoTagging>)geoTagging currentlySelectedPlace:(id<TSEGeoPlace>)currentlySelectedPlace delegate:(id<TSELocationSelectionDelegate>)delegate
{
    NSParameterAssert(location);
    NSParameterAssert(geoTagging);
    NSParameterAssert(delegate);

    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        _location = location;
        _geoTagging = geoTagging;
        _delegate = delegate;
        _selectedPlace = currentlySelectedPlace;

        self.title = [TSELocalized localizedString:TSEUI_LOCALIZABLE_SHARE_EXT_LOCATION];

        if (@available(iOS 11.0, *)) {
            self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _headerMapView = [[TSELocationMapTableViewHeaderView alloc] initWithCenterCoordinates:self.location.coordinate];
    _headerMapView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), kMapViewHeaderHeight);
    self.tableView.tableHeaderView = self.headerMapView;

    [self.tableView registerClass:[TSELoadingTableViewCell class] forCellReuseIdentifier:TSELoadingTableViewCell.reuseIdentifier];
    [self.tableView registerClass:[TSEFoursquareLogoTableViewCell class] forCellReuseIdentifier:TSEFoursquareLogoTableViewCell.reuseIdentifier];
    [self.tableView registerClass:[TSEGeoPlaceTableViewCell class] forCellReuseIdentifier:TSEGeoPlaceTableViewCell.reuseIdentifier];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self loadPlaces];
}

- (void)loadPlaces
{
    if (self.loading) {
        return;
    }

    self.loading = YES;

    __weak typeof(self) weakSelf = self;
    [self.geoTagging loadPlacesNearLocation:self.location withCompletion:^(NSArray<id<TSEGeoPlace>> * _Nullable places, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;

            if (!strongSelf) {
                return;
            }

            strongSelf.loading = NO;

            if (places) {
                strongSelf.places = places;
            } else {
                [strongSelf presentAlertForError:error];
            }
        });
    }];
}

- (void)presentAlertForError:(NSError *)error
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[TSELocalized localizedString:TSEUI_LOCALIZABLE_LOCATION_SERVICES_ERROR_ALERT_TITLE]
                                                                             message:[TSELocalized localizedString:TSEUI_LOCALIZABLE_LOCATION_SERVICES_ERROR_ALERT_MESSAGE]
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:[TSELocalized localizedString:TSEUI_LOCALIZABLE_CANCEL_ACTION_LABEL]
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:true completion:nil];
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:[TSELocalized localizedString:TSEUI_LOCALIZABLE_RETRY_ACTION_LABEL]
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:true completion:nil];
        [self loadPlaces];
    }]];

    [self presentViewController:alertController animated:true completion:nil];
}

- (void)setLoading:(BOOL)loading
{
    if (loading != _loading) {
        _loading = loading;

        [self.tableView reloadData];
    }
}

- (void)setPlaces:(NSArray<id<TSEGeoPlace>> *)places
{
    _places = [places copy];

    self.shouldShowFoursquareLogo = tse_filter(places, ^BOOL(id<TSEGeoPlace> _Nonnull place) {
        return place.isFoursquarePlace;
    }).count > 0;

    [self.tableView reloadData];
}

- (void)setSelectedPlace:(id<TSEGeoPlace>)selectedPlace
{
    if (selectedPlace != _selectedPlace) {
        _selectedPlace = selectedPlace;

        [self.tableView reloadData];

        [self.delegate locationSelectionTableViewController:self didSelectLocation:selectedPlace];
    }
}

- (BOOL)isNullPlaceSelectionRowIndexPath:(NSIndexPath *)indexPath
{
    return self.places.count > 0 && indexPath.row == 0;
}

- (BOOL)isFoursquareLogoCellAtIndexPath:(NSIndexPath *)indexPath
{
    return self.places.count > 0 && (NSUInteger)indexPath.row == self.places.count + 1;
}

- (nullable id<TSEGeoPlace>)geoPlaceForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.places.count == 0 || [self isNullPlaceSelectionRowIndexPath:indexPath] || [self isFoursquareLogoCellAtIndexPath:indexPath]) {
        return nil;
    } else {
        // -1 needed because the "None" row offsets everything by 1.
        return self.places[(NSUInteger)indexPath.row - 1];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.places.count > 0) {
        // +1 for the "None" place
        const NSInteger placeCells = (NSInteger)self.places.count + 1;
        if (self.shouldShowFoursquareLogo) {
            return placeCells + 1;
        } else {
            return placeCells;
        }
    } else if (self.loading) {
        // "Loading" row
        return 1;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.places.count > 0) {
        if ([self isFoursquareLogoCellAtIndexPath:indexPath]) {
            return [tableView dequeueReusableCellWithIdentifier:TSEFoursquareLogoTableViewCell.reuseIdentifier forIndexPath:indexPath];
        }

        TSEGeoPlaceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TSEGeoPlaceTableViewCell.reuseIdentifier forIndexPath:indexPath];

        if ([self isNullPlaceSelectionRowIndexPath:indexPath]) {
            [cell configureWithNullSelectionSelected:self.selectedPlace == nil];
        } else {
            id<TSEGeoPlace> place = [self geoPlaceForRowAtIndexPath:indexPath];

            [cell configureWithPlace:place selected:[place.placeID isEqualToString:self.selectedPlace.placeID]];
        }

        return cell;
    } else {
        return [tableView dequeueReusableCellWithIdentifier:TSELoadingTableViewCell.reuseIdentifier forIndexPath:indexPath];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.loading) {
        return;
    }

    self.selectedPlace = [self geoPlaceForRowAtIndexPath:indexPath];
}

@end
