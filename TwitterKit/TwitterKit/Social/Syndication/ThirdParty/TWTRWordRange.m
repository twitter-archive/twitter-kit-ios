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

#import "TWTRWordRange.h"
#import <CoreFoundation/CFStringTokenizer.h>
#import <Foundation/Foundation.h>

#define kUnicodeALM ((unichar)0x061C)
#define kUnicodeLRM ((unichar)0x200E)
#define kUnicodeRLM ((unichar)0x200F)
#define kUnicodeLRE ((unichar)0x202A)
#define kUnicodeRLE ((unichar)0x202B)
#define kUnicodePDF ((unichar)0x202C)
#define kUnicodeLRO ((unichar)0x202D)
#define kUnicodeRLO ((unichar)0x202E)
#define kUnicodeLRI ((unichar)0x2066)
#define kUnicodeRLI ((unichar)0x2067)
#define kUnicodeFSI ((unichar)0x2068)
#define kUnicodePDI ((unichar)0x2069)
#define kUnicodeIdeographicSpace ((unichar)0x3000)

extern unichar UnicodeLRM;

NS_INLINE BOOL UnicodeIsDirectionControlCharacter(UniChar c)
{
    return c == kUnicodeALM || c == kUnicodeLRM || c == kUnicodeRLM || (kUnicodeLRE <= c && c <= kUnicodeRLO) || (kUnicodeLRI <= c && c <= kUnicodePDI);
}

@implementation NSString (TWTRWordRange)

#pragma mark private

- (NSRange)_tfs_wordRangeExpandLeft:(NSRange)currentRange
{
    NSInteger index = currentRange.location - 1;
    if ((index < 0) || ((NSUInteger)index >= self.length)) {
        return currentRange;
    }

    while ((index >= 0) && ([self characterAtIndex:index] == '_')) {
        index--;
        currentRange.location--;
        currentRange.length++;
    }

    NSRange previousRange = [self wordRangeForIndex:index];
    if ((previousRange.location == NSNotFound) || (previousRange.location >= currentRange.location)) {
        return currentRange;
    }
    NSRange newRange = NSMakeRange(previousRange.location, currentRange.location + currentRange.length - previousRange.location);

    return [self _tfs_wordRangeExpandLeft:newRange];
}

- (NSRange)_tfs_wordRangeExpandRight:(NSRange)currentRange
{
    NSInteger index = currentRange.location + currentRange.length;
    if ((index < 0) || ((NSUInteger)index >= self.length)) {
        return currentRange;
    }

    while (((NSUInteger)index < self.length) && ([self characterAtIndex:index] == '_')) {
        index++;
        currentRange.length++;
    }

    NSRange nextRange = [self wordRangeForIndex:index];
    if ((nextRange.location == NSNotFound) || ((nextRange.location + nextRange.length) <= (currentRange.location + currentRange.length))) {
        return currentRange;
    }
    NSRange newRange = NSMakeRange(currentRange.location, nextRange.location + nextRange.length - currentRange.location);

    return [self _tfs_wordRangeExpandRight:newRange];
}

#pragma mark public

- (NSRange)wordRangeForIndex:(NSInteger)index
{
    static CFStringTokenizerRef tokenizer = NULL;
    if (!tokenizer) {
        // shared tokenizer
        tokenizer = CFStringTokenizerCreate(NULL, (CFStringRef) @"", CFRangeMake(0, 0), kCFStringTokenizerUnitWord, NULL);
    }

    if (index < 0 || (NSUInteger)index > self.length) {
        return NSMakeRange(NSNotFound, 0);
    }

    if ((NSUInteger)index < self.length) {
        // Ignore Unicode direction characters
        while (index >= 0) {
            UniChar c = [self characterAtIndex:index];
            if (!UnicodeIsDirectionControlCharacter(c)) {
                break;
            }
            index--;
        }
    }

    NSInteger maxWordLength = 20;  // limit search

    CFIndex tokenizerStart = MAX(index - maxWordLength, 0);
    CFIndex tokenizerEnd = MIN(index + maxWordLength, (CFIndex)self.length);
    CFRange tokenizerRange = CFRangeMake(tokenizerStart, tokenizerEnd - tokenizerStart);
    NSRange range = NSMakeRange(NSNotFound, 0);
    CFStringTokenizerSetString(tokenizer, (__bridge CFStringRef)self, tokenizerRange);
    CFStringTokenizerTokenType r = CFStringTokenizerGoToTokenAtIndex(tokenizer, index);
    if ((r == kCFStringTokenizerTokenNormal) || (r & kCFStringTokenizerTokenHasSubTokensMask)) {
        CFRange cfRange = CFStringTokenizerGetCurrentTokenRange(tokenizer);
        range.location = cfRange.location;
        range.length = cfRange.length;
    }

    return range;
}

- (NSRange)wordRangeIncludingUnderscoreForIndex:(NSInteger)index
{
    NSRange wordRange = [self wordRangeForIndex:index];
    if ((wordRange.location == NSNotFound) && (index >= 0) && ((NSUInteger)index < self.length) && ([self characterAtIndex:index] == '_')) {
        wordRange = NSMakeRange(index, 1);
    }
    if (wordRange.location != NSNotFound) {
        wordRange = [self _tfs_wordRangeExpandLeft:wordRange];
        wordRange = [self _tfs_wordRangeExpandRight:wordRange];
    }
    return wordRange;
}

@end
