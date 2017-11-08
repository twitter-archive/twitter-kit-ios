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
#import "TWTRAPIConstantsStatus.h"
#import "TWTRCardEntity.h"
#import "TWTRFixtureLoader.h"
#import "TWTRPlayerCardEntity.h"
#import "TWTRTestCase.h"
#import "TWTRTweetMediaEntity.h"
#import "TWTRTweetRepository.h"
#import "TWTRTweet_Private.h"
#import "TWTRUser.h"
#import "TWTRVideoMetaData.h"

typedef void (^InvocationBlock)(NSInvocation *);

@interface TWTRTweetTests : TWTRTestCase

@property (nonatomic) TWTRTweet *tweet;
@property (nonatomic) NSDictionary *tweetDict;
@property (nonatomic) TWTRTweet *tweetWithRetweet;
@property (nonatomic) TWTRTweet *replyTweet;
@property (nonatomic) TWTRTweet *retweet;
@property (nonatomic) TWTRTweet *videoTweet;
@property (nonatomic) NSDictionary *videoTweetDict;
@property (nonatomic) id mockRepo;

@end

@implementation TWTRTweetTests

- (void)setUp
{
    [super setUp];

    id mockRepo = [OCMockObject mockForClass:[TWTRTweetRepository class]];

    self.tweetDict = [TWTRFixtureLoader dictFromJSONFile:@"ObamaTweet.json"];
    NSDictionary *tweetWithRetweetDict = [TWTRFixtureLoader dictFromJSONFile:@"ObamaRetweet.json"];

    TWTRTweet *tweet = [TWTRFixtureLoader obamaTweet];
    [tweet setValue:mockRepo forKey:@"tweetRepo"];

    TWTRTweet *tweetWithRetweet = [[TWTRTweet alloc] initWithJSONDictionary:tweetWithRetweetDict];
    [tweetWithRetweet setValue:mockRepo forKey:@"tweetRepo"];

    TWTRTweet *replyTweet = [[TWTRTweet alloc] initWithJSONDictionary:[TWTRFixtureLoader dictFromJSONFile:@"IndianBurgerReplyTweet.json"]];
    [replyTweet setValue:mockRepo forKey:@"tweetRepo"];

    TWTRTweet *retweet = [TWTRFixtureLoader retweetTweet];
    [retweet setValue:mockRepo forKey:@"tweetRepo"];

    self.tweet = tweet;
    self.tweetWithRetweet = tweetWithRetweet;
    self.retweet = retweet;
    self.replyTweet = replyTweet;
    self.videoTweet = [TWTRFixtureLoader videoTweet];
    self.videoTweetDict = [TWTRFixtureLoader dictFromJSONFile:@"MovieTweet.json"];
    self.mockRepo = mockRepo;
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [self setTweet:nil];
    [self.mockRepo stopMocking];
    [super tearDown];
}

#pragma mark - Init

- (void)testInitWithJsonDictionaryTweetAttributes
{
    TWTRTweet *tweet = [self tweet];

    XCTAssertTrue([@"266031293945503744" isEqualToString:tweet.tweetID], @"Tweet ID not set properly");

    NSDate *expectedDate = [NSDate dateWithTimeIntervalSince1970:1352261778];
    XCTAssertEqualObjects(expectedDate, [tweet createdAt], @"Tweet data not set properly");

    XCTAssertTrue([tweet isLiked], @"Tweet should be favorited");
    XCTAssertFalse([tweet isRetweeted], @"Tweet should be retweeted");
    XCTAssertEqual(742891ll, [tweet retweetCount], @"Retweet count not set properly");
    XCTAssertEqual(290344ll, [tweet likeCount], @"Like count not set properly");
}

- (void)testInitWithJsonDictionaryAuthor
{
    TWTRUser *user = [[self tweet] author];

    XCTAssertNotNil(user, @"Author not set");
    XCTAssertEqualObjects(@"BarackObama", [user screenName], @"Author screen name for tweet not set properly");
    XCTAssertEqualObjects(@"Barack Obama", [user name], @"Author screen name for tweet not set properly");
    XCTAssertTrue([user isVerified], @"Author verified status for tweet not set properly");
}

- (void)testInitWithJsonDictionaryRetweet
{
    TWTRTweet *tweet = self.tweetWithRetweet;
    XCTAssertTrue([tweet.retweetID isEqualToString:@"492812034954637312"], @"Tweet retweet id not set properly");
}

- (void)testInitWithJsonDictionaryReply
{
    TWTRTweet *reply = self.replyTweet;
    XCTAssertTrue([reply.inReplyToUserID isEqualToString:@"18353903"], @"Tweet inReplyToUserID not set properly");
    XCTAssertTrue([reply.inReplyToScreenName isEqualToString:@"kang"], @"Tweet inReplyToScreenName not set properly");
    XCTAssertTrue([reply.inReplyToTweetID isEqualToString:@"483405064757719040"], @"Tweet inReplyToTweetID not set properly");
}

- (void)testInitWithJsonDictionaryMedias
{
    NSArray *media = [[self tweet] media];

    XCTAssertEqual(1, [media count], @"Media entity is missing");
}

- (void)testTweetsWithJSONArrayEmpty
{
    NSArray *tweets = [TWTRTweet tweetsWithJSONArray:@[]];
    XCTAssertTrue([tweets count] == 0, @"Should have 0 tweets");
}

- (void)testTweetsWithJSONArrayNil
{
    NSArray *tweets = [TWTRTweet tweetsWithJSONArray:nil];
    XCTAssertTrue([tweets count] == 0, @"Should have 0 tweets");
}

- (void)testTweetsWithJSONArrayOne
{
    NSArray *tweets = [TWTRTweet tweetsWithJSONArray:@[[self tweetDict]]];
    XCTAssertTrue([tweets count] == 1, @"Should have 1 tweet");
}

- (void)testTweetsWithJSONArrayMultiple
{
    NSArray *tweetJSONArray = @[[self tweetDict], [self tweetDict]];
    NSArray *tweets = [TWTRTweet tweetsWithJSONArray:tweetJSONArray];
    XCTAssertTrue([tweets count] == 2, @"Should have 2 tweets");
}

- (void)testTweetWithFavoriteToggled_returnsNewTweet
{
    XCTAssert(self.tweet != [self.tweet tweetWithLikeToggled]);
}

- (void)testTweetWithFavoriteToggled_togglesValue
{
    TWTRTweet *toggledTweet = [self.tweet tweetWithLikeToggled];
    XCTAssertEqual(toggledTweet.isLiked, NO);
}

- (void)testTweetWithFavoriteToggled_togglesTwiceProperly
{
    TWTRTweet *doubleToggledTweet = [[self.tweet tweetWithLikeToggled] tweetWithLikeToggled];
    XCTAssertEqual(doubleToggledTweet.isLiked, YES);
}

- (void)testTweetEncoding
{
    TWTRTweet *tweet = self.replyTweet;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:tweet];
    XCTAssertTrue([data length] > 0, @"Encoded Tweet invalid.");
}

- (void)testTweetDecoding
{
    TWTRTweet *tweet = self.replyTweet;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:tweet];
    TWTRTweet *decodedTweet = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [self assertDecodedTweet:decodedTweet equalToOriginalTweet:tweet];
    XCTAssertEqualObjects(decodedTweet, tweet);
}

- (void)testTweetDecoding_videoTweet
{
    TWTRTweet *originalTweet = self.videoTweet;
    NSData *archivedTweet = [NSKeyedArchiver archivedDataWithRootObject:originalTweet];
    TWTRTweet *decodedTweet = [NSKeyedUnarchiver unarchiveObjectWithData:archivedTweet];
    [self assertDecodedTweet:decodedTweet equalToOriginalTweet:originalTweet];
    XCTAssertEqualObjects(originalTweet.media, decodedTweet.media);
    XCTAssertEqualObjects(originalTweet, decodedTweet);
}

- (void)testTweetDecoding_vineTweet
{
    TWTRTweet *originalTweet = [TWTRFixtureLoader vineTweetV13];
    NSData *archivedTweet = [NSKeyedArchiver archivedDataWithRootObject:originalTweet];
    TWTRTweet *decodedTweet = [NSKeyedUnarchiver unarchiveObjectWithData:archivedTweet];
    [self assertDecodedTweet:decodedTweet equalToOriginalTweet:originalTweet];
    XCTAssertEqualObjects(originalTweet.media, decodedTweet.media);
    XCTAssertEqualObjects(originalTweet, decodedTweet);
}

- (void)testTweetHasMediaTrue
{
    XCTAssertTrue(self.tweet.hasMedia, @"Tweet should have media");
}

- (void)testTweetHasMediaFalse
{
    XCTAssertFalse(self.replyTweet.hasMedia, @"Tweet should not have media");
}

- (void)testTweetMediaUsesHTTPS
{
    XCTAssert([self.tweet.media.firstObject.mediaUrl hasPrefix:@"https://"]);
}

- (void)testTweetMediaMediaURL
{
    XCTAssert([self.tweet.media.firstObject.mediaUrl isEqualToString:@"https://pbs.twimg.com/media/A7EiDWcCYAAZT1D.jpg"]);
}

- (void)testTweetMediaDisplayURL
{
    XCTAssert([self.tweet.media.firstObject.displayURL isEqualToString:@"pic.twitter.com/bAJE6Vom"]);
}

- (void)testTweetMediaTweetTextURL
{
    XCTAssert([self.tweet.media.firstObject.tweetTextURL isEqualToString:@"http://t.co/bAJE6Vom"]);
}

- (void)testTweetText
{
    XCTAssert([self.tweet.text isEqualToString:@"Four more years. http://t.co/bAJE6Vom"]);
}

- (void)testTweetLinkText
{
    TWTRTweet *gatesTweet = [TWTRFixtureLoader gatesTweet];

    XCTAssert([gatesTweet.text isEqualToString:@"Life-saving innovations don’t have to be high-tech. @MelindaGates explains in the @WSJ: http://t.co/JteTVkVqWn"]);
}

- (void)testMediaEntity
{
    XCTAssertNotNil(self.tweet.media.firstObject, @"Tweet should have at least one media entity.");
    XCTAssertNotNil(self.tweet.media.firstObject.mediaUrl, @"Media entity should have url");
    XCTAssertTrue([self.tweet.media.firstObject.sizes count] > 0, @"Media entity should have different sizes");
}

- (void)testLanguageCode_initialParse
{
    XCTAssert([self.tweet.languageCode isEqualToString:@"en"]);
}

- (void)testLanguageCode_copy
{
    TWTRTweet *copy = [self.tweet copy];
    XCTAssert([copy.languageCode isEqualToString:@"en"]);
}

- (void)testLanguageCode_serialized
{
    NSData *serializedTweet = [NSKeyedArchiver archivedDataWithRootObject:self.tweet];
    TWTRTweet *decodedTweet = [NSKeyedUnarchiver unarchiveObjectWithData:serializedTweet];

    XCTAssert([decodedTweet.languageCode isEqualToString:@"en"]);
}

- (void)testMediaEntity_copy
{
    TWTRTweetMediaEntity *copy = [self.tweet.media.firstObject copy];
    XCTAssertEqualObjects(copy, self.tweet.media.firstObject);
}

- (void)testMediaEntity_equality
{
    TWTRTweetMediaEntity *first = [TWTRFixtureLoader obamaTweet].media.firstObject;
    TWTRTweetMediaEntity *second = [TWTRFixtureLoader obamaTweet].media.firstObject;

    XCTAssertTrue([first isEqual:second]);
}

- (void)testMediaEntity_notEqual
{
    TWTRTweetMediaEntity *first = [TWTRFixtureLoader obamaTweet].media.firstObject;
    TWTRTweetMediaEntity *second = [TWTRFixtureLoader videoTweet].media.firstObject;

    XCTAssertFalse(first == second);
    XCTAssertFalse([first isEqual:second]);
}

- (void)testRetweetedTweet_notNil
{
    XCTAssertNotNil(self.retweet.retweetedTweet);
}

- (void)testRetweetedTweet_parsesRetweetedTweetID
{
    XCTAssertEqualObjects(self.retweet.retweetedTweet.tweetID, @"572827576265252864");
}

- (void)testRetweetedTweet_supportsNSCoding
{
    TWTRTweet *tweet = self.retweet;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:tweet];
    TWTRTweet *decodedTweet = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    [self assertDecodedTweet:decodedTweet equalToOriginalTweet:tweet];
}

- (void)testVideoTweet_hasVideoEntity
{
    XCTAssertNotNil([self.videoTweet videoMetaData]);
}

- (void)testCashTagTweet_hasCashTag
{
    TWTRTweet *tweet = [TWTRFixtureLoader cashtagTweet];
    XCTAssert(tweet.cashtags.count == 1);
}

- (void)testVideoTweet_properClass
{
    XCTAssert([[self.videoTweet videoMetaData] isKindOfClass:[TWTRVideoMetaData class]]);
}

- (void)testVideoTweet_noVideoEntityForRegularTweet
{
    XCTAssert([self.tweet videoMetaData] == nil);
}

- (void)testVideoTweet_copyMediaEntity
{
    TWTRTweetMediaEntity *copy = [self.videoTweet.videoMetaData copy];
    XCTAssertEqualObjects(copy, self.videoTweet.videoMetaData);
}

- (void)testVideoTweet_equal
{
    TWTRVideoMetaData *first = [TWTRFixtureLoader videoTweet].videoMetaData;
    TWTRVideoMetaData *second = [TWTRFixtureLoader videoTweet].videoMetaData;

    XCTAssertTrue([first isEqual:second]);
}

- (void)testVideoTweet_notEqual
{
    TWTRVideoMetaData *first = [TWTRFixtureLoader videoTweet].videoMetaData;
    TWTRVideoMetaData *second = [TWTRFixtureLoader obamaTweet].videoMetaData;

    XCTAssertFalse(first == second);
    XCTAssertFalse([first isEqual:second]);
}

- (void)testTweetParsing_DoesntCrashWithOldFormat
{
    NSMutableDictionary *oldFormatJSON = [self.tweetDict mutableCopy];
    oldFormatJSON[@"extended_entities"] = nil;

    XCTAssertNoThrow([[TWTRTweet alloc] initWithJSONDictionary:oldFormatJSON]);
}

- (void)testVineTweet_containsCard
{
    TWTRTweet *vineTweet = [TWTRFixtureLoader vineTweetV13];
    XCTAssertNotNil(vineTweet.cardEntity);

    XCTAssertTrue([vineTweet.cardEntity isKindOfClass:[TWTRPlayerCardEntity class]]);
    TWTRPlayerCardEntity *entity = (TWTRPlayerCardEntity *)vineTweet.cardEntity;

    XCTAssertEqual(entity.playerCardType, TWTRPlayerCardTypeVine);
}

- (void)testTweetEntities_containsHashtags
{
    NSDictionary *entitiesDict = self.videoTweetDict[@"entities"];
    XCTAssert([[entitiesDict allKeys] containsObject:@"hashtags"]);
}

- (void)testTweetEntities_containsSymbols
{
    NSDictionary *entitiesDict = self.videoTweetDict[@"entities"];
    XCTAssert([[entitiesDict allKeys] containsObject:@"symbols"]);
}

- (void)testTweetEntities_containsURLs
{
    NSDictionary *entitiesDict = self.videoTweetDict[@"entities"];
    XCTAssert([[entitiesDict allKeys] containsObject:@"urls"]);
}

- (void)testTweetEntities_containsUserMentions
{
    NSDictionary *entitiesDict = self.videoTweetDict[@"entities"];
    XCTAssert([[entitiesDict allKeys] containsObject:@"user_mentions"]);
}

- (void)testTweetEntities_parsedUserMentions
{
    NSArray *userMentions = self.videoTweetDict[@"entities"][@"user_mentions"];
    XCTAssertEqual([userMentions count], 3);
}

- (void)testExtendedTweetSetsTextProperty
{
    TWTRTweet *tweet = [TWTRFixtureLoader extendedTweet];
    XCTAssertEqualObjects(tweet.text, @"@jeremycloud It's neat to have owls and raccoons around until you realize that raccoons will eat the eggs from the owl's nest https://t.co/Q0pkaU4ORH");
}

- (void)testNormalTweet_isNotQuoteTweet
{
    XCTAssertFalse(self.tweet.isQuoteTweet);
    XCTAssertNil(self.tweet.quotedTweet);
}

- (void)testQuoteTweet_isQouteTweet
{
    TWTRTweet *quoteTweet = [TWTRFixtureLoader quoteTweet];
    XCTAssert(quoteTweet.isQuoteTweet);
}

- (void)testQuoteTweet_quoteTweetStatus
{
    TWTRTweet *quoteTweet = [TWTRFixtureLoader quoteTweet];
    XCTAssertNotNil(quoteTweet.quotedTweet);
    XCTAssertEqualObjects(quoteTweet.quotedTweet.tweetID, @"735617035615408128");
}

#pragma mark - Test Helpers
- (void)assertDecodedTweet:(TWTRTweet *)decodedTweet equalToOriginalTweet:(TWTRTweet *)originalTweet
{
    XCTAssertEqualObjects(originalTweet.tweetID, decodedTweet.tweetID);
    XCTAssertEqual(originalTweet.likeCount, decodedTweet.likeCount);
    XCTAssertEqual(originalTweet.retweetCount, decodedTweet.retweetCount);
    XCTAssertEqualObjects(originalTweet.inReplyToTweetID, decodedTweet.inReplyToTweetID);
    XCTAssertEqualObjects(originalTweet.inReplyToScreenName, decodedTweet.inReplyToScreenName);
    XCTAssertEqualObjects(originalTweet.inReplyToUserID, decodedTweet.inReplyToUserID);
    XCTAssertTrue(originalTweet.retweetID == decodedTweet.retweetID || [originalTweet.retweetID isEqualToString:decodedTweet.retweetID], @"Decoded Tweet retweetID does not match");
    XCTAssertTrue([originalTweet.createdAt isEqualToDate:decodedTweet.createdAt]);
    XCTAssertEqualObjects(originalTweet.text, decodedTweet.text);
    XCTAssertEqualObjects(originalTweet.author.userID, decodedTweet.author.userID);
    XCTAssertEqual([originalTweet.hashtags count], [decodedTweet.hashtags count]);
    XCTAssertEqual([originalTweet.media count], [decodedTweet.media count]);
    XCTAssertEqual([originalTweet.urls count], [decodedTweet.urls count]);
    XCTAssertEqual([originalTweet.userMentions count], [decodedTweet.userMentions count]);
    XCTAssertEqual(originalTweet.isLiked, decodedTweet.isLiked);
    XCTAssertEqual(originalTweet.isRetweeted, decodedTweet.isRetweeted);
    XCTAssertEqualObjects(originalTweet.languageCode, decodedTweet.languageCode);
    XCTAssertEqualObjects(originalTweet.cardEntity, decodedTweet.cardEntity);
}

#pragma mark - Performance Tests
// TODO: @kang These tests seem to be really flakey when run on CI box. Graph them instead of asserting
- (void)DISABLE_testTweetParsingFromJSONDictionaryPerformance
{
    size_t iterations = 100;
    uint64_t averageTime = dispatch_benchmark(iterations, ^{
        @autoreleasepool {
            __unused TWTRTweet *obamaTweet = [[TWTRTweet alloc] initWithJSONDictionary:self.tweetDict];
        }
    });
    XCTAssert(averageTime <= 500000);  // ns
}

@end
