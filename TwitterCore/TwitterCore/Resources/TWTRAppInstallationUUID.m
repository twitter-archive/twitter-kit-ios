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

#import "TWTRAppInstallationUUID.h"

#pragma mark - Twitter UDID

static NSString *const TWTRInstallationUUIDKey = @"com.twitter.sdk.social.ios.iuuid";

@implementation TWTRAppInstallationUUID

+ (NSString *)appInstallationUUID
{
    @synchronized(self)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *iuuid = [userDefaults stringForKey:TWTRInstallationUUIDKey];

        if (!iuuid) {
            CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
            iuuid = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
            CFRelease(uuid);

            [userDefaults setObject:iuuid forKey:TWTRInstallationUUIDKey];
            [userDefaults synchronize];
        }

        return iuuid;
    }
}

@end
