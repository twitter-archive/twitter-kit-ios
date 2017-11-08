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
 *  Authentication configuration details. Encapsulates credentials required to authenticate a Twitter application. You can obtain your credentials at https://apps.twitter.com/.
 */
@interface TWTRAuthConfig : NSObject

/**
 *  The consumer key of the Twitter application.
 */
@property (nonatomic, copy, readonly) NSString *consumerKey;
/**
 *  The consumer secret of the Twitter application.
 */
@property (nonatomic, copy, readonly) NSString *consumerSecret;

/**
 *  Returns an `TWTRAuthConfig` object initialized by copying the values from the consumer key and consumer secret.
 *
 *  @param consumerKey The consumer key.
 *  @param consumerSecret The consumer secret.
 */
- (instancetype)initWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret;

/**
 *  Unavailable. Use `initWithConsumerKey:consumerSecret:` instead.
 */
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
