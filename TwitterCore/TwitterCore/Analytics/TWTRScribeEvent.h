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
 This header is private to the Twitter Core SDK and not exposed for public SDK consumption
 */

#import <Foundation/Foundation.h>
#import "TFSScribe.h"
#import "TWTRScribeClientEventNamespace.h"
#import "TWTRScribeItem.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString *const TWTRScribeEventImpressionClient;
FOUNDATION_EXTERN NSString *const TWTRScribeEventImpressionPage;
FOUNDATION_EXTERN NSString *const TWTRScribeEventImpressionSectionTweet;
FOUNDATION_EXTERN NSString *const TWTRScribeEventImpressionSectionQuoteTweet;
FOUNDATION_EXTERN NSString *const TWTRScribeEventImpressionSectionVideo;
FOUNDATION_EXTERN NSString *const TWTRScribeEventImpressionSectionGallery;
FOUNDATION_EXTERN NSString *const TWTRScribeEventImpressionSectionAuth;

FOUNDATION_EXTERN NSString *const TWTRScribeEventImpressionComponent;
FOUNDATION_EXTERN NSString *const TWTRScribeEmptyKey;
FOUNDATION_EXTERN NSString *const TWTRScribeEventImpressionTypeLoad;
FOUNDATION_EXTERN NSString *const TWTRScribeEventImpressionTypeImpression;
FOUNDATION_EXTERN NSString *const TWTRScribeEventImpressionTypeShare;
FOUNDATION_EXTERN NSString *const TWTRScribeEventImpressionAction;
FOUNDATION_EXTERN NSString *const TWTRScribeEventActionClick;
FOUNDATION_EXTERN NSString *const TWTRScribeEventActionFilter;

FOUNDATION_EXTERN NSString *const TWTRScribeEventUniquesClient;
FOUNDATION_EXTERN NSString *const TWTRScribeEventUniquesPageTweetViews;
FOUNDATION_EXTERN NSString *const TWTRScribeEventUniquesPageLogin;
FOUNDATION_EXTERN NSString *const TWTRScribeEventUniquesAction;

FOUNDATION_EXTERN NSString *const TWTRScribeActionLike;
FOUNDATION_EXTERN NSString *const TWTRScribeActionUnlike;
FOUNDATION_EXTERN NSString *const TWTRScribeActionStart;
FOUNDATION_EXTERN NSString *const TWTRScribeActionSuccess;
FOUNDATION_EXTERN NSString *const TWTRScribeActionCancelled;
FOUNDATION_EXTERN NSString *const TWTRScribeActionFailure;

/**
 *  Possible values for which category to scribe events to.
 */
typedef NS_ENUM(NSUInteger, TWTRScribeEventCategory) {
    /**
     *  Used for logging impressions and feature usage for Tweet views.
     */
    TWTRScribeEventCategoryImpressions = 1,
    /**
     *  Used only for logging number of uniques using the Kit. There are no browsing history logged,
     *  so we can keep the events longer to calculate monthly actives.
     */
    TWTRScribeEventCategoryUniques
};

@interface TWTRScribeEvent : NSObject <TFSScribeEventParameters>

@property (nonatomic, copy, readonly, nullable) NSString *userID;
@property (nonatomic, copy, readonly, nullable) NSString *tweetID;
@property (nonatomic, copy, readonly) NSString *eventInfo;
@property (nonatomic, assign, readonly) TWTRScribeEventCategory category;
@property (nonatomic, copy, readonly) TWTRScribeClientEventNamespace *eventNamespace;
@property (nonatomic, copy, readonly) NSArray<TWTRScribeItem *> *items;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithUserID:(nullable NSString *)userID tweetID:(nullable NSString *)tweetID category:(TWTRScribeEventCategory)category eventNamespace:(TWTRScribeClientEventNamespace *)eventNamespace items:(nullable NSArray<TWTRScribeItem *> *)items;

- (instancetype)initWithUserID:(nullable NSString *)userID eventInfo:(nullable NSString *)eventInfo category:(TWTRScribeEventCategory)category eventNamespace:(TWTRScribeClientEventNamespace *)eventNamespace items:(nullable NSArray<TWTRScribeItem *> *)items;

#pragma mark - TFSScribeEventParameters

- (NSDictionary *)dictionaryRepresentation;
- (NSString *)userID;
- (NSData *)data;

@end

/**
 *  A Scribe event for logging errors to the Twitter backend
 */
@interface TWTRErrorScribeEvent : TWTRScribeEvent

@property (nonatomic, readonly) NSError *error;
@property (nonatomic, copy, readonly) NSString *errorMessage;

/**
 *  Initializer
 *
 *  @param error        (optional) An NSError object representing this error case.
 *  @param errorMessage (required) An error message describing the error situation.
 *
 *  @return A fully initialized scribe object ready to enqueue or nil if any of
 *          the required parameters are missing.
 */
- (instancetype)initWithError:(nullable NSError *)error message:(NSString *)errorMessage;

@end

NS_ASSUME_NONNULL_END
