//
//  TWTRMockURLSessionProtocol.m
//  TwitterKit
//
//  Created by Chase Latta on 6/29/15.
//  Copyright (c) 2015 Twitter. All rights reserved.
//

#import <TwitterCore/TWTRAssertionMacros.h>
#import "TWTRMockURLSessionProtocol.h"

@implementation TWTRMockURLResponse

- (instancetype)initWithResponseString:(NSString *)string code:(NSInteger)statusCode error:(NSError *)error headerFields:(NSDictionary *)headerFields
{
    self = [super init];
    if (self) {
        _responseString = [string copy];
        _statusCode = statusCode;
        _error = error;
        _headerFields = [headerFields copy];
    }
    return self;
}

+ (instancetype)responseWithError:(NSError *)error
{
    return [self responseWithError:error headerFields:@{}];
}

+ (instancetype)responseWithError:(NSError *)error headerFields:(NSDictionary *)headerFields
{
    TWTRParameterAssertOrReturnValue(error, nil);
    TWTRParameterAssertOrReturnValue(headerFields, nil);
    return [[self alloc] initWithResponseString:nil code:0 error:error headerFields:headerFields];
}

+ (instancetype)responseWithString:(NSString *)string
{
    return [self responseWithString:string statusCode:200];
}

+ (instancetype)responseWithString:(NSString *)string statusCode:(NSInteger)statusCode
{
    return [self responseWithString:string statusCode:statusCode headerFields:@{}];
}

+ (instancetype)responseWithString:(NSString *)string statusCode:(NSInteger)statusCode headerFields:(NSDictionary *)headerFields
{
    TWTRParameterAssertOrReturnValue(string, nil);
    TWTRParameterAssertOrReturnValue(headerFields, nil);
    return [[self alloc] initWithResponseString:string code:statusCode error:nil headerFields:headerFields];
}

@end

@implementation TWTRMockURLSessionProtocol

+ (BOOL)isEmpty
{
    return [[self responses] count] == 0;
}

+ (NSMutableArray *)responses
{
    static NSMutableArray *array;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        array = [NSMutableArray array];
    });
    return array;
}

+ (void)pushResponse:(TWTRMockURLResponse *)response
{
    TWTRParameterAssertOrReturn(response);
    [[self responses] addObject:response];
}

+ (nullable TWTRMockURLResponse *)popResponse;
{
    NSMutableArray *responses = [self responses];
    if (responses.count == 0) {
        return nil;
    }
    
    TWTRMockURLResponse *response = responses[0];
    [responses removeObjectAtIndex:0];

    return response;
}

#pragma mark - Protocol Overrides
+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    return YES;
}

+ (BOOL)canInitWithTask:(NSURLSessionTask *)task
{
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return NO;
}

- (void)startLoading
{
    TWTRMockURLResponse *response = [[self class] popResponse];
    NSError *failureError = nil;
    
    if (!response) {
        failureError = [self errorForNoResponse:self.request];
    } else if (response.error) {
        failureError = response.error;
    }
    
    if (failureError) {
        [self.client URLProtocol:self didFailWithError:failureError];
    } else {
        NSURLResponse *HTTPResponse = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL statusCode:response.statusCode HTTPVersion:@"HTTP/1.1" headerFields:response.headerFields];
        [self.client URLProtocol:self didReceiveResponse:HTTPResponse cacheStoragePolicy:NSURLCacheStorageNotAllowed];

        NSData *data = [response.responseString dataUsingEncoding:NSUTF8StringEncoding];
        [self.client URLProtocol:self didLoadData:data];
        [self.client URLProtocolDidFinishLoading:self];
    }
}

- (void)stopLoading
{
}

- (NSError *)errorForNoResponse:(NSURLRequest *)request
{
    NSDictionary *userInfo = @{NSURLErrorFailingURLStringErrorKey: request.URL.absoluteString, NSLocalizedDescriptionKey: @"The Internet connection appears to be offline."};
    return [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorNotConnectedToInternet userInfo:userInfo];
}

@end
