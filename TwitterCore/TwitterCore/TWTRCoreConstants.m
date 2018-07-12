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

#import "TWTRCoreConstants.h"

#define TWC_SDK_BUNDLE_ID TWC_STR(TWC_BUNDLE_IDENTIFIER)

NSString *const TWTRCoreVersion = @"3.2.0";
NSString *const TWTRCoreBundleID = @TWC_SDK_BUNDLE_ID;

NSString *const TWTRTwitterCoreVersion = @TWC_STR(DISPLAY_VERSION);
NSString *const TWTRTwitterCoreBuildNumber = @TWC_STR(BUILD_VERSION);

@interface TWTRCore : NSObject

@end

@implementation TWTRCore

+ (NSString *)bundleIdentifier
{
    return TWTRCoreBundleID;
}

+ (NSString *)kitDisplayVersion
{
    return TWTRCoreVersion;
}

@end
