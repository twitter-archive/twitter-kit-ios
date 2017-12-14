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

#import "TWTRScribeSink.h"
#import <TwitterCore/TWTRAssertionMacros.h>
#import <TwitterCore/TWTRAuthSession.h>
#import <TwitterCore/TWTRIdentifier.h>
#import <TwitterCore/TWTRScribeCardEvent.h>
#import <TwitterCore/TWTRScribeClientEventNamespace_Private.h>
#import <TwitterCore/TWTRScribeEvent.h>
#import <TwitterCore/TWTRScribeFilterDetails.h>
#import <TwitterCore/TWTRScribeMediaDetails.h>
#import <TwitterCore/TWTRScribeService.h>
#import <TwitterCore/TWTRSessionStore.h>
#import "TWTRScribeSink_Private.h"
#import "TWTRTweetMediaEntity.h"
#import "TWTRTweetView_Private.h"
#import "TWTRTwitter.h"
#import "TWTRVideoPlaybackConfiguration.h"

static NSString *const TWTRScribeEventSectionComposer = @"composer";
static NSString *const TWTRScribeEventElementCancelButton = @"cancel";
static NSString *const TWTRScribeEventElementTweetButton = @"tweet";

static NSString *stringRepresentationOfTimelineType(TWTRTimelineType timelineType)
{
    switch (timelineType) {
        case TWTRTimelineTypeUser:
            return @"user";
        case TWTRTimelineTypeSearch:
            return @"search";
        case TWTRTimelineTypeCollection:
            return @"collection";
        case TWTRTimelineTypeList:
            return @"list";
    }

    [NSException raise:NSInternalInconsistencyException format:@"Invalid timeline type passed in."];
    return nil;
}

static NSString *stringRepresentationOfShowingActions(BOOL showingActions)
{
    return showingActions ? @"actions" : @"";
}

static NSString *stringRepresentationOfTweetViewStyle(TWTRTweetViewStyle style)
{
    if (style == TWTRTweetViewStyleRegular) {
        return @"default";
    } else {
        return @"compact";
    }
}

static TWTRScribeMediaType scribeMediaTypeFromTWTRMediaType(TWTRMediaType mediaType)
{
    switch (mediaType) {
        case TWTRMediaTypeVideo:
            return TWTRScribeMediaTypeConsumerVideo;
        case TWTRMediaTypeGIF:
            return TWTRScribeMediaTypeGIF;
        case TWTRMediaTypeVine:
            return TWTRScribeMediaTypeVine;
        default:
            NSLog(@"Unrecognized Tweet media entity type.");
            return -1;
    }
}

static NSString *scribeStringRepresentationOfPercentMediaPlayed(NSUInteger percentMediaPlayed)
{
    if (percentMediaPlayed == 0) {
        return @"play";
    } else if (percentMediaPlayed == 100) {
        return @"playback_retention";
    } else {
        return [NSString stringWithFormat:@"playback_%02tu", percentMediaPlayed];
    }
}

static NSString *scribeStringRepresentationOfVideoPlayed(BOOL isInlinePlayback)
{
    return isInlinePlayback ? @"inline" : @"fullscreen";
}

static NSString *stringRepresentationOfViewName(TWTRScribeViewName viewName)
{
    switch (viewName) {
        case TWTRScribeViewNameTweet:
            return @"tweet";
        case TWTRScribeViewNameTweetDetail:
            return @"tweet_detail";
    }
    return TWTRScribeClientEventNamespaceEmptyValue;
}

@interface TWTRScribeSink ()

@property (nonatomic, strong) TWTRScribeService *scribeService;

@end

@implementation TWTRScribeSink

- (instancetype)initWithScribeService:(TWTRScribeService *)scribeService
{
    if (self = [super init]) {
        _scribeService = scribeService;
    }

    return self;
}

#pragma mark - API requests

- (void)didLoadTweetsWithIDs:(NSArray *)tweetIDs
{
    NSMutableArray *events = [NSMutableArray arrayWithCapacity:tweetIDs.count];
    TWTRScribeClientEventNamespace *namespace = [[self class] tweetLoadNamespace];

    for (NSString *tweetID in tweetIDs) {
        [events addObject:[[TWTRScribeEvent alloc] initWithUserID:[self currentUserID] tweetID:tweetID category:TWTRScribeEventCategoryImpressions eventNamespace:namespace items:nil]];
    }

    [self.scribeService enqueueEvents:events];
}

#pragma mark - Timelines

- (void)didShowTimelineOfType:(TWTRTimelineType)timelineType timelineID:(NSString *)timelineID
{
    // Scribe impression
    TWTRScribeClientEventNamespace *impressionNamespace = [[self class] timelineImpressionNamespaceWithTimelineType:timelineType];
    NSArray *items = nil;
    if (timelineID) {
        // Only collections have its own type, others are just represented as Tweets
        TWTRScribeItemType itemType = timelineType == TWTRTimelineTypeCollection ? TWTRScribeItemTypeCustomTimeline : TWTRScribeItemTypeTweet;
        TWTRScribeItem *timelineScribeItem = [[TWTRScribeItem alloc] initWithItemType:itemType itemID:timelineID];
        items = @[timelineScribeItem];
    }
    [self scribeImpressionEventWithTweetID:nil userID:[self currentUserID] namespace:impressionNamespace items:items];

    // Scribe unique
    TWTRScribeClientEventNamespace *uniqueNamespace = [[self class] timelineUniqueNamespaceWithTimelineType:timelineType];
    [self scribeUniqueEventWithNamespace:uniqueNamespace];
}

#pragma mark - Filter
// tfw:iOS:timeline:::filter
// Scribe filter information when filter
- (void)didFilterRequestedTweets:(NSUInteger)requestedTweets totalFilters:(NSUInteger)totalFilters totalFilteredTweets:(NSUInteger)totalFilteredTweets;
{
    TWTRScribeFilterDetails *scribeFilterDetails = [[TWTRScribeFilterDetails alloc] initWithRequestedTweets:requestedTweets totalFilters:totalFilters totalFilteredTweets:totalFilteredTweets];
    TWTRScribeItem *item = [[TWTRScribeItem alloc] initWithItemType:TWTRScribeItemTypeMessage itemID:nil cardEvent:nil mediaDetails:nil filterDetails:scribeFilterDetails];
    TWTRScribeClientEventNamespace *namespace = [[TWTRScribeClientEventNamespace alloc] initWithClient:TWTRScribeEventImpressionClient page:TWTRScribeClientEventNamespaceTimelineValue section:TWTRScribeClientEventNamespaceEmptyValue component:TWTRScribeClientEventNamespaceEmptyValue element:TWTRScribeClientEventNamespaceEmptyValue action:TWTRScribeEventActionFilter];
    TWTRScribeEvent *event = [[TWTRScribeEvent alloc] initWithUserID:[self currentUserID] tweetID:nil category:TWTRScribeEventCategoryImpressions eventNamespace:namespace items:@[item]];
    [self.scribeService enqueueEvent:event];
}

// tfw:iOS:timeline:::impression
// Scribe impression when Tweets are shown
- (void)didFilterWithTweetsShown:(NSUInteger)totalFilters
{
    TWTRScribeFilterDetails *scribeFilterDetails = [[TWTRScribeFilterDetails alloc] initWithFilters:totalFilters];
    TWTRScribeItem *item = [[TWTRScribeItem alloc] initWithItemType:TWTRScribeItemTypeMessage itemID:nil cardEvent:nil mediaDetails:nil filterDetails:scribeFilterDetails];
    TWTRScribeClientEventNamespace *namespace = [[TWTRScribeClientEventNamespace alloc] initWithClient:TWTRScribeEventImpressionClient page:TWTRScribeClientEventNamespaceTimelineValue section:TWTRScribeClientEventNamespaceEmptyValue component:TWTRScribeClientEventNamespaceEmptyValue element:TWTRScribeClientEventNamespaceEmptyValue action:TWTRScribeEventActionFilter];
    TWTRScribeEvent *event = [[TWTRScribeEvent alloc] initWithUserID:[self currentUserID] tweetID:nil category:TWTRScribeEventCategoryImpressions eventNamespace:namespace items:@[item]];
    [self.scribeService enqueueEvent:event];
}

#pragma mark - Favorite

- (void)didLikeTweetWithID:(NSString *)tweetID forUserID:(NSString *)userID fromViewName:(TWTRScribeViewName)viewName
{
    TWTRScribeClientEventNamespace *namespace = [[TWTRScribeClientEventNamespace alloc] initWithClient:TWTRScribeEventImpressionClient page:TWTRScribeEventImpressionPage section:stringRepresentationOfViewName(viewName) component:TWTRScribeEmptyKey element:TWTRScribeEventImpressionAction action:TWTRScribeActionLike];

    [self scribeImpressionEventWithTweetID:tweetID userID:userID namespace:namespace items:nil];
}

- (void)didUnlikeTweetWithID:(NSString *)tweetID forUserID:(NSString *)userID fromViewName:(TWTRScribeViewName)viewName
{
    TWTRScribeClientEventNamespace *namespace = [[TWTRScribeClientEventNamespace alloc] initWithClient:TWTRScribeEventImpressionClient page:TWTRScribeEventImpressionPage section:stringRepresentationOfViewName(viewName) component:TWTRScribeEmptyKey element:TWTRScribeEventImpressionAction action:TWTRScribeActionUnlike];

    [self scribeImpressionEventWithTweetID:tweetID userID:userID namespace:namespace items:nil];
}

#pragma mark - Tweet view impressions

- (void)didShowTweetWithID:(NSString *)tweetID style:(TWTRTweetViewStyle)style showingActions:(BOOL)showingActions
{
    NSString *tweetStyle = stringRepresentationOfTweetViewStyle(style);
    NSString *actionsValue = stringRepresentationOfShowingActions(showingActions);

    // Unique
    [self didSeeTweetViewWithStyle:tweetStyle showingActions:actionsValue];

    // Impression
    TWTRScribeClientEventNamespace *namespace = [[self class] tweetViewImpressionNamespaceWithStyle:tweetStyle showingActions:actionsValue];
    [self scribeImpressionEventWithTweetID:tweetID userID:[self currentUserID] namespace:namespace items:nil];
}

- (void)didShowQuoteTweetWithID:(NSString *)tweetID
{
    // Impression
    TWTRScribeClientEventNamespace *namespace = [[TWTRScribeClientEventNamespace alloc] initWithClient:TWTRScribeEventImpressionClient page:TWTRScribeEventImpressionPage section:TWTRScribeEventImpressionSectionTweet component:TWTRScribeEventImpressionSectionQuoteTweet element:TWTRScribeClientEventNamespaceEmptyValue action:TWTRScribeEventImpressionTypeImpression];

    [self scribeImpressionEventWithTweetID:tweetID userID:[self currentUserID] namespace:namespace items:nil];
}

- (void)didShowTweetDetailWithTweetID:(NSString *)tweetID forUserID:(NSString *)userID
{
    TWTRScribeClientEventNamespace *namespace = [[TWTRScribeClientEventNamespace alloc] initWithClient:TWTRScribeEventImpressionClient page:TWTRScribeEventImpressionPage section:stringRepresentationOfViewName(TWTRScribeViewNameTweetDetail) component:TWTRScribeClientEventNamespaceEmptyValue element:TWTRScribeClientEventNamespaceEmptyValue action:TWTRScribeEventImpressionTypeImpression];
    [self scribeImpressionEventWithTweetID:tweetID userID:userID namespace:namespace items:nil];
}

- (void)didShowQuoteTweetDetailWithTweetID:(NSString *)tweetID;
{
    TWTRScribeClientEventNamespace *namespace = [[TWTRScribeClientEventNamespace alloc] initWithClient:TWTRScribeEventImpressionClient page:TWTRScribeEventImpressionPage section:stringRepresentationOfViewName(TWTRScribeViewNameTweetDetail) component:TWTRScribeEventImpressionSectionQuoteTweet element:TWTRScribeClientEventNamespaceEmptyValue action:TWTRScribeEventImpressionTypeImpression];
    [self scribeImpressionEventWithTweetID:tweetID userID:nil namespace:namespace items:nil];
}

#pragma mark - Media Player

- (void)didShowMediaEntities:(NSArray<TWTRTweetMediaEntity *> *)mediaEntities inTweetID:(NSString *)tweetID publishedByOwnerID:(NSString *)ownerID
{
    TWTRScribeClientEventNamespace *namespace = [[TWTRScribeClientEventNamespace alloc] initWithClient:TWTRScribeEventImpressionClient page:TWTRScribeEventImpressionPage section:TWTRScribeEventImpressionSectionVideo component:TWTRScribeClientEventNamespaceEmptyValue element:TWTRScribeClientEventNamespaceEmptyValue action:TWTRScribeEventImpressionTypeImpression];
    NSMutableArray<TWTRScribeMediaDetails *> *scribeMediaDetails = [NSMutableArray arrayWithCapacity:[mediaEntities count]];
    [mediaEntities enumerateObjectsUsingBlock:^(TWTRTweetMediaEntity *mediaEntity, NSUInteger idx, BOOL *stop) {
        TWTRScribeMediaType scribeMediaType = scribeMediaTypeFromTWTRMediaType(mediaEntity.mediaType);
        TWTRScribeMediaDetails *scribeMediaDetailsForEntity = [[TWTRScribeMediaDetails alloc] initWithPublisherID:ownerID contentID:mediaEntity.mediaID mediaType:scribeMediaType];
        [scribeMediaDetails addObject:scribeMediaDetailsForEntity];
    }];

    for (TWTRScribeMediaDetails *scribeMediaDetailsForEntity in scribeMediaDetails) {
        TWTRScribeItem *item = [[TWTRScribeItem alloc] initWithItemType:TWTRScribeItemTypeTweet itemID:tweetID cardEvent:nil mediaDetails:scribeMediaDetailsForEntity];
        TWTRScribeEvent *event = [[TWTRScribeEvent alloc] initWithUserID:nil tweetID:nil category:TWTRScribeEventCategoryImpressions eventNamespace:namespace items:@[item]];
        [self.scribeService enqueueEvent:event];
    }
}

- (void)didPlayPercentOfMedia:(NSUInteger)percentOfMedia fromPlaybackConfiguration:(TWTRVideoPlaybackConfiguration *)playbackConfiguration inTweetID:(NSString *)tweetID publishedByOwnerID:(NSString *)ownerID
{
    TWTRParameterAssertOrReturn((percentOfMedia >= 0) && (percentOfMedia <= 100));

    TWTRScribeClientEventNamespace *namespace = [[TWTRScribeClientEventNamespace alloc] initWithClient:TWTRScribeEventImpressionClient page:TWTRScribeEventImpressionPage section:TWTRScribeEventImpressionSectionVideo component:TWTRScribeClientEventNamespaceEmptyValue element:TWTRScribeClientEventNamespaceEmptyValue action:scribeStringRepresentationOfPercentMediaPlayed(percentOfMedia)];
    TWTRScribeMediaType scribeMediaType = scribeMediaTypeFromTWTRMediaType(playbackConfiguration.mediaType);
    TWTRScribeMediaDetails *scribeMediaDetailsForEntity = [[TWTRScribeMediaDetails alloc] initWithPublisherID:ownerID contentID:playbackConfiguration.mediaID mediaType:scribeMediaType];

    TWTRScribeItem *item = [[TWTRScribeItem alloc] initWithItemType:TWTRScribeItemTypeTweet itemID:tweetID cardEvent:nil mediaDetails:scribeMediaDetailsForEntity];
    TWTRScribeEvent *event = [[TWTRScribeEvent alloc] initWithUserID:[self currentUserID] tweetID:nil category:TWTRScribeEventCategoryImpressions eventNamespace:namespace items:@[item]];
    [self.scribeService enqueueEvent:event];
}

- (void)didBeginPlaybackFromPlaybackConfiguration:(TWTRVideoPlaybackConfiguration *)playbackConfiguration inTweetID:(NSString *)tweetID publishedByOwnerID:(NSString *)ownerID isInlinePlayback:(BOOL)isInlinePlayback
{
    TWTRScribeClientEventNamespace *namespace = [[TWTRScribeClientEventNamespace alloc] initWithClient:TWTRScribeEventImpressionClient page:TWTRScribeEventImpressionPage section:TWTRScribeEventImpressionSectionVideo component:TWTRScribeClientEventNamespacePlayerValue element:TWTRScribeClientEventNamespaceEmptyValue action:scribeStringRepresentationOfVideoPlayed(isInlinePlayback)];
    TWTRScribeMediaType scribeMediaType = scribeMediaTypeFromTWTRMediaType(playbackConfiguration.mediaType);
    TWTRScribeMediaDetails *scribeMediaDetailsForEntity = [[TWTRScribeMediaDetails alloc] initWithPublisherID:ownerID contentID:playbackConfiguration.mediaID mediaType:scribeMediaType];

    TWTRScribeItem *item = [[TWTRScribeItem alloc] initWithItemType:TWTRScribeItemTypeTweet itemID:tweetID cardEvent:nil mediaDetails:scribeMediaDetailsForEntity];
    TWTRScribeEvent *event = [[TWTRScribeEvent alloc] initWithUserID:[self currentUserID] tweetID:nil category:TWTRScribeEventCategoryImpressions eventNamespace:namespace items:@[item]];
    [self.scribeService enqueueEvent:event];
}

#pragma mark - Photo Gallery

// TwitterKit   tfw:iOS:gallery: : :show
// Twitter iOS  iphone:gallery: :gallery:photo:show
- (void)didPresentPhotoGallery
{
    TWTRScribeClientEventNamespace *namespace = [[TWTRScribeClientEventNamespace alloc] initWithClient:TWTRScribeEventImpressionClient page:TWTRScribeEventImpressionPage section:TWTRScribeEventImpressionSectionGallery component:TWTRScribeClientEventNamespaceEmptyValue element:TWTRScribeClientEventNamespaceEmptyValue action:TWTRScribeClientEventNamespaceShowAction];

    TWTRScribeEvent *event = [[TWTRScribeEvent alloc] initWithUserID:nil tweetID:nil category:TWTRScribeEventCategoryImpressions eventNamespace:namespace items:nil];

    [self.scribeService enqueueEvent:event];
}

// TwitterKit   tfw:iOS:gallery: : :impression
// Twitter iOS  iphone:gallery: :gallery:photo:impression
- (void)didSeeMediaEntity:(TWTRTweetMediaEntity *)mediaEntity fromTweetID:(NSString *)tweetID
{
    TWTRScribeClientEventNamespace *namespace = [[TWTRScribeClientEventNamespace alloc] initWithClient:TWTRScribeEventImpressionClient page:TWTRScribeEventImpressionPage section:TWTRScribeEventImpressionSectionGallery component:TWTRScribeClientEventNamespaceEmptyValue element:TWTRScribeClientEventNamespaceEmptyValue action:TWTRScribeClientEventNamespaceImpressionAction];

    TWTRScribeEvent *event = [[TWTRScribeEvent alloc] initWithUserID:nil tweetID:tweetID category:TWTRScribeEventCategoryImpressions eventNamespace:namespace items:nil];

    [self.scribeService enqueueEvent:event];
}

// TwitterKit   tfw:iOS:gallery: : :navigate
// Twitter iOS  iphone:gallery: :gallery:photo:navigate
- (void)didNavigateInsideGallery
{
    TWTRScribeClientEventNamespace *namespace = [[TWTRScribeClientEventNamespace alloc] initWithClient:TWTRScribeEventImpressionClient page:TWTRScribeEventImpressionPage section:TWTRScribeEventImpressionSectionGallery component:TWTRScribeClientEventNamespaceEmptyValue element:TWTRScribeClientEventNamespaceEmptyValue action:TWTRScribeClientEventNamespaceNavigateAction];

    TWTRScribeEvent *event = [[TWTRScribeEvent alloc] initWithUserID:nil tweetID:nil category:TWTRScribeEventCategoryImpressions eventNamespace:namespace items:nil];

    [self.scribeService enqueueEvent:event];
}

// TwitterKit   tfw:iOS:gallery: : :dismiss
// Twitter iOS  iphone:gallery: :gallery:photo:dismiss
- (void)didDismissPhotoGallery
{
    TWTRScribeClientEventNamespace *namespace = [[TWTRScribeClientEventNamespace alloc] initWithClient:TWTRScribeEventImpressionClient page:TWTRScribeEventImpressionPage section:TWTRScribeEventImpressionSectionGallery component:TWTRScribeClientEventNamespaceEmptyValue element:TWTRScribeClientEventNamespaceEmptyValue action:TWTRScribeClientEventNamespaceDismissAction];

    TWTRScribeEvent *event = [[TWTRScribeEvent alloc] initWithUserID:nil tweetID:nil category:TWTRScribeEventCategoryImpressions eventNamespace:namespace items:nil];

    [self.scribeService enqueueEvent:event];
}

#pragma mark - Sharing

- (void)didShareTweetWithID:(NSString *)tweetID forUserID:(NSString *)userID fromViewName:(TWTRScribeViewName)viewName
{
    NSString *component = TWTRScribeEmptyKey;
    if (viewName == TWTRScribeViewNameTweet) {
        component = TWTRScribeEventImpressionComponent;
    }

    TWTRScribeClientEventNamespace *namespace = [[TWTRScribeClientEventNamespace alloc] initWithClient:TWTRScribeEventImpressionClient page:TWTRScribeEventImpressionPage section:stringRepresentationOfViewName(viewName) component:component element:TWTRScribeEmptyKey action:TWTRScribeEventImpressionTypeShare];
    [self scribeImpressionEventWithTweetID:tweetID userID:userID namespace:namespace items:nil];
}

#pragma mark - Uniques

- (void)didSeeTweetViewWithStyle:(NSString *)tweetStyle showingActions:(NSString *)showingActions
{
    TWTRScribeClientEventNamespace *namespace = [[self class] twitterKitTweetViewUsageNamespaceWithTweetViewStyle:tweetStyle showingActions:showingActions];
    TWTRScribeEvent *event = [[TWTRScribeEvent alloc] initWithUserID:[self currentUserID] tweetID:nil category:TWTRScribeEventCategoryUniques eventNamespace:namespace items:nil];

    [self.scribeService enqueueEvent:event];
}

- (void)didStartOAuthLogin
{
    TWTRScribeClientEventNamespace *namespace = [[self class] twitterKitLoginUsageNamespace];
    TWTRScribeEvent *event = [[TWTRScribeEvent alloc] initWithUserID:[self currentUserID] tweetID:nil category:TWTRScribeEventCategoryUniques eventNamespace:namespace items:nil];
    [self.scribeService enqueueEvent:event];
}

- (void)didVerifyCredentialsForSession:(id<TWTRAuthSession>)session
{
    /// NOTE: session is unused as this point but exposed here for future changes.
    TWTRScribeClientEventNamespace *namespace = [[self class] verifyCredentialsUniqueNamespace];
    TWTRScribeEvent *event = [[TWTRScribeEvent alloc] initWithUserID:[self currentUserID] tweetID:nil category:TWTRScribeEventCategoryUniques eventNamespace:namespace items:nil];
    [self.scribeService enqueueEvent:event];
}

#pragma mark - Helpers

- (void)scribeImpressionEventWithTweetID:(NSString *)tweetID userID:(NSString *)userID namespace:(TWTRScribeClientEventNamespace *)namespace items:(NSArray<TWTRScribeItem *> *)items
{
    TWTRScribeEvent *event = [[TWTRScribeEvent alloc] initWithUserID:userID tweetID:tweetID category:TWTRScribeEventCategoryImpressions eventNamespace:namespace items:items];

    [self.scribeService enqueueEvent:event];
}

- (void)scribeUniqueEventWithNamespace:(TWTRScribeClientEventNamespace *)namespace
{
    TWTRScribeEvent *event = [[TWTRScribeEvent alloc] initWithUserID:nil tweetID:nil category:TWTRScribeEventCategoryUniques eventNamespace:namespace items:nil];

    [self.scribeService enqueueEvent:event];
}

- (TWTRScribeEvent *)uniqueScribeEventWithNamespace:(TWTRScribeClientEventNamespace *)namespace
{
    return [[TWTRScribeEvent alloc] initWithUserID:[self currentUserID] tweetID:nil category:TWTRScribeEventCategoryUniques eventNamespace:namespace items:nil];
}

- (NSString *)currentUserID
{
    TWTRSession *session = [TWTRTwitter sharedInstance].sessionStore.session;
    return (session.userID ?: @"0");  // Guest User ID is 0
}

#pragma mark - Namespaces

+ (TWTRScribeClientEventNamespace *)tweetLoadNamespace
{
    return [[TWTRScribeClientEventNamespace alloc] initWithClient:TWTRScribeEventImpressionClient page:TWTRScribeEventImpressionPage section:TWTRScribeEventImpressionSectionTweet component:TWTRScribeEventImpressionComponent element:TWTRScribeEmptyKey action:TWTRScribeEventImpressionTypeLoad];
}

+ (TWTRScribeClientEventNamespace *)tweetViewImpressionNamespaceWithStyle:(NSString *)style showingActions:(NSString *)showingActions
{
    return [[TWTRScribeClientEventNamespace alloc] initWithClient:TWTRScribeEventImpressionClient page:TWTRScribeEventImpressionPage section:TWTRScribeEventImpressionSectionTweet component:style element:showingActions action:TWTRScribeEventImpressionTypeImpression];
}

+ (TWTRScribeClientEventNamespace *)tweetViewShareNamespace
{
    return [[TWTRScribeClientEventNamespace alloc] initWithClient:TWTRScribeEventImpressionClient page:TWTRScribeEventImpressionPage section:TWTRScribeEventImpressionSectionTweet component:TWTRScribeEventImpressionComponent element:TWTRScribeEmptyKey action:TWTRScribeEventImpressionTypeShare];
}

+ (TWTRScribeClientEventNamespace *)twitterKitTweetViewUsageNamespaceWithTweetViewStyle:(NSString *)style showingActions:(NSString *)showingActions
{
    return [[TWTRScribeClientEventNamespace alloc] initWithClient:TWTRScribeEventUniquesClient page:TWTRScribeEventUniquesPageTweetViews section:style component:showingActions element:TWTRScribeClientEventNamespaceEmptyValue action:TWTRScribeEventUniquesAction];
}

+ (TWTRScribeClientEventNamespace *)twitterKitLoginUsageNamespace
{
    return [[TWTRScribeClientEventNamespace alloc] initWithClient:TWTRScribeEventUniquesClient page:TWTRScribeEventUniquesPageLogin section:TWTRScribeClientEventNamespaceEmptyValue component:TWTRScribeClientEventNamespaceEmptyValue element:TWTRScribeClientEventNamespaceEmptyValue action:TWTRScribeEventUniquesAction];
}

+ (TWTRScribeClientEventNamespace *)timelineUniqueNamespaceWithTimelineType:(TWTRTimelineType)timelineType
{
    NSString *timelineName = stringRepresentationOfTimelineType(timelineType);
    TWTRScribeClientEventNamespace *namespace = [[TWTRScribeClientEventNamespace alloc] initWithClient:TWTRScribeEventUniquesClient page:TWTRScribeClientEventNamespaceTimelineValue section:timelineName component:TWTRScribeClientEventNamespaceInitialValue element:TWTRScribeClientEventNamespaceEmptyValue action:TWTRScribeEventImpressionTypeImpression];
    return namespace;
}

+ (TWTRScribeClientEventNamespace *)timelineImpressionNamespaceWithTimelineType:(TWTRTimelineType)timelineType
{
    NSString *timelineName = stringRepresentationOfTimelineType(timelineType);
    TWTRScribeClientEventNamespace *namespace = [[TWTRScribeClientEventNamespace alloc] initWithClient:TWTRScribeEventImpressionClient page:TWTRScribeEventImpressionPage section:TWTRScribeClientEventNamespaceTimelineValue component:timelineName element:TWTRScribeClientEventNamespaceInitialValue action:TWTRScribeEventImpressionTypeImpression];
    return namespace;
}

+ (TWTRScribeClientEventNamespace *)verifyCredentialsUniqueNamespace
{
    TWTRScribeClientEventNamespace *namespace = [[TWTRScribeClientEventNamespace alloc] initWithClient:TWTRScribeEventUniquesClient page:TWTRScribeClientEventNamespaceCredentialsPage section:TWTRScribeClientEventNamespaceEmptyValue component:TWTRScribeClientEventNamespaceEmptyValue element:TWTRScribeClientEventNamespaceEmptyValue action:TWTRScribeClientEventNamespaceImpressionAction];
    return namespace;
}

#pragma mark - Errors

- (void)didEncounterError:(NSError *)error withMessage:(NSString *)errorMessage
{
    TWTRParameterAssertOrReturn(errorMessage);
    TWTRParameterAssertOrReturn(error);

    NSLog(@"[TwitterKit] did encounter error with message \"%@\": %@", errorMessage, error);

    TWTRErrorScribeEvent *event = [[TWTRErrorScribeEvent alloc] initWithError:error message:errorMessage];
    [self.scribeService enqueueEvent:event];
}

#pragma mark - Composer

- (void)didOpenComposer
{
    TWTRScribeClientEventNamespace *namespace = [[TWTRScribeClientEventNamespace alloc] initWithClient:TWTRScribeEventImpressionClient page:TWTRScribeEventImpressionPage section:TWTRScribeEventSectionComposer component:TWTRScribeClientEventNamespaceEmptyValue element:TWTRScribeClientEventNamespaceEmptyValue action:TWTRScribeEventImpressionTypeImpression];
    TWTRScribeEvent *event = [[TWTRScribeEvent alloc] initWithUserID:[self currentUserID] tweetID:nil category:TWTRScribeEventCategoryImpressions eventNamespace:namespace items:nil];
    [self.scribeService enqueueEvent:event];
}

- (void)didTapCancelFromComposerWithSelectedUserID:(NSString *)userID
{
    TWTRScribeClientEventNamespace *namespace = [[TWTRScribeClientEventNamespace alloc] initWithClient:TWTRScribeEventImpressionClient page:TWTRScribeEventImpressionPage section:TWTRScribeEventSectionComposer component:TWTRScribeClientEventNamespaceEmptyValue element:TWTRScribeEventElementCancelButton action:TWTRScribeEventActionClick];
    TWTRScribeEvent *event = [[TWTRScribeEvent alloc] initWithUserID:userID tweetID:nil category:TWTRScribeEventCategoryImpressions eventNamespace:namespace items:nil];
    [self.scribeService enqueueEvent:event];
}

- (void)didTapSendFromComposerWithSelectedUserID:(NSString *)userID
{
    TWTRScribeClientEventNamespace *namespace = [[TWTRScribeClientEventNamespace alloc] initWithClient:TWTRScribeEventImpressionClient page:TWTRScribeEventImpressionPage section:TWTRScribeEventSectionComposer component:TWTRScribeClientEventNamespaceEmptyValue element:TWTRScribeEventElementTweetButton action:TWTRScribeEventActionClick];
    TWTRScribeEvent *event = [[TWTRScribeEvent alloc] initWithUserID:userID tweetID:nil category:TWTRScribeEventCategoryImpressions eventNamespace:namespace items:nil];
    [self.scribeService enqueueEvent:event];
}

// tfw:ios:auth:[safari|webview|app|system]::start       When auth flow starts
// tfw:ios:auth:[safari|webview|app|system]::success  	When auth flow gets a token back
// tfw:ios:auth:[safari|webview|app|system]::cancelled  	When auth flow is cancelled
// tfw:ios:auth:[safari|webview|app|system]::failure     When auth flow fails
#pragma mark - Login

- (void)didStartSSOLogin
{
    [self.scribeService enqueueEvent:[self authEventWithType:@"app" eventName:TWTRScribeActionStart]];
}

- (void)didFinishSSOLogin
{
    [self.scribeService enqueueEvent:[self authEventWithType:@"app" eventName:TWTRScribeActionSuccess]];
}

- (void)didCancelSSOLogin
{
    [self.scribeService enqueueEvent:[self authEventWithType:@"app" eventName:TWTRScribeActionCancelled]];
}

- (void)didFailSSOLogin
{
    [self.scribeService enqueueEvent:[self authEventWithType:@"app" eventName:TWTRScribeActionFailure]];
}

- (void)didStartSafariLogin
{
    [self.scribeService enqueueEvent:[self authEventWithType:@"safari" eventName:TWTRScribeActionStart]];
}

- (void)didFinishSafariLogin
{
    [self.scribeService enqueueEvent:[self authEventWithType:@"safari" eventName:TWTRScribeActionSuccess]];
}

- (void)didCancelSafariLogin
{
    [self.scribeService enqueueEvent:[self authEventWithType:@"safari" eventName:TWTRScribeActionCancelled]];
}

- (void)didFailSafariLogin
{
    [self.scribeService enqueueEvent:[self authEventWithType:@"safari" eventName:TWTRScribeActionFailure]];
}

- (void)didStartWebLogin
{
    [self.scribeService enqueueEvent:[self authEventWithType:@"webview" eventName:TWTRScribeActionStart]];
}

- (void)didFinishWebLogin
{
    [self.scribeService enqueueEvent:[self authEventWithType:@"webview" eventName:TWTRScribeActionSuccess]];
}

- (void)didCancelWebLogin
{
    [self.scribeService enqueueEvent:[self authEventWithType:@"webview" eventName:TWTRScribeActionCancelled]];
}

- (void)didFailWebLogin
{
    [self.scribeService enqueueEvent:[self authEventWithType:@"webview" eventName:TWTRScribeActionFailure]];
}

- (TWTRScribeEvent *)authEventWithType:(NSString *)authType eventName:(NSString *)name
{
    TWTRScribeClientEventNamespace *namespace = [[TWTRScribeClientEventNamespace alloc] initWithClient:TWTRScribeEventImpressionClient page:TWTRScribeEventImpressionPage section:TWTRScribeEventImpressionSectionAuth component:authType element:TWTRScribeClientEventNamespaceEmptyValue action:name];
    TWTRScribeEvent *event = [[TWTRScribeEvent alloc] initWithUserID:[self currentUserID] tweetID:nil category:TWTRScribeEventCategoryImpressions eventNamespace:namespace items:nil];

    return event;
}

@end
