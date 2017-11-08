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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TWTRMediaEntitySizeResizingMode) {
    TWTRMediaEntitySizeResizingModeFit,
    TWTRMediaEntitySizeResizingModeCrop,
};

FOUNDATION_EXTERN NSString *NSStringFromTWTRMediaEntitySizeResizingMode(TWTRMediaEntitySizeResizingMode resizingMode);
FOUNDATION_EXTERN TWTRMediaEntitySizeResizingMode TWTRMediaEntitySizeResizingModeFromString(NSString *resizingModeString);

@interface TWTRMediaEntitySize : NSObject <NSCoding>

/**
 * The name of the size. 'large', 'medium', etc.
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 * Resize mode of the image size e.g. Fit, Crop.
 */
@property (nonatomic, readonly) TWTRMediaEntitySizeResizingMode resizingMode;

/**
 * The actual size.
 */
@property (nonatomic, readonly) CGSize size;

- (instancetype)init NS_UNAVAILABLE;

/**
 *  Designated initializer.
 *
 *  @param name         The name of the size. If nil will default to the empty string.
 *  @param resizingMode The resizing mode of this entity size.
 *  @param size         The size of the entity.
 */
- (instancetype)initWithName:(NSString *)name resizingMode:(TWTRMediaEntitySizeResizingMode)resizingMode size:(CGSize)size NS_DESIGNATED_INITIALIZER;

- (BOOL)isEqualToMediaEntitySize:(TWTRMediaEntitySize *)otherSize;

/**
 *  Returns a dictionary of valid `TWTRMediaEntitySize` instances from the Twitter API response for media sizes.
 *
 *  @param dictionary A parsed dictionary of media sizes from the Twitter API response
 *
 *  @return Dictionary of parsed `TWTRMediaEntitySize` instances keyed by size name.
 */
+ (NSDictionary *)mediaEntitySizesWithJSONDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
