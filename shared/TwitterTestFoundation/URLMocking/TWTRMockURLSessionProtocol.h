//
//  TWTRMockURLSessionProtocol.h
//  TwitterKit
//
//  Created by Chase Latta on 6/29/15.
//  Copyright (c) 2015 Twitter. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TWTRMockURLResponse : NSObject

/**
 The response string or nil if an error should be returned.
 */
@property (nonatomic, copy, readonly, nullable) NSString *responseString;

/**
 The status code for this response.
 */
@property (nonatomic, readonly) NSInteger statusCode;

/**
 If non-nil the error will be returned instead of a valid response.
 */
@property (nonatomic, readonly, nullable) NSError *error;

@property (nonatomic, copy, readonly) NSDictionary *headerFields;

+ (instancetype)responseWithError:(NSError *)error;
+ (instancetype)responseWithError:(NSError *)error headerFields:(NSDictionary *)headerFields;

+ (instancetype)responseWithString:(NSString *)string;
+ (instancetype)responseWithString:(NSString *)string statusCode:(NSInteger)statusCode;
+ (instancetype)responseWithString:(NSString *)string statusCode:(NSInteger)statusCode headerFields:(NSDictionary *)headerFields;

@end

/**
 The TWTRMockURLSessionProtocl is a FIFO stack based protocol. It will pop
 a response off the stack to return. If the stack is empty the protocol will
 act as if it cannot reach the server. This class is not thread safe and can
 only handle a single request at a time.
 */
@interface TWTRMockURLSessionProtocol : NSURLProtocol

/**
 Pushes a response object onto the stack
 */
+ (void)pushResponse:(TWTRMockURLResponse *)response;

/**
 Returns YES if there are no responses queued.
 
 This method can be useful to verify that all your 
 requests were executed during your test.
 */
+ (BOOL)isEmpty;

@end

NS_ASSUME_NONNULL_END
