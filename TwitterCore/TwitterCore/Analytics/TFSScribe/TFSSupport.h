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

#ifndef TFSScribe_TFSSupport_h
#define TFSScribe_TFSSupport_h

/**
 *  Twitter Foundation Assert macros:
 *
 *  TFNAssert : assert - when the condition isn't met, throws an exception. Only compiled for EMPLOYEE_BUILD builds
 *
 *  TFNAssertMainThread : Assert that you are on the main thread.
 *  TFNAssertNotMainThread : Assert that you are NOT on the main thread.
 *  TFNAssertNever : Always triggered assert.  Use this when a line of code should be unreachable.
 *
 *  TFNStaticAssert : Assert via the compiler. This will prevent build from succeeding when the condition fails.
 */

#ifndef TFNASSERT_ENABLED
#if EMPLOYEE_BUILD
#define TFNASSERT_ENABLED 1
#endif
#endif

#if TFNASSERT_ENABLED
#define TFNAssert(condition) NSCAssert((condition), @"assertion failed: " #condition)
#else
#define TFNAssert(condition) ((void)0)
#endif

#define TFNAssertMainThread() TFNAssert([NSThread isMainThread])
#define TFNAssertNotMainThread() TFNAssert(![NSThread isMainThread])
#define TFNAssertNever() TFNAssert(0 && "this line should never get executed")

// NOTE: TFNStaticAssert's msg argument should be valid as a variable.  That is, composed of ASCII letters, numbers and underscore characters only.
#if __has_feature(c_static_assert)
#define TFNStaticAssert(condition, msg) _Static_assert((condition), "static assertion failed: " #condition " - " #msg)
#else
#define __TFNStaticAssert(line, msg) TFNStaticAssert_##line##_##msg
#define _TFNStaticAssert(line, msg) __TFNStaticAssert(line, msg)
#define TFNStaticAssert(condition, msg) typedef char _TFNStaticAssert(__LINE__, msg)[(condition) ? 1 : -1]
#endif

#endif
