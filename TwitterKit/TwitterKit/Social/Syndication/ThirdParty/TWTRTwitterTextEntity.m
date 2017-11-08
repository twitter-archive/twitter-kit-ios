//
//  TwitterTextEntity.m
//
//  Copyright 2012-2014 Twitter, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import "TWTRTwitterTextEntity.h"

@implementation TWTRTwitterTextEntity

- (instancetype)initWithType:(TWTRTwitterTextEntityType)type range:(NSRange)range
{
    self = [super init];
    if (self) {
        _type = type;
        _range = range;
    }
    return self;
}

+ (instancetype)entityWithType:(TWTRTwitterTextEntityType)type range:(NSRange)range
{
    TWTRTwitterTextEntity *entity = [[self alloc] initWithType:type range:range];
#if !__has_feature(objc_arc)
    [entity autorelease];
#endif
    return entity;
}

- (NSComparisonResult)compare:(TWTRTwitterTextEntity *)right
{
    NSUInteger leftLocation = _range.location;
    NSUInteger leftLength = _range.length;
    NSRange rightRange = right.range;
    NSUInteger rightLocation = rightRange.location;
    NSUInteger rightLength = rightRange.length;

    if (leftLocation < rightLocation) {
        return NSOrderedAscending;
    } else if (leftLocation > rightLocation) {
        return NSOrderedDescending;
    } else if (leftLength < rightLength) {
        return NSOrderedAscending;
    } else if (leftLength > rightLength) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

- (NSString *)description
{
    NSString *typeString = nil;
    switch (_type) {
        case TWTRTwitterTextEntityURL:
            typeString = @"URL";
            break;
        case TWTRTwitterTextEntityScreenName:
            typeString = @"ScreenName";
            break;
        case TWTRTwitterTextEntityHashtag:
            typeString = @"Hashtag";
            break;
        case TWTRTwitterTextEntityListName:
            typeString = @"ListName";
            break;
        case TWTRTwitterTextEntitySymbol:
            typeString = @"Symbol";
            break;
    }
    return [NSString stringWithFormat:@"<%@: %@ %@>", NSStringFromClass([self class]), typeString, NSStringFromRange(_range)];
}

@end
