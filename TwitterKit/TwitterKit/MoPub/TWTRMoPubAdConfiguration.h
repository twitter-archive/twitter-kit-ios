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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Bridging class for configuring how to load your MoPub ad unit.
 */
@interface TWTRMoPubAdConfiguration : NSObject

/**
 *  Ad unit ID of the MoPub ad.
 */
@property (nonatomic, copy, readonly) NSString *adUnitID;

/**
 *  Keywords specified in comma-separated key-value pairs to provide
 *  better targetting of the ads. e.g. "marital:single,age:24"
 *  @see https://github.com/mopub/mopub-ios-sdk/blob/master/MoPubSDK/Native%20Ads/MPNativeAdRequestTargeting.h
 */
@property (nonatomic, copy, readonly, nullable) NSString *keywords;

- (instancetype)init NS_UNAVAILABLE;

/**
 *  Initializes a new MoPub ad configuration.
 *
 *  @param adUnitID The ad unit ID as configured in the MoPub dashboard
 *  @param keywords Keywords for better ad targeting
 *
 *  @return Fully initialized ad configuration.
 */
- (instancetype)initWithAdUnitID:(NSString *)adUnitID keywords:(nullable NSString *)keywords;

@end

NS_ASSUME_NONNULL_END
