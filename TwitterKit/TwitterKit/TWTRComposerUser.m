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

#import "TWTRComposerUser.h"

TWTRComposerUser *userFromUser(TWTRUser *twitterKitUser)
{
    TWTRComposerUser *user = [[TWTRComposerUser alloc] init];
    user.fullName = twitterKitUser.name;
    user.avatarURL = [NSURL URLWithString:twitterKitUser.profileImageURL];
    user.username = twitterKitUser.screenName;
    user.userID = [twitterKitUser.userID longLongValue];
    user.verified = twitterKitUser.isVerified;

    return user;
}

@implementation TWTRComposerUser

@end
