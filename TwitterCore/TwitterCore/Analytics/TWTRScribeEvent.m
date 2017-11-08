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

#import "TWTRScribeEvent.h"
#import <TwitterCore/TWTRAssertionMacros.h>
#import "TWTRCoreLanguage.h"
#import "TWTRIdentifier.h"
#import "TWTRScribeItem.h"

NSString *const TWTRScribeEventImpressionClient = @"tfw";
NSString *const TWTRScribeEventImpressionPage = @"iOS";
NSString *const TWTRScribeEventImpressionSectionTweet = @"tweet";
NSString *const TWTRScribeEventImpressionSectionQuoteTweet = @"quote";
NSString *const TWTRScribeEventImpressionSectionVideo = @"video";
NSString *const TWTRScribeEventImpressionSectionGallery = @"gallery";
NSString *const TWTRScribeEventImpressionSectionAuth = @"auth";
NSString *const TWTRScribeEventImpressionComponent = @"default";
NSString *const TWTRScribeEventImpressionTypeLoad = @"load_tweet";
NSString *const TWTRScribeEventImpressionTypeImpression = @"impression";
NSString *const TWTRScribeEventImpressionTypeShare = @"share";
NSString *const TWTRScribeEventImpressionAction = @"actions";
NSString *const TWTRScribeEventActionClick = @"click";
NSString *const TWTRScribeEventActionFilter = @"filter";

NSString *const TWTRScribeEventUniquesClient = @"iOS";
NSString *const TWTRScribeEventUniquesPageTweetViews = @"tweet";
NSString *const TWTRScribeEventUniquesPageLogin = @"login";
NSString *const TWTRScribeEventUniquesAction = @"impression";

NSString *const TWTRScribeFormatVersion = @"2";
NSString *const TWTRScribeEmptyKey = @"";
NSString *const TWTRScribeActionLike = @"like";
NSString *const TWTRScribeActionUnlike = @"unlike";
NSString *const TWTRScribeActionStart = @"start";
NSString *const TWTRScribeActionSuccess = @"success";
NSString *const TWTRScribeActionCancelled = @"cancelled";
NSString *const TWTRScribeActionFailure = @"failure";

/**
 *  Used for external_ids.AD_ID for syndicated_sdk_impression category only due
 *  to convenience mapping added on the backend i.e. AD_ID -> 6, the raw enum value
 */
NSString *const TWTRScribeEventAdvertisingIDStringKey = @"AD_ID";

@interface TWTRScribeEvent ()

@property (nonatomic, readonly, strong) NSNumber *timestamp;
@property (nonatomic, readonly, copy) NSString *currentLanguage;

@end

@implementation TWTRScribeEvent

- (instancetype)init
{
    NSAssert(NO, @"Invalid initializer called on %@", [self class]);
    return nil;
}

- (instancetype)initWithUserID:(NSString *)userID tweetID:(NSString *)tweetID category:(TWTRScribeEventCategory)category eventNamespace:(TWTRScribeClientEventNamespace *)eventNamespace items:(NSArray<TWTRScribeItem *> *)items
{
    NSParameterAssert(eventNamespace);

    if (self = [super init]) {
        _userID = userID ?: @"0";
        _tweetID = tweetID;
        _category = category;
        _eventNamespace = eventNamespace;
        _currentLanguage = [[TWTRCoreLanguage preferredLanguage] copy];
        _timestamp = [NSNumber numberWithLongLong:(CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970) * 1000];

        NSMutableArray *mergedItems = [items mutableCopy] ?: [NSMutableArray array];
        if (_tweetID) {
            [mergedItems addObject:[[TWTRScribeItem alloc] initWithItemType:TWTRScribeItemTypeTweet itemID:tweetID]];
        }
        _items = mergedItems;
    }

    return self;
}

- (instancetype)initWithUserID:(NSString *)userID eventInfo:(NSString *)eventInfo category:(TWTRScribeEventCategory)category eventNamespace:(TWTRScribeClientEventNamespace *)eventNamespace items:(NSArray<TWTRScribeItem *> *)items
{
    if (self = [self initWithUserID:userID tweetID:nil category:category eventNamespace:eventNamespace items:items]) {
        _eventInfo = [eventInfo copy];
    }
    return self;
}

- (NSMutableDictionary *)standardParameters
{
    NSString *adID = TWTRIdentifierForAdvertising();

    NSMutableDictionary *paramsDictionary = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                              [TWTRScribeClientEventNamespace scribeKey]: [self.eventNamespace dictionaryRepresentation],
                                                                                              @"_category_": [TWTRScribeEvent categoryStringFromEnum:self.category] ?: @"",
                                                                                              @"format_version": TWTRScribeFormatVersion,
                                                                                              @"language": [self currentLanguage],
                                                                                              @"ts": self.timestamp,
    }];

    // we should not be scribing IDFA unless it's for counting uniques due to legal policies around
    // first vs. third-party interactions
    if (self.category == TWTRScribeEventCategoryUniques && [adID length] > 0) {
        paramsDictionary[@"external_ids"] = @{TWTRScribeEventAdvertisingIDStringKey: adID};
    }

    // Set do_not_track to 1 if there is no advertising identifier (since that implies that
    // the user has set disallowed ad-tracking in settings).
    paramsDictionary[@"do_not_track"] = ([adID length] > 0) ? @0 : @1;

    // required field only for uniques category but we are not doing anything with it so just passing
    // in some random value for now until we start tracking created_at of app ID
    if (self.category == TWTRScribeEventCategoryUniques) {
        paramsDictionary[@"device_id_created_at"] = @0;
    }

    // Miscellaneous event specific information
    if (self.eventInfo) {
        paramsDictionary[@"event_info"] = self.eventInfo;
    }

    // id of the user who's profile or profile-related page this event was triggered on
    if (self.userID) {
        paramsDictionary[@"profile_id"] = self.userID;
    }

    if ([self.items count] > 0) {
        NSString *itemsScribeKey = [TWTRScribeItem scribeKey];
        paramsDictionary[itemsScribeKey] = [NSMutableArray array];
        for (TWTRScribeItem *item in self.items) {
            [paramsDictionary[itemsScribeKey] addObject:[item dictionaryRepresentation]];
        }
    }

    return [paramsDictionary mutableCopy];
}

#pragma mark - TFSScribeEventParameters

- (NSDictionary *)dictionaryRepresentation
{
    return [self standardParameters];
}

- (NSData *)data
{
    return [NSJSONSerialization dataWithJSONObject:[self dictionaryRepresentation] options:0 error:NULL];
}

#pragma mark - Scribe Categories

+ (NSString *)categoryStringFromEnum:(TWTRScribeEventCategory)category
{
    switch (category) {
        case TWTRScribeEventCategoryImpressions:
            return @"tfw_client_event";
        case TWTRScribeEventCategoryUniques:
            return @"syndicated_sdk_impression";
        default:
            break;
    }
    return nil;
}

@end

#pragma mark - Errors

static NSString *errorDescription(NSError *error)
{
    NSString *description = [NSString stringWithFormat:@"Error Code=%li Domain=%@", (long)error.code, error.domain];
    NSString *localizedDescription = error.userInfo[NSLocalizedDescriptionKey];
    if (localizedDescription) {
        description = [description stringByAppendingFormat:@" Description=%@", localizedDescription];
    }
    return description;
}

static NSDictionary *detailsForError(NSError *error)
{
    return @{
        @"item_type": @(TWTRScribeItemTypeUser),
        @"description": errorDescription(error),
    };
}

@implementation TWTRErrorScribeEvent

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *parameters = [[super dictionaryRepresentation] mutableCopy];

    parameters[@"message"] = self.errorMessage;

    // Add all nested error objects
    NSMutableArray *items = [NSMutableArray array];
    NSError *error = self.error;
    while (error != nil) {
        [items addObject:detailsForError(error)];
        error = error.userInfo[NSUnderlyingErrorKey];
    }

    // Overwrite super's list of items (changes from Tweet type to User)
    parameters[[TWTRScribeItem scribeKey]] = items;

    return parameters;
}

- (instancetype)initWithError:(NSError *)error message:(NSString *)errorMessage
{
    TWTRParameterAssertOrReturnValue(error, nil);
    TWTRParameterAssertOrReturnValue(errorMessage, nil);
    TWTRParameterAssertOrReturnValue([errorMessage length] > 0, nil);

    self = [super initWithUserID:nil tweetID:nil category:TWTRScribeEventCategoryImpressions eventNamespace:[TWTRScribeClientEventNamespace errorNamespace] items:@[]];
    if (self) {
        _error = error;
        _errorMessage = [errorMessage copy];
    }

    return self;
}

@end
