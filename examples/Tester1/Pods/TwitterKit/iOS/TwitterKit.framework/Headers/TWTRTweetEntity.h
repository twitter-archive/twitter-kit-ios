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
#import <TwitterKit/TWTRJSONConvertible.h>

NS_ASSUME_NONNULL_BEGIN

@interface TWTRTweetEntity : NSObject <NSCoding, NSCopying, TWTRJSONConvertible>

/**
 * The start index of the entity in code points.
 */
@property (nonatomic, readonly) NSInteger startIndex;

/**
 * The end index of the entity in code points.
 */
@property (nonatomic, readonly) NSInteger endIndex;

/**
 * Initializes the receiver with the given start index and end index.
 */
- (instancetype)initWithStartIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex;

/**
 * Subclasses should override this method to provide an accessibility value
 * which can be used inside of Tweets.
 */
- (NSString *)accessibilityValue;

@end

NS_ASSUME_NONNULL_END
