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
 This header is private to the Twitter Core SDK and not exposed for public SDK consumption
 */

#import <Foundation/Foundation.h>
#import "TWTRScribeSerializable.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TWTRScribeFilterDetailsType) { TWTRScribeFilterDetailsTypeDefault = 1, TWTRScribeFilterDetailsTypeCompact = 2 };

@interface TWTRScribeFilterDetails : NSObject <TWTRScribeSerializable>

@property (nonatomic) NSUInteger totalFilteredTweets;
@property (nonatomic) NSUInteger requestedTweets;
@property (nonatomic) NSUInteger totalFilters;
@property (nonatomic, assign, readonly) TWTRScribeFilterDetailsType scribeType;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFilters:(NSUInteger)totalFilters;
/**
 *  Initializes a new filter detail scribe item.
 *
 *  @param totalFilters         number of filters
 *  @param requestedTweets      number of tweets requested to filter
 *  @param totalFilteredTweets  number of tweets that got filtered
 *
 *  @return A new filter detail scribe item.
 */
- (instancetype)initWithRequestedTweets:(NSUInteger)requestedTweets totalFilters:(NSUInteger)totalFilters totalFilteredTweets:(NSUInteger)totalFilteredTweets;

- (NSString *)stringRepresentation;

@end

NS_ASSUME_NONNULL_END
