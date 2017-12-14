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

#import "TWTRTweetCache.h"

#import "TWTRPersistentStore.h"
#import "TWTRTweet.h"
#import "TWTRTweet_Private.h"
#import "TWTRVersionedCacheable.h"

@implementation TWTRTweetCache

#pragma mark - Init

- (instancetype)initWithPath:(NSString *)path maxSize:(NSUInteger)maxSize
{
    self = [super init];

    if (self) {
        _store = [[TWTRPersistentStore alloc] initWithPath:path maxSize:maxSize];
    }

    return self;
}

#pragma mark - Getters and Setters

- (TWTRTweet *)tweetWithID:(NSString *)tweetIDString perspective:(NSString *)userIDString
{
    TWTRPersistentStore *store = [self store];
    NSString *key = [TWTRTweet versionedCacheKeyWithID:tweetIDString perspective:userIDString];

    id obj = [store objectForKey:key];

    // Can't cast the returned object into a TWTRTweet, so remove it since it's now useless.
    if (obj && ![obj isKindOfClass:[TWTRTweet class]]) {
        [store removeObjectForKey:key];
        return nil;
    }

    return (TWTRTweet *)obj;
}

- (BOOL)storeTweet:(TWTRTweet *)tweet perspective:(NSString *)userIDString
{
    NSString *key = [TWTRTweet versionedCacheKeyWithID:tweet.tweetID perspective:userIDString];

    return [[self store] setObject:tweet forKey:key];
}

- (BOOL)removeTweetWithID:(NSString *)tweetIDString perspective:(NSString *)userIDString
{
    NSString *key = [TWTRTweet versionedCacheKeyWithID:tweetIDString perspective:userIDString];

    return [[self store] removeObjectForKey:key];
}

@end
