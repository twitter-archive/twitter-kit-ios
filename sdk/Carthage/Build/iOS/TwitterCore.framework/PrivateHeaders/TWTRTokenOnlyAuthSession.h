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
#import "TWTRAuthSession.h"

NS_ASSUME_NONNULL_BEGIN

@interface TWTRTokenOnlyAuthSession : NSObject <TWTRAuthSession>

@property (nonatomic, copy, readonly) NSString *authToken;

@property (nonatomic, copy, readonly) NSString *authTokenSecret;

/**
 * This value is here to satisfy TWTRAuthSession protocol but
 * it defaults to an empty string and cannot be updated.
 */
@property (nonatomic, copy, readonly) NSString *userID;

- (instancetype)initWithToken:(NSString *)authToken secret:(NSString *)authTokenSecret;
+ (instancetype)authSessionWithToken:(NSString *)authToken secret:(NSString *)authTokenSecret;

@end

NS_ASSUME_NONNULL_END
