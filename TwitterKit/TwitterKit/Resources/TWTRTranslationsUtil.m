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

#import "TWTRTranslationsUtil.h"
#import <TwitterCore/TWTRResourcesUtil.h>
#import "TWTRConstants_Private.h"

NSString *TWTRLocalizedString(NSString *key)
{
    return [TWTRTranslationsUtil localizedStringForKey:key];
}

@implementation TWTRTranslationsUtil

+ (NSString *)localizedStringForKey:(NSString *)key
{
    return [TWTRResourcesUtil localizedStringForKey:key bundlePath:TWTRResourceBundleLocation];
}

+ (NSString *)accessibilityStringByConcatenatingItems:(NSArray *)stringArray
{
    NSMutableString *result = [NSMutableString string];
    BOOL firstString = YES;
    for (id obj in stringArray) {
        if ([obj isKindOfClass:[NSString class]]) {
            NSString *string = obj;
            if ([string length]) {
                NSString *trimmed = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([trimmed length]) {
                    if (!firstString) {
                        NSRange range = [result rangeOfCharacterFromSet:[NSCharacterSet punctuationCharacterSet] options:(NSBackwardsSearch | NSAnchoredSearch)];
                        if (range.location == NSNotFound) {
                            range = [result rangeOfString:@"." options:(NSBackwardsSearch | NSAnchoredSearch)];
                        }
                        if (range.location == NSNotFound) {
                            [result appendString:@"."];
                        }
                        [result appendString:@"\n"];
                    }

                    [result appendString:trimmed];
                    firstString = NO;
                }
            }
        }
    }
    return result;
}

@end
