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

NS_ASSUME_NONNULL_BEGIN

@interface TWTRStringUtil : NSObject

+ (NSString *)stringByReplacingLastOccurrenceOfString:(NSString *)target withString:(NSString *)replacement inStringIgnoringExtension:(NSString *)original;
+ (BOOL)stringContainsOnlyNumbers:(NSString *)string;
+ (BOOL)stringContainsOnlyHexNumbers:(NSString *)string;
+ (NSInteger)hexIntegerValueWithString:(NSString *)string;

/**
 * Returns a string in the format of minutes:seconds -> 2:09
 * @note this method will return nil for values less than 0.
 */
+ (nullable NSString *)displayStringFromTimeInterval:(NSTimeInterval)interval;

/**
 * Returns the preview text up to a given code point.
 */
+ (NSString *)previewTextFromFullText:(NSString *)fullText previewLength:(NSInteger)length;

@end

NS_ASSUME_NONNULL_END
