//
//  TUDelorean+Rollback.m
//  TwitterKit
//
//  Created by Kang Chen on 2/5/15.
//  Copyright (c) 2015 Twitter. All rights reserved.
//

#import "TUDelorean+Rollback.h"

@implementation TUDelorean (Rollback)

+ (void)temporarilyTimeTravelTo:(NSDate *)date block:(TUDeloreanBlock)block {
    [TUDelorean timeTravelTo:date block:block];
    [TUDelorean backToThePresent];
}

+ (void)temporarilyJump:(NSTimeInterval)timeInterval block:(TUDeloreanBlock)block {
    [TUDelorean jump:timeInterval block:block];
    [TUDelorean backToThePresent];
}

@end
