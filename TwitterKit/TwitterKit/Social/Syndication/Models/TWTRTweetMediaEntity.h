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

#import <TwitterKit/TWTRJSONConvertible.h>
#import "TWTRMediaType.h"
#import "TWTRTweetEntity.h"

@class TWTRMediaEntitySize;
@class TWTRVideoMetaData;
@class TWTRVideoPlaybackConfiguration;

NS_ASSUME_NONNULL_BEGIN

/**
 * A Tweet entity which represents some sort of media.
 */
@interface TWTRTweetMediaEntity : TWTRTweetEntity <TWTRJSONConvertible>

#pragma mark - Properties

/**
 *  Media HTTPS URL
 *  e.g. https://pbs.twimg.com/media/BrdQYCpCcAAYa2h.jpg
 */
@property (nonatomic, copy, readonly) NSString *mediaUrl;

/**
 *  URL to display if need be
 *  e.g. pic.twitter.com/tJWrsXd85p
 */
@property (nonatomic, copy, readonly) NSString *displayURL;

/**
 *  Original URL in tweet text
 *  e.g. http://t.co/tJWrsXd85p
 */
@property (nonatomic, copy, readonly) NSString *tweetTextURL;

/**
 *  Dictionary of size details which maps Strings to
 *  TWTRMediaEntitySize objects.
 */
@property (nonatomic, copy, readonly) NSDictionary *sizes;

/**
 *  ID of the media content. This is unique to media entities.
 */
@property (nonatomic, copy, readonly) NSString *mediaID;

/**
 * The media type of this entity.
 */
@property (nonatomic, readonly) TWTRMediaType mediaType;

/**
 * If this media entity represents a video this property will hold the video details.
 */
@property (nonatomic, readonly, nullable) TWTRVideoMetaData *videoMetaData;

/**
 * Determines if the media entity can be embedded.
 */
@property (nonatomic, readonly) BOOL embeddable;

/**
 *  Determines if the embeddable parameter was in the dictionary response at all. If
 *  it was not defined, the  embeddable property will also be set to NO.
 */
@property (nonatomic, readonly) BOOL isEmbeddableDefined;

@end

NS_ASSUME_NONNULL_END
