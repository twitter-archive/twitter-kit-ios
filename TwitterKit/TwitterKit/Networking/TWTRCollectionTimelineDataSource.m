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

#import "TWTRCollectionTimelineDataSource.h"
#import <TwitterCore/TWTRAssertionMacros.h>
#import <TwitterCore/TWTRMultiThreadUtil.h>
#import "TWTRAPIClient_Private.h"
#import "TWTRTimelineCursor.h"
#import "TWTRTimelineFilter.h"
#import "TWTRTimelineFilterManager.h"

@interface TWTRCollectionTimelineDataSource ()
@property (nonatomic) TWTRTimelineFilterManager *timelineFilterManager;
@end

@implementation TWTRCollectionTimelineDataSource
@synthesize APIClient = _APIClient;

- (instancetype)initWithCollectionID:(NSString *)collectionID APIClient:(TWTRAPIClient *)client
{
    return [self initWithCollectionID:collectionID APIClient:client maxTweetsPerRequest:0];
}

- (instancetype)initWithCollectionID:(NSString *)collectionID APIClient:(TWTRAPIClient *)client maxTweetsPerRequest:(NSUInteger)maxTweetsPerRequest
{
    TWTRParameterAssertOrReturnValue(collectionID, nil);
    TWTRParameterAssertOrReturnValue(client, nil);

    if (!collectionID || !client) {
        NSLog(@"[TwitterKit] Failed to receive required parameters initializing TWTRCollectionTimelineDataSource");
        return nil;
    }
    if (self = [super init]) {
        _collectionID = [collectionID copy];
        _maxTweetsPerRequest = maxTweetsPerRequest;
        _APIClient = client;
    }
    return self;
}

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

    [self.APIClient loadTweetsForCollectionID:self.collectionID parameters:params timelineFilterManager:self.timelineFilterManager completion:completion];
}

- (TWTRTimelineType)timelineType
{
    return TWTRTimelineTypeCollection;
}

#pragma mark - Helper Methods

- (NSDictionary *)queryParametersWithMaxPosition:(NSString *)maxPosition
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (self.maxTweetsPerRequest) {
        parameters[@"count"] = [NSString stringWithFormat:@"%lu", (long)self.maxTweetsPerRequest];
    }

    if (maxPosition) {
        // We have already loaded tweets; make sure to only load tweets up to (max_position) the position that we have already loaded (our saved minPosition)
        parameters[@"max_position"] = maxPosition;
    }

    return parameters;
}

@end
