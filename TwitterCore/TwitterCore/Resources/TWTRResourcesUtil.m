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

#include <sys/sysctl.h>

#import "TWTRCoreConstants.h"
#import "TWTRCoreLanguage.h"
#import "TWTRResourcesUtil_Private.h"

NSString *const TWTRResourcesUtilLanguageType = @"lproj";
NSString *const TWTRResourcesUtilFallbackLanguage = @"en";
NSString *const TWTRResourcesUtilDefaultValue = @"com.twitter.resourcesutil.default_value";
static NSString *kitVersion;

@implementation TWTRResourcesUtil

+ (NSBundle *)bundleWithBundlePath:(NSString *)bundlePath
{
    NSString *bundleName = [bundlePath stringByDeletingPathExtension];
    NSString *bundleType = [bundlePath pathExtension];

    // Doing [self class] here so it works across targets. Otherwise kitBundle might not be what
    // you expect
    NSBundle *bundle1 = [NSBundle bundleForClass:[self class]];
    NSBundle *bundle = [NSBundle bundleWithPath:[bundle1 pathForResource:bundleName ofType:bundleType]];
    return bundle;
}

+ (NSBundle *)localizedBundleWithBundle:(NSBundle *)bundle
{
    NSString *language = [TWTRCoreLanguage preferredLanguage];
    return [NSBundle bundleWithPath:[bundle pathForResource:language ofType:TWTRResourcesUtilLanguageType]];
}

+ (NSBundle *)localizedBundleWithBundlePath:(NSString *)bundlePath
{
    NSBundle *bundle = [TWTRResourcesUtil bundleWithBundlePath:bundlePath];
    NSBundle *localizedBundle = [TWTRResourcesUtil localizedBundleWithBundle:bundle];
    if (localizedBundle == nil) {
        localizedBundle = bundle;
    }
    return localizedBundle;
}

+ (NSString *)localizedStringForKey:(NSString *)key bundlePath:(NSString *)bundlePath
{
    NSBundle *localizedBundle = [TWTRResourcesUtil localizedBundleWithBundlePath:bundlePath];
    NSString *localizedString = [localizedBundle localizedStringForKey:key value:TWTRResourcesUtilDefaultValue table:nil];
    if (localizedString == nil || [localizedString isEqualToString:TWTRResourcesUtilDefaultValue]) {
        NSAssert(false, @"Could not find key '%@' in current locale bundle", key);
        NSBundle *kitBundle = [TWTRResourcesUtil bundleWithBundlePath:bundlePath];
        NSString *fallbackBundlePath = [kitBundle pathForResource:TWTRResourcesUtilFallbackLanguage ofType:TWTRResourcesUtilLanguageType];
        NSBundle *fallbackBundle = [NSBundle bundleWithPath:fallbackBundlePath];
        localizedString = [fallbackBundle localizedStringForKey:key value:nil table:nil];
    }
    return localizedString;
}

+ (CGFloat)screenScale
{
#if TARGET_OS_WATCH
    return 1.0;
#elif IS_UIKIT_AVAILABLE
    return [[UIScreen mainScreen] scale];
#else
    return [[NSScreen mainScreen] backingScaleFactor];
#endif
}

+ (NSString *)deviceModel
{
    NSString *model = nil;

#if TARGET_OS_SIMULATOR
#if TARGET_OS_WATCH
    model = @"watchOS Simulator";
#elif TARGET_OS_TV
    model = @"tvOS Simulator";
#elif TARGET_OS_IPHONE
    switch (UI_USER_INTERFACE_IDIOM()) {
        case UIUserInterfaceIdiomPhone:
            model = @"iOS Simulator (iPhone)";
            break;
        case UIUserInterfaceIdiomPad:
            model = @"iOS Simulator (iPad)";
            break;
        default:
            model = @"iOS Simulator (Unknown)";
            break;
    }
#endif
#elif TARGET_OS_EMBEDDED
    model = [self hostSysctlEntry:"hw.machine"];
#else
    model = [self hostSysctlEntry:"hw.model"];
#endif

    return model;
}

+ (NSString *)OSVersionString
{
#if TARGET_OS_TV
    NSString *name = @"tvOS";
#elif TARGET_OS_WATCH
    NSString *name = @"watchOS";
#elif TARGET_OS_IOS
    NSString *name = @"iOS";
#else
    NSString *name = @"OS X";
#endif

    NSOperatingSystemVersion version = [self hostGetOSVersion];
    NSString *hostOSDisplayVersion = [NSString stringWithFormat:@"%ld.%ld.%ld", (long)version.majorVersion, (long)version.minorVersion, (long)version.patchVersion];

    return [NSString stringWithFormat:@"%@ %@ (%@)", name, hostOSDisplayVersion, [self hostOSBuildVersion]];
}

+ (NSString *)platform
{
#if TARGET_OS_TV
    NSString *name = @"tvOS";
#elif TARGET_OS_WATCH
    NSString *name = @"watchOS";
#elif TARGET_OS_IOS
    NSString *name = @"iOS";
#else
    NSString *name = @"OS X";
#endif

    return name;
}

+ (void)setKitVersion:(NSString *)version
{
    kitVersion = version;
}

+ (NSString *)userAgentFromKitBundle
{
    NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleExecutableKey];
    NSString *applicationVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey];
    NSString *deviceModel = [self deviceModel];
    NSString *systemVersion = [self OSVersionString];
    NSString *platform = [self platform];
    CGFloat screenScale = [self screenScale];

    NSString *version = kitVersion ?: TWTRCoreVersion;

    // We can change this string more fully after the Fabric TSA period ends.
    return [NSString stringWithFormat:@"Fabric/X.Y.Z (%@/%@; %@; %@ %@; Scale/%0.2f) TwitterKit/%@", applicationName, applicationVersion, deviceModel, systemVersion, platform, screenScale, version];
}

+ (NSString *)localizedApplicationDisplayName;
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleNameKey];
}

+ (NSOperatingSystemVersion)hostGetOSVersion
{
    // works on 10.10/8.0
    if ([NSProcessInfo.processInfo respondsToSelector:@selector(operatingSystemVersion)]) {
        return [NSProcessInfo.processInfo operatingSystemVersion];
    }

    NSOperatingSystemVersion version = {0, 0, 0};

#if TARGET_OS_IPHONE

#if TARGET_OS_WATCH
    NSString *versionString = [[WKInterfaceDevice currentDevice] systemVersion];
#else
    NSString *versionString = [[UIDevice currentDevice] systemVersion];
#endif

    NSArray *parts = [versionString componentsSeparatedByString:@"."];

    if (parts.count > 0) {
        version.majorVersion = [[parts objectAtIndex:0] integerValue];
    }

    if ([parts count] > 1) {
        version.minorVersion = [[parts objectAtIndex:1] integerValue];
    }

    if ([parts count] > 2) {
        version.patchVersion = [[parts objectAtIndex:2] integerValue];
    }

#else

    SInt32 major, minor, bugfix;

    major = 10;
    minor = 0;
    bugfix = 0;
    if (Gestalt(gestaltSystemVersionMajor, &major) != noErr) {
        //  CLSSDKLog("Unable to determine OS version\n");
    }

    if (Gestalt(gestaltSystemVersionMinor, &minor) != noErr) {
        //  CLSSDKLog("Unable to determine OS version\n");
    }

    if (Gestalt(gestaltSystemVersionBugFix, &bugfix) != noErr) {
        //   CLSSDKLog("Unable to determine OS version\n");
    }

    version.majorVersion = major;
    version.minorVersion = minor;
    version.patchVersion = bugfix;

#endif

    return version;
}

+ (NSString *)hostOSBuildVersion
{
    return [self hostSysctlEntry:"kern.osversion"];
}

#define FAB_HOST_SYSCTL_BUFFER_SIZE (128)

+ (NSString *)hostSysctlEntry:(const char *)sysctlKey
{
    char buffer[FAB_HOST_SYSCTL_BUFFER_SIZE];
    size_t bufferSize = FAB_HOST_SYSCTL_BUFFER_SIZE;
    if (sysctlbyname(sysctlKey, buffer, &bufferSize, NULL, 0) != 0) {
        return nil;
    }
    return [NSString stringWithUTF8String:buffer];
}

@end
