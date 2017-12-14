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

#if IS_UIKIT_AVAILABLE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

@interface TWTRUtils : NSObject

+ (NSDictionary *)dictionaryWithQueryString:(NSString *)queryString;
+ (NSString *)queryStringFromDictionary:(NSDictionary *)dictionary;
+ (NSString *)urlEncodedStringForString:(NSString *)inputString;
+ (NSString *)urlDecodedStringForString:(NSString *)inputString;
+ (NSString *)base64EncodedStringWithData:(NSData *)data;
#if IS_UIKIT_AVAILABLE
+ (UIViewController *)topViewController;
#endif
+ (NSString *)localizedLongAppName;
+ (NSString *)localizedShortAppName;

/**
 * Returns YES if both objects are nil or if obj.
 */
+ (BOOL)isEqualOrBothNil:(NSObject *)obj other:(NSObject *)otherObj;

@end
