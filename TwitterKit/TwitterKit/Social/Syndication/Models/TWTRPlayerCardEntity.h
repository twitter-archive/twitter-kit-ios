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

#import <UIKit/UIKit.h>
#import "TWTRCardEntity.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TWTRPlayerCardType) {
    TWTRPlayerCardTypeUnknown = 0,
    TWTRPlayerCardTypeVine = 1,
};

/**
 * The binding values for the player card.
 */
@interface TWTRPlayerCardEntityBindingValues : NSObject <TWTRJSONConvertible, NSCoding, NSCopying>

/**
 * The name of the app the player represents.
 */
@property (nonatomic, readonly, copy) NSString *appName;

/**
 * The URL for the player's stream.
 */
@property (nonatomic, readonly, copy) NSString *playerStreamURL;

/**
 * The URL to deep link to the original player.
 */
@property (nonatomic, readonly, copy) NSString *playerURL;

/**
 * The URL to the preview image of the player.
 */
@property (nonatomic, readonly, copy) NSString *playerImageURL;

/**
 * The size of the image returned from playerImageURL.
 */
@property (nonatomic, readonly) CGSize playerImageSize;

/**
 * A text description of hte card.
 */
@property (nonatomic, readonly, copy) NSString *cardDescription;

@end

/**
 * A Card entity that represents a Player card.
 */
@interface TWTRPlayerCardEntity : TWTRCardEntity <TWTRJSONConvertible, NSCoding, NSCopying>

/**
 * The type of card this represents.
 */
@property (nonatomic, readonly) TWTRPlayerCardType playerCardType;

/**
 * The card's binding values.
 */
@property (nonatomic, readonly) TWTRPlayerCardEntityBindingValues *bindingValues;

@end

NS_ASSUME_NONNULL_END
