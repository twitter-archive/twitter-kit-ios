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

#import "TWTRUserAuthRequestSigner.h"
#import "TWTROAuth1aAuthRequestSigner.h"

@implementation TWTRUserAuthRequestSigner

+ (NSURLRequest *)signedURLRequest:(NSURLRequest *)URLRequest authConfig:(TWTRAuthConfig *)authConfig session:(id<TWTRAuthSession>)session
{
    return [TWTROAuth1aAuthRequestSigner signedURLRequest:URLRequest authConfig:authConfig session:session];
}

@end
