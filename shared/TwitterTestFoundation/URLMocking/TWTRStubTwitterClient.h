//
//  StubTwitterClient.h
//
//  Created by Steven Hepting on 7/18/14.
//  Copyright (c) 2014 Twitter. All rights reserved.
//

#import <TwitterCore/TWTRNetworking.h>
#import <TwitterKit/TWTRKit.h>
#import "TWTRAPIClient.h"
@protocol TWTRSessionStore;
@protocol TWTRSessionStore_Private;

/*
 *  Provide a stub implementation of the TWTRAPIClient to more fully test any class which depend heavily on what the TWTRAPIClient returns from the network.
 *
 *  To use, just directly set any properties on this class and they will be used for the completion block parameters for `sendTwitterRequest:completion`.
 */
@interface TWTRStubTwitterClient : TWTRAPIClient

/**
 *  Response data to be returned by this stub.
 */
@property (nonatomic) NSData *responseData;

/**
 *  Response error to be returned by this stub.
 */
@property (nonatomic) NSError *responseError;

/**
 *  Media upload error to be returned by this stub.
 */
@property (nonatomic) NSError *uploadError;

/**
 *  URL request error to be returned by this stub.
 */
@property (nonatomic) NSError *urlRequestError;

/*
 *  The HTTP request that was attempted by the code under test.
 */
@property (nonatomic) NSURLRequest *sentRequest;

/*
 *  All network requests we are sending
 */
@property (nonatomic) NSMutableArray *sentRequestsArray;
/**
 *  A stub API client suitable for inspecting requests and
 *  stubbing responses.
 */
+ (instancetype)stubTwitterClient;

/**
 *  The body of the sent HTTP request in String format
 */
- (NSString *)sentHTTPBodyString;

@end

@interface TWTRAPIClient (URLMocking)

/**
 * Returns a new URL session with the given protocol classes which can be used for mocking.
 *
 * When this method is used in conjunction with TWTRMockURLSessionProtocol
 * much more flexibility is offered in how requests are handled.
 */
+ (NSURLSession *)URLSessionForMockingWithProtocolClasses:(NSArray *)protocolClasses;

@end

@interface TWTRNetworking (URLMocking)

/**
 * Returns a new URL session with the given protocol classes which can be used for mocking.
 *
 * When this method is used in conjunction with TWTRMockURLSessionProtocol
 * much more flexibility is offered in how requests are handled.
 */
+ (NSURLSession *)URLSessionForMockingWithProtocolClasses:(NSArray *)protocolClasses;

@end
