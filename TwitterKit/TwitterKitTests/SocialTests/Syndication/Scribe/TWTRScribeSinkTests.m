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

#import <OCMock/OCMock.h>
#import <TwitterCore/TWTRAuthenticationConstants.h>
#import <TwitterCore/TWTRScribeCardEvent.h>
#import <TwitterCore/TWTRScribeClientEventNamespace.h>
#import <TwitterCore/TWTRScribeClientEventNamespace_Private.h>
#import <TwitterCore/TWTRScribeEvent.h>
#import <TwitterCore/TWTRScribeItem.h>
#import <TwitterCore/TWTRScribeMediaDetails.h>
#import <TwitterCore/TWTRScribeService.h>
#import <TwitterCore/TWTRSession.h>
#import <XCTest/XCTest.h>
#import "TWTRAPIClient.h"
#import "TWTRFixtureLoader.h"
#import "TWTRScribeConstants.h"
#import "TWTRScribeSink.h"
#import "TWTRScribeSink_Private.h"
#import "TWTRStubScribeService.h"
#import "TWTRTestSessionStore.h"
#import "TWTRTweet.h"
#import "TWTRTweetMediaEntity.h"
#import "TWTRTweetView.h"
#import "TWTRTweet_Private.h"
#import "TWTRTwitter.h"
#import "TWTRTwitter_Private.h"
#import "TWTRVideoPlaybackConfiguration.h"

static NSString *const testUserID = @"1";
static NSString *const testUserScreenName = @"screenName";
static TWTRSession *userSession;

@interface TWTRScribeSinkTests : XCTestCase

@property (nonatomic) id scribeServiceMock;
@property (nonatomic) TWTRScribeSink *scribeSink;
@property (nonatomic) TWTRScribeSink *scribeSinkWithMock;
@property (nonatomic) TWTRStubScribeService *stubScribeService;
@property (nonatomic) TWTRTweetMediaEntity *mediaEntity;
@property (nonatomic) TWTRTestSessionStore *sessionStore;
@property (nonatomic) TWTRVideoPlaybackConfiguration *playbackConfiguration;

@end

@implementation TWTRScribeSinkTests

+ (void)setUp
{
    NSDictionary *authDict = @{TWTRAuthOAuthTokenKey: @"token", TWTRAuthAppOAuthUserIDKey: testUserID, TWTRAuthAppOAuthScreenNameKey: testUserScreenName, TWTRAuthOAuthSecretKey: @"secret"};
    userSession = [[TWTRSession alloc] initWithSessionDictionary:authDict];
}

- (void)setUp
{
    [super setUp];

    self.scribeServiceMock = OCMClassMock([TWTRScribeService class]);
    self.scribeSinkWithMock = [[TWTRScribeSink alloc] initWithScribeService:self.scribeServiceMock];

    self.stubScribeService = [TWTRStubScribeService new];
    self.scribeSink = [[TWTRScribeSink alloc] initWithScribeService:self.stubScribeService];

    self.mediaEntity = [TWTRFixtureLoader videoTweet].media.firstObject;
    self.playbackConfiguration = [TWTRVideoPlaybackConfiguration playbackConfigurationForTweetMediaEntity:self.mediaEntity];
    self.sessionStore = [[TWTRTestSessionStore alloc] initWithUserSessions:@[userSession] guestSession:nil];
}

- (void)testScribeLoadTweetWithIDsEmptyNoScribe
{
    [[self.scribeServiceMock reject] enqueueEvent:OCMOCK_ANY];
    [self.scribeSinkWithMock didLoadTweetsWithIDs:@[]];
    OCMVerifyAll(self.scribeServiceMock);
}

- (void)testScribeLoadTweetWithIDsOne
{
    [self.scribeSink didLoadTweetsWithIDs:@[@"1"]];
    NSArray *scribeTweetIDs = [self.stubScribeService.latestEvents valueForKey:@"tweetID"];

    XCTAssert([scribeTweetIDs containsObject:@"1"]);
}

- (void)testScribeLoadTweetWithIDs_usesProperKeys
{
    [self.scribeSink didLoadTweetsWithIDs:@[@"1"]];

    XCTAssert([self.stubScribeService.latestEvents count] == 1);
    TWTRScribeEvent *event = self.stubScribeService.latestEvent;

    NSDictionary *eventProperties = event.dictionaryRepresentation[@"event_namespace"];
    XCTAssertEqualObjects(eventProperties[TWTRScribeClientEventNamespaceClientKey], @"tfw");
    XCTAssertEqualObjects(eventProperties[TWTRScribeClientEventNamespacePageKey], @"iOS");
    XCTAssertEqualObjects(eventProperties[TWTRScribeClientEventNamespaceSectionKey], @"tweet");
    XCTAssertEqualObjects(eventProperties[TWTRScribeClientEventNamespaceComponentKey], @"default");
    XCTAssertEqualObjects(eventProperties[TWTRScribeClientEventNamespaceElementKey], @"");
    XCTAssertEqualObjects(eventProperties[TWTRScribeClientEventNamespaceActionKey], @"load_tweet");
}

- (void)testScribeLoadTweetWithIDs_doesNotContainUserID
{
    id kitMock = [OCMockObject niceMockForClass:[TWTRTwitter class]];
    [[[kitMock stub] andReturn:kitMock] sharedInstance];
    [[[kitMock stub] andReturn:self.sessionStore] sessionStore];

    [self.scribeSink didLoadTweetsWithIDs:@[@"1"]];

    XCTAssertNotNil(self.stubScribeService.latestEvent);
    XCTAssert([self.stubScribeService.latestEvent dictionaryRepresentation][@"user_id"] == nil);
    [kitMock stopMocking];
}

- (void)testScribeLoadTweetWithIDs_ScribesProperIDs
{
    [self.scribeSink didLoadTweetsWithIDs:@[@"987324", @"612834"]];

    NSArray *tweetIDs = [self.stubScribeService.latestEvents valueForKey:@"tweetID"];
    XCTAssert([tweetIDs containsObject:@"612834"]);
    XCTAssert([tweetIDs containsObject:@"987324"]);
    XCTAssert([tweetIDs count] == 2);
}

- (void)testScribeLoadTweetWithIDs_ScribesProperType
{
    [self.scribeSink didLoadTweetsWithIDs:@[@"987324"]];

    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    XCTAssert([[event dictionaryRepresentation][@"item_type"] unsignedIntegerValue] == TWTRScribeItemTypeTweet);
}

#pragma mark - Tweet Impressions

- (void)testScribeTweetView_usesProperKeysWithActions
{
    [self.scribeSink didShowTweetWithID:@"9028" style:TWTRTweetViewStyleCompact showingActions:YES];

    TWTRScribeEvent *event = self.stubScribeService.latestEvent;

    NSDictionary *eventProperties = event.dictionaryRepresentation[@"event_namespace"];
    XCTAssertEqualObjects(eventProperties[TWTRScribeClientEventNamespaceClientKey], @"tfw");
    XCTAssertEqualObjects(eventProperties[TWTRScribeClientEventNamespacePageKey], @"iOS");
    XCTAssertEqualObjects(eventProperties[TWTRScribeClientEventNamespaceSectionKey], @"tweet");
    XCTAssertEqualObjects(eventProperties[TWTRScribeClientEventNamespaceElementKey], @"actions");
    XCTAssertEqualObjects(eventProperties[TWTRScribeClientEventNamespaceActionKey], @"impression");
}

- (void)testScribeTweetView_specifiesActionsInElementWhenShown
{
    [self.scribeSink didShowTweetWithID:@"9028" style:TWTRTweetViewStyleCompact showingActions:YES];
    XCTAssertEqualObjects(self.stubScribeService.latestEvent.eventNamespace.element, @"actions");
}

- (void)testScribeTweetView_emptyElementForNoAction
{
    [self.scribeSink didShowTweetWithID:@"9028" style:TWTRTweetViewStyleCompact showingActions:NO];
    XCTAssertEqualObjects(self.stubScribeService.latestEvent.eventNamespace.element, @"");
}

- (void)testScribeTweetView_setsComponentToCompact
{
    [self.scribeSink didShowTweetWithID:@"9028" style:TWTRTweetViewStyleCompact showingActions:YES];
    XCTAssertEqualObjects(self.stubScribeService.latestEvent.eventNamespace.component, @"compact");
}

- (void)testScribeTweetView_setsComponentToRegular
{
    [self.scribeSink didShowTweetWithID:@"9028" style:TWTRTweetViewStyleRegular showingActions:YES];
    XCTAssertEqualObjects(self.stubScribeService.latestEvent.eventNamespace.component, @"default");
}

- (void)testScribeTweetDetailView_setsViewNameInSection
{
    [self.scribeSink didShowTweetDetailWithTweetID:@"1" forUserID:@"123"];
    XCTAssertEqualObjects(self.stubScribeService.latestEvent.eventNamespace.section, @"tweet_detail");
}

- (void)testScribeTweetDetailView_setsTweetID
{
    [self.scribeSink didShowTweetDetailWithTweetID:@"1" forUserID:@"123"];
    TWTRScribeEvent *latestEvent = self.stubScribeService.latestEvent;
    TWTRScribeItem *tweetItem = latestEvent.items.firstObject;
    XCTAssertEqual(tweetItem.itemType, TWTRScribeItemTypeTweet);
    XCTAssertEqualObjects(tweetItem.itemID, @"1");
}

- (void)testScribeTweetDetailView_setsUserID
{
    [self.scribeSink didShowTweetDetailWithTweetID:@"1" forUserID:@"123"];
    TWTRScribeEvent *latestEvent = self.stubScribeService.latestEvent;
    XCTAssertEqualObjects([latestEvent dictionaryRepresentation][@"profile_id"], @"123");
}

- (void)testScribeSink_didShowTweetCallsDidSeeTweetWithActions
{
    id mockScribeSink = OCMPartialMock(self.scribeSink);
    OCMExpect([mockScribeSink didSeeTweetViewWithStyle:@"compact" showingActions:@"actions"]);

    [mockScribeSink didShowTweetWithID:@"124" style:TWTRTweetViewStyleCompact showingActions:YES];
    OCMVerifyAll(mockScribeSink);
}

- (void)testScribeSink_didShowTweetCallsDidSeeTweetNoActions
{
    id mockScribeSink = OCMPartialMock(self.scribeSink);
    OCMExpect([mockScribeSink didSeeTweetViewWithStyle:@"compact" showingActions:@""]);
    [mockScribeSink didShowTweetWithID:@"124" style:TWTRTweetViewStyleCompact showingActions:NO];
    OCMVerifyAll(mockScribeSink);
}

- (void)testScribeSink_didShowTweetCallsDidSeeTweetWithActionsRegular
{
    id mockScribeSink = OCMPartialMock(self.scribeSink);
    OCMExpect([mockScribeSink didSeeTweetViewWithStyle:@"default" showingActions:@"actions"]);
    [mockScribeSink didShowTweetWithID:@"124" style:TWTRTweetViewStyleRegular showingActions:YES];
    OCMVerifyAll(mockScribeSink);
}

- (void)testScribeSink_didShowTweetCallsDidSeeTweetNoActionsRegular
{
    id mockScribeSink = OCMPartialMock(self.scribeSink);
    OCMExpect([mockScribeSink didSeeTweetViewWithStyle:@"default" showingActions:@""]);
    [mockScribeSink didShowTweetWithID:@"124" style:TWTRTweetViewStyleRegular showingActions:NO];
    OCMVerifyAll(mockScribeSink);
}

- (void)testShowTimelineTypeTimelineID_scribesCollectionID
{
    [self.scribeSink didShowTimelineOfType:TWTRTimelineTypeCollection timelineID:@"123"];
    NSArray<TWTRScribeEvent *> *latestEvents = [self.stubScribeService latestEvents];
    TWTRScribeItem *scribeItem = latestEvents[0].items.firstObject;
    XCTAssertEqual(scribeItem.itemType, TWTRScribeItemTypeCustomTimeline);
    XCTAssertEqualObjects(scribeItem.itemID, @"123");
}

- (void)testShowTimelineTypeTimelineID_noScribeItemUnlessTimelineIDIsProvided
{
    [self.scribeSink didShowTimelineOfType:TWTRTimelineTypeList timelineID:nil];
    TWTRScribeEvent *lastEvent = [self.stubScribeService latestEvent];
    TWTRScribeItem *scribeItem = lastEvent.items.firstObject;
    XCTAssertNil(scribeItem);
}

- (void)testShowTimelineTypeTimelineID_coalesceItemTypeForNonCollectionTimelines
{
    [self.scribeSink didShowTimelineOfType:TWTRTimelineTypeList timelineID:@"123"];
    NSArray<TWTRScribeEvent *> *lastEvents = [self.stubScribeService latestEvents];
    TWTRScribeItem *scribeItem = lastEvents[0].items.firstObject;
    XCTAssertEqual(scribeItem.itemType, TWTRScribeItemTypeTweet);
    XCTAssertEqualObjects(scribeItem.itemID, @"123");
}

#pragma mark - Media Player

- (void)testDidShowMediaEntity_correctNamespace
{
    [self.scribeSink didShowMediaEntities:@[self.mediaEntity] inTweetID:@"1" publishedByOwnerID:@"2"];
    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    XCTAssertEqual(event.category, TWTRScribeEventCategoryImpressions);
    XCTAssertEqualObjects(event.eventNamespace.client, @"tfw");
    XCTAssertEqualObjects(event.eventNamespace.page, @"iOS");
    XCTAssertEqualObjects(event.eventNamespace.section, @"video");
    XCTAssertEqualObjects(event.eventNamespace.component, @"");
    XCTAssertEqualObjects(event.eventNamespace.element, @"");
    XCTAssertEqualObjects(event.eventNamespace.action, @"impression");
}

- (void)testDidShowMediaEntity_hasMediaDetails
{
    [self.scribeSink didShowMediaEntities:@[self.mediaEntity] inTweetID:@"1" publishedByOwnerID:@"2"];
    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    XCTAssertEqual(event.items.count, 1);
    TWTRScribeItem *item = event.items.firstObject;
    XCTAssertEqualObjects(item.itemID, @"1");
    TWTRScribeMediaDetails *mediaDetails = item.mediaDetails;
    XCTAssertNotNil(mediaDetails);
    XCTAssertEqualObjects(mediaDetails.publisherID, @"2");
    XCTAssertEqualObjects(mediaDetails.contentID, @"663898843579179008");
    XCTAssertEqual(mediaDetails.mediaType, TWTRScribeMediaTypeConsumerVideo);
}

- (void)testDidPlayPercentOfMedia_twoDigitsPercentage
{
    [self.scribeSink didPlayPercentOfMedia:1 fromPlaybackConfiguration:self.playbackConfiguration inTweetID:@"1" publishedByOwnerID:@"2"];
    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    XCTAssertEqual(event.category, TWTRScribeEventCategoryImpressions);
    XCTAssertEqualObjects(event.eventNamespace.client, @"tfw");
    XCTAssertEqualObjects(event.eventNamespace.page, @"iOS");
    XCTAssertEqualObjects(event.eventNamespace.section, @"video");
    XCTAssertEqualObjects(event.eventNamespace.component, @"");
    XCTAssertEqualObjects(event.eventNamespace.element, @"");
    XCTAssertEqualObjects(event.eventNamespace.action, @"playback_01");
}

- (void)testDidPlayPercentOfMedia_correctNamespace
{
    [self.scribeSink didPlayPercentOfMedia:0 fromPlaybackConfiguration:self.playbackConfiguration inTweetID:@"1" publishedByOwnerID:@"2"];
    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    XCTAssertEqual(event.category, TWTRScribeEventCategoryImpressions);
    XCTAssertEqualObjects(event.eventNamespace.client, @"tfw");
    XCTAssertEqualObjects(event.eventNamespace.page, @"iOS");
    XCTAssertEqualObjects(event.eventNamespace.section, @"video");
    XCTAssertEqualObjects(event.eventNamespace.component, @"");
    XCTAssertEqualObjects(event.eventNamespace.element, @"");
    XCTAssertEqualObjects(event.eventNamespace.action, @"play");
}

- (void)testDidPlayPercentOfMedia_correctNamespaceForProgress
{
    [self.scribeSink didPlayPercentOfMedia:50 fromPlaybackConfiguration:self.playbackConfiguration inTweetID:@"1" publishedByOwnerID:@"2"];
    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    XCTAssertEqual(event.category, TWTRScribeEventCategoryImpressions);
    XCTAssertEqualObjects(event.eventNamespace.client, @"tfw");
    XCTAssertEqualObjects(event.eventNamespace.page, @"iOS");
    XCTAssertEqualObjects(event.eventNamespace.section, @"video");
    XCTAssertEqualObjects(event.eventNamespace.component, @"");
    XCTAssertEqualObjects(event.eventNamespace.element, @"");
    XCTAssertEqualObjects(event.eventNamespace.action, @"playback_50");
}

- (void)testDidPlayPercentOfMedia_correctNamespaceForDone
{
    [self.scribeSink didPlayPercentOfMedia:100 fromPlaybackConfiguration:self.playbackConfiguration inTweetID:@"1" publishedByOwnerID:@"2"];
    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    XCTAssertEqual(event.category, TWTRScribeEventCategoryImpressions);
    XCTAssertEqualObjects(event.eventNamespace.client, @"tfw");
    XCTAssertEqualObjects(event.eventNamespace.page, @"iOS");
    XCTAssertEqualObjects(event.eventNamespace.section, @"video");
    XCTAssertEqualObjects(event.eventNamespace.component, @"");
    XCTAssertEqualObjects(event.eventNamespace.element, @"");
    XCTAssertEqualObjects(event.eventNamespace.action, @"playback_retention");
}

- (void)testDidPlayPercentOfMedia_hasMediaDetails
{
    [self.scribeSink didPlayPercentOfMedia:0 fromPlaybackConfiguration:self.playbackConfiguration inTweetID:@"1" publishedByOwnerID:@"2"];
    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    XCTAssertEqual(event.items.count, 1);
    TWTRScribeItem *item = event.items.firstObject;
    XCTAssertEqualObjects(item.itemID, @"1");
    TWTRScribeMediaDetails *mediaDetails = item.mediaDetails;
    XCTAssertNotNil(mediaDetails);
    XCTAssertEqualObjects(mediaDetails.publisherID, @"2");
    XCTAssertEqualObjects(mediaDetails.contentID, @"663898843579179008");
    XCTAssertEqual(mediaDetails.mediaType, TWTRScribeMediaTypeConsumerVideo);
}

- (void)testDidBeginPlayback_inline
{
    [self.scribeSink didBeginPlaybackFromPlaybackConfiguration:self.playbackConfiguration inTweetID:@"1" publishedByOwnerID:@"2" isInlinePlayback:YES];
    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    XCTAssertEqual(event.category, TWTRScribeEventCategoryImpressions);
    XCTAssertEqualObjects(event.eventNamespace.client, @"tfw");
    XCTAssertEqualObjects(event.eventNamespace.page, @"iOS");
    XCTAssertEqualObjects(event.eventNamespace.section, @"video");
    XCTAssertEqualObjects(event.eventNamespace.component, @"player");
    XCTAssertEqualObjects(event.eventNamespace.element, @"");
    XCTAssertEqualObjects(event.eventNamespace.action, @"inline");
}

- (void)testDidBeginInlinePlayback_fullscreen
{
    [self.scribeSink didBeginPlaybackFromPlaybackConfiguration:self.playbackConfiguration inTweetID:@"1" publishedByOwnerID:@"2" isInlinePlayback:NO];
    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    XCTAssertEqual(event.category, TWTRScribeEventCategoryImpressions);
    XCTAssertEqualObjects(event.eventNamespace.client, @"tfw");
    XCTAssertEqualObjects(event.eventNamespace.page, @"iOS");
    XCTAssertEqualObjects(event.eventNamespace.section, @"video");
    XCTAssertEqualObjects(event.eventNamespace.component, @"player");
    XCTAssertEqualObjects(event.eventNamespace.element, @"");
    XCTAssertEqualObjects(event.eventNamespace.action, @"fullscreen");
}

#pragma mark - Unique

- (void)testDidSeeTweetViewWithStyle
{
    [self.scribeSink didSeeTweetViewWithStyle:@"compact" showingActions:@"actions"];
    TWTRScribeEvent *event = self.stubScribeService.latestEvent;

    //    XCTAssertEqualObjects(event.userID, @0); // Should we even be checking this?
    XCTAssertNil(event.tweetID);
    XCTAssertEqual(event.category, TWTRScribeEventCategoryUniques);
    XCTAssertEqualObjects(event.eventNamespace, [TWTRScribeSink twitterKitTweetViewUsageNamespaceWithTweetViewStyle:@"compact" showingActions:@"actions"]);
}

#pragma mark - OAuth

- (void)testdidStartOAuthLogin
{
    [self.scribeSink didStartOAuthLogin];

    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    XCTAssertNil(event.tweetID);
    XCTAssertEqual(event.category, TWTRScribeEventCategoryUniques);
    XCTAssertEqualObjects(event.eventNamespace, [TWTRScribeSink twitterKitLoginUsageNamespace]);
}

#pragma mark - Like

- (void)testDidLike_UsesProperKeys
{
    [self.scribeSink didLikeTweetWithID:@"1" forUserID:@"1" fromViewName:TWTRScribeViewNameTweet];

    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    TWTRScribeClientEventNamespace *namespace = event.eventNamespace;

    XCTAssertEqualObjects(namespace.client, @"tfw");
    XCTAssertEqualObjects(namespace.page, @"iOS");
    XCTAssertEqualObjects(namespace.section, @"tweet");
    XCTAssertEqualObjects(namespace.component, @"");
    XCTAssertEqualObjects(namespace.element, @"actions");
    XCTAssertEqualObjects(namespace.action, @"like");
}

- (void)testDidLike_UsesProperTweetID
{
    [self.scribeSink didLikeTweetWithID:@"8937492" forUserID:@"1" fromViewName:TWTRScribeViewNameTweet];
    XCTAssertEqualObjects(self.stubScribeService.latestEvent.tweetID, @"8937492");
}

- (void)testDidLike_UsesProperCategory
{
    [self.scribeSink didUnlikeTweetWithID:@"1" forUserID:@"1" fromViewName:TWTRScribeViewNameTweet];
    XCTAssertEqual(self.stubScribeService.latestEvent.category, TWTRScribeEventCategoryImpressions);
}

- (void)testDidLike_scribesUserID
{
    [self.scribeSink didLikeTweetWithID:@"1" forUserID:@"123" fromViewName:TWTRScribeViewNameTweet];

    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    XCTAssertEqualObjects([event dictionaryRepresentation][@"profile_id"], @"123");
}

- (void)testDidLike_scribesViewNameAsSection
{
    [self.scribeSink didLikeTweetWithID:@"1" forUserID:@"1" fromViewName:TWTRScribeViewNameTweet];

    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    XCTAssertEqualObjects(event.eventNamespace.section, @"tweet");
}

- (void)testDidLike_scribesTweetDetailViewNameAsSection
{
    [self.scribeSink didLikeTweetWithID:@"1" forUserID:@"1" fromViewName:TWTRScribeViewNameTweetDetail];

    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    XCTAssertEqualObjects(event.eventNamespace.section, @"tweet_detail");
}

- (void)testDidUnlike_UsesProperKeys
{
    [self.scribeSink didUnlikeTweetWithID:@"1" forUserID:@"1" fromViewName:TWTRScribeViewNameTweet];

    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    TWTRScribeClientEventNamespace *namespace = event.eventNamespace;
    XCTAssertEqualObjects(namespace.client, @"tfw");
    XCTAssertEqualObjects(namespace.page, @"iOS");
    XCTAssertEqualObjects(namespace.section, @"tweet");
    XCTAssertEqualObjects(namespace.component, @"");
    XCTAssertEqualObjects(namespace.element, @"actions");
    XCTAssertEqualObjects(namespace.action, @"unlike");
}

- (void)testDidUnlike_scribesUserID
{
    [self.scribeSink didUnlikeTweetWithID:@"1" forUserID:@"123" fromViewName:TWTRScribeViewNameTweet];

    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    XCTAssertEqualObjects([event dictionaryRepresentation][@"profile_id"], @"123");
}

- (void)testDidUnlike_scribesViewNameAsSection
{
    [self.scribeSink didUnlikeTweetWithID:@"1" forUserID:@"1" fromViewName:TWTRScribeViewNameTweet];

    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    XCTAssertEqualObjects(event.eventNamespace.section, @"tweet");
}

- (void)testDidUnlike_scribesTweetDetailViewNameAsSection
{
    [self.scribeSink didUnlikeTweetWithID:@"1" forUserID:@"1" fromViewName:TWTRScribeViewNameTweetDetail];

    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    XCTAssertEqualObjects(event.eventNamespace.section, @"tweet_detail");
}

#pragma mark - Composer

- (void)testDidSeeComposerWithCardType
{
    [self.scribeSink didOpenComposer];

    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    TWTRScribeClientEventNamespace *namespace = event.eventNamespace;
    XCTAssertEqualObjects(namespace.client, @"tfw");
    XCTAssertEqualObjects(namespace.page, @"iOS");
    XCTAssertEqualObjects(namespace.section, @"composer");
    XCTAssertEqualObjects(namespace.component, @"");
    XCTAssertEqualObjects(namespace.element, @"");
    XCTAssertEqualObjects(namespace.action, @"impression");
}

- (void)testDidTapCancelComposerWithCardType
{
    [self.scribeSink didTapCancelFromComposerWithSelectedUserID:@"234"];

    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    XCTAssertEqualObjects(event.userID, @"234");
    TWTRScribeClientEventNamespace *namespace = event.eventNamespace;
    XCTAssertEqualObjects(namespace.client, @"tfw");
    XCTAssertEqualObjects(namespace.page, @"iOS");
    XCTAssertEqualObjects(namespace.section, @"composer");
    XCTAssertEqualObjects(namespace.component, @"");
    XCTAssertEqualObjects(namespace.element, @"cancel");
    XCTAssertEqualObjects(namespace.action, @"click");
}

- (void)testDidTapTweetComposerWithCardType
{
    [self.scribeSink didTapSendFromComposerWithSelectedUserID:@"345"];

    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    XCTAssertEqualObjects(event.userID, @"345");
    TWTRScribeClientEventNamespace *namespace = event.eventNamespace;
    XCTAssertEqualObjects(namespace.client, @"tfw");
    XCTAssertEqualObjects(namespace.page, @"iOS");
    XCTAssertEqualObjects(namespace.section, @"composer");
    XCTAssertEqualObjects(namespace.component, @"");
    XCTAssertEqualObjects(namespace.element, @"tweet");
    XCTAssertEqualObjects(namespace.action, @"click");
}

#pragma mark - Tweet Sharing

- (void)testDidShareTweet_properNamespaceForTweet
{
    [self.scribeSink didShareTweetWithID:@"1" forUserID:@"123" fromViewName:TWTRScribeViewNameTweet];
    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    TWTRScribeClientEventNamespace *namespace = event.eventNamespace;
    XCTAssertEqualObjects(namespace.client, @"tfw");
    XCTAssertEqualObjects(namespace.page, @"iOS");
    XCTAssertEqualObjects(namespace.section, @"tweet");
    XCTAssertEqualObjects(namespace.component, @"default");
    XCTAssertEqualObjects(namespace.element, @"");
    XCTAssertEqualObjects(namespace.action, @"share");
}

- (void)testDidShareTweet_properNamespaceForTweetDetail
{
    [self.scribeSink didShareTweetWithID:@"1" forUserID:@"123" fromViewName:TWTRScribeViewNameTweetDetail];
    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    TWTRScribeClientEventNamespace *namespace = event.eventNamespace;
    XCTAssertEqualObjects(namespace.client, @"tfw");
    XCTAssertEqualObjects(namespace.page, @"iOS");
    XCTAssertEqualObjects(namespace.section, @"tweet_detail");
    XCTAssertEqualObjects(namespace.component, @"");
    XCTAssertEqualObjects(namespace.element, @"");
    XCTAssertEqualObjects(namespace.action, @"share");
}

- (void)testDidShareTweet_setsTweetID
{
    [self.scribeSink didShareTweetWithID:@"1" forUserID:@"123" fromViewName:TWTRScribeViewNameTweet];
    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    TWTRScribeItem *tweetItem = event.items.firstObject;
    XCTAssertEqual(tweetItem.itemType, TWTRScribeItemTypeTweet);
    XCTAssertEqualObjects(tweetItem.itemID, @"1");
}

- (void)testDidShareTweet_setsUserID
{
    [self.scribeSink didShareTweetWithID:@"1" forUserID:@"123" fromViewName:TWTRScribeViewNameTweet];
    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    XCTAssertEqualObjects([event dictionaryRepresentation][@"profile_id"], @"123");
}

#pragma mark - Namespaces

- (void)testTweetLoadNamespace
{
    TWTRScribeClientEventNamespace *namespace = [TWTRScribeSink tweetLoadNamespace];
    XCTAssertEqualObjects(namespace.client, TWTRScribeEventImpressionClient);
    XCTAssertEqualObjects(namespace.page, TWTRScribeEventImpressionPage);
    XCTAssertEqualObjects(namespace.section, TWTRScribeEventImpressionSectionTweet);
    XCTAssertEqualObjects(namespace.component, TWTRScribeEventImpressionComponent);
    XCTAssertEqualObjects(namespace.element, TWTRScribeEmptyKey);
    XCTAssertEqualObjects(namespace.action, TWTRScribeEventImpressionTypeLoad);
}

- (void)testTweetViewImpressionNamespaceWithStyle
{
    TWTRScribeClientEventNamespace *namespace = [TWTRScribeSink tweetViewImpressionNamespaceWithStyle:@"compact" showingActions:@"actions"];
    XCTAssertEqualObjects(namespace.client, TWTRScribeEventImpressionClient);
    XCTAssertEqualObjects(namespace.page, TWTRScribeEventImpressionPage);
    XCTAssertEqualObjects(namespace.section, TWTRScribeEventImpressionSectionTweet);
    XCTAssertEqualObjects(namespace.component, @"compact");
    XCTAssertEqualObjects(namespace.element, @"actions");
    XCTAssertEqualObjects(namespace.action, TWTRScribeEventImpressionTypeImpression);
}

- (void)testTweetViewShareNamespace
{
    TWTRScribeClientEventNamespace *namespace = [TWTRScribeSink tweetViewShareNamespace];
    XCTAssertEqualObjects(namespace.client, TWTRScribeEventImpressionClient);
    XCTAssertEqualObjects(namespace.page, TWTRScribeEventImpressionPage);
    XCTAssertEqualObjects(namespace.section, TWTRScribeEventImpressionSectionTweet);
    XCTAssertEqualObjects(namespace.component, TWTRScribeEventImpressionComponent);
    XCTAssertEqualObjects(namespace.element, TWTRScribeEmptyKey);
    XCTAssertEqualObjects(namespace.action, TWTRScribeEventImpressionTypeShare);
}

- (void)testTwitterKitTweetViewUsageNamespaceWithTweetViewStyle
{
    TWTRScribeClientEventNamespace *namespace = [TWTRScribeSink twitterKitTweetViewUsageNamespaceWithTweetViewStyle:@"compact" showingActions:@"actions"];
    XCTAssertEqualObjects(namespace.client, TWTRScribeEventUniquesClient);
    XCTAssertEqualObjects(namespace.page, TWTRScribeEventUniquesPageTweetViews);
    XCTAssertEqualObjects(namespace.section, @"compact");
    XCTAssertEqualObjects(namespace.component, @"actions");
    XCTAssertEqualObjects(namespace.element, TWTRScribeClientEventNamespaceEmptyValue);
    XCTAssertEqualObjects(namespace.action, TWTRScribeEventUniquesAction);
}

- (void)testTwitterKitLoginUsageNamespace
{
    [self validateTwitterKitUsageNamespacesWithNamespace:[TWTRScribeSink twitterKitLoginUsageNamespace] expectedPage:TWTRScribeEventUniquesPageLogin];
}

- (void)validateTwitterKitUsageNamespacesWithNamespace:(TWTRScribeClientEventNamespace *)namespace expectedPage:(NSString *)expectedPage
{
    XCTAssertEqualObjects(namespace.client, TWTRScribeEventUniquesClient);
    XCTAssertEqualObjects(namespace.page, expectedPage);
    XCTAssertEqualObjects(namespace.section, TWTRScribeClientEventNamespaceEmptyValue);
    XCTAssertEqualObjects(namespace.component, TWTRScribeClientEventNamespaceEmptyValue);
    XCTAssertEqualObjects(namespace.element, TWTRScribeClientEventNamespaceEmptyValue);
    XCTAssertEqualObjects(namespace.action, TWTRScribeEventUniquesAction);
}

#pragma mark - Photo Gallery

- (void)testGalleryNamespace_show
{
    [self.scribeSink didPresentPhotoGallery];

    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    XCTAssertEqualObjects(event.eventNamespace.section, @"gallery");
    XCTAssertEqualObjects(event.eventNamespace.action, @"show");
}

- (void)testGalleryNamespace_impression
{
    [self.scribeSink didSeeMediaEntity:self.mediaEntity fromTweetID:@"83279"];

    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    XCTAssertEqualObjects(event.eventNamespace.section, @"gallery");
    XCTAssertEqualObjects(event.eventNamespace.action, @"impression");
    XCTAssertEqualObjects(event.tweetID, @"83279");
}

- (void)testGalleryNamespace_navigate
{
    [self.scribeSink didNavigateInsideGallery];

    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    XCTAssertEqualObjects(event.eventNamespace.section, @"gallery");
    XCTAssertEqualObjects(event.eventNamespace.action, @"navigate");
}

- (void)testGalleryNamespace_dismiss
{
    [self.scribeSink didDismissPhotoGallery];

    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    XCTAssertEqualObjects(event.eventNamespace.section, @"gallery");
    XCTAssertEqualObjects(event.eventNamespace.action, @"dismiss");
}

#pragma mark - Login

- (void)testMobileSSOAuth_start
{
    [self.scribeSink didStartSSOLogin];

    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    XCTAssertEqualObjects(event.eventNamespace.client, @"tfw");
    XCTAssertEqualObjects(event.eventNamespace.page, @"iOS");
    XCTAssertEqualObjects(event.eventNamespace.section, @"auth");
    XCTAssertEqualObjects(event.eventNamespace.component, @"app");
    XCTAssertEqualObjects(event.eventNamespace.element, @"");
    XCTAssertEqualObjects(event.eventNamespace.action, @"start");
}

- (void)testMobileSSOAuth_finish
{
    [self.scribeSink didFinishSSOLogin];

    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    XCTAssertEqualObjects(event.eventNamespace.client, @"tfw");
    XCTAssertEqualObjects(event.eventNamespace.page, @"iOS");
    XCTAssertEqualObjects(event.eventNamespace.section, @"auth");
    XCTAssertEqualObjects(event.eventNamespace.component, @"app");
    XCTAssertEqualObjects(event.eventNamespace.element, @"");
    XCTAssertEqualObjects(event.eventNamespace.action, @"success");
}

- (void)testMobileSSOAuth_cancel
{
    [self.scribeSink didCancelSSOLogin];

    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    XCTAssertEqualObjects(event.eventNamespace.client, @"tfw");
    XCTAssertEqualObjects(event.eventNamespace.page, @"iOS");
    XCTAssertEqualObjects(event.eventNamespace.section, @"auth");
    XCTAssertEqualObjects(event.eventNamespace.component, @"app");
    XCTAssertEqualObjects(event.eventNamespace.element, @"");
    XCTAssertEqualObjects(event.eventNamespace.action, @"cancelled");
}

- (void)testMobileSSOAuth_fail
{
    [self.scribeSink didFailSSOLogin];

    TWTRScribeEvent *event = self.stubScribeService.latestEvent;
    XCTAssertEqualObjects(event.eventNamespace.client, @"tfw");
    XCTAssertEqualObjects(event.eventNamespace.page, @"iOS");
    XCTAssertEqualObjects(event.eventNamespace.section, @"auth");
    XCTAssertEqualObjects(event.eventNamespace.component, @"app");
    XCTAssertEqualObjects(event.eventNamespace.element, @"");
    XCTAssertEqualObjects(event.eventNamespace.action, @"failure");
}

@end
