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

#import "TWTRSEThrottledProperty.h"

@interface TWTRSEThrottledProperty ()

@property (nonatomic, readonly) NSTimeInterval throttleInterval;

@property (nonatomic, nullable) NSTimer *timer;

@end

@implementation TWTRSEThrottledProperty

- (instancetype)initWithThottleInterval:(NSTimeInterval)throttleInterval observer:(nonnull id<TWTRSEThrottledPropertyObserver>)observer
{
    NSParameterAssert(observer);

    if ((self = [super init])) {
        _throttleInterval = throttleInterval;
        _observer = observer;
    }

    return self;
}

- (void)_tseui_throttledPropertyTimerFired:(NSTimer *)timer
{
    [_observer throttledProperty:self didChangeValue:timer.userInfo];
    _timer = nil;
}

- (void)setLastValue:(id)lastValue
{
    _lastValue = lastValue;
    [_timer invalidate];

    // - scheduledTimerWithTimeInterval:target:selector:userInfo:repeats: required to support iOS 9
    // - 'self' and 'lastValue' will be held strongly by timer until it is invalidated ... and it will
    //   invalidate itself when fired the first time because of repeats:NO .
    _timer = [NSTimer scheduledTimerWithTimeInterval:_throttleInterval target:self selector:@selector(_tseui_throttledPropertyTimerFired:) userInfo:lastValue repeats:NO];
}

@end
