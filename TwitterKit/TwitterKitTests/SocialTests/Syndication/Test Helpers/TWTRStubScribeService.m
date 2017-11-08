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

#import "TWTRStubScribeService.h"

@implementation TWTRStubScribeService

- (instancetype)init
{
    if (self = [super init]) {
        _latestEvents = [NSMutableArray array];
    }

    return self;
}

- (void)enqueueEvent:(TWTRScribeEvent *)event
{
    [_latestEvents addObject:event];
}

- (void)enqueueEvents:(NSArray *)events
{
    [_latestEvents addObjectsFromArray:events];
}

- (TWTRScribeEvent *)latestEvent
{
    return self.latestEvents.lastObject;
}

- (void)flush
{
    _latestEvents = [NSMutableArray array];
}

@end
