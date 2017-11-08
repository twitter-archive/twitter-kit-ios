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

#import "TWTRImageLoaderTaskManager.h"
#import <TwitterCore/TWTRAssertionMacros.h>

@interface TWTRImageLoaderTaskManager ()

/**
 *  Mapping of ID -> in-flight Tasks. `currentTasks` should _only_ be modified by operations in the
 *  serial `tasksQueue` dispatch queue.
 */
@property (nonatomic) NSMutableDictionary *currentTasks;

@end

@implementation TWTRImageLoaderTaskManager

- (instancetype)init
{
    if (self = [super init]) {
        _currentTasks = [NSMutableDictionary dictionary];
    }

    return self;
}

- (void)addTask:(NSURLSessionTask *)task withRequestID:(id<NSCopying>)requestID
{
    TWTRParameterAssertOrReturn(task && requestID);
    self.currentTasks[requestID] = task;
}

- (nullable NSURLSessionTask *)removeTaskWithRequestID:(id<NSCopying>)requestID
{
    TWTRParameterAssertOrReturnValue(requestID, nil);

    NSURLSessionTask *task = self.currentTasks[requestID];
    if (task) {
        [self.currentTasks removeObjectForKey:requestID];
    }
    return task;
}

@end
