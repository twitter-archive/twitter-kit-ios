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

#import "TWTRUserTimelineDataSource.h"
#import <TwitterCore/TWTRAssertionMacros.h>
#import <TwitterCore/TWTRMultiThreadUtil.h>
#import "TWTRAPIClient_Private.h"
#import "TWTRTimelineCursor.h"
#import "TWTRTimelineDataSource_Constants.h"
#import "TWTRTimelineFilterManager.h"
#import "TWTRTimelineParser.h"

@interface TWTRUserTimelineDataSource ()
@property (nonatomic) TWTRTimelineFilterManager *timelineFilterManager;
@end

@implementation TWTRUserTimelineDataSource
@synthesize APIClient = _APIClient;

- (instancetype)initWithScreenName:(NSString *)screenName APIClient:(TWTRAPIClient *)client
{
    TWTRParameterAssertOrReturnValue(screenName, nil);
    TWTRParameterAssertOrReturnValue(client, nil);

    return [self initWithScreenName:screenName userID:nil APIClient:client maxTweetsPerRequest:TWTRTimelineDataSourceDefaultMaxTweetsPerRequest includeReplies:TWTRTimelineDataSourceDefaultIncludeReplies includeRetweets:TWTRTimelineDataSourceDefaultIncludeRetweets];
}

- (instancetype)initWithScreenName:(NSString *)screenName userID:(NSString *)userID APIClient:(TWTRAPIClient *)client maxTweetsPerRequest:(NSUInteger)maxTweetsPerRequest includeReplies:(BOOL)includeReplies includeRetweets:(BOOL)includeRetweets
{
    TWTRParameterAssertOrReturnValue(client, nil);
    BOOL missingBothScreenNameAndUserID = (!screenName && !userID);
    if (missingBothScreenNameAndUserID) {
        NSLog(@"[TwitterKit] Must supply either a screenname or userID");
        return nil;
    }

    if (self = [super init]) {
        _userID = [userID copy];
        _screenName = [screenName copy];
        _maxTweetsPerRequest = maxTweetsPerRequest;
        _includeRetweets = includeRetweets;
        _includeReplies = includeReplies;
        _APIClient = client;
    }
    return self;
}

#pragma mark - Property

- (void)setTimelineFilter:(TWTRTimelineFilter *)timelineFilter
{
    [TWTRMultiThreadUtil assertMainThread];

    if (_timelineFilter != timelineFilter) {
        _timelineFilter = timelineFilter;

        // update associated filter manager
        if (timelineFilter != nil) {
            _timelineFilterManager = [[TWTRTimelineFilterManager alloc] initWithFilters:timelineFilter];
        } else {
            _timelineFilterManager = nil;
        }
    }
}

#pragma mark - TWTRTimelineDataSource Protocol Methods

- (void)loadPreviousTweetsBeforePosition:(NSString *)position completion:(TWTRLoadTimelineCompletion)completion
{
    NSDictionary *params = [self queryParametersWithMaxPosition:position];

    [self.APIClient loadTweetsForUserTimeline:self.screenName userID:self.userID parameters:params timelineFilterManager:self.timelineFilterManager completion:completion];
}

- (TWTRTimelineType)timelineType
{
    return TWTRTimelineTypeUser;
}

#pragma mark - Helper Methods

- (NSDictionary *)queryParametersWithMaxPosition:(NSString *)maxPosition
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    if (maxPosition) {
        // When fetching a new page of tweets, we need to offset
        // the 'max_id' to ensure that we don't load the last
        // tweet a second time
        NSString *dedupedTweetPosition = decrementTweetPosition(maxPosition);
        if (dedupedTweetPosition) {
            parameters[@"max_id"] = dedupedTweetPosition;
        }
    }

    if (self.maxTweetsPerRequest) {
        parameters[@"count"] = [NSString stringWithFormat:@"%tu", self.maxTweetsPerRequest];
    }

    parameters[@"exclude_replies"] = self.includeReplies ? @"false" : @"true";
    parameters[@"include_rts"] = self.includeRetweets ? @"true" : @"false";

    return parameters;
}

@end
