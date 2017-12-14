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

#import "TWTRMoPubVersionChecker.h"
#import <MoPub/MoPub.h>
#import <math.h>

static NSInteger IntegerVersionFromStringVersion(NSString *version)
{
    NSMutableArray<NSString *> *versions = [[version componentsSeparatedByString:@"."] mutableCopy];
    // normalize parsed versions e.g. 4.0 -> 4.0.0
    for (NSUInteger i = 0; i < 3 - [versions count]; i++) {
        [versions addObject:@"0"];
    }

    __block NSInteger integerVersion = 0;
    [versions enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        const NSInteger parsedVersion = [obj integerValue];
        integerVersion += parsedVersion * pow(100, 2 - idx);  // e.g. X(major) x 100 ^ 2 = X0000
    }];
    return integerVersion;
}

NSUInteger TWTRMoPubMinimumRequiredVersion = 40600;  // 4.6.0

@implementation TWTRMoPubVersionChecker

+ (BOOL)isValidVersion
{
    return [self integerVersion] >= TWTRMoPubMinimumRequiredVersion;
}

+ (NSInteger)integerVersion
{
    // If MoPub is included in this application
    id mopubClass = NSClassFromString(@"MoPub");
    if (mopubClass) {
        // If MoPub is new enough to have the version instance method
        // implemented on [MoPub sharedInstance]
        id sharedMoPub = [mopubClass performSelector:@selector(sharedInstance)];
        if ([sharedMoPub respondsToSelector:@selector(version)]) {
            NSString *mopubVersionString = [sharedMoPub performSelector:@selector(version)];
            return IntegerVersionFromStringVersion(mopubVersionString);
        } else {
            NSLog(@"Twitter Kit requires MoPub version 4.6.0 and above.");
        }
    }
    return -1;
}

@end
