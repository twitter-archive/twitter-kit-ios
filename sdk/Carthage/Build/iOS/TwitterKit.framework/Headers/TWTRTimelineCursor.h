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

/**
 This Model object is a generic type of `Cursor` to represent the range of Tweets
 which have already been loaded from the Twitter API. A dataset that supports
 "cursoring" splits of a set of results (or Tweets in our case) in pages. One
 page is loaded at a time, and the cursor from the previous request is used to
 calculated which set of Tweets should be requested.


 ## Positions
 For User, Search, and List Timelines generally corresponds to a real Tweet ID.

           newer Tweets
         (not yet loaded)

     -- newest/highest Tweet --      maxPosition

           loaded Tweets

     -- oldest/lowest Tweet --      minPosition
                                    minPosition - 1
           older Tweets
         (not yet loaded)

   More: https://dev.twitter.com/overview/api/cursoring

 */
@interface TWTRTimelineCursor : NSObject

/**
 *  The ID of the Tweet highest up in a batch of Tweets received from a Timeline.
 *  Often this corresponds to the newest Tweet in terms of time.
 *
 *  For User, Search, and List Timelines this corresponds to a real Tweet ID..
 */
@property (nonatomic, copy, readonly) NSString *maxPosition;

/**
 *  The ID of the Tweet lowest in a batch of Tweets received from a Timeline. This
 *  often corresponds to the oldest Tweet in terms of time.
 *
 */
@property (nonatomic, copy, readonly) NSString *minPosition;

- (instancetype)init NS_UNAVAILABLE;

/**
 *  Initialize a new cursor.
 *
 *  @param maxPosition The highest (newest) Tweet ID received in this batch of Tweets.
 *  @param minPosition The lowest (oldest) Tweet ID received in this batch of Tweets.
 *
 *  @return The initialized cursor to be passed back from a request for a Timeline from
 *          the Twitter API.
 */
- (instancetype)initWithMaxPosition:(NSString *)maxPosition minPosition:(NSString *)minPosition;

@end
