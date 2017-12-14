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
#import "TWTRJSONConvertible.h"

@class TWTRMediaEntityDisplayConfiguration;
@class TWTRVideoPlaybackConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface TWTRCardEntity : NSObject <NSCoding, NSCopying>

/**
 * The URL for this card.
 */
@property (nonatomic, copy, readonly) NSString *URLString;

/**
 * Creates a card from the given JSON dictionary or nil if no
 * card can be created. This method will return a subclass of
 * TWTRCardEntity.
 *
 * @note TWTRCardEntity classes should not be created directly, use this method instead.
 */
+ (nullable instancetype)cardEntityFromJSONDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
