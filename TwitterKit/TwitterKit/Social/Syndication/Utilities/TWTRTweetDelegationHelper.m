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

#import "TWTRTweetDelegationHelper.h"
#import <UIKit/UIKit.h>
#import "TWTRConstants_Private.h"
#import "TWTROSVersionInfo.h"
#import "TWTRTweet.h"
#import "TWTRTweetCashtagEntity.h"
#import "TWTRTweetHashtagEntity.h"
#import "TWTRTweetUserMentionEntity.h"
#import "TWTRURLUtility.h"
#import "TWTRUser.h"

@implementation TWTRTweetDelegationHelper

+ (void)performDefaultActionForTappingProfileForUser:(TWTRUser *)user
{
    NSURL *webURL = [self URLWithReferral:user.profileURL];
    NSURL *deepLinkURL = [NSURL URLWithString:[NSString stringWithFormat:@"twitter://user?screen_name=%@", user.screenName]];
    [self openURL:webURL deeplinkURL:deepLinkURL];
}

+ (void)performDefaultActionForTappingURL:(NSURL *)URL
{
    [[UIApplication sharedApplication] openURL:URL];
}

+ (void)performDefaultActionForTappingHashtag:(TWTRTweetHashtagEntity *)hashtag
{
    NSURL *webURL = [self hashtagEntityURLString:hashtag.text];
    NSURL *deepLinkURL = [NSURL URLWithString:[NSString stringWithFormat:@"twitter://search?query=%%23%@", hashtag.text]];

    [self openURL:webURL deeplinkURL:deepLinkURL];
}

+ (void)performDefaultActionForTappingCashtag:(TWTRTweetCashtagEntity *)cashtag
{
    NSURL *webURL = [self cashtagEntityURLString:cashtag.text];
    NSURL *deepLinkURL = [NSURL URLWithString:[NSString stringWithFormat:@"twitter://search?query=%%24%@", cashtag.text]];
    [self openURL:webURL deeplinkURL:deepLinkURL];
}

+ (void)performDefaultActionForTappingUserMention:(TWTRTweetUserMentionEntity *)userMention
{
    NSURL *webURL = [self userMentionURLString:userMention.screenName];
    NSURL *deepLinkURL = [NSURL URLWithString:[NSString stringWithFormat:@"twitter://user?screen_name=%@", userMention.screenName]];
    [self openURL:webURL deeplinkURL:deepLinkURL];
}

+ (void)performDefaultActionForTappingTweet:(TWTRTweet *)tweet
{
    NSURL *webURL = [self URLWithReferral:tweet.permalink];
    NSURL *deepLinkURL = [TWTRURLUtility deepLinkURLForTweet:tweet];

    [self openURL:webURL deeplinkURL:deepLinkURL];
}

+ (void)openURL:(NSURL *)webURL deeplinkURL:(NSURL *)deepLinkURL
{
    BOOL iOS10 = [[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)];

    if (iOS10) {
        // Attempt Deep-Link
        [[UIApplication sharedApplication] openURL:deepLinkURL
            options:@{}
            completionHandler:^(BOOL success) {
                if (success == NO) {
                    // Open on web
                    [[UIApplication sharedApplication] openURL:webURL];
                }
            }];
    } else {
        if ([[UIApplication sharedApplication] canOpenURL:deepLinkURL]) {
            // Deep-link
            [[UIApplication sharedApplication] openURL:deepLinkURL];
        } else {
            // Open on web
            [[UIApplication sharedApplication] openURL:webURL];
        }
    }
}

+ (NSURL *)hashtagEntityURLString:(NSString *)hashtag
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.twitter.com/hashtag/%@", hashtag]];
    return [self URLWithReferral:url];
}

+ (NSURL *)cashtagEntityURLString:(NSString *)cashtag
{
    NSString *cashtagURL = [NSString stringWithFormat:@"https://twitter.com/search?q=%@&src=ctag", cashtag];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", cashtagURL, TWTRURLReferrer]];
    return url;
}

+ (NSURL *)userMentionURLString:(NSString *)username
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.twitter.com/%@", username]];
    return [self URLWithReferral:url];
}

+ (NSURL *)URLWithReferral:(NSURL *)originalURL
{
    NSURL *URLWithReferral = [NSURL URLWithString:TWTRURLReferrer relativeToURL:originalURL];
    return URLWithReferral;
}

@end
