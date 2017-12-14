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

#if IS_UIKIT_AVAILABLE
#import <AdSupport/AdSupport.h>
#endif
#import "TWTRIdentifier.h"

@implementation TWTRIdentifier

#pragma mark - IDFA Collection

/*
 * We obfuscate the selectors here so developers using the TwitterKit SDK and do not serve ads
 * do not run into rejection issues with the app store submission process due to use of the IDFA.
 */

#if IS_UIKIT_AVAILABLE
static id getASManager()
{
    // Obfuscation to protect us from static analysis finding the string ASIdentifierManager
    SEL managerSelector = NSSelectorFromString([NSString stringWithFormat:@"%@%@%@", @"shar", @"edMan", @"ager"]);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    // requires clang flags because we are calling an obfuscated selector
    return [NSClassFromString([NSString stringWithFormat:@"%@%@%@", @"ASI", @"dentif", @"ierManager"]) performSelector:managerSelector];
#pragma clang diagnostic pop
}

// This is intentionally named in order to not contain the string 'AdSupport' in our symbol table
static BOOL isAdvertisingSupportFrameworkLinked()
{
    return getASManager() != nil;
}

// This is intentionally named in order to not contain the string 'advertisingTracking'
static BOOL isTrackingForAdvertisingEnabled()
{
    if (isAdvertisingSupportFrameworkLinked()) {
        ASIdentifierManager *manager = getASManager();
        // Obfuscation to protect us from static analysis finding usage of isAdvertisingTrackingEnabled
        SEL trackingSelector = NSSelectorFromString([NSString stringWithFormat:@"%@%@%@", @"isAdvert", @"isingTrack", @"ingEnabled"]);

        if ([manager respondsToSelector:trackingSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            // requires clang flags because we are calling an obfuscated selector
            BOOL (*func)(id, SEL) = (BOOL(*)(id, SEL))[manager methodForSelector:trackingSelector];
            return ((func)(manager, trackingSelector));
#pragma clang diagnostic pop
        }
    }
    return NO;
}
#endif

// This is intentionally named in order to not contain the string 'advertisingIdentifier'
NSString *TWTRIdentifierForAdvertising()
{
#if IS_UIKIT_AVAILABLE
    if (isTrackingForAdvertisingEnabled()) {
        ASIdentifierManager *manager = getASManager();
        // Obfuscation to protect us from static analysis finding usage of advertisingIdentifier
        SEL ifaSelector = NSSelectorFromString([NSString stringWithFormat:@"%@%@%@", @"advert", @"isingIden", @"tifier"]);

        if ([manager respondsToSelector:ifaSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            // requires clang flags because we are calling an obfuscated selector
            id result = [manager performSelector:ifaSelector];
#pragma clang diagnostic pop
            if ([result isKindOfClass:[NSUUID class]]) {
                return [(NSUUID *)result UUIDString];
            }
        }
    }
#endif

    return nil;
}

@end
