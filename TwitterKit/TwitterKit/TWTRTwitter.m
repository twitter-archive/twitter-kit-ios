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

#import "TWTRTwitter.h"
#import <TwitterCore/TWTRAPIConstantsUser.h>
#import <TwitterCore/TWTRAPIServiceConfig.h>
#import <TwitterCore/TWTRAPIServiceConfigRegistry.h>
#import <TwitterCore/TWTRAssertionMacros.h>
#import <TwitterCore/TWTRAuthConfigSessionsValidator.h>
#import <TwitterCore/TWTRAuthConfigStore.h>
#import <TwitterCore/TWTRAuthenticationConstants.h>
#import <TwitterCore/TWTRCoreConstants.h>
#import <TwitterCore/TWTRMultiThreadUtil.h>
#import <TwitterCore/TWTRNetworkingConstants.h>
#import <TwitterCore/TWTRNetworkingPipeline.h>
#import <TwitterCore/TWTRResourcesUtil.h>
#import <TwitterCore/TWTRSessionRefreshStrategy.h>
#import <TwitterCore/TWTRSessionStore.h>
#import <TwitterCore/TWTRSessionStore_Private.h>
#import <TwitterCore/TWTRSession_Private.h>
#import <TwitterCore/TWTRUtils.h>
#import "TWTRAPIClient.h"
#import "TWTRAPIClient_Private.h"
#import "TWTRAssetURLSessionConfig.h"
#import "TWTRConstants_Private.h"
#import "TWTRCookieStorageUtil.h"
#import "TWTRImageLoader.h"
#import "TWTRLoginURLParser.h"
#import "TWTRMobileSSO.h"
#import "TWTRNotificationConstants.h"
#import "TWTRPersistentStore.h"
#import "TWTRRuntime.h"
#import "TWTRSessionMigrator.h"
#import "TWTRSystemAccountSerializer.h"
#import "TWTRTweetCache.h"
#import "TWTRTweetRepository.h"
#import "TWTRTweetViewDelegate.h"
#import "TWTRTwitterAPIServiceConfig.h"
#import "TWTRTwitter_Private.h"
#import "TWTRURLSessionConfig.h"
#import "TWTRUser.h"
#import "TWTRWebAuthenticationFlow.h"

#define AssetCachePath (@"cache/assets")

static const NSUInteger MB = 1048576;
static const NSUInteger AssetCacheMaxSize = 10 * MB;

NSString *const TWTRInvalidInitializationException = @"TWTRInvalidInitializationException";

@interface TWTRTwitter ()

@property (nonatomic) TWTRWebAuthenticationFlow *webAuthenticationFlow;
@property (nonatomic) TWTRMobileSSO *mobileSSO;

@end

@implementation TWTRTwitter
@synthesize sessionStore = _sessionStore;
@synthesize authConfig = _authConfig;

#pragma mark - FABKit

+ (NSString *)kitDisplayVersion
{
    return TWTRVersion;
}

+ (NSString *)bundleIdentifier
{
    return TWTRBundleID;
}

#pragma mark - Compatibility with pre-3PK Fabric API.

- (NSString *)version
{
    return [[self class] kitDisplayVersion];
}

- (NSString *)bundleIdentifier
{
    return [[self class] bundleIdentifier];
}

#pragma mark - Shared Kit Accessor

static TWTRTwitter *sharedTwitter;
+ (TWTRTwitter *)sharedInstance
{
    if (!sharedTwitter) {
        sharedTwitter = [[super allocWithZone:nil] init];
    }

    [TWTRMultiThreadUtil assertMainThread];
    return sharedTwitter;
}

// Only to be used for testing
+ (void)setSharedTwitter:(TWTRTwitter *)newShared
{
    sharedTwitter = newShared;
}

// Not thread safe. See header documentation.
+ (void)resetSharedInstance
{
    [TWTRMultiThreadUtil assertMainThread];
    sharedTwitter = nil;
}

// Override alloc to ensure only one instance, the shared one, is ever created
+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

#pragma mark - Init and Start

- (void)startWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret
{
    [self startWithConsumerKey:consumerKey consumerSecret:consumerSecret accessGroup:nil];
}

- (void)startWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret accessGroup:(NSString *)accessGroup
{
    if (self.isInitialized) {
        return;
    }

    if ([consumerKey length] == 0 || [consumerSecret length] == 0) {
        [NSException raise:TWTRInvalidInitializationException format:@"[%@] %@ called with empty consumer key or secret.", [self class], NSStringFromSelector(_cmd)];
    }

    [self ensureResourcesBundleExists];
    [self setupAPIServiceConfigs];

    self->_authConfig = [[TWTRAuthConfig alloc] initWithConsumerKey:consumerKey consumerSecret:consumerSecret];

    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];

    [self setupImageLoaderWithCacheDir:cacheDir];

    [self setupNetworkingSessionStackWithAccessGroup:accessGroup];
    [TWTRResourcesUtil setKitVersion:TWTRVersion];

    [self kitDidFinishStarting];
    _initialized = YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  TwitterKit makes sure that the container app has the Resources.bundle file that it needs.
 *  If this file is not present, localization strings will be missing, which leads to something
 *  that's harder to debug by developers.
 *  @throws NSException
 */
- (void)ensureResourcesBundleExists
{
    const BOOL resourcesBundleExists = ([TWTRResourcesUtil bundleWithBundlePath:TWTRResourceBundleLocation] != nil);
    if (!resourcesBundleExists) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ resources file not found. Please re-install TwitterKit with CocoaPods to ensure it is properly set-up.", TWTRResourceBundleLocation.lastPathComponent] userInfo:nil];
    }
}

#pragma mark - Public

- (TWTRSessionStore *)sessionStore
{
    [self assertTwitterKitInitialized];
    return _sessionStore;
}

- (TWTRAuthConfig *)authConfig
{
    [self assertTwitterKitInitialized];
    return _authConfig;
}

#pragma mark - Kit Lifecycle

/**
 *  Signals the kit has finished starting and all the essential networking and auth components
 *  are ready to be used.
 */
- (void)kitDidFinishStarting
{
    _userSessionVerifier = [[TWTRUserSessionVerifier alloc] initWithDelegate:self maxDesiredInterval:TWTRUserSessionVerifierIntervalDaily];
    [self.userSessionVerifier startVerificationAfterDelay:TWTRUserSessionVerifierDefaultDelay];
}

#pragma mark - TWTRUserSessionVerifierDelegate

- (void)userSessionVerifierNeedsSessionVerification:(TWTRUserSessionVerifier *)userSessionVerifier
{
    TWTRParameterAssertOrReturn(self.sessionStore);

    NSArray *sessions = [self.sessionStore existingUserSessions];

    for (id<TWTRAuthSession> session in sessions) {
        [self pingVerifySessionForAuthSession:session];
    }
}

- (void)pingVerifySessionForAuthSession:(id<TWTRAuthSession>)session
{
    TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:session.userID];

    [client verifySessionWithCompletion:^(id object, NSError *error) {
#if DEBUG
        if (error) {
            NSLog(@"Error verifying user session %@: %@", session.userID, error);
        }
#endif
    }];
}

- (void)assertTwitterKitInitialized
{
    if ([TWTRRuntime isRunningUnitTests]) {
        return;
    }
    if (!self.isInitialized) {
        [NSException raise:TWTRInvalidInitializationException format:@"Attempted to call TwitterKit methods before calling the requisite start method. You must call TWTRTwitter.sharedInstance().start(withConsumerKey:consumerSecret:) before calling any other methods."];
    }
}

#pragma mark - Setup Methods

- (void)setupAPIServiceConfigs
{
    id<TWTRAPIServiceConfig> twitterConfig = [[TWTRTwitterAPIServiceConfig alloc] init];
    id<TWTRAPIServiceConfig> uploadConfig = [[TWTRTwitterUploadServiceConfig alloc] init];
    id<TWTRAPIServiceConfig> cardsConfig = [[TWTRTwitterCardsServiceConfig alloc] init];

    [[TWTRAPIServiceConfigRegistry defaultRegistry] registerServiceConfig:twitterConfig forType:TWTRAPIServiceConfigTypeDefault];
    [[TWTRAPIServiceConfigRegistry defaultRegistry] registerServiceConfig:uploadConfig forType:TWTRAPIServiceConfigTypeUpload];
    [[TWTRAPIServiceConfigRegistry defaultRegistry] registerServiceConfig:cardsConfig forType:TWTRAPIServiceConfigTypeCards];
}

- (void)setupNetworkingSessionStackWithAccessGroup:(nullable NSString *)accessGroup
{
    NSURLSession *URLSession = [TWTRAPIClient URLSession];

    id<TWTRAPIServiceConfig> defaultConfig = [[TWTRAPIServiceConfigRegistry defaultRegistry] configForType:TWTRAPIServiceConfigTypeDefault];

    TWTRGuestSessionRefreshStrategy *guestSessionRefreshStrategy = [[TWTRGuestSessionRefreshStrategy alloc] initWithAuthConfig:_authConfig APIServiceConfig:defaultConfig];

    _sessionStore = [[TWTRSessionStore alloc] initWithAuthConfig:_authConfig APIServiceConfig:defaultConfig refreshStrategies:@[guestSessionRefreshStrategy] URLSession:URLSession accessGroup:accessGroup];

    TWTRSessionMigrator *migrator = [[TWTRSessionMigrator alloc] init];
    [migrator runMigrationWithDestination:_sessionStore removeOnSuccess:NO];

    _sessionStore.userLogoutHook = ^(NSString *userID) {
        [migrator removeDeprecatedSessions];

        // also clear web view cookies so users will actually be prompted on the next web login
        [TWTRCookieStorageUtil clearCookiesWithDomainSuffix:@"twitter.com"];
        [[NSNotificationCenter defaultCenter] postNotificationName:TWTRUserDidLogOutNotification object:nil userInfo:@{TWTRLoggedOutUserIDKey: userID}];
    };

    // Only persist session to system account for Twitter user sessions. No callback because
    // we don't care if this succeeds since it will also be persisted into the keychain.
    _sessionStore.userSessionSavedCompletion = ^(id<TWTRAuthSession> savedSession) {
        if ([savedSession isMemberOfClass:[TWTRSession class]]) {
            TWTRSession *twitterUserSession = savedSession;
            [TWTRSystemAccountSerializer saveToSystemAccountCredentials:[twitterUserSession dictionaryRepresentation] completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:TWTRUserDidLogInNotification object:nil userInfo:@{TWTRLoggedInUserIDKey: twitterUserSession.userID}];
        }
    };

    [TWTRAPIClient registerSharedSessionStore:_sessionStore];

    TWTRAuthConfigStore *configStore = [[TWTRAuthConfigStore alloc] initWithNameSpace:TWTRBundleID];
    TWTRAuthConfigSessionsValidator *sessionsValidator = [[TWTRAuthConfigSessionsValidator alloc] initWithConfigStore:configStore sessionStore:_sessionStore];
    [sessionsValidator validateSessionStoreContainsValidAuthConfig];
}

- (void)setupImageLoaderWithCacheDir:(NSString *)cacheDir
{
    NSString *assetCacheFullPath = [cacheDir stringByAppendingPathComponent:AssetCachePath];
    TWTRImageLoaderDiskCache *assetDiskCache = [[TWTRImageLoaderDiskCache alloc] initWithPath:assetCacheFullPath maxSize:AssetCacheMaxSize];

    NSURLSessionConfiguration *assetSessionConfig = [TWTRAssetURLSessionConfig defaultConfiguration];
    NSURLSession *imageSession = [NSURLSession sessionWithConfiguration:assetSessionConfig];
    TWTRImageLoaderTaskManager *imageTaskManager = [[TWTRImageLoaderTaskManager alloc] init];
    TWTRImageLoader *imageLoader = [[TWTRImageLoader alloc] initWithSession:imageSession cache:assetDiskCache taskManager:imageTaskManager];
    _imageLoader = imageLoader;
}

#pragma mark - Login

- (void)logInWithCompletion:(TWTRLogInCompletion)completion
{
    [self logInWithViewController:nil completion:completion];
}

- (void)logInWithViewController:(UIViewController *)viewController completion:(TWTRLogInCompletion)completion
{
    TWTRParameterAssertOrReturn(completion);
    [self assertTwitterKitInitialized];

    TWTRLoginURLParser *loginURLParser = [[TWTRLoginURLParser alloc] initWithAuthConfig:self.sessionStore.authConfig];
    if (![loginURLParser hasValidURLScheme]) {
        // Throws exception if the app does not have a valid scheme
        [NSException raise:TWTRInvalidInitializationException format:@"Attempt made to Log in or Like a Tweet without a valid Twitter Kit URL Scheme set up in the app settings. Please see https://dev.twitter.com/twitterkit/ios/installation for more info."];
    } else {
        __weak typeof(viewController) weakViewController = viewController;
        self.mobileSSO = [[TWTRMobileSSO alloc] initWithAuthConfig:self.sessionStore.authConfig];
        [self.mobileSSO attemptAppLoginWithCompletion:^(TWTRSession *session, NSError *error) {
            if (session) {
                completion(session, error);
            } else {
                if (error.domain == TWTRLogInErrorDomain && error.code == TWTRLogInErrorCodeCancelled) {
                    // The user tapped "Cancel"
                    completion(session, error);
                } else {
                    typeof(weakViewController) strongViewController = weakViewController;
                    // There wasn't a Twitter app
                    [self performWebBasedLogin:strongViewController completion:completion];
                }
            }
        }];
    }
}

#pragma mark - Internal Login

- (void)performWebBasedLogin:(UIViewController *)viewController completion:(TWTRLogInCompletion)completion
{
    if (!viewController) {
        viewController = [TWTRUtils topViewController];
    }

    self.webAuthenticationFlow = [[TWTRWebAuthenticationFlow alloc] initWithSessionStore:self.sessionStore];

    __weak typeof(viewController) weakViewController = viewController;
    [self.webAuthenticationFlow beginAuthenticationFlow:^(UIViewController *controller) {
        __strong typeof(weakViewController) strongViewController = weakViewController;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        [strongViewController presentViewController:navigationController animated:YES completion:nil];
    }
        completion:^(TWTRSession *session, NSError *error) {
            /**
                Grab the top view controller here since the top most view controller should be the
                web view controller at this point in the login cycle otherwise this would dismiss
                the view controller below it.
             */
            [[TWTRUtils topViewController] dismissViewControllerAnimated:YES completion:nil];
            completion(session, error);
        }];
}

- (BOOL)shouldShowWebBasedLogin:(NSError *)error
{
    if ([error.domain isEqualToString:TWTRLogInErrorDomain]) {
        return error.code == TWTRLogInErrorCodeDenied || error.code == TWTRLogInErrorCodeNoAccounts;
    }
    return NO;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary *)options
{
    NSString *sourceApplication = options[UIApplicationOpenURLOptionsSourceApplicationKey];
    BOOL isSSOBundle = [self.mobileSSO isSSOWithSourceApplication:sourceApplication];
    BOOL isWeb = [self.mobileSSO isWebWithSourceApplication:sourceApplication];

    if (isSSOBundle) {
        [self.mobileSSO processRedirectURL:url];
    } else if (isWeb) {
        BOOL isTokenValid = [self.mobileSSO verifyOauthTokenResponsefromURL:url];
        if (isTokenValid) {
            // If it wasn't a Mobile SSO redirect, try to handle as
            // SFSafariViewController redirect
            return [self.webAuthenticationFlow resumeAuthenticationWithRedirectURL:url];
        }
    } else {
        [self.mobileSSO triggerInvalidSourceError];
    }

    return NO;
}

#pragma mark - TwitterCore

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)applicationSupportDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
