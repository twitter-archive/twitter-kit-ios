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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * SecItem methods are wrapped so they can be mocked in unit tests using OCMock because the behaviour of
 * these methods is inconsistent in a testing environment.
 */
@interface TWTRSecItemWrapper : NSObject

/**
 * Calls SecItemAdd()
 */
+ (OSStatus)secItemAdd:(CFDictionaryRef)attributes withResult:(CFTypeRef *__nullable CF_RETURNS_RETAINED)result;

/**
 * Calls SecItemDelegate()
 */
+ (OSStatus)secItemDelete:(CFDictionaryRef)query;

/**
 * Calls SecItemCopyMatching()
 */
+ (OSStatus)secItemCopyMatching:(CFDictionaryRef)query withResult:(CFTypeRef *__nullable CF_RETURNS_RETAINED)result;

/**
 * Calls SecItemUpdate()
 */
+ (OSStatus)secItemUpdate:(CFDictionaryRef)query withAttributes:(CFDictionaryRef)attributes;

@end

NS_ASSUME_NONNULL_END
