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

/**
 *  Mapping to `MediaType` in scribing.
 */
typedef NS_ENUM(NSUInteger, TWTRScribeMediaType) {
    /**
     *  Consumer video uploaded to Twitter.
     */
    TWTRScribeMediaTypeConsumerVideo = 1,
    /**
     *  Amplify videos.
     */
    TWTRScribeMediaTypeProfessionalVideo = 2,
    /**
     *  Gif as a video.
     */
    TWTRScribeMediaTypeGIF = 3,
    /**
     *  Vine as a video.
     */
    TWTRScribeMediaTypeVine = 4
};

@interface TWTRScribeMediaDetails : NSObject <TWTRScribeSerializable>

@property (nonatomic, readonly, copy) NSString *publisherID;
@property (nonatomic, readonly, copy) NSString *contentID;
@property (nonatomic, readonly) TWTRScribeMediaType mediaType;

- (instancetype)init NS_UNAVAILABLE;
/**
 *  Initializes a new media detail scribe item.
 *
 *  @param publisherID Owner (publisher) of the content. This is often the Twitter user.
 *  @param contentID   UUID to the content. This is often the entity ID.
 *  @param mediaType   Type of media included.
 *
 *  @return A new media detail scribe item.
 */
- (instancetype)initWithPublisherID:(NSString *)publisherID contentID:(NSString *)contentID mediaType:(TWTRScribeMediaType)mediaType;

@end

NS_ASSUME_NONNULL_END
