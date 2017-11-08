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

#import "TWTRSubscription.h"
#import "TWTRSubscriber.h"

@implementation TWTRSubscription

- (instancetype)initWithSubscriber:(id<TWTRSubscriber>)subscriber className:(NSString *)className key:(NSString *)key
{
    if (self = [super init]) {
        _subscriber = subscriber;
        _className = [className copy];
        _key = [key copy];
    }

    return self;
}

@end
