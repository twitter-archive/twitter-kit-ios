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
#import "TWTRTestCase.h"

@interface TWTRImageLoaderTaskManagerTests : TWTRTestCase

@property (nonatomic) TWTRImageLoaderTaskManager *taskManager;
@property (nonatomic) NSURLSessionTask *task;

@end

@implementation TWTRImageLoaderTaskManagerTests

- (void)setUp
{
    [super setUp];

    self.taskManager = [[TWTRImageLoaderTaskManager alloc] init];
    self.task = [[NSURLSessionTask alloc] init];
}

- (void)testAddTaskWithRequestID_added
{
    [self.taskManager addTask:self.task withRequestID:@"id"];
    NSURLSessionTask *task = [self.taskManager removeTaskWithRequestID:@"id"];
    XCTAssertEqualObjects(task, self.task);
}

- (void)testRemoveTaskWithRequestID_nonexistentTaskReturnsNil
{
    NSURLSessionTask *task = [self.taskManager removeTaskWithRequestID:@"id"];
    XCTAssertNil(task);
}

@end
