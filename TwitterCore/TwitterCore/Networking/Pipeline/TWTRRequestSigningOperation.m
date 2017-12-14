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

#import "TWTRRequestSigningOperation.h"
#import <TwitterCore/TWTRAssertionMacros.h>
#import <TwitterCore/TWTRGuestAuthRequestSigner.h>
#import <TwitterCore/TWTRSession.h>
#import <TwitterCore/TWTRUserAuthRequestSigner.h>
#import "TWTRNetworkingPipelinePackage.h"

@interface TWTRRequestSigningOperation ()
@property (nonatomic, copy) TWTRRequestSigningSuccessBlock successCallbackToExecute;
@property (nonatomic, copy) TWTRRequestSigningCancelBlock cancelCallbackToExecute;
@end

@implementation TWTRRequestSigningOperation

- (instancetype)init;
{
    [self doesNotRecognizeSelector:_cmd];
    return self;
}

- (instancetype)initWithPackage:(TWTRNetworkingPipelinePackage *)package success:(TWTRRequestSigningSuccessBlock)successBlock cancel:(TWTRRequestSigningCancelBlock)cancelBlock
{
    TWTRParameterAssertOrReturnValue(package, nil);
    self = [super init];
    if (self) {
        _networkingPackage = package;
        _successCallbackToExecute = [successBlock copy];
        _cancelCallbackToExecute = [cancelBlock copy];
    }
    return self;
}

- (void)main
{
    NSURLRequest *signedRequest = [self signRequest:self.networkingPackage.request];
    if (signedRequest) {
        [self invokeSuccessBlock:signedRequest];
    } else {
        [self invokeCancelBlock];
    }
}

- (void)cancel
{
    [super cancel];
    if (!self.isExecuting) {
        [self invokeCancelBlock];
    }
}

- (void)invokeSuccessBlock:(NSURLRequest *)signedRequest
{
    if (self.successCallbackToExecute) {
        self.successCallbackToExecute(signedRequest);
    }
    [self didInvokeCompletionBlock];
}

- (void)invokeCancelBlock
{
    if (self.cancelCallbackToExecute) {
        self.cancelCallbackToExecute();
    }
    [self didInvokeCompletionBlock];
}

- (void)didInvokeCompletionBlock
{
    self.cancelCallbackToExecute = nil;
    self.successCallbackToExecute = nil;
}

- (NSURLRequest *)signRequest:(NSURLRequest *)request
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end

@interface TWTRGuestRequestSigningOperation ()
@property (nonatomic, copy, readonly) TWTRGuestSessionProvider sessionProvider;
@end

@implementation TWTRGuestRequestSigningOperation

- (instancetype)initWithPackage:(TWTRNetworkingPipelinePackage *)package sessionProvider:(TWTRGuestSessionProvider)sessionProvider success:(TWTRRequestSigningSuccessBlock)successBlock cancel:(TWTRRequestSigningCancelBlock)cancelBlock
{
    TWTRParameterAssertOrReturnValue(sessionProvider, nil);

    self = [super initWithPackage:package success:successBlock cancel:cancelBlock];
    if (self) {
        _sessionProvider = [sessionProvider copy];
    }
    return self;
}

- (NSURLRequest *)signRequest:(NSURLRequest *)request
{
    TWTRGuestSession *session = self.sessionProvider();

    return [TWTRGuestAuthRequestSigner signedURLRequest:self.networkingPackage.request session:session];
}

@end

@interface TWTRUserRequestSigningOperation ()
@property (nonatomic, copy, readonly) TWTRUserSessionProvider sessionProvider;
@end

@implementation TWTRUserRequestSigningOperation

- (instancetype)initWithPackage:(TWTRNetworkingPipelinePackage *)package sessionProvider:(TWTRUserSessionProvider)sessionProvider success:(TWTRRequestSigningSuccessBlock)successBlock cancel:(TWTRRequestSigningCancelBlock)cancelBlock
{
    TWTRParameterAssertOrReturnValue(sessionProvider, nil);

    self = [super initWithPackage:package success:successBlock cancel:cancelBlock];
    if (self) {
        _sessionProvider = [sessionProvider copy];
    }
    return self;
}

- (NSURLRequest *)signRequest:(NSURLRequest *)request
{
    TWTRAuthConfig *authConfig = self.networkingPackage.sessionStore.authConfig;
    TWTRSession *session = self.sessionProvider();

    if (session) {
        return [TWTRUserAuthRequestSigner signedURLRequest:self.networkingPackage.request authConfig:authConfig session:session];
    } else {
        return nil;
    }
}

@end
