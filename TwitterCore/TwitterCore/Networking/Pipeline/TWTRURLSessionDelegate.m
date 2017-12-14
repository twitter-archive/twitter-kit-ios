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

#import "TWTRURLSessionDelegate.h"
#import "TWTRServerTrustEvaluator.h"

@interface TWTRURLSessionDelegate ()

@property (nonatomic, readonly) TWTRServerTrustEvaluator *trustEvaluator;

@end

@implementation TWTRURLSessionDelegate

- (instancetype)init
{
    self = [super init];
    if (self) {
        _trustEvaluator = [[TWTRServerTrustEvaluator alloc] init];
    }
    return self;
}

#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler;
{
    NSURLProtectionSpace *protectionSpace = challenge.protectionSpace;

    if ([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        SecTrustRef serverTrust = protectionSpace.serverTrust;
        NSString *requestHost = task.currentRequest.URL.host;

        if ([self.trustEvaluator evaluateServerTrust:serverTrust forDomain:requestHost]) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        } else {
            NSLog(@"[%@] Cancelling API request, SSL certificate is invalid.", [self class]);
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
    } else {
        completionHandler(NSURLSessionAuthChallengeRejectProtectionSpace, nil);
    }
}

@end
