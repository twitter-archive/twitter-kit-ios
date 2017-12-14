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

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@protocol TWTRSEAccount <NSObject>

@property (nonatomic, readonly) long long userID;
@property (nonatomic, readonly, copy) NSString *username;

@end

#define TWTRSEAccountDisplayUsername(account) [NSString stringWithFormat:@"@%@", (account).username]
#define TWTRSEDisplayUsername(username) [NSString stringWithFormat:@"@%@", username]

NS_ASSUME_NONNULL_END
