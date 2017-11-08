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

#import "TWTRAPINetworkErrorsShim.h"
#import "TWTRAPIErrorCode.h"
#import "TWTRNetworkingConstants.h"

@interface TWTRAPINetworkErrorsShim ()

@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSData *responseData;

@end

@implementation TWTRAPINetworkErrorsShim

- (instancetype)initWithHTTPResponse:(NSURLResponse *)response responseData:(NSData *)responseData
{
    if (self = [super init]) {
        _response = response;
        _responseData = responseData;
    }

    return self;
}

- (NSError *)validate
{
    if (self.responseData == nil) {
        return nil;
    }

    NSError *jsonError;

    id responseDict = [NSJSONSerialization JSONObjectWithData:self.responseData options:0 error:&jsonError];
    NSString *apiErrorMessage = @"";
    NSNumber *apiErrorCode;
    NSString *failureReason = @"";
    NSInteger errorCode = NSURLErrorBadServerResponse;
    NSString *errorDomain = TWTRNetworkingErrorDomain;
    NSHTTPURLResponse *httpResponse;
    BOOL errorExists = NO;

    if (jsonError == nil && [responseDict isKindOfClass:[NSDictionary class]]) {
        id errors = responseDict[@"errors"];
        NSDictionary *normalizedError = [self firstNormalizedAPIErrorInResponseBody:errors];
        if (normalizedError) {
            apiErrorMessage = normalizedError[@"message"];
            apiErrorCode = normalizedError[@"code"];
            errorExists = YES;
        }
    } else {
        apiErrorMessage = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    }

    if ([apiErrorMessage length] > 0) {
        failureReason = [NSString stringWithFormat:@"Twitter API error : %@ (code %@)", apiErrorMessage, apiErrorCode];
    }

    if (apiErrorCode) {
        errorDomain = TWTRAPIErrorDomain;
        errorCode = [apiErrorCode unsignedIntegerValue];
    }

    if ([self.response isKindOfClass:[NSHTTPURLResponse class]]) {
        httpResponse = (NSHTTPURLResponse *)self.response;
    }

    if (httpResponse == nil || ![[TWTRAPINetworkErrorsShim acceptableHTTPStatusCodes] containsIndex:(NSUInteger)[httpResponse statusCode]]) {
        errorExists = YES;
    }

    if (errorExists) {
        NSString *errorStr = [NSString stringWithFormat:@"Request failed: %@ (%lu)", [NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]], (unsigned long)[httpResponse statusCode]];
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: errorStr, NSLocalizedFailureReasonErrorKey: failureReason, NSURLErrorFailingURLErrorKey: self.response.URL ?: [NSNull null], TWTRNetworkingStatusCodeKey: @([httpResponse statusCode]) };
        NSError *validationError = [NSError errorWithDomain:errorDomain code:errorCode userInfo:userInfo];
        return validationError;
    }

    return nil;
}

#pragma mark - Helpers
+ (NSIndexSet *)acceptableHTTPStatusCodes
{
    return [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];  // 2XX
}

/**
 *  Normalizes different formats of API errors into one standard and returns the first error if any.
 *
 *  @param errors usually an array of errors but can sometimes just be a string of the error message
 */
- (NSDictionary *)firstNormalizedAPIErrorInResponseBody:(id)errors
{
    if ([errors isKindOfClass:[NSString class]]) {
        NSString *errorMessage = [errors copy];
        // In the case of already retweeted, we only get the error message and no error codes. It also
        // comes back as a string and not dictionary like most errors
        if ([errorMessage isEqualToString:@"sharing is not permissible for this status (Share validations failed)"]) {
            return @{ @"message": errorMessage, @"code": @(TWTRAPIErrorCodeAlreadyRetweeted) };
        }
    } else if ([errors isKindOfClass:[NSArray class]]) {
        NSDictionary *firstError = [errors firstObject];
        return firstError;
    }
    return nil;
}

@end

@implementation TWTRAPIResponseValidator

- (BOOL)validateResponse:(NSHTTPURLResponse *)response data:(NSData *)data error:(NSError **)error
{
    TWTRAPINetworkErrorsShim *shim = [[TWTRAPINetworkErrorsShim alloc] initWithHTTPResponse:response responseData:data];
    NSError *validationError = [shim validate];

    if (validationError) {
        if (error) {
            *error = validationError;
        }
        return NO;
    } else {
        return YES;
    }
}

@end
