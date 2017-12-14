//
//  StubTwitterClient.m
//
//  Created by Steven Hepting on 7/18/14.
//  Copyright (c) 2014 Twitter. All rights reserved.
//

#import "TWTRStubTwitterClient.h"
#import <TwitterCore/TWTRAPIServiceConfig.h>
#import <TwitterCore/TWTRNetworking.h>
#import <TwitterCore/TWTRSessionStore.h>
#import <TwitterCore/TWTRSessionStore_Private.h>
#import "TWTRAPIClient_Private.h"
#import "TWTRTestSessionStore.h"

@implementation TWTRStubTwitterClient

+ (instancetype)stubTwitterClient
{
    TWTRTestSessionStore *sessionStore = [[TWTRTestSessionStore alloc] initWithUserSessions:@[] guestSession:nil];
    TWTRStubTwitterClient *client = [[TWTRStubTwitterClient alloc] initWithSessionStore:sessionStore userID:@"1"];
    client.sentRequestsArray = [NSMutableArray new];
    return client;
}

- (NSURLRequest *)URLRequestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters error:(NSError **)error
{
    if (self.urlRequestError) {
        *error = self.urlRequestError;
        return nil;
    }
    return [super URLRequestWithMethod:method URLString:URLString parameters:parameters error:error];
}

- (NSProgress *)sendTwitterRequest:(NSURLRequest *)request completion:(TWTRNetworkCompletion)completion
{
    return [self sendTwitterRequest:request queue:dispatch_get_main_queue() completion:completion];
}

- (NSProgress *)sendTwitterRequest:(NSURLRequest *)request queue:(dispatch_queue_t)queue completion:(TWTRNetworkCompletion)completion
{
    self.sentRequest = request;
    if (self.responseError) {
        completion(nil, nil, self.responseError);
    } else {
        completion(nil, self.responseData, nil);
    }
    return nil;
}

- (void)uploadMedia:(NSData *)media contentType:(NSString *)contentType completion:(TWTRMediaUploadResponseCompletion)completion
{
    if (self.uploadError) {
        completion(nil, self.uploadError);
    } else {
        completion(@"982389", nil);
    }
}
- (void)postToUploadPathWithParameters:(NSDictionary *)parameters completion:(TWTRJSONRequestCompletion)completion
{
    if (self.uploadError) {
        completion(nil, nil, self.uploadError);
    } else {
        completion(nil, @{@"media_id_string": @"982389"}, nil);
    }
}

- (void)callTimelineResponseBlock:(TWTRLoadTimelineCompletion)completion withTweets:(NSArray *)tweets cursor:(TWTRTimelineCursor *)cursor error:(NSError *)error
{
    completion(tweets, cursor, error);
}

- (void)callGenericResponseBlock:(TWTRGenericResponseCompletion)completion withObject:(id)object error:(NSError *)error
{
    completion(object, error);
}

- (NSString *)sentHTTPBodyString
{
    return [[NSString alloc] initWithData:self.sentRequest.HTTPBody encoding:NSUTF8StringEncoding];
}

@end

@implementation TWTRAPIClient (URLMocking)

+ (NSURLSession *)URLSessionForMockingWithProtocolClasses:(NSArray *)protocolClasses
{
    NSURLSession *currentSession = [self URLSession];
    NSURLSessionConfiguration *config = [currentSession.configuration copy];
    config.protocolClasses = protocolClasses;

    return [NSURLSession sessionWithConfiguration:config delegate:currentSession.delegate delegateQueue:currentSession.delegateQueue];
}

@end

@interface TWTRNetworking ()

+ (NSURLSession *)URLSession;

@end

@implementation TWTRNetworking (URLMocking)

+ (NSURLSession *)URLSessionForMockingWithProtocolClasses:(NSArray *)protocolClasses
{
    NSURLSession *currentSession = [self URLSession];
    NSURLSessionConfiguration *config = [currentSession.configuration copy];
    config.protocolClasses = protocolClasses;

    return [NSURLSession sessionWithConfiguration:config delegate:currentSession.delegate delegateQueue:currentSession.delegateQueue];
}

@end
