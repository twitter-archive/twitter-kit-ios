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

/**
 This header is private to the Twitter Kit SDK and not exposed for public SDK consumption
 */

#import <Foundation/Foundation.h>
#import <TwitterCore/TWTRSession.h>
#import "TWTRUser.h"
#import "TwitterShareExtensionUI.h"

NS_ASSUME_NONNULL_BEGIN

/*
 *  User object to bridge between Twitter Kit sessions,
 *  and shared composer user objects with avatar and name.
 *
 *  Used for picking between multiple accounts in the shared
 *  composer view controller.
 */
@interface TWTRComposerUser : NSObject <TWTRSETwitterUser>

@property (nullable, nonatomic, copy) NSString *fullName;
@property (nullable, nonatomic, copy) NSURL *avatarURL;
@property (nonatomic) long long userID;
@property (nonnull, nonatomic, copy) NSString *username;
@property (nonatomic) BOOL verified;

@end

TWTRComposerUser *userFromUser(TWTRUser *twitterKitUser);

NS_ASSUME_NONNULL_END
