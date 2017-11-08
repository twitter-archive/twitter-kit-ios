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

#import "TWTRNetworkingPipelinePackage.h"
#import <TwitterCore/TWTRAssertionMacros.h>

@interface TWTRNetworkingPipelinePackage ()
@property (nonatomic, readwrite) NSInteger attemptCounter;
@end

@implementation TWTRNetworkingPipelinePackage

- (instancetype)initWithRequest:(NSURLRequest *)request sessionStore:(id<TWTRSessionStore>)sessionStore userID:(NSString *)userID completion:(TWTRNetworkingPipelineCallback)callback
{
    TWTRParameterAssertOrReturnValue(request, nil);
    TWTRParameterAssertOrReturnValue(sessionStore, nil);

    self = [super init];
    if (self) {
        _request = [request copy];
        _sessionStore = sessionStore;
        _userID = [userID copy];
        _callback = [callback copy];
        _attemptCounter = 1;  // starts with 1
        _UUID = [NSUUID UUID];
    }
    return self;
}

- (instancetype)copyForRetry
{
    TWTRNetworkingPipelinePackage *newCopy = [self copy];

    newCopy.attemptCounter = _attemptCounter + 1;
    return newCopy;
}

+ (instancetype)packageWithRequest:(NSURLRequest *)request sessionStore:(id<TWTRSessionStore>)sessionStore userID:(NSString *)userID completion:(TWTRNetworkingPipelineCallback)callback
{
    return [[self alloc] initWithRequest:request sessionStore:sessionStore userID:userID completion:callback];
}

- (id)copyWithZone:(NSZone *)zone
{
    TWTRNetworkingPipelinePackage *copy = [[TWTRNetworkingPipelinePackage alloc] initWithRequest:_request sessionStore:_sessionStore userID:_userID completion:_callback];
    copy->_UUID = self.UUID;
    return copy;
}

@end
