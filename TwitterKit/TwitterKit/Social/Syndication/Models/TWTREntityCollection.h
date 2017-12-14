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
 This header is private to the Twitter Kit SDK and not exposed for public SDK consumption
 */

#import <Foundation/Foundation.h>
#import <TwitterKit/TWTRJSONConvertible.h>

@class TWTRTweetCashtagEntity;
@class TWTRTweetHashtagEntity;
@class TWTRTweetMediaEntity;
@class TWTRTweetUrlEntity;
@class TWTRTweetUserMentionEntity;

NS_ASSUME_NONNULL_BEGIN

@interface TWTREntityCollection : NSObject <NSCoding, NSCopying, TWTRJSONConvertible>

@property (nonatomic, copy, readonly, nullable) NSArray<TWTRTweetHashtagEntity *> *hashtags;
@property (nonatomic, copy, readonly, nullable) NSArray<TWTRTweetCashtagEntity *> *cashtags;
@property (nonatomic, copy, readonly, nullable) NSArray<TWTRTweetMediaEntity *> *media;
@property (nonatomic, copy, readonly, nullable) NSArray<TWTRTweetUrlEntity *> *urls;
@property (nonatomic, copy, readonly, nullable) NSArray<TWTRTweetUserMentionEntity *> *userMentions;

@end

NS_ASSUME_NONNULL_END
