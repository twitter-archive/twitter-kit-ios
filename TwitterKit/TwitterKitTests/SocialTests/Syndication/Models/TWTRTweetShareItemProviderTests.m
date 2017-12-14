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
#import "TWTRFixtureLoader.h"
#import "TWTRTestCase.h"
#import "TWTRTranslationsUtil.h"
#import "TWTRTweet.h"
#import "TWTRTweetShareItemProvider.h"
#import "TWTRTweetShareItemProvider_Private.h"
#import "TWTRUser.h"

static TWTRTweet *tweet;

@interface TWTRTweetShareItemProviderTests : TWTRTestCase

@property (nonatomic, strong) TWTRTweetShareItemProvider *shareItemProvider;
@property (nonatomic, strong) id placeholderItem;
@property (nonatomic, strong) id item;

@end

@implementation TWTRTweetShareItemProviderTests

+ (void)setUp
{
    tweet = [TWTRFixtureLoader obamaTweet];
}

- (void)setUp
{
    [super setUp];

    self.shareItemProvider = [[TWTRTweetShareItemProvider alloc] initWithTweet:tweet];
    self.placeholderItem = self.shareItemProvider.placeholderItem;
    self.item = self.shareItemProvider.item;
}

- (void)testPlaceholderOfTypeString
{
    XCTAssert([self.placeholderItem isKindOfClass:[NSString class]]);
}

- (void)testPlaceholderSameTypeAsItem
{
    XCTAssert([self.placeholderItem isKindOfClass:[self.item class]], @"Apple SDK spec requires placeholderItem and item to be the same class");
}

- (void)testPlaceholderValue_empty
{
    NSString *placeholderItem = self.placeholderItem;
    XCTAssert([placeholderItem isEqualToString:TWTRTweetShareItemProviderPlaceholder]);
}

- (void)testItemValue
{
    TWTRUser *author = tweet.author;
    NSString *shareContent = [NSString stringWithFormat:@"Check out @%1$@\'s Tweet: https://twitter.com/%1$@/status/%2$@", author.screenName, tweet.tweetID];
    NSString *itemString = self.item;
    XCTAssert([shareContent isEqualToString:itemString]);
}

- (void)testSubjectForActivityType
{
    TWTRUser *author = tweet.author;
    NSString *shareSubject = [NSString stringWithFormat:@"Tweet from %1$@ (@%2$@)", author.name, author.screenName];
    NSString *shareItemSubject = [self.shareItemProvider activityViewController:OCMClassMock([UIActivityViewController class]) subjectForActivityType:nil];
    XCTAssert([shareSubject isEqualToString:shareItemSubject]);
}

@end
