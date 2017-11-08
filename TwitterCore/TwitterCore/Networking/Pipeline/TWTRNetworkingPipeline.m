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

#import "TWTRNetworkingPipeline.h"
#import <TwitterCore/TWTRAssertionMacros.h>
#import "TWTRNetworkingPipelinePackage.h"
#import "TWTRNetworkingPipelineQueue.h"

static NSString *const TWTRNetworkingPipelineGuestKey = @"TWTRNetworkingPipelineGuestKey";

@interface TWTRNetworkingPipeline ()

/**
 * a lookup table that maps user names to the pipeline queue that will process the requests.
 */
@property (nonatomic, readonly) NSMutableDictionary *userQueueLookupTable;

/**
 * the queue that will process all guest requests.
 */
@property (nonatomic, readonly) TWTRNetworkingPipelineQueue *guestQueue;

/**
 * The URLSession to pass to the queues.
 */
@property (nonatomic, readonly) NSURLSession *URLSession;

@end

@implementation TWTRNetworkingPipeline

- (instancetype)initWithURLSession:(NSURLSession *)URLSession responseValidator:(id<TWTRNetworkingResponseValidating>)responseValidator;
{
    TWTRParameterAssertOrReturnValue(URLSession, nil);

    self = [super init];
    if (self) {
        _guestQueue = [TWTRNetworkingPipelineQueue guestPipelineQueueWithURLSession:URLSession responseValidator:responseValidator];
        _userQueueLookupTable = [NSMutableDictionary dictionary];
        _URLSession = URLSession;
        _responseValidator = responseValidator;
    }
    return self;
}

- (NSProgress *)enqueueRequest:(NSURLRequest *)request sessionStore:(id<TWTRSessionStore>)sessionStore
{
    return [self enqueueRequest:request sessionStore:sessionStore requestingUser:nil];
}

- (NSProgress *)enqueueRequest:(NSURLRequest *)request sessionStore:(id<TWTRSessionStore>)sessionStore requestingUser:(NSString *)userID
{
    return [self enqueueRequest:request sessionStore:sessionStore requestingUser:userID completion:nil];
}

- (NSProgress *)enqueueRequest:(NSURLRequest *)request sessionStore:(id<TWTRSessionStore>)sessionStore requestingUser:(NSString *)userID completion:(TWTRNetworkingPipelineCallback)completion
{
    TWTRParameterAssertOrReturnValue(request, nil);
    TWTRParameterAssertOrReturnValue(sessionStore, nil);
    if (!request || !sessionStore) {
        if (completion) {
            completion(nil, nil, [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:nil]);
        }
    }

    TWTRNetworkingPipelinePackage *package = [TWTRNetworkingPipelinePackage packageWithRequest:request sessionStore:sessionStore userID:userID completion:completion];

    if (userID && [userID longLongValue]) {
        return [self enqueueUserPackage:package];
    } else {
        return [self enqueueGuestPackage:package];
    }
}

#pragma mark - Protected Methods
- (TWTRNetworkingPipelineQueue *)userQueueForUser:(NSString *)userID
{
    static dispatch_queue_t serialQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serialQueue = dispatch_queue_create("com.twitterkit.networking-pipeline.user-queue-creation-queue", DISPATCH_QUEUE_SERIAL);
    });

    TWTRNetworkingPipelineQueue *__block queue = nil;
    dispatch_sync(serialQueue, ^{
        queue = self.userQueueLookupTable[userID];
        if (queue == nil) {
            queue = [TWTRNetworkingPipelineQueue userPipelineQueueWithURLSession:self.URLSession responseValidator:self.responseValidator];
            self.userQueueLookupTable[userID] = queue;
        }
    });

    return queue;
}

#pragma mark - Private Methods
- (NSProgress *)enqueueGuestPackage:(TWTRNetworkingPipelinePackage *)package
{
    return [self.guestQueue enqueuePipelinePackage:package];
}

- (NSProgress *)enqueueUserPackage:(TWTRNetworkingPipelinePackage *)package
{
    TWTRNetworkingPipelineQueue *queue = [self userQueueForUser:package.userID];
    return [queue enqueuePipelinePackage:package];
}

@end
