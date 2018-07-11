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

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@class TWTRSEThrottledProperty;

@protocol TWTRSEThrottledPropertyObserver <NSObject>

- (void)throttledProperty:(TWTRSEThrottledProperty *)throttledProperty didChangeValue:(nullable id)lastValue;

@end

/**
 Note: This class is NOT thread-safe.
 */
@interface TWTRSEThrottledProperty <T> : NSObject

- (instancetype)init NS_UNAVAILABLE;

/**
 A wrapper for a property that may change in quick succession, but whose values you're only interested in observing after it's settled for a certain interval.

 @param throttleInterval How long it has to pass after a value is received to notify about it.
 @param observer The delegate to receive throttled udpates for the values of the property. The delegate method will be called on the same queue the `lastValue` property is set on.
 */
- (instancetype)initWithThottleInterval:(NSTimeInterval)throttleInterval observer:(id<TWTRSEThrottledPropertyObserver>)observer;

@property (nonatomic, weak, nullable) id<TWTRSEThrottledPropertyObserver> observer;
@property (nonatomic, nullable) T lastValue;

@end

NS_ASSUME_NONNULL_END
