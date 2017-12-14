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

/**
 This header is private to the Twitter Kit SDK and not exposed for public SDK consumption
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TWTRMoPubAdConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Wrapper class around `MPTableViewAdPlacer`.
 */
@interface TWTRTableViewAdPlacer : NSObject

- (instancetype)init NS_UNAVAILABLE;

/**
 *  Initializes a new wrapper ad placer.
 *
 *  @param tableView        The `UITableView` to places ads into.
 *  @param viewController   The view controller to present modal view content
 *                          when the ad cell is tapped.
 *  @param adConfiguration  The ad rendering configuration
 *
 *  @return A fully initialized wrapper ad placer.
 */
- (instancetype)initWithTableView:(UITableView *)tableView viewController:(UIViewController *)viewController adConfiguration:(TWTRMoPubAdConfiguration *)adConfiguration;

/**
 *  Starts injecting ads per server-side configuration into the associating table view. This is no-op
 *  if MoPub is not linked or the provided `adConfiguration` is invalid.
 *  @see `-[MPTableViewAdPlacer loadAdsForAdUnitID:targeting:]`.
 */
- (void)loadAdUnitIfConfigured;

@end

NS_ASSUME_NONNULL_END
