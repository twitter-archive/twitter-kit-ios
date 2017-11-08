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

//  Intentionally separating these out from `TWTRAPIConstants` so we can be immune to changes
//  in the values of the API response. Changing any of these values can be a breaking change
//  for the TwitterKit customers who had stored the model objects we return because they
//  conform to `NSCoding` protocol.

FOUNDATION_EXPORT NSString *const TWTRTweetCodingFieldCreatedAt;
FOUNDATION_EXPORT NSString *const TWTRTweetCodingFieldCurrentUserRetweet;
FOUNDATION_EXPORT NSString *const TWTRTweetCodingFieldEntitiesHashtags;
FOUNDATION_EXPORT NSString *const TWTRTweetCodingFieldEntitiesMedia;
FOUNDATION_EXPORT NSString *const TWTRTweetCodingFieldEntitiesUrls;
FOUNDATION_EXPORT NSString *const TWTRTweetCodingFieldEntitiesUserMentions;
FOUNDATION_EXPORT NSString *const TWTRTweetCodingFieldLikeCount;
FOUNDATION_EXPORT NSString *const TWTRTweetCodingFieldLiked;
FOUNDATION_EXPORT NSString *const TWTRTweetCodingFieldID;
FOUNDATION_EXPORT NSString *const TWTRTweetCodingFieldInReplyToScreenName;
FOUNDATION_EXPORT NSString *const TWTRTweetCodingFieldInReplyToStatusID;
FOUNDATION_EXPORT NSString *const TWTRTweetCodingFieldInReplyToUserID;
FOUNDATION_EXPORT NSString *const TWTRTweetCodingFieldRetweetCount;
FOUNDATION_EXPORT NSString *const TWTRTweetCodingFieldRetweeted;
FOUNDATION_EXPORT NSString *const TWTRTweetCodingFieldRetweetedTweet;
FOUNDATION_EXPORT NSString *const TWTRTweetCodingFieldText;
FOUNDATION_EXPORT NSString *const TWTRTweetCodingFieldUser;
