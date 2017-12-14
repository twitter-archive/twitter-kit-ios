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
 * Assigning this object to any data source that implements `TWTRTimelineDataSource`
 * will filter the tweets on that timeline using the provided filter configuration.
 */
@interface TWTRTimelineFilter : NSObject <NSCopying>

@property (nonatomic, copy, nullable) NSSet *keywords;

@property (nonatomic, copy, nullable) NSSet *hashtags;

@property (nonatomic, copy, nullable) NSSet *handles;

@property (nonatomic, copy, nullable) NSSet *urls;

- (nullable instancetype)initWithJSONDictionary:(nonnull NSDictionary *)dictionary;
- (nonnull instancetype) new NS_UNAVAILABLE;

/*
 * Returns count of all filters
 */
- (NSUInteger)filterCount;
@end
