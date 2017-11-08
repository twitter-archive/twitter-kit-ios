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

#import <TwitterKit/TWTRJSONConvertible.h>
#import "TWTRTweetEntity.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * A Tweet entity which represents a URL
 */
@interface TWTRTweetUrlEntity : TWTRTweetEntity <NSCoding, TWTRJSONConvertible>

/**
 * The URL to display. This property may be truncated and may
 * not be a valid URL.
 */
@property (nonatomic, copy, readonly) NSString *displayUrl;

/**
 * The expanded URL. This property will be a valid URL.
 */
@property (nonatomic, copy, readonly) NSString *expandedUrl;

/**
 * The t.co link which will redirect to the original URL.
 */
@property (nonatomic, copy, readonly) NSString *url;

@end

NS_ASSUME_NONNULL_END
