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

#import "TWTRCardEntity.h"

extern NSString *const TWTRCardSiteValueToUserIDStringTransformerName;
extern NSString *const TWTRCardEntityBindingValueStringTransformerName;
extern NSString *const TWTRCardEntityBindingValueImageTransformerName;

@interface TWTRCardEntity ()

- (instancetype)initWithURL:(NSString *)URL;

/**
 * Subclasses should do the least amount of work necessary to determine
 * if they can be initialized with the given dictionary.
 */
+ (BOOL)canInitWithJSONDictionary:(NSDictionary<NSString *, id> *)JSONDictionary;

@end

@interface TWTRCardEntityImageValue : NSObject <NSCoding, NSCopying>

- (instancetype)initWithURL:(NSString *)imageURL height:(CGFloat)height width:(CGFloat)width;

@property (nonatomic, readonly, copy) NSString *imageURL;
@property (nonatomic, readonly) CGSize imageSize;

@end
