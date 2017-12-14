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

#import "TWTRListTimelineDataSource.h"
#import <TwitterCore/TWTRAssertionMacros.h>
#import <TwitterCore/TWTRMultiThreadUtil.h>
#import "TWTRAPIClient_Private.h"
#import "TWTRTimelineCursor.h"
#import "TWTRTimelineDataSource_Constants.h"
#import "TWTRTimelineFilter.h"
#import "TWTRTimelineFilterManager.h"
#import "TWTRTimelineParser.h"

@interface TWTRListTimelineDataSource ()
@property (nonatomic) TWTRTimelineFilterManager *timelineFilterManager;
@end

@implementation TWTRListTimelineDataSource
@synthesize APIClient = _APIClient;

- (instancetype)initWithListID:(NSString *)listID APIClient:(TWTRAPIClient *)client
{
    return [self initWithListID:listID listSlug:nil listOwnerScreenName:nil APIClient:client maxTweetsPerRequest:TWTRTimelineDataSourceDefaultMaxTweetsPerRequest includeRetweets:TWTRTimelineDataSourceDefaultIncludeRetweets];
}

- (instancetype)initWithListSlug:(NSString *)listSlug listOwnerScreenName:(NSString *)listOwnerScreenName APIClient:(TWTRAPIClient *)client
{
    return [self initWithListID:nil listSlug:listSlug listOwnerScreenName:listOwnerScreenName APIClient:client maxTweetsPerRequest:TWTRTimelineDataSourceDefaultMaxTweetsPerRequest includeRetweets:TWTRTimelineDataSourceDefaultIncludeRetweets];
}

- (instancetype)initWithListID:(nullable NSString *)listID listSlug:(nullable NSString *)listSlug listOwnerScreenName:(nullable NSString *)listOwnerScreenName APIClient:(TWTRAPIClient *)client maxTweetsPerRequest:(NSUInteger)maxTweetsPerRequest includeRetweets:(BOOL)includeRetweets
{
    TWTRParameterAssertOrReturnValue([listID length] > 0 || ([listSlug length] > 0 && [listOwnerScreenName length] > 0), nil);
    TWTRParameterAssertOrReturnValue(client, nil);

    if (self = [super init]) {
        if (listID) {
            _listID = [listID copy];
        } else {
            _listSlug = [listSlug copy];
            _listOwnerScreenName = [listOwnerScreenName copy];
        }
        _APIClient = client;
        _maxTweetsPerRequest = maxTweetsPerRequest;
        _includeRetweets = includeRetweets;
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

    if (self.listID) {
        [self.APIClient loadTweetsForListID:self.listID parameters:params timelineFilterManager:self.timelineFilterManager completion:completion];
    } else {
        [self.APIClient loadTweetsForListSlug:self.listSlug listOwnerScreenName:self.listOwnerScreenName parameters:params timelineFilterManager:self.timelineFilterManager completion:completion];
    }
}

- (TWTRTimelineType)timelineType
{
    return TWTRTimelineTypeList;
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

    parameters[@"include_rts"] = self.includeRetweets ? @"true" : @"false";

    return parameters;
}

@end
