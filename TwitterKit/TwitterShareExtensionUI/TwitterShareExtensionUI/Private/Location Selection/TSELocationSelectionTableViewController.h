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

#import "TSESelectionTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class CLLocation;
@protocol TSEGeoPlace;
@protocol TSEGeoTagging;
@class TSELocationSelectionTableViewController;

@protocol TSELocationSelectionDelegate <NSObject>

/**
 Invoked on the main thread whenever the user changes the selection on `TSELocationSelectionTableViewController`.

 @param locationSelectionTableViewController The view controller invoking this method.
 @param location The selected location or nil if the user selected "None".
 */
- (void)locationSelectionTableViewController:(TSELocationSelectionTableViewController *)locationSelectionTableViewController didSelectLocation:(nullable id<TSEGeoPlace>)location;

@end

@interface TSELocationSelectionTableViewController : TSESelectionTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style NS_UNAVAILABLE;

@property (nullable, nonatomic, weak) id<TSELocationSelectionDelegate> delegate;

/**
 @param location (required): The current location of the user to be used to request places around.
 @param geoTagging (required): An object that can provide places to geo-tag the tweet.
 @param currentlySelectedPlace (optional): A place to auto-select on the list or nil if "None" is currently selected.
 @param delegate (required): The object that will be notified with changes to the place selection.
 */
- (instancetype)initWithCurrentLocation:(CLLocation *)location geoTagging:(id<TSEGeoTagging>)geoTagging currentlySelectedPlace:(nullable id<TSEGeoPlace>)currentlySelectedPlace delegate:(id<TSELocationSelectionDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
