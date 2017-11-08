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

#import <Foundation/Foundation.h>

typedef void (^TWTRAuthenticationProviderCompletion)(NSDictionary *responseObject, NSError *error);

@interface TWTRAuthenticationProvider : NSObject

/**
 *  Authenticate with the Twitter API
 *
 *  @param completion (required) The completion block to be called upon succes or failure.
 *                               Will be called on an arbitrary queue.
 */
- (void)authenticateWithCompletion:(TWTRAuthenticationProviderCompletion)completion;

@end
