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

#import "TWTRStubMobileSSO.h"

@implementation TWTRStubMobileSSO

- (void)attemptAppLoginWithCompletion:(TWTRLogInCompletion)completion
{
    self.didAttemptAppLogin = YES;

    if (completion) {
        completion(self.session, self.error);
    }
}

- (instancetype)init
{
    if (self = [super init]) {
        self.session = [[TWTRSession alloc] initWithAuthToken:@"token'" authTokenSecret:@"secret" userName:@"username" userID:@"9843"];
    }
    return self;
}

@end
