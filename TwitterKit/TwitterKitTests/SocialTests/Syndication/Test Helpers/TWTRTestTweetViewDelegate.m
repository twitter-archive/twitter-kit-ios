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

#import "TWTRTestTweetViewDelegate.h"
#import <TwitterCore/TWTRSession.h>
#import <TwitterCore/TWTRSessionStore.h>

@implementation TWTRActionAndSessionTweetViewDelegate

- (instancetype)initWithSessionStore:(id<TWTRSessionStore>)sessionStore session:(TWTRSession *)session
{
    if (self = [super init]) {
        _sessionStore = sessionStore;
        _session = session;
    }
    return self;
}

- (void)tweetView:(TWTRTweetView *)tweetView didLikeTweet:(TWTRTweet *)tweet
{ /* not implemented */
}

- (void)tweetView:(TWTRTweetView *)tweetView didUnlikeTweet:(TWTRTweet *)tweet
{ /* not implemented */
}

@end

@implementation TWTRActionTweetViewDelegate

- (void)tweetView:(TWTRTweetView *)tweetView didLikeTweet:(TWTRTweet *)tweet
{ /* not implemented */
}

- (void)tweetView:(TWTRTweetView *)tweetView didUnlikeTweet:(TWTRTweet *)tweet
{ /* not implemented */
}

@end
