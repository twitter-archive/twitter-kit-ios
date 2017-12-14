//
//  TwitterTextEntity.h
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

typedef NS_ENUM(NSUInteger, TWTRTwitterTextEntityType) {
    TWTRTwitterTextEntityURL,
    TWTRTwitterTextEntityScreenName,
    TWTRTwitterTextEntityHashtag,
    TWTRTwitterTextEntityListName,
    TWTRTwitterTextEntitySymbol,
};

@interface TWTRTwitterTextEntity : NSObject

@property (nonatomic) TWTRTwitterTextEntityType type;
@property (nonatomic) NSRange range;

+ (instancetype)entityWithType:(TWTRTwitterTextEntityType)type range:(NSRange)range;

@end
