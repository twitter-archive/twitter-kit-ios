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

#import "TWTRConstants_Private.h"

#pragma mark - Twitter kit constants

NSString *const TWTRVersion = @"3.4.2";
NSString *const TWTRResourceBundleLocation = @"TwitterKitResources.bundle";
NSString *const TWTRBundleID = @"com.twitter.sdk.ios";

#pragma mark - User messages

NSString *const TWTRMissingConsumerKeyMsg = @"consumer key is nil or zero length";
NSString *const TWTRMissingConsumerSecretMsg = @"consumer secret is nil or zero length";

#pragma mark - Twitter API

NSString *const TWTRAPIRateLimitHeader = @"x-rate-limit-limit";
NSString *const TWTRAPIRateLimitRemainingHeader = @"x-rate-limit-remaining";
NSString *const TWTRAPIRateLimitResetHeader = @"x-rate-limit-reset";

#pragma mark - Kit Info

NSString *const TWTRKitInfoConsumerKeyKey = @"consumerKey";
NSString *const TWTRKitInfoConsumerSecretKey = @"consumerSecret";

#pragma mark - URL Referrer

NSString *const TWTRURLReferrer = @"?ref_src=twsrc%5Etwitterkit";
