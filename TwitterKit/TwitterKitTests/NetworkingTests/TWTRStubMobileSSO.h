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

#import <TwitterCore/TWTRNetworking.h>
#import <TwitterKit/TWTRKit.h>
#import "TWTRMobileSSO.h"

/*
 *  Provide a stub implementation of the TWTRMobileSSO to more fully test any class which depend on what the TWTRMobileSSO returns.
 */

@interface TWTRStubMobileSSO : TWTRMobileSSO

@property (nonatomic) NSError *error;
@property (nonatomic) TWTRSession *session;
@property (nonatomic) BOOL didAttemptAppLogin;

@end
