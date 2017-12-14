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

#import <MoPub/MPNativeAdRendering.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  View of the individual MoPub ad.
 */
@interface TWTRMoPubNativeAdView : UIView

/**
 *  Ad's main title text.
 */
@property (nonatomic, readonly) UILabel *titleTextLabel;

/**
 *  Ad's main text.
 */
@property (nonatomic, readonly) UILabel *mainTextLabel;

/**
 *  Ad's call-to-action text.
 */
@property (nonatomic, readonly) UILabel *callToActionTextLabel;

/**
 *  Ad's icon, usually image of the advertiser.
 */
@property (nonatomic, readonly) UIImageView *iconImageView;

/**
 *  Main image of the ad.
 */
@property (nonatomic, readonly) UIImageView *mainImageView;

@end

NS_ASSUME_NONNULL_END
