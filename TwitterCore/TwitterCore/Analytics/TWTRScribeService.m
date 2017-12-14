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

#import "TWTRScribeService.h"
#import "TFSScribe.h"
#import "TFSScribeImpression.h"
#import "TWTRAPIServiceConfig.h"
#import "TWTRAppInstallationUUID.h"
#import "TWTRAssertionMacros.h"
#import "TWTRAuthSession.h"
#import "TWTRAuthenticationConstants.h"
#import "TWTRConstants.h"
#import "TWTRGuestSession.h"
#import "TWTRMultiThreadUtil.h"
#import "TWTRNetworking.h"
#import "TWTRNetworkingPipeline.h"
#import "TWTRResourcesUtil.h"
#import "TWTRSessionStore.h"
#import "TWTRSessionStore_Private.h"

static NSString *const TWTRScribePath = @"/i/jot/sdk";
static NSString *const TWTRScribeLogKey = @"log";
static NSString *const TWTRScribeDelayHeaderKey = @"X-CLIENT-EVENT-ENABLED";
static NSString *const TWTRScribeClientIDHeaderKey = @"X-Client-UUID";
// Addition of the polling header properly attributes polling or scribe request from user action ones.
static NSString *const TWTRPollingOrScribeRequestHeaderKey = @"X-Twitter-Polling";
static NSString *const TWTRPollingOrScribeRequestHeaderValue = @"true";

__unused static NSInteger const TWTRScribeHTTPStatusOverCapacity = 503;

#if DEBUG
static NSInteger const ScribeBatchSendDelay = 5;
#else
static NSInteger const ScribeBatchSendDelay = 60;
#endif

#define DEBUG_SCRIBE 0

#if DEBUG && DEBUG_SCRIBE
#define TWTRScribeServiceDebugLog(FMT, ...) NSLog(FMT, ##__VA_ARGS__)
#else
#define TWTRScribeServiceDebugLog(FMT, ...)
#endif

@interface TWTRScribeService () <TFSScribeRequestHandler>

@property (nonatomic, readonly) TFSScribe *scribe;
@property (nonatomic, readonly) TWTRSessionStore *sessionStore;
@property (nonatomic, readonly) TWTRNetworkingPipeline *networkingPipeline;
@property (nonatomic, readonly) id<TWTRAPIServiceConfig> scribeAPIServiceConfig;

@property (nonatomic) NSTimer *scribeTimer;

@property (nonatomic) NSTimeInterval secondsToDelayScribe;
@property (nonatomic) NSInteger scribeFailCount;

@end

@implementation TWTRScribeService

- (instancetype)initWithScribe:(TFSScribe *)scribe scribeAPIServiceConfig:(id<TWTRAPIServiceConfig>)APIserviceConfig
{
    TWTRParameterAssertOrReturnValue(scribe, nil);
    TWTRParameterAssertOrReturnValue(APIserviceConfig, nil);

    self = [super init];
    if (self) {
        _scribe = scribe;
        _scribeAPIServiceConfig = APIserviceConfig;
        [self openScribe:scribe];
    }

    return self;
}

#pragma mark - Public Methods

- (void)setSessionStore:(TWTRSessionStore *)sessionStore networkingPipeline:(TWTRNetworkingPipeline *)pipeline
{
    _sessionStore = sessionStore;
    _networkingPipeline = pipeline;
}

- (void)enqueueEvent:(TWTRScribeEvent *)event
{
    if (event == nil) {
        return;
    }

    [self enqueueEvents:@[event]];
}

- (void)enqueueEvents:(NSArray *)events
{
    if (![self isValidEventsArray:events]) {
        return;
    }

    TWTRScribeServiceDebugLog(@"[%@] Enqueuing %@ events", [self class], @(events.count));

    for (id<TFSScribeEventParameters> eventParameters in events) {
        [self.scribe enqueueEvent:eventParameters];
    }
}

#pragma mark - Scribe Action Helpers

- (void)openScribe:(TFSScribe *)scribe
{
    TWTRParameterAssertOrReturn(scribe);

    [scribe openWithStartBlock:nil
               completionBlock:^{
                   [self scheduleScribe];
               }];
}

- (void)scribePendingEvents
{
    TWTRScribeServiceDebugLog(@"[%@] Scribing pending events", [self class]);

    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray<NSString *> *existingUserIDs = [self existingUserIDs];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (NSString *userID in existingUserIDs) {
                [self.scribe flushUserID:userID requestHandler:self];
            }
        });
    });
}

- (void)scheduleScribe
{
    // This method is called on a background thread and the timer must be set on the main thread.
    // We must read the current session information in -scribePendingEvents from the main thread, and NSTimer shouldn't be used from GCD queues.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.scribeTimer invalidate];
        // This must be set to repeat because TFSScribe only calls handleScribeOutgoingEvents:completionHandler:
        // if there are pending events to scribe. We restart the timer in handleScribeOutgoingEvents:completionHandler:
        // in case we need to increase the timer's period.
        self.scribeTimer = [NSTimer scheduledTimerWithTimeInterval:(ScribeBatchSendDelay + self.secondsToDelayScribe) target:self selector:@selector(scribePendingEvents) userInfo:nil repeats:YES];
    });
}

#pragma mark - TFSScribeRequestHandler

- (void)handleScribeOutgoingEvents:(NSString *)outgoingEvents userID:(NSString *)userID completionHandler:(TFSScribeRequestCompletionBlock)completionHandler
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self mainThreadHandleScribeOutgoingEvents:outgoingEvents userID:userID completionHandler:completionHandler];
    });
}

- (void)mainThreadHandleScribeOutgoingEvents:(NSString *)outgoingEvents userID:(NSString *)userID completionHandler:(TFSScribeRequestCompletionBlock)completionHandler
{
    [TWTRMultiThreadUtil assertMainThread];

    TWTRScribeServiceDebugLog(@"[%@] Scribing events", [self class]);

    [self sendOutgoingEvents:outgoingEvents
                      userID:userID
           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
               NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;

               TFSScribeServiceRequestDisposition scribeDisposition = TFSScribeServiceRequestDispositionSuccess;

               TWTRScribeServiceDebugLog(@"[%@] Scribe HTTP status: %@, error: %@", [self class], @(httpURLResponse.statusCode), connectionError);
               if (connectionError) {
                   BOOL overCapacity = (httpURLResponse.statusCode == TWTRScribeHTTPStatusOverCapacity);

                   id delayNextScribeValue = httpURLResponse.allHeaderFields[TWTRScribeDelayHeaderKey];
                   BOOL shouldDelayNextScribe = [delayNextScribeValue respondsToSelector:@selector(boolValue)] ? [delayNextScribeValue boolValue] : NO;

                   if (overCapacity || shouldDelayNextScribe) {
                       scribeDisposition = TFSScribeServiceRequestDispositionServerError;

                       // Linearly increase the delay if there's a server error
                       self.secondsToDelayScribe = ScribeBatchSendDelay * ++self.scribeFailCount;
                   } else {
                       scribeDisposition = TFSScribeServiceRequestDispositionClientError;
                   }
               } else {
                   self.secondsToDelayScribe = 0;
                   self.scribeFailCount = 0;
               }

               completionHandler(scribeDisposition);
               [self scheduleScribe];
           }];
}

- (void)sendOutgoingEvents:(NSString *)outgoingEvents userID:(NSString *)userID completionHandler:(TWTRTwitterNetworkCompletion)completionHandler
{
    NSDictionary *requestBodyParams = @{TWTRScribeLogKey: outgoingEvents};

    NSURLRequest *request = [self scribeServiceRequestParameters:requestBodyParams];
    [self enqueuePipelineRequest:request userID:userID completionHandler:completionHandler];
}

- (void)enqueuePipelineRequest:(NSURLRequest *)request userID:(NSString *)userID completionHandler:(TWTRTwitterNetworkCompletion)completionHandler
{
    TWTRParameterAssertOrReturn(self.networkingPipeline);
    TWTRParameterAssertOrReturn(self.sessionStore);

    [self.networkingPipeline enqueueRequest:request
                               sessionStore:self.sessionStore
                             requestingUser:userID
                                 completion:^(NSData *data, NSURLResponse *response, NSError *error) {
                                     completionHandler(response, data, error);
                                 }];
}

#pragma mark - URL Request Building

- (NSURLRequest *)scribeServiceRequestParameters:(NSDictionary *)parameters
{
    TWTRNetworking *requestBuilder = [self requestBuilder];
    return [self URLRequestWithAttributionHeadersFromRequestBuilder:requestBuilder parameters:parameters];
}

- (TWTRNetworking *)requestBuilder
{
    TWTRAuthConfig *config = self.sessionStore.authConfig;
    return [[TWTRNetworking alloc] initWithAuthConfig:config];
}

- (NSURLRequest *)URLRequestWithAttributionHeadersFromRequestBuilder:(TWTRNetworking *)builder parameters:(NSDictionary *)parameters;
{
    NSURL *scribeURL = TWTRAPIURLWithPath(self.scribeAPIServiceConfig, TWTRScribePath);
    NSURLRequest *request = [builder URLRequestForPOSTMethodWithURLString:[scribeURL absoluteString] parameters:parameters];
    return [self URLRequestByAppendingAttributionHeadersToRequest:request];
}

- (NSURLRequest *)URLRequestByAppendingAttributionHeadersToRequest:(NSURLRequest *)request
{
    NSMutableURLRequest *mutableRequest = [request mutableCopy];

    [mutableRequest setValue:[TWTRAppInstallationUUID appInstallationUUID] forHTTPHeaderField:TWTRScribeClientIDHeaderKey];
    [mutableRequest setValue:TWTRPollingOrScribeRequestHeaderValue forHTTPHeaderField:TWTRPollingOrScribeRequestHeaderKey];

    return mutableRequest;
}

#pragma mark - Private Helpers

- (NSArray<NSString *> *)existingUserIDs
{
    NSArray<id<TWTRAuthSession>> *userSessions = self.sessionStore.existingUserSessions;
    NSMutableArray<NSString *> *userIDs = [NSMutableArray arrayWithCapacity:[userSessions count] + 1];

    // Add guest 'user ID'
    [userIDs addObject:@"0"];

    // Add all current User sessions
    for (id<TWTRAuthSession> userSession in userSessions) {
        [userIDs addObject:userSession.userID];
    }

    return userIDs;
}

- (BOOL)isValidEventsArray:(NSArray *)events
{
    if ((events == nil) || (events.count == 0)) {
        return NO;
    }

    for (id possibleEvent in events) {
        if (![possibleEvent conformsToProtocol:@protocol(TFSScribeEventParameters)]) {
            return NO;
        }
    }

    return YES;
}

@end
