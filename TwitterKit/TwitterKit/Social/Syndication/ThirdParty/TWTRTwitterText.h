//
//  TwitterText.h
//
//  Copyright 2012-2014 Twitter, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

/**
 This header is private to the Twitter Kit SDK and not exposed for public SDK consumption
 */

#import <Foundation/Foundation.h>
#import "TWTRTwitterTextEntity.h"

@interface TWTRTwitterText : NSObject

+ (NSArray *)entitiesInText:(NSString *)text;
+ (NSArray *)URLsInText:(NSString *)text;
+ (NSArray *)hashtagsInText:(NSString *)text checkingURLOverlap:(BOOL)checkingURLOverlap;
+ (NSArray *)symbolsInText:(NSString *)text checkingURLOverlap:(BOOL)checkingURLOverlap;
+ (NSArray *)mentionedScreenNamesInText:(NSString *)text;
+ (NSArray *)mentionsOrListsInText:(NSString *)text;
+ (TWTRTwitterTextEntity *)repliedScreenNameInText:(NSString *)text;

+ (NSCharacterSet *)validHashtagBoundaryCharacterSet;

+ (NSUInteger)tweetLength:(NSString *)text;
+ (NSUInteger)tweetLength:(NSString *)text httpURLLength:(NSUInteger)httpURLLength httpsURLLength:(NSUInteger)httpsURLLength;

+ (NSInteger)remainingCharacterCount:(NSString *)text;
+ (NSInteger)remainingCharacterCount:(NSString *)text httpURLLength:(NSUInteger)httpURLLength httpsURLLength:(NSUInteger)httpsURLLength;

@end
