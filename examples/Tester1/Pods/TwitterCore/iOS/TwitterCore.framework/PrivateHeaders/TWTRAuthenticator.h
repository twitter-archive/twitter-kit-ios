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
 This header is private to the Twitter Core SDK and not exposed for public SDK consumption
 */

#import <Foundation/Foundation.h>
#import <TwitterCore/TwitterCore.h>
#import "TWTRAuthenticationConstants.h"

/**
 * The TWTRAuthenticator has been deprecated. Users should use the TWTRSessionStore
 * in favor of the authenticator.
 */
@interface TWTRAuthenticator : NSObject

+ (NSDictionary *)authenticationResponseForAuthType:(TWTRAuthType)authType __attribute__((deprecated("This class is removed in favor of TWTRSessionStore")));
+ (void)logoutAuthType:(TWTRAuthType)authType __attribute__((deprecated("This class is removed in favor of TWTRSessionStore")));

/**
 *  Save authentiation information to keychain and to disk.
 *
 *  @param authDict Authentication dictionary received from the Twitter API.
 *  @param authType The TWTRAuthType of the response being saved.
 *  @param error    An error object to return information about any error situations encountered.
 *
 *  @return Returns YES if everything saved correctly, NO if errors were encountered.
 */
+ (BOOL)saveAuthenticationWithDictionary:(NSDictionary *)authDict forAuthType:(TWTRAuthType)authType error:(out NSError *__autoreleasing *)error __attribute__((deprecated("This class is removed in favor of TWTRSessionStore")));

@end
