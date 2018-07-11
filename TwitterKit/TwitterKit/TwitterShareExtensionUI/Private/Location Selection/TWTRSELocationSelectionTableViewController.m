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

#import "TWTRSELocationSelectionTableViewController.h"
#import "NSArray+Helpers.h"
#import "TWTRSEFonts.h"
#import "TWTRSEGeoPlace.h"
#import "TWTRSEGeoPlaceTableViewCell.h"
#import "TWTRSEGeoTagging.h"
#import "TWTRSELoadingTableViewCell.h"
#import "TWTRSELocalizedString.h"
#import "TWTRSELocationMapTableViewHeaderView.h"
#import "UIView+TSEExtensions.h"

@import MapKit;

#pragma mark -

static const CGFloat kMapViewHeaderHeight = 125.0;

@interface TWTRSELocationSelectionTableViewController ()

@property (nonatomic, readonly, nonnull) CLLocation *location;
@property (nonatomic, readonly, nonnull) id<TWTRSEGeoTagging> geoTagging;
@property (nonatomic, readonly, nonnull) TWTRSELocationMapTableViewHeaderView *headerMapView;

@property (nonatomic) BOOL loading;
@property (nonatomic, nullable) NSArray<id<TWTRSEGeoPlace>> *places;
@property (nonatomic, nullable) id<TWTRSEGeoPlace> selectedPlace;

@end

@implementation TWTRSELocationSelectionTableViewController

- (instancetype)initWithCurrentLocation:(CLLocation *)location geoTagging:(id<TWTRSEGeoTagging>)geoTagging currentlySelectedPlace:(id<TWTRSEGeoPlace>)currentlySelectedPlace delegate:(id<TWTRSELocationSelectionDelegate>)delegate
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

    _headerMapView = [[TWTRSELocationMapTableViewHeaderView alloc] initWithCenterCoordinates:self.location.coordinate];
    _headerMapView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), kMapViewHeaderHeight);
    self.tableView.tableHeaderView = self.headerMapView;

    [self.tableView registerClass:[TWTRSELoadingTableViewCell class] forCellReuseIdentifier:TWTRSELoadingTableViewCell.reuseIdentifier];
    [self.tableView registerClass:[TWTRSEGeoPlaceTableViewCell class] forCellReuseIdentifier:TWTRSEGeoPlaceTableViewCell.reuseIdentifier];
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
    [self.geoTagging loadPlacesNearLocation:self.location
                             withCompletion:^(NSArray<id<TWTRSEGeoPlace>> *_Nullable places, NSError *_Nullable error) {
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
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[TSELocalized localizedString:TSEUI_LOCALIZABLE_LOCATION_SERVICES_ERROR_ALERT_TITLE] message:[TSELocalized localizedString:TSEUI_LOCALIZABLE_LOCATION_SERVICES_ERROR_ALERT_MESSAGE] preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:[TSELocalized localizedString:TSEUI_LOCALIZABLE_CANCEL_ACTION_LABEL]
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *_Nonnull action) {
                                                          [alertController dismissViewControllerAnimated:true completion:nil];
                                                      }]];

    [alertController addAction:[UIAlertAction actionWithTitle:[TSELocalized localizedString:TSEUI_LOCALIZABLE_RETRY_ACTION_LABEL]
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *_Nonnull action) {
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

- (void)setPlaces:(NSArray<id<TWTRSEGeoPlace>> *)places
{
    _places = [places copy];
    [self.tableView reloadData];
}

- (void)setSelectedPlace:(id<TWTRSEGeoPlace>)selectedPlace
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

- (nullable id<TWTRSEGeoPlace>)geoPlaceForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.places.count == 0 || [self isNullPlaceSelectionRowIndexPath:indexPath]) {
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
        return placeCells;
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
        TWTRSEGeoPlaceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TWTRSEGeoPlaceTableViewCell.reuseIdentifier forIndexPath:indexPath];

        if ([self isNullPlaceSelectionRowIndexPath:indexPath]) {
            [cell configureWithNullSelectionSelected:self.selectedPlace == nil];
        } else {
            id<TWTRSEGeoPlace> place = [self geoPlaceForRowAtIndexPath:indexPath];

            [cell configureWithPlace:place selected:[place.placeID isEqualToString:self.selectedPlace.placeID]];
        }

        return cell;
    } else {
        return [tableView dequeueReusableCellWithIdentifier:TWTRSELoadingTableViewCell.reuseIdentifier forIndexPath:indexPath];
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
