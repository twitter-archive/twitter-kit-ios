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

#import "TWTRTableViewAdPlacer.h"
#import <MoPub/MPTableViewAdPlacer.h>
#import "TWTRMoPubAdConfiguration.h"
#import "TWTRMoPubAdConfiguration_Private.h"
#import "TWTRMoPubVersionChecker.h"

static Class TWTRTableViewAdPlacerClass = nil;

@interface TWTRTableViewAdPlacer ()

@property (nonatomic, readonly, nullable) id adPlacer;
@property (nonatomic, readonly, nonnull) TWTRMoPubAdConfiguration *adConfig;

@end

@implementation TWTRTableViewAdPlacer

+ (void)initialize
{
    if (self == [TWTRTableViewAdPlacer class]) {
        TWTRTableViewAdPlacerClass = NSClassFromString(@"MPTableViewAdPlacer");
    }
}

- (instancetype)initWithTableView:(UITableView *)tableView viewController:(UIViewController *)viewController adConfiguration:(TWTRMoPubAdConfiguration *)adConfiguration
{
    if (self = [super init]) {
        _adConfig = adConfiguration;
        id rendererConfiguration = [self.adConfig adRendererConfiguration];

        if (![TWTRMoPubVersionChecker isValidVersion]) {
            NSLog(@"[TwitterKit] Requires MoPub SDK version >= %td in order to render ads.", TWTRMoPubMinimumRequiredVersion);
        } else {
            if (rendererConfiguration) {
                _adPlacer = [TWTRTableViewAdPlacerClass placerWithTableView:tableView viewController:viewController rendererConfigurations:@[rendererConfiguration]];
            }
        }
    }

    return self;
}

- (void)loadAdUnitIfConfigured
{
    [self.adPlacer loadAdsForAdUnitID:self.adConfig.adUnitID targeting:self.adConfig.adRequestTargeting];
}

@end
