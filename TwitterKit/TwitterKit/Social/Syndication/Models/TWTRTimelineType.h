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

/*
 *  Type of timelines that may be loaded and shown to the user.
 */
typedef NS_ENUM(NSUInteger, TWTRTimelineType) {

    /*
     *  User Timeline
     */
    TWTRTimelineTypeUser = 1,

    /*
     *  Search Timeline
     */
    TWTRTimelineTypeSearch,

    /**
     *  Collection Timeline
     */
    TWTRTimelineTypeCollection,

    /**
     *  List Timeline
     */
    TWTRTimelineTypeList,
};
