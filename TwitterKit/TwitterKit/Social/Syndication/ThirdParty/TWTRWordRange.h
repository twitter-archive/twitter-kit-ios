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

#import "TWTRWordRange.h"

@interface NSString (TWTRWordRange)

/**
 find a "word" in this string based on canonical boundaries

 @param index location around which to look for a TwitterText 'word'
 @return a range representing the "word" which contains index (nil if no TwitterText 'word' token found)
 */
- (NSRange)wordRangeForIndex:(NSInteger)index;

/**
 this function does the same thing as wordRangeForIndex:, but where '_' is a valid character

 @param index location in this string around which to find a 'word' as a token
 @return the value represented by wordRangeForIndex: where '_' is a valid character in the word at index
 */

- (NSRange)wordRangeIncludingUnderscoreForIndex:(NSInteger)index;

@end
