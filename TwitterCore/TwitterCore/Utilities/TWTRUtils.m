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

#import "TWTRUtils.h"
#import <Foundation/Foundation.h>

@implementation TWTRUtils

+ (NSDictionary *)dictionaryWithQueryString:(NSString *)queryString
{
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
    NSArray *keyValues = [queryString componentsSeparatedByString:@"&"];
    for (NSString *keyValue in keyValues) {
        NSArray *elements = [keyValue componentsSeparatedByString:@"="];
        if (elements.count == 2) {
            NSString *key = elements[0];
            NSString *value = elements[1];
            key = [self urlDecodedStringForString:key];
            value = [self urlDecodedStringForString:value];
            mutableDictionary[key] = value;
        }
    }
    return mutableDictionary;
}

+ (NSString *)queryStringFromDictionary:(NSDictionary *)dictionary
{
    NSMutableArray *pairs = [NSMutableArray array];
    for (NSString *key in [dictionary keyEnumerator]) {
        id value = [dictionary objectForKey:key];
        NSString *escapedValue = [self urlEncodedStringForString:value];
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escapedValue]];
    }
    return [pairs componentsJoinedByString:@"&"];
}

+ (NSString *)urlEncodedStringForString:(NSString *)inputString
{
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[inputString UTF8String];
    NSUInteger sourceLen = strlen((const char *)source);
    for (NSUInteger i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' || (thisChar >= 'a' && thisChar <= 'z') || (thisChar >= 'A' && thisChar <= 'Z') || (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

+ (NSString *)urlDecodedStringForString:(NSString *)inputString
{
    return [inputString stringByRemovingPercentEncoding];
}

+ (NSString *)base64EncodedStringWithData:(NSData *)data
{
    return [data base64EncodedStringWithOptions:0];  // 0 => Don't insert newlines into encoded string
}

#if IS_UIKIT_AVAILABLE
+ (UIWindow *)mainAppWindow
{
    id<UIApplicationDelegate> appDelegate = [UIApplication sharedApplication].delegate;
    if ([appDelegate respondsToSelector:@selector(window)] && appDelegate.window != nil) {
        return appDelegate.window;
    } else {
        return [UIApplication sharedApplication].keyWindow;
    }
}

+ (UIViewController *)topViewController
{
    return [self.class topViewControllerWithRootViewController:[self mainAppWindow].rootViewController];
}

+ (UIViewController *)topViewControllerWithRootViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController) {
        UIViewController *presentedViewController = rootViewController.presentedViewController;
        return [self.class topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}
#endif

+ (NSString *)localizedLongAppName
{
    NSString *name = [[NSBundle mainBundle] localizedInfoDictionary][@"CFBundleDisplayName"] ?: [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"] ?: [[NSProcessInfo processInfo] processName];
    return name;
}

+ (NSString *)localizedShortAppName
{
    NSString *name = [[NSBundle mainBundle] localizedInfoDictionary][@"CFBundleName"] ?: [[NSBundle mainBundle] infoDictionary][@"CFBundleName"] ?: [TWTRUtils localizedLongAppName];
    return name;
}

+ (BOOL)isEqualOrBothNil:(NSObject *)obj other:(NSObject *)otherObj
{
    if (obj == nil && otherObj == nil) {
        return YES;
    } else {
        return [obj isEqual:otherObj];
    }
}

@end
