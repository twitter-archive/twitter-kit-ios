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

#import "TWTRSEAutoCompletionViewModel.h"
#import "TWTRSEAccount.h"
#import "TWTRSETweet.h"
#import "TWTRSEWordRangeCalculator.h"

@interface NSString (TWTRSEAutoCompletionViewModel)
- (BOOL)isSpecialAutoCompleteSymbolAtIndex:(NSUInteger)index;
- (BOOL)isSpaceOrCarriageReturnAtIndex:(NSUInteger)index;
- (NSString *)stringForTwitterTextEntityIntersectingRange:(NSRange)range;
@end

@interface NSString () <TWTRSEWordRangeCalculator>
@end

@implementation TWTRSEAutoCompletionViewModel

- (BOOL)wordIsHashtag:(NSString *)word
{
    return [word hasPrefix:@"#"];
}

- (BOOL)wordIsUsername:(NSString *)word
{
    return [word hasPrefix:@"@"];
}

- (NSString *)stripUsernameMarkersFromWord:(NSString *)word
{
    if ([self wordIsUsername:word]) {
        NSRange atSignRange = [word rangeOfString:@"@"];
        return [word stringByReplacingCharactersInRange:atSignRange withString:@""];
    } else {
        return word;
    }
}

- (NSString *)wordAroundSelectedLocation:(NSUInteger)selectedLocation inText:(NSString<TWTRSEWordRangeCalculator> *)text
{
    NSParameterAssert([text respondsToSelector:@selector(wordRangeIncludingUnderscoreForIndex:)]);
    const NSUInteger index = (0 != selectedLocation) ? selectedLocation - 1 : 0;
    NSRange wordRange = [text wordRangeIncludingUnderscoreForIndex:index];
    if (NSNotFound == wordRange.location) {
        if (0 == text.length || index + 1 >= text.length || ![text isSpecialAutoCompleteSymbolAtIndex:index]) {
            return nil;
        }

        wordRange = [text wordRangeIncludingUnderscoreForIndex:index + 1];
        if (NSNotFound == wordRange.location) {
            return nil;
        }
    }

    return [text stringForTwitterTextEntityIntersectingRange:wordRange] ?: [text substringWithRange:wordRange];
}

- (NSString *)insertAutoCompletionWord:(NSString *)word inWordAtLocation:(NSUInteger)wordLocation inText:(NSString<TWTRSEWordRangeCalculator> *)text insertionEndLocation:(NSUInteger *)insertionEndLocation
{
    NSParameterAssert([text respondsToSelector:@selector(wordRangeIncludingUnderscoreForIndex:)]);
    NSUInteger index = (0 != wordLocation) ? wordLocation - 1 : 0;
    NSRange wordRange = [text wordRangeIncludingUnderscoreForIndex:index];
    if (wordRange.location == NSNotFound) {
        if ([text isSpecialAutoCompleteSymbolAtIndex:index]) {
            if (index + 1 < text.length && ![text isSpaceOrCarriageReturnAtIndex:index + 1]) {
                wordRange = [text wordRangeIncludingUnderscoreForIndex:++index];
            } else {  // just the symbol
                wordRange = (NSRange){.location = index, .length = 1};
            }
        }
    }

    if (wordRange.location == NSNotFound) {
        wordRange = (NSRange){.location = index, .length = 0};
    } else if (0 != wordRange.location) {
        index = wordRange.location - 1;
        if ([text isSpecialAutoCompleteSymbolAtIndex:index]) {
            wordRange.location--;
            wordRange.length++;
        }
    }

    NSUInteger endOfReplacementIndex = NSMaxRange(wordRange);
    BOOL shouldAddSpace = (text.length <= endOfReplacementIndex) || !([text isSpaceOrCarriageReturnAtIndex:endOfReplacementIndex]);

    // putting a space after an auto-completed word matches what goes on in
    // the in-app composer and also SLShareViewController behavior
    NSString *replacementWord = (shouldAddSpace) ? [word stringByAppendingString:@" "] : word;

    NSString *result = [text stringByReplacingCharactersInRange:wordRange withString:replacementWord];

    if (insertionEndLocation) {
        *insertionEndLocation = wordRange.location + replacementWord.length;
    }

    return result;
}

@end

@implementation NSString (TWTRSEAutoCompletionViewModel)

- (BOOL)isSpecialAutoCompleteSymbolAtIndex:(NSUInteger)index
{
    unichar c = [self characterAtIndex:index];
    return '#' == c || '@' == c;
}

- (BOOL)isSpaceOrCarriageReturnAtIndex:(NSUInteger)index
{
    unichar c = [self characterAtIndex:index];
    return ' ' == c || 0x000A == c;
}

- (NSString *)stringForTwitterTextEntityIntersectingRange:(NSRange)range
{
    NSArray<TwitterTextEntity *> *entities = [[TWTRSETweet twitterText] entitiesInText:self];
    for (TwitterTextEntity *entity in entities) {
        if (0 != NSIntersectionRange([(id)entity range], range).length) {
            return [self substringWithRange:[(id)entity range]];
        }
    }
    return nil;
}

@end
