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
//
//  This file preserves the interface of our (now legacy) App Card
//  composer, while presenting our own subclass of the shared Tweet
//  composer class TWTRSETweetShareViewController.
//
//
//    ┌─────────────────────────────────┐
//    │                                 │       Private,
//    │ TWTRSETweetShareViewController  │ <──── shared with
//    │                                 │       TOO iOS app
//    ├─────────────────────────────────┤
//    │                                 │       Our subclass &
//    │    TWTRSharedComposerWrapper    │ <──── delegate of shared
//    │                                 │       composer
//    └────────────┬────────────────────┘
//                 │
//                 │
//                 │
//  ┌──────────────┴───────────────┐     ┌───────────────────────┐
//  │                              │     │                       │
//  │  TWTRComposerViewController  │     │     TWTRComposer      │
//  │                              │     │                       │
//  │  (legacy App Card composer,  │     │   (legacy SLSocial    │
//  │ current preferred interface) │     │ wrapper, deprecated)  │
//  │                              <─────┤                       │
//  └──────────────┬───────────────┘     └───────────────────────┘
//                 │                                 │
//                 ▼                                 ▼
//

#import "TWTRComposerViewController.h"
#import <TwitterCore/TWTRAssertionMacros.h>
#import "TWTRSharedComposerWrapper.h"

@implementation TWTRComposerViewController

+ (instancetype)emptyComposer
{
    return (TWTRComposerViewController *)[[TWTRSharedComposerWrapper alloc] initWithInitialText:nil image:nil videoURL:nil];
}

- (instancetype)initWithInitialText:(nullable NSString *)initialText image:(nullable UIImage *)image videoURL:(nullable NSURL *)videoURL
{
    return (TWTRComposerViewController *)[[TWTRSharedComposerWrapper alloc] initWithInitialText:initialText image:image videoURL:videoURL];
}

- (instancetype)initWithInitialText:(nullable NSString *)initialText image:(nullable UIImage *)image videoData:(nullable NSData *)videoData
{
    return (TWTRComposerViewController *)[[TWTRSharedComposerWrapper alloc] initWithInitialText:initialText image:image videoData:videoData];
}

@end
