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

#import "TWTRSessionFixtureLoader.h"
#import "TWTRAuthenticationConstants.h"
#import "TWTRGuestSession.h"
#import "TWTRSession.h"

@implementation TWTRSessionFixtureLoader

+ (TWTRSession *)twitterSession
{
    NSDictionary *sessionDictionary = @{ TWTRAuthOAuthTokenKey: @"token", TWTRAuthOAuthSecretKey: @"secret", TWTRAuthAppOAuthScreenNameKey: @"screen_name", TWTRAuthAppOAuthUserIDKey: @"123" };
    return [[TWTRSession alloc] initWithSessionDictionary:sessionDictionary];
}

+ (TWTRGuestSession *)twitterGuestSession
{
    return [self twitterGuestSessionWithGuestToken:@"guest_auth_token"];
}

+ (TWTRGuestSession *)twitterGuestSessionWithGuestToken:(NSString *)guestToken
{
    NSDictionary *sessionDictionary = @{ TWTRAuthAppOAuthTokenKey: @"oauth_token", TWTRGuestAuthOAuthTokenKey: guestToken };
    return [[TWTRGuestSession alloc] initWithSessionDictionary:sessionDictionary];
}

+ (NSString *)twitterSessionDictionaryStringWithUserID:(NSString *)userID
{
    return [NSString stringWithFormat:@"{\"oauth_token\": \"token\", \"oauth_token_secret\": \"secret\", \"screen_name\": \"screen_name\", \"user_id\": %@}", userID];
}

@end
