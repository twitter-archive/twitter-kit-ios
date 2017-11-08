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
#import "TWTRScribeSerializable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Type of promotional card. Numeric values are direct mapping of what's in the backend.
 */
typedef NS_ENUM(NSUInteger, TWTRScribePromotionCardType) {
    /**
     *  Image App Card
     */
    TWTRScribePromotionCardTypeImageAppDownload = 8,
};

/**
 *  Immutable representation of a scribe Card event item.
 */
@interface TWTRScribeCardEvent : NSObject <TWTRScribeSerializable>

@property (nonatomic, readonly) TWTRScribePromotionCardType promotionCardType;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithPromotionCardType:(TWTRScribePromotionCardType)promotionCardType;

@end

NS_ASSUME_NONNULL_END
