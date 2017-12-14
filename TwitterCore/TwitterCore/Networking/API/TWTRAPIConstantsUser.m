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

#import "TWTRAPIConstantsUser.h"
#import <Foundation/Foundation.h>

NSString *const TWTRAPIConstantsUserShowURL = @"/1.1/users/show.json";

NSString *const TWTRAPIConstantsVerifyCredentialsURL = @"/1.1/account/verify_credentials.json";

// parameters
NSString *const TWTRAPIConstantsUserParamUserID = @"user_id";
NSString *const TWTRAPIConstantsUserParamIncludeEmail = @"include_email";
NSString *const TWTRAPIConstantsUserParamSkipStatus = @"skip_status";
