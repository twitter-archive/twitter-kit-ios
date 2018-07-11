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

#import "TWTRSEBaseTableViewCell.h"

@protocol TWTRSEGeoPlace;

NS_ASSUME_NONNULL_BEGIN

@interface TWTRSEGeoPlaceTableViewCell : TWTRSEBaseTableViewCell

/**
 @param place (required) The place to show the details for.
 @param selected Whether this place is currently selected.
 */
- (void)configureWithPlace:(id<TWTRSEGeoPlace>)place selected:(BOOL)selected;

/**
 Display a text indicating this selection will not geo-tag the tweet.

 @param selected Whether this place is currently selected.
 */
- (void)configureWithNullSelectionSelected:(BOOL)selected;

@end

NS_ASSUME_NONNULL_END
