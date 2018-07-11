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

@import MapKit;
#import "TWTRSELocationMapTableViewHeaderView.h"

static const CLLocationDistance kMapHorizontalPadding = 3000;
static const CLLocationDistance kMapVerticalPadding = 1000;

@interface TWTRSELocationMapTableViewHeaderView ()

@property (nonatomic, readonly) MKMapView *mapView;

@end

@implementation TWTRSELocationMapTableViewHeaderView

- (instancetype)initWithCenterCoordinates:(CLLocationCoordinate2D)coordinates
{
    if ((self = [super initWithFrame:CGRectZero])) {
        _mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
        _mapView.mapType = MKMapTypeStandard;
        _mapView.centerCoordinate = coordinates;
        _mapView.zoomEnabled = YES;
        _mapView.showsUserLocation = YES;
        _mapView.userTrackingMode = MKUserTrackingModeNone;
        _mapView.region = MKCoordinateRegionMakeWithDistance(coordinates, kMapHorizontalPadding, kMapVerticalPadding);

        [self addSubview:_mapView];
    }

    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.mapView.frame = self.bounds;
}

@end
