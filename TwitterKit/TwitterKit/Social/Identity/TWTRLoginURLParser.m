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

#import "TWTRLoginURLParser.h"
#import <SafariServices/SafariServices.h>
#import <TwitterCore/TWTRAuthConfig.h>
#import <TwitterCore/TWTRAuthenticationConstants.h>
#import <TwitterCore/TWTRNetworkingUtil.h>
#import "TWTRTwitter.h"
#import "TWTRWebAuthenticationFlow.h"
#import "TWTRWebAuthenticationViewController.h"

@interface TWTRLoginURLParser ()

@property (nonatomic, copy) NSString *twitterKitURLScheme;
@property (nonatomic, copy) NSString *twitterAuthURL;

@end

@implementation TWTRLoginURLParser

- (instancetype)initWithAuthConfig:(TWTRAuthConfig *)config
{
    if (self = [super init]) {
        self.twitterKitURLScheme = [NSString stringWithFormat:@"twitterkit-%@", config.consumerKey];
        self.twitterAuthURL = [NSString stringWithFormat:@"twitterauth://authorize?consumer_key=%@&consumer_secret=%@&oauth_callback=%@", config.consumerKey, config.consumerSecret, self.twitterKitURLScheme];
    }
    return self;
}

#pragma mark - Public

- (NSString *)authRedirectScheme
{
    if ([self hasValidURLScheme]) {
        return self.twitterKitURLScheme;
    } else {
        return TWTRSDKScheme;
    }
}

- (BOOL)isMobileSSOSuccessURL:(NSURL *)url
{
    BOOL properScheme = [self isTwitterKitRedirectURL:url];

    NSDictionary *parameters = [TWTRNetworkingUtil parametersFromQueryString:url.host];
    NSArray *keys = [parameters allKeys];
    BOOL successState = [keys containsObject:@"secret"] && [keys containsObject:@"token"] && [keys containsObject:@"username"] && properScheme;

    BOOL isSuccessURL = successState && properScheme;

    return isSuccessURL;
}

- (BOOL)isMobileSSOCancelURL:(NSURL *)url
{
    BOOL properScheme = [self isTwitterKitRedirectURL:url];
    BOOL cancelState = (url.host == nil) && properScheme;

    BOOL isCancelURL = properScheme && cancelState;

    return isCancelURL;
}

- (BOOL)isOauthTokenVerifiedFromURL:(NSURL *)url
{
    NSDictionary *parameters = [TWTRNetworkingUtil parametersFromQueryString:url.absoluteString];
    NSString *token = parameters[TWTRAuthOAuthTokenKey];
    if (token == nil) {
        token = parameters[TWTRAuthAppOAuthDeniedKey];
    }

    return [[[TWTRTwitter sharedInstance] sessionStore] isValidOauthToken:token];
}

- (NSDictionary *)parametersForSSOURL:(NSURL *)url
{
    return [TWTRNetworkingUtil parametersFromQueryString:url.host];
}

- (BOOL)isTwitterKitRedirectURL:(NSURL *)url
{
    return [self isTwitterKitURLScheme:url.scheme];
}

- (BOOL)hasValidURLScheme
{
    return ([self appSpecificURLScheme] != nil);
}

- (NSURL *)twitterAuthorizeURL
{
    return [NSURL URLWithString:self.twitterAuthURL];
}

#pragma mark - Internal

- (BOOL)isTwitterKitURLScheme:(NSString *)scheme
{
    // The Twitter API will redirect to a lowercase version of the
    // URL that we pass to them
    return [scheme caseInsensitiveCompare:self.twitterKitURLScheme] == NSOrderedSame;
}

// This method parses the schemes from the Info.plist which has a
// format like this:
// @[ @{
//     @"CFBundleTypeRole": @"Editor",
//     @"CFBundleURLSchemes": @[@"twitterkit-k8Uf0x"],
//   },
//   @{
//     @"CFBundleTypeRole": @"Editor",
//     @"CFBundleURLSchemes": @[@"appscheme83289239"],
//   }
// ]
- (NSString *)appSpecificURLScheme
{
    NSString *matchingScheme;
    NSDictionary *infoPlist = [NSBundle mainBundle].infoDictionary;
    NSArray *urlTypes = [infoPlist objectForKey:@"CFBundleURLTypes"];

    for (NSDictionary *schemeDetails in urlTypes) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id _Nullable evaluatedObject, NSDictionary<NSString *, id> *_Nullable bindings) {
            NSString *scheme = (NSString *)evaluatedObject;
            return (scheme) ? [self isTwitterKitURLScheme:scheme] : NO;
        }];

        NSArray *filteredArray = [[schemeDetails objectForKey:@"CFBundleURLSchemes"] filteredArrayUsingPredicate:predicate];
        if ([filteredArray count] > 0) {
            matchingScheme = [filteredArray firstObject];
        }
    }

    return matchingScheme;
}

@end
