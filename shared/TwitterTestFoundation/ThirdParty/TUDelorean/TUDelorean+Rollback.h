//
//  TUDelorean+Rollback.h
//  TwitterKit
//
//  Created by Kang Chen on 2/5/15.
//  Copyright (c) 2015 Twitter. All rights reserved.
//

#import "TUDelorean.h"

/**
 *  Extends the default TUDelorean to automatically travel back to the present after executing
 *  time travel blocks.
 */
@interface TUDelorean (Rollback)

+ (void)timeTravelTo:(NSDate *)date block:(TUDeloreanBlock)block __attribute__((unavailable("Use method in temporarilyTimeTravelTo:block:")));
+ (void)temporarilyTimeTravelTo:(NSDate *)date block:(TUDeloreanBlock)block;
+ (void)jump:(NSTimeInterval)timeInterval block:(TUDeloreanBlock)block __attribute__((unavailable("Use method in temporarilyJump:block:")));
+ (void)temporarilyJump:(NSTimeInterval)timeInterval block:(TUDeloreanBlock)block;

@end
