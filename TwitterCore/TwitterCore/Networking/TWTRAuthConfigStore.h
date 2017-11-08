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

#import <Foundation/Foundation.h>
@class TWTRAuthConfig;

NS_ASSUME_NONNULL_BEGIN

@interface TWTRAuthConfigStore : NSObject

- (instancetype)init NS_UNAVAILABLE;

/**
 * Initializes the auth config store
 *
 * @param nameSpace the namespace to associate with this store.
 */
- (instancetype)initWithNameSpace:(NSString *)nameSpace;

/**
 * Saves the given auth config replacing the last saved config.
 */
- (void)saveAuthConfig:(TWTRAuthConfig *)authConfig;

/**
 * Returns the auth config object that was last saved or nil
 * if there is none.
 */
- (nullable TWTRAuthConfig *)lastSavedAuthConfig;

/**
 * Removes the last saved auth config.
 */
- (void)forgetAuthConfig;

@end

NS_ASSUME_NONNULL_END
