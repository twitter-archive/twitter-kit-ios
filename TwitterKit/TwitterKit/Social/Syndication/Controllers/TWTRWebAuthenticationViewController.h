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

/**
 This header is private to the Twitter Kit SDK and not exposed for public SDK consumption
 */

#import <UIKit/UIKit.h>
@class TWTRAuthConfig;
@class TWTRSession;
@protocol TWTRAPIServiceConfig;

NS_ASSUME_NONNULL_BEGIN

typedef void (^TWTRWebAuthenticationViewControllerCompletion)(TWTRSession *_Nullable session, NSError *_Nullable error);

@interface TWTRWebAuthenticationViewController : UIViewController

@property (nonatomic, copy) TWTRWebAuthenticationViewControllerCompletion completion;

/*
 *  Initialize either a WebViewController or SFSafariViewController based on existing session in TWTRSessionStore.
 */
- (instancetype)initWithAuthenticationToken:(NSString *)token authConfig:(TWTRAuthConfig *)authConfig APIServiceConfig:(id<TWTRAPIServiceConfig>)serviceConfig hasExistingSession:(BOOL)hasExistingSession;

/*
 *  Parse the verification URL from a URL response.
 */
- (void)handleAuthResponseWithURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
