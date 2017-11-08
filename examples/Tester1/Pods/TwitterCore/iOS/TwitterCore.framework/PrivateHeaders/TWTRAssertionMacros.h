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

#import <TwitterCore/TWTRConstants.h>

#ifdef __OBJC__

#define TWTRParameterAssertSettingError(condition, errorPointer)                                                                                                                                                 \
    NSParameterAssert((condition));                                                                                                                                                                              \
    if (!(condition)) {                                                                                                                                                                                          \
        NSLog(@"[TwitterKit] %@ Invalid parameter not satisfying: %s", NSStringFromSelector(_cmd), #condition);                                                                                                  \
        if (errorPointer != NULL) {                                                                                                                                                                              \
            *errorPointer = [NSError errorWithDomain:TWTRErrorDomain code:TWTRErrorCodeMissingParameter userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Missing parameter %s", #condition]}]; \
        }                                                                                                                                                                                                        \
    }

#define TWTRParameterAssertOrReturnValue(condition, returnValue)                                                \
    NSParameterAssert((condition));                                                                             \
    if (!(condition)) {                                                                                         \
        NSLog(@"[TwitterKit] %@ Invalid parameter not satisfying: %s", NSStringFromSelector(_cmd), #condition); \
        return returnValue;                                                                                     \
    }

#define TWTRParameterAssertOrReturnNil(condition)                                                               \
    NSParameterAssert((condition));                                                                             \
    if (!(condition)) {                                                                                         \
        NSLog(@"[TwitterKit] %@ Invalid parameter not satisfying: %s", NSStringFromSelector(_cmd), #condition); \
        return nil;                                                                                             \
    }

#define TWTRParameterAssertOrReturn(condition)                                                                  \
    NSParameterAssert((condition));                                                                             \
    if (!(condition)) {                                                                                         \
        NSLog(@"[TwitterKit] %@ Invalid parameter not satisfying: %s", NSStringFromSelector(_cmd), #condition); \
        return;                                                                                                 \
    }

#define TWTRAssertMainThread()                                                                         \
    if (![NSThread isMainThread]) {                                                                    \
        [NSException raise:NSInternalInconsistencyException format:@"Need to be on the main thread."]; \
        return;                                                                                        \
    }

// Check a single argument, and call a completion block if it's missing
#define TWTRCheckArgumentWithCompletion(condition, completion)     \
    TWTRParameterAssertOrReturn(completion);                       \
    NSError *parameterError;                                       \
    TWTRParameterAssertSettingError((condition), &parameterError); \
    if (parameterError) {                                          \
        completion(nil, nil, parameterError);                      \
        return;                                                    \
    }

#define TWTRCheckArgumentWithCompletion2(condition, completion)    \
    TWTRParameterAssertOrReturn(completion);                       \
    NSError *parameterError;                                       \
    TWTRParameterAssertSettingError((condition), &parameterError); \
    if (parameterError) {                                          \
        completion(nil, parameterError);                           \
        return;                                                    \
    }

#endif
