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

#import "TWTRAPIServiceConfigRegistry.h"
#import "TWTRAssertionMacros.h"

@interface TWTRAPIServiceConfigRegistry ()

@property (nonatomic, readonly) NSMutableDictionary *registeredConfigs;

@end

@implementation TWTRAPIServiceConfigRegistry

+ (instancetype)defaultRegistry
{
    static TWTRAPIServiceConfigRegistry *registry = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        registry = [[TWTRAPIServiceConfigRegistry alloc] init];
    });
    return registry;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _registeredConfigs = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)registerServiceConfig:(id<TWTRAPIServiceConfig>)config forType:(TWTRAPIServiceConfigType)type
{
    TWTRParameterAssertOrReturn(config);
    self.registeredConfigs[@(type)] = config;
}

- (nullable id<TWTRAPIServiceConfig>)configForType:(TWTRAPIServiceConfigType)type
{
    return self.registeredConfigs[@(type)];
}

@end
