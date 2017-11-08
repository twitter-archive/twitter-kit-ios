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

#import <TwitterKit/TWTRJSONConvertible.h>
#import "TWTRTweetEntity.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * A Tweet entity which represents a user mention.
 */
@interface TWTRTweetUserMentionEntity : TWTRTweetEntity <NSCoding, TWTRJSONConvertible>

/**
 * The userID of the user whom ha   s been mentioned.
 */
@property (nonatomic, copy, readonly) NSString *userID;

/**
 * The name of the user whom has been mentioned.
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 * The screen name of the user whom has been mentioned.
 */
@property (nonatomic, copy, readonly) NSString *screenName;

@end

NS_ASSUME_NONNULL_END
