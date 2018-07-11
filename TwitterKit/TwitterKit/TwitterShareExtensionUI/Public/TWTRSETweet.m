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

#import "TWTRSETweet.h"
#import "TWTRSEAccount.h"
#import "TWTRSETweetAttachment.h"

@interface TWTRSETweet ()
@property (nullable, nonatomic, readonly) NSString *textWithAttachmentURLs;
@end

@implementation TWTRSETweet

static Class<TwitterTextProtocol> sTwitterTextClass;

+ (void)setTwitterText:(Class<TwitterTextProtocol>)twitterText
{
    sTwitterTextClass = twitterText;
}

+ (Class<TwitterTextProtocol>)twitterText
{
    return sTwitterTextClass;
}

- (instancetype)initWithInReplyToTweetID:(NSNumber *)inReplyToTweetID text:(NSString *)text attachment:(id<TWTRSETweetAttachment>)attachment place:(id<TWTRSEGeoPlace>)place usernames:(NSArray<NSString *> *)usernames hashtags:(NSArray<NSString *> *)hashtags
{
    if ((self = [super init])) {
        _inReplyToTweetID = [inReplyToTweetID copy];
        _attachment = attachment;
        _place = place;

        _text = [self textWithLeadingUsernames:usernames hashtags:hashtags text:text];
    }

    return self;
}

+ (TWTRSETweet *)emptyTweet
{
    return [[self alloc] initWithInReplyToTweetID:nil text:@"" attachment:nil place:nil usernames:nil hashtags:nil];
}

- (nullable NSString *)textWithAttachmentURLs
{
    NSString *url = self.attachment.urlString;
    return (url && ![url hasPrefix:@"file://"]) ? [[self.text stringByAppendingString:@" "] stringByAppendingString:url] : self.text;
}

- (nonnull NSString *)textWithLeadingUsernames:(nullable NSArray<NSString *> *)usernames hashtags:(nullable NSArray<NSString *> *)hashtags text:(nullable NSString *)text
{
    NSMutableString *presentationText = [NSMutableString string];

    for (NSString *username in usernames) {
        [presentationText appendFormat:@"%@ ", TWTRSEDisplayUsername(username)];
    }

    [presentationText appendString:text ?: @""];

    for (NSString *hashtag in hashtags) {
        [presentationText appendString:[@" #" stringByAppendingString:hashtag]];
    }

    return [presentationText copy];
}

- (NSInteger)remainingCharacters
{
    return [[[self class] twitterText] remainingCharacterCount:self.textWithAttachmentURLs];
}

- (BOOL)isWithinCharacterLimit
{
    return [[[self class] twitterText] remainingCharacterCount:self.textWithAttachmentURLs] >= 0;
}

- (BOOL)isNearOrOverCharacterLimit
{
    return [[[self class] twitterText] remainingCharacterCount:self.textWithAttachmentURLs] < 20;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return [[TWTRSETweet alloc] initWithInReplyToTweetID:self.inReplyToTweetID text:self.text attachment:self.attachment place:self.place usernames:nil hashtags:nil];
}

@end
