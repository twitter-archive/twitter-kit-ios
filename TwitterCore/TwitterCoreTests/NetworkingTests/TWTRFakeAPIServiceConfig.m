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

#import "TWTRFakeAPIServiceConfig.h"

@implementation TWTRFakeAPIServiceConfig

- (NSString *)apiHost
{
    return @"api.sample.com";
}

- (NSString *)apiScheme
{
    return @"https";
}

- (NSString *)serviceName
{
    return @"api.sample.fake-api-service";
}

@end

@implementation TWTRRandomAPIServiceConfig {
    NSString *_uniqueIdentifier;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _uniqueIdentifier = [[NSUUID UUID] UUIDString];
    }
    return self;
}

- (NSString *)apiHost
{
    return [NSString stringWithFormat:@"api.%@.com", _uniqueIdentifier];
}

- (NSString *)apiScheme
{
    return @"https";
}

- (NSString *)serviceName
{
    return _uniqueIdentifier;
}

@end
