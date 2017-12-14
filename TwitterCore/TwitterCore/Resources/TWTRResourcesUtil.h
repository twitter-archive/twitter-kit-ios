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
 This header is private to the Twitter Core SDK and not exposed for public SDK consumption
 */

#import <Foundation/Foundation.h>

#if IS_UIKIT_AVAILABLE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString *const TWTRResourcesUtilLanguageType;

@interface TWTRResourcesUtil : NSObject

/**
 *  Returns the bundle given its name. This is useful for retrieving any bundle and future refactoring
 *  such as when Digits has its own kit resources.
 *
 *  @param bundlePath path of the bundle e.g. TwitterKitResources.bundle
 *
 *  @return the bundle
 */
+ (NSBundle *)bundleWithBundlePath:(NSString *)bundlePath;

/**
 *  Retrieves the localized bundle of the given resource bundle.
 *
 *  @param bundle localized bundle
 *
 *  @return localized bundle
 */
+ (NSBundle *)localizedBundleWithBundle:(NSBundle *)bundle;

/**
 *  Retrieves the localized bundle for the given bundle path.
 *
 *  @param bundlePath path of the bundle e.g. TwitterKitResources.bundle
 *
 *  @return localized bundle in the given resource bundle path
 */
+ (NSBundle *)localizedBundleWithBundlePath:(NSString *)bundlePath;

/**
 *  Retrieves the localized string for the given key. If the string is not found in the right locale strings file, falls back to English.
 *
 *  @param key key for the desired localized string, e.g. "BUTTON_OKAY"
 *  @param bundlePath path of the bundle e.g. TwitterKitResources.bundle
 *
 *  @return localized string
 */
+ (NSString *)localizedStringForKey:(NSString *)key bundlePath:(NSString *)bundlePath;

/**
 *  Constructs the canonical user agent string based on
 *  kit info in the main bundle.
 *
 *  @return Kit user agent string for URL requests.
 */
+ (NSString *)userAgentFromKitBundle;

/**
 *  Returns the localized display name of the application.
 */
+ (NSString *)localizedApplicationDisplayName;

/**
 *  Returns the platform of the application.
 */
+ (NSString *)platform;

/**
 * Returns the screen scale of the application.
 */
+ (CGFloat)screenScale;

/**
 * Set the version of the parent Kit (Twitter Kit or Digits)
 */
+ (void)setKitVersion:(nullable NSString *)version;

@end

NS_ASSUME_NONNULL_END
