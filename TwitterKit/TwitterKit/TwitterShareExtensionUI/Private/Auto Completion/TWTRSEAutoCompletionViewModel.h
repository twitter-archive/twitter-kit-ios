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

@import Foundation;

@protocol TWTRSEWordRangeCalculator;

NS_ASSUME_NONNULL_BEGIN

@interface TWTRSEAutoCompletionViewModel : NSObject

- (BOOL)wordIsHashtag:(nullable NSString *)word;
- (BOOL)wordIsUsername:(nullable NSString *)word;

- (NSString *)stripUsernameMarkersFromWord:(NSString *)word;

- (nullable NSString *)wordAroundSelectedLocation:(NSUInteger)selectedLocation inText:(nullable NSString *)text;

- (nullable NSString *)insertAutoCompletionWord:(NSString *)word inWordAtLocation:(NSUInteger)wordLocation inText:(NSString *)text insertionEndLocation:(NSUInteger *)insertionEndLocation;

@end

NS_ASSUME_NONNULL_END
