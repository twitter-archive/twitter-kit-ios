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

NS_ASSUME_NONNULL_BEGIN

/**
 * The base session which all sessions must conform to.
 */
@protocol TWTRBaseSession <NSObject, NSCoding>
@end

/**
 *  Encapsulates the authorization details of an OAuth Session.
 */
@protocol TWTRAuthSession <TWTRBaseSession>

@property (nonatomic, readonly, copy) NSString *authToken;
@property (nonatomic, readonly, copy) NSString *authTokenSecret;
@property (nonatomic, readonly, copy) NSString *userID;

@end

NS_ASSUME_NONNULL_END
