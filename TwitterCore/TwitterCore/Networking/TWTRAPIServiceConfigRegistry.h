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
#import "TWTRAPIServiceConfig.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TWTRAPIServiceConfigType) { TWTRAPIServiceConfigTypeDefault, TWTRAPIServiceConfigTypeCards, TWTRAPIServiceConfigTypeUpload };

@interface TWTRAPIServiceConfigRegistry : NSObject

/**
 * Returns the default registry instance.
 */
+ (instancetype)defaultRegistry;

/**
 * Registers a service config with the receiver.
 *
 * @param config the config object to register.
 * @param type the type of config object to register.
 */
- (void)registerServiceConfig:(id<TWTRAPIServiceConfig>)config forType:(TWTRAPIServiceConfigType)type;

/**
 * Returns a config object that has been registered for the given type or nil if nothing has been registered.
 */
- (nullable id<TWTRAPIServiceConfig>)configForType:(TWTRAPIServiceConfigType)type;

@end

NS_ASSUME_NONNULL_END
