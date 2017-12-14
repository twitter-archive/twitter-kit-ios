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

//  Intentionally separating these out from `TWTRAPIConstants` so we can be immune to changes
//  in the values of the API response. Changing any of these values can be a breaking change
//  for the TwitterKit customers who had stored the model objects we return because they
//  conform to `NSCoding` protocol.

FOUNDATION_EXTERN NSString *const TWTRTweetCodingFieldCreatedAt;
FOUNDATION_EXTERN NSString *const TWTRTweetCodingFieldCurrentUserRetweet;
FOUNDATION_EXTERN NSString *const TWTRTweetCodingFieldEntitiesHashtags;
FOUNDATION_EXTERN NSString *const TWTRTweetCodingFieldEntitiesMedia;
FOUNDATION_EXTERN NSString *const TWTRTweetCodingFieldEntitiesUrls;
FOUNDATION_EXTERN NSString *const TWTRTweetCodingFieldEntitiesUserMentions;
FOUNDATION_EXTERN NSString *const TWTRTweetCodingFieldLikeCount;
FOUNDATION_EXTERN NSString *const TWTRTweetCodingFieldLiked;
FOUNDATION_EXTERN NSString *const TWTRTweetCodingFieldID;
FOUNDATION_EXTERN NSString *const TWTRTweetCodingFieldInReplyToScreenName;
FOUNDATION_EXTERN NSString *const TWTRTweetCodingFieldInReplyToStatusID;
FOUNDATION_EXTERN NSString *const TWTRTweetCodingFieldInReplyToUserID;
FOUNDATION_EXTERN NSString *const TWTRTweetCodingFieldRetweetCount;
FOUNDATION_EXTERN NSString *const TWTRTweetCodingFieldRetweeted;
FOUNDATION_EXTERN NSString *const TWTRTweetCodingFieldRetweetedTweet;
FOUNDATION_EXTERN NSString *const TWTRTweetCodingFieldText;
FOUNDATION_EXTERN NSString *const TWTRTweetCodingFieldUser;
