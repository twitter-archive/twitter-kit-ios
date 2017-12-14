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

#import "TWTRStringUtil.h"
#import <CoreText/CoreText.h>

@implementation TWTRStringUtil

+ (NSString *)stringByReplacingLastOccurrenceOfString:(NSString *)target withString:(NSString *)replacement inStringIgnoringExtension:(NSString *)original
{
    // Create a regular expression
    BOOL isCaseSensitive = NO;

    NSError *error = NULL;
    NSRegularExpressionOptions regexOptions = isCaseSensitive ? 0 : NSRegularExpressionCaseInsensitive;

    // Look for the pattern while ignoring extensions
    NSString *pattern = [NSString stringWithFormat:@"%@(\\..+$)", target];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:regexOptions error:&error];
    if (error) {
        return nil;
    }

    // Matching the entire string
    NSRange range = NSMakeRange(0, original.length);

    // Bringing the extension back in the replacement
    NSString *replacementString = [NSString stringWithFormat:@"%@$1", replacement];

    return [regex stringByReplacingMatchesInString:original options:0 range:range withTemplate:replacementString];
}

#pragma mark - NSString+TFNAdditions

+ (BOOL)stringContainsOnlyNumbers:(NSString *)string
{
    NSUInteger len = string.length;
    if (len == 0) {
        return NO;
    }

    UniChar buffer[len];
    [string getCharacters:buffer];

    for (int i = 0; i < len; i++) {
        UniChar c = buffer[i];
        if (!('0' <= c && c <= '9')) {
            return NO;
        }
    }

    return YES;
}

+ (BOOL)stringContainsOnlyHexNumbers:(NSString *)string
{
    NSUInteger len = string.length;
    if (len == 0) {
        return NO;
    }

    UniChar buffer[len];
    [string getCharacters:buffer];

    for (int i = 0; i < len; i++) {
        UniChar c = buffer[i];
        if (!(('0' <= c && c <= '9') || ('a' <= c && c <= 'f') || ('A' <= c && c <= 'F'))) {
            return NO;
        }
    }

    return YES;
}

+ (NSInteger)hexIntegerValueWithString:(NSString *)string
{
    NSUInteger len = string.length;
    if (len == 0) {
        return 0;
    }

    NSInteger result = 0;
    UniChar buffer[len];
    [string getCharacters:buffer];

    for (int i = 0; i < len; i++) {
        UniChar c = buffer[i];
        int num = 0;
        if ('0' <= c && c <= '9') {
            num = c - '0';
        } else if ('a' <= c && c <= 'f') {
            num = c - 'a' + 10;
        } else if ('A' <= c && c <= 'F') {
            num = c - 'A' + 10;
        } else {
            break;
        }
        result *= 16;
        result += num;
    }

    return result;
}

+ (nullable NSString *)displayStringFromTimeInterval:(NSTimeInterval)interval
{
    if (interval < 0) {
        return nil;
    }

    NSInteger roundedInterval = round(interval);
    NSInteger minutes = roundedInterval / 60;
    NSInteger seconds = roundedInterval % 60;

    return [NSString stringWithFormat:@"%td:%02td", minutes, seconds];
}

+ (NSString *)previewTextFromFullText:(NSString *)fullText previewLength:(NSInteger)length
{
    /// TODO: We don't have a great way of seeing if the API actually returns the text in preview mode vs.
    /// compact mode yet. When in compact mode it still returns the preview_text_length field even though
    /// it may actually be longer than the actual text length. When the API is updated and we can have
    /// more confidence in the preview_length we can remove this check.
    NSInteger actualLength = [fullText rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, fullText.length)].length;
    if (actualLength <= length) {
        return fullText;
    }

    NSRange range = NSMakeRange(0, length);
    NSRange composedRange = [fullText rangeOfComposedCharacterSequencesForRange:range];
    return [fullText substringWithRange:composedRange];
}

@end
