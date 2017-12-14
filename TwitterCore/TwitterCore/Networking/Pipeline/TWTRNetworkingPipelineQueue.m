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

#import "TWTRNetworkingPipelineQueue.h"
#import <TwitterCore/TWTRAssertionMacros.h>
#import <TwitterCore/TWTRConstants.h>
#import "TWTRAPIDateSync.h"
#import "TWTRNetworkingPipelinePackage.h"
#import "TWTRRequestSigningOperation.h"

// the cap on the number of TWTRNetworkingPipelineQueue level attempts (including retries) of a failed networking request.
// this count is in addition to the original request attempt itself.
#define SAME_REQUEST_ATTEMPT_CAP (3)

@interface TWTRNetworkingPipelineQueue ()

/**
 * A queue that provides a mechanism for serializing fetches and refreshes of sessions.
 */
@property (nonatomic, readonly) dispatch_queue_t serialAccessQueue;

/**
 * A queue that provides a mechanism for safely handling cancellation.
 */
@property (nonatomic, readonly) dispatch_queue_t cancellationSupportQueue;

/**
 * A marker indicating that we are currently fetching or refreshing a session.
 */
@property (nonatomic, getter=isFetchingSession) BOOL fetchingSession;

/**
 * The session object that this queue will use for request signing. This object is
 * not typed because we only want to store a reference that gets passed back to the
 * request signing classes. This allows us to change the session objects without
 * having to change the pipeline queue implementation.
 */
@property (nonatomic) id session;

/**
 * If the session fetch fails we hold on to it so we can pass that back to the user.
 */
@property (nonatomic) NSError *sessionFetchError;

/**
 * The operation queue that handles the signing.
 */
@property (nonatomic, readonly) NSOperationQueue *operationQueue;

/**
 * A URLSession object which will execute the requests.
 */
@property (nonatomic, readonly) NSURLSession *URLSession;

/**
 * A weak map table which holds the in flight tasks.
 */
@property (nonatomic, readonly) NSMapTable *inFlightTasks;

/**
 * A weak hash table to help track the invoked packages.
 */
@property (nonatomic, readonly) NSHashTable *invokedPackages;

/**
 * A set of UUID's which are associated with requests that should be cancelled.
 */
@property (nonatomic, readonly) NSMutableSet *pendingCancellations;

/**
 * A flag to indicate if we are going to NSLog network requests
 */
@property (nonatomic, readonly) BOOL logNetworkRequest;

@end

@implementation TWTRNetworkingPipelineQueue

- (instancetype)initWithType:(TWTRNetworkingPipelineQueueType)type URLSession:(NSURLSession *)session responseValidator:(id<TWTRNetworkingResponseValidating>)responseValidator
{
    TWTRParameterAssertOrReturnValue(session, nil);

    self = [super init];
    if (self) {
        _URLSession = session;
        _queueType = type;
        _serialAccessQueue = dispatch_queue_create("com.twitterkit.network-pipeline-queue.access-queue", DISPATCH_QUEUE_SERIAL);
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.suspended = YES;
        _responseValidator = responseValidator;
        _invokedPackages = [NSHashTable weakObjectsHashTable];

        _inFlightTasks = [NSMapTable strongToWeakObjectsMapTable];
        _pendingCancellations = [NSMutableSet set];
        _cancellationSupportQueue = dispatch_queue_create("com.twitterkit.network-pipeline-queue.cancellation-support-queue", DISPATCH_QUEUE_SERIAL);

        // setting the argument by editing arguments in the app's scheme
        _logNetworkRequest = [[[NSProcessInfo processInfo] arguments] containsObject:@"-nslog_network_request"];
    }
    return self;
}

+ (instancetype)guestPipelineQueueWithURLSession:(NSURLSession *)session responseValidator:(id<TWTRNetworkingResponseValidating>)responseValidator
{
    return [[self alloc] initWithType:TWTRNetworkingPipelineQueueTypeGuest URLSession:session responseValidator:responseValidator];
}

+ (instancetype)userPipelineQueueWithURLSession:(NSURLSession *)session responseValidator:(id<TWTRNetworkingResponseValidating>)responseValidator
{
    return [[self alloc] initWithType:TWTRNetworkingPipelineQueueTypeUser URLSession:session responseValidator:responseValidator];
}

- (NSProgress *)enqueuePipelinePackage:(TWTRNetworkingPipelinePackage *)package
{
    NSProgress *progress = [[NSProgress alloc] initWithParent:nil userInfo:nil];

    @weakify(self) progress.cancellationHandler = ^{
        @strongify(self);
        [self markPackageAsCancelled:package];
    };

    [self fetchSessionIfNeededForPackage:package];

    TWTRRequestSigningOperation *operation = [self requestSigningOperationWithPackage:package];
    [self.operationQueue addOperation:operation];

    return progress;
}

- (void)setSession:(id)session
{
    _session = session;
    if (session) {
        self.operationQueue.suspended = NO;
    } else {
        self.operationQueue.suspended = YES;
    }
}

- (TWTRRequestSigningOperation *)requestSigningOperationWithPackage:(TWTRNetworkingPipelinePackage *)package
{
    TWTRRequestSigningSuccessBlock successBlock = [self requestSigningSuccessBlock:package];
    TWTRRequestSigningCancelBlock cancelBlock = [self requestSigningCancelBlock:package];

    if (self.queueType == TWTRNetworkingPipelineQueueTypeGuest) {
        return [self guestRequestSigningOperationWithPackage:package successBlock:successBlock cancelBlock:cancelBlock];
    } else {
        return [self userRequestSigningOperationWithPackage:package successBlock:successBlock cancelBlock:cancelBlock];
    }
}

- (TWTRRequestSigningOperation *)guestRequestSigningOperationWithPackage:(TWTRNetworkingPipelinePackage *)package successBlock:(TWTRRequestSigningSuccessBlock)successBlock cancelBlock:(TWTRRequestSigningCancelBlock)cancelBlock
{
    TWTRGuestSessionProvider sessionProvider = ^{
        return self.session;
    };
    return [[TWTRGuestRequestSigningOperation alloc] initWithPackage:package sessionProvider:sessionProvider success:successBlock cancel:cancelBlock];
}

- (TWTRRequestSigningOperation *)userRequestSigningOperationWithPackage:(TWTRNetworkingPipelinePackage *)package successBlock:(TWTRRequestSigningSuccessBlock)successBlock cancelBlock:(TWTRRequestSigningCancelBlock)cancelBlock
{
    TWTRUserSessionProvider sessionProvider = ^{
        return self.session;
    };
    return [[TWTRUserRequestSigningOperation alloc] initWithPackage:package sessionProvider:sessionProvider success:successBlock cancel:cancelBlock];
}

- (TWTRRequestSigningSuccessBlock)requestSigningSuccessBlock:(TWTRNetworkingPipelinePackage *)package
{
    @weakify(self) return ^(NSURLRequest *signedRequest) {
        @strongify(self)[self sendRequestForPackage:package withSignedRequest:signedRequest];
    };
}

- (TWTRRequestSigningCancelBlock)requestSigningCancelBlock:(TWTRNetworkingPipelinePackage *)package
{
    @weakify(self) return ^{
        @strongify(self)[self invokeCancelCallbackForPackage:package];
    };
}

#pragma mark - Queue Management
/**
 * We only want to execute the fetch session once here so we use the following algorithm.
 *  - dispatch the logic to a serial queue
 *  - if we have a session don't do anything.
 *  - if we don't have a session suspend the queue so subsequent blocks do not get executed.
 *  - fetch the session and then resume the queue.
 */
- (void)fetchSessionIfNeededForPackage:(TWTRNetworkingPipelinePackage *)package
{
    dispatch_async(self.serialAccessQueue, ^{
        if (self.session == nil && !self.isFetchingSession) {
            [self beginFetchingOrRefreshingSession];
            [self fetchSessionForPackage:package];
        }
    });
}

/**
 * Calling this method will cancel any requests that are currently in the queue.
 * The result of this is that the operations will invoke their cancel blocks which
 * will call -[TWTRNetworkingPipelineQueue invokeCancelCallbackForPackage] with the
 * appropriate error.
 */
- (void)cancelAllPendingRequests
{
    [self.operationQueue cancelAllOperations];
}

#pragma mark - Session Fetching

/**
 * this method fetches the session for the given package. It will reset the value stored in
 * the sessionFetchError property and will set the session queue's session with the fetched session.
 * If it fails all queued operations will be canceled and if it succeeds the operations
 * will resume with the new session.
 */
- (void)fetchSessionForPackage:(TWTRNetworkingPipelinePackage *)package;
{
    self.sessionFetchError = nil;

    void (^fetchCompletion)(id receivedSession, NSError *error) = ^(id receivedSession, NSError *error) {
        [self handleSessionStoreResponse:receivedSession error:error];
    };

    if (self.queueType == TWTRNetworkingPipelineQueueTypeGuest) {
        [package.sessionStore fetchGuestSessionWithCompletion:^(id session, NSError *error) {
            fetchCompletion(session, error);
        }];
    } else {
        id<TWTRAuthSession> session = [package.sessionStore sessionForUserID:package.userID];
        NSError *fetchError = nil;

        if (!session) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The userID %@ was not found in the session store", package.userID]};
            fetchError = [NSError errorWithDomain:TWTRLogInErrorDomain code:TWTRLogInErrorCodeSessionNotFound userInfo:userInfo];
        }

        fetchCompletion(session, fetchError);
    }
}

/**
 * This method will refresh the queue's current session object. The code is executed
 * asynchronously on a serial queue to guarantee that only one refresh call is executing
 * at any given time. If a refresh is already in flight the package will just be enqueued
 * in the queue again until the session has been refreshed or a cancelation event occurs.
 */
- (void)refreshSession:(id)session forPackage:(TWTRNetworkingPipelinePackage *)package
{
    dispatch_async(self.serialAccessQueue, ^{
        /// Fetching a new session is the same as refreshing.
        if (!self.isFetchingSession) {
            // set session to nil to suspend the queue
            self.session = nil;
            [self beginFetchingOrRefreshingSession];

            [package.sessionStore refreshSessionClass:[session class] sessionID:package.userID completion:^(id refreshedSession, NSError *error) {
                [self handleSessionStoreResponse:refreshedSession error:error];
            }];
        }
        [self enqueuePipelinePackage:package];
    });
}

- (void)handleSessionStoreResponse:(id)session error:(NSError *)error
{
    dispatch_async(self.serialAccessQueue, ^{
        self.sessionFetchError = error;

        if (session) {
            self.session = session;
        } else {
            self.session = nil;
            [self cancelAllPendingRequests];
        }
        [self endFetchingOrRefreshingSession];
    });
}

- (void)beginFetchingOrRefreshingSession
{
    TWTRParameterAssertOrReturn(!self.fetchingSession);
    self.fetchingSession = YES;
}

- (void)endFetchingOrRefreshingSession
{
    TWTRParameterAssertOrReturn(self.fetchingSession);
    self.fetchingSession = NO;
}

#pragma mark - Cancellation Support

- (void)appendInFlightTask:(NSURLSessionTask *)task forPackage:(TWTRNetworkingPipelinePackage *)package
{
    [self withCancellationSupportQueueAsync:^{
        [self.inFlightTasks setObject:task forKey:package.UUID];
    }];
}

- (void)markPackageAsCancelled:(TWTRNetworkingPipelinePackage *)package
{
    [self withCancellationSupportQueueAsync:^{
        NSURLSessionTask *task = [self.inFlightTasks objectForKey:package.UUID];
        if (task != nil) {
            [task cancel];
        } else {
            [self.pendingCancellations addObject:package.UUID];

            // We need to explicitly trigger the callback because there is no data task.
            NSError *error = [[self class] fetchCancelledErrorForPackage:package];
            [self invokeCallbackForPackage:package withData:nil response:nil error:error];
        }
    }];
}

- (BOOL)isPackageCancelled:(TWTRNetworkingPipelinePackage *)package shouldRemoveIfNecessary:(BOOL)shouldRemove
{
    BOOL __block containsObject;
    [self withCancellationSupportQueueSync:^{
        containsObject = [self.pendingCancellations containsObject:package.UUID];
        if (shouldRemove) {
            [self.pendingCancellations removeObject:package.UUID];
        }
    }];

    return containsObject;
}

- (void)withCancellationSupportQueueAsync:(dispatch_block_t)block
{
    dispatch_async(self.cancellationSupportQueue, block);
}

- (void)withCancellationSupportQueueSync:(dispatch_block_t)block
{
    dispatch_sync(self.cancellationSupportQueue, block);
}

#pragma mark - Request Sending
- (void)sendRequestForPackage:(TWTRNetworkingPipelinePackage *)package withSignedRequest:(NSURLRequest *)signedRequest
{
    TWTRParameterAssertOrReturn(self.session);

    // NOTE: There is a small race condition here which would happen if somebody
    // cancels a request after we check to see if it is in the pendingCancellations
    // set and before the URLSessionTask is created. We are ok with this race condition
    // because cancellation is never fully guaranteed and it is an unlikely scenario.
    // If we see this happening more than we expect then we can evaluate at that time.
    if ([self isPackageCancelled:package shouldRemoveIfNecessary:YES]) {
        return;
    }

    // Capture the session at the time of sending
    id localSession = self.session;

#ifdef DEBUG
    if (self.logNetworkRequest) {
        NSLog(@"Sending requests to %@ %@ with headers [%@ -- %@] ", signedRequest.HTTPMethod, signedRequest.URL.absoluteString, signedRequest.allHTTPHeaderFields, self.URLSession.configuration.HTTPAdditionalHeaders);
    }
#endif

    NSURLSessionDataTask *task = [self.URLSession dataTaskWithRequest:signedRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [self syncLocalTime:response];

        if (error || ![self validateResponse:response data:data error:&error]) {
            [self packageRequest:package session:localSession didReceiveError:error];
        } else {
            [self packageRequest:package session:localSession didReceiveResponse:response data:data];
        }
    }];

    [self appendInFlightTask:task forPackage:package];
    [task resume];
}

- (void)packageRequest:(TWTRNetworkingPipelinePackage *)package session:(id)localSesion didReceiveError:(NSError *)error
{
    const BOOL needsRefresh = [package.sessionStore isExpiredSession:localSesion error:error];

    if (needsRefresh && package.attemptCounter < SAME_REQUEST_ATTEMPT_CAP) {
        [self refreshSession:localSesion forPackage:[package copyForRetry]];
    } else {
#ifdef DEBUG
        if (package.attemptCounter >= SAME_REQUEST_ATTEMPT_CAP) {
            NSLog(@"Reaching retry cap for request %@", package.request.URL.absoluteString);
        }
#endif
        [self invokeCallbackForPackage:package withData:nil response:nil error:error];
    }
}

- (void)packageRequest:(TWTRNetworkingPipelinePackage *)package session:(id)localSesion didReceiveResponse:(NSURLResponse *)response data:(NSData *)data
{
    const BOOL needsRefresh = [package.sessionStore isExpiredSession:localSesion response:(NSHTTPURLResponse *)response];

    if (needsRefresh && package.attemptCounter < SAME_REQUEST_ATTEMPT_CAP) {
        [self refreshSession:localSesion forPackage:[package copyForRetry]];
    } else {
#ifdef DEBUG
        if (package.attemptCounter >= SAME_REQUEST_ATTEMPT_CAP) {
            NSLog(@"Reaching retry cap for request %@", package.request.URL.absoluteString);
        }
#endif
        [self invokeCallbackForPackage:package withData:data response:response error:nil];
    }
}

- (void)invokeCancelCallbackForPackage:(TWTRNetworkingPipelinePackage *)package
{
    NSError *error;
    if (self.sessionFetchError) {
        error = self.sessionFetchError;
    } else {
        error = [[self class] sessionFetchFailureError];
    }

    [self invokeCallbackForPackage:package withData:nil response:nil error:error];
}

- (void)invokeCallbackForPackage:(TWTRNetworkingPipelinePackage *)package withData:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error
{
    // We keep track of the invoked packages so that we only invoke it once.
    // The packages will be removed from the invoked packages set when they are deallocated.
    if (package.callback && ![self.invokedPackages containsObject:package]) {
        [self.invokedPackages addObject:package];
        package.callback(data, response, error);
    }
}

- (BOOL)validateResponse:(nullable NSURLResponse *)response data:(nullable NSData *)data error:(NSError **)error
{
    if (self.responseValidator) {
        return [self.responseValidator validateResponse:response data:data error:error];
    } else {
        return YES;
    }
}

- (void)syncLocalTime:(nullable NSURLResponse *)response
{
    TWTRAPIDateSync *dateSync = [[TWTRAPIDateSync alloc] initWithHTTPResponse:response];
    [dateSync sync];
}

+ (NSError *)sessionFetchFailureError
{
    return [NSError errorWithDomain:TWTRLogInErrorDomain code:TWTRLogInErrorCodeFailed userInfo:@{ NSLocalizedDescriptionKey: @"Unable to fetch session" }];
}

+ (NSError *)fetchCancelledErrorForPackage:(TWTRNetworkingPipelinePackage *)package
{
    NSDictionary *userInfo = @{NSURLErrorFailingURLErrorKey: package.request.URL, NSURLErrorFailingURLStringErrorKey: package.request.URL.absoluteString};
    return [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:userInfo];
}

@end
