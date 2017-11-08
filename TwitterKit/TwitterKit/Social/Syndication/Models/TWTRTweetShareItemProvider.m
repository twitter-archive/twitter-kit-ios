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

#import "TWTRTweetShareItemProvider.h"
#import "TWTRTranslationsUtil.h"
#import "TWTRTweet.h"
#import "TWTRTweetShareItemProvider_Private.h"
#import "TWTRUser.h"

NSString *const TWTRTweetShareItemProviderPlaceholder = @"";
NSString *const TWTRTweetShareItemProviderTweetItemSubjectFormatString = @"tw__share_tweet_subject_format";
NSString *const TWTRTweetShareItemProviderItemFormatString = @"tw__share_tweet_generic_template_format";

@implementation TWTRTweetShareItemProvider

- (instancetype)initWithTweet:(TWTRTweet *)tweet
{
    self = [super initWithPlaceholderItem:TWTRTweetShareItemProviderPlaceholder];

    if (self) {
        self.tweet = tweet;
    }

    return self;
}

- (id)item
{
    NSString *localizedItem = TWTRLocalizedString(TWTRTweetShareItemProviderItemFormatString);
    TWTRUser *tweetAuthor = self.tweet.author;
    NSString *tweetURL = [NSString stringWithFormat:@"https://twitter.com/%@/status/%@", tweetAuthor.screenName, self.tweet.tweetID];
    return [NSString stringWithFormat:localizedItem, tweetAuthor.screenName, tweetURL];
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
    NSString *localizedItemSubject = TWTRLocalizedString(TWTRTweetShareItemProviderTweetItemSubjectFormatString);
    TWTRUser *tweetAuthor = self.tweet.author;
    NSString *tweetAuthorName = tweetAuthor.name;
    NSString *tweetAuthorScreenName = tweetAuthor.screenName;

    return [NSString stringWithFormat:localizedItemSubject, tweetAuthorName, tweetAuthorScreenName];
}

@end
