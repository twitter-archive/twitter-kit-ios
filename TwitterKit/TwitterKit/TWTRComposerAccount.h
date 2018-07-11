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
#import "TwitterShareExtensionUI.h"

@class TWTRSession;

NS_ASSUME_NONNULL_BEGIN

/*
 *  Account object to bridge between Twitter Kit user objects,
 *  and shared composer account objects.
 *
 *  Used for passing along account authentication details when
 *  sending a Tweet from the shared composer.
 */
@interface TWTRComposerAccount : NSObject <TWTRSEAccount>

/*
 *  The user ID of this account.
 *
 *  e.g. 832938
 */
@property (nonatomic) long long userID;

/*
 *  The username of this account.
 *
 *  e.g. StevenTest3
 */
@property (nonatomic, copy) NSString *username;

- (NSString *)userIDString;

@end

TWTRComposerAccount *accountFromSession(TWTRSession *session);

NS_ASSUME_NONNULL_END
