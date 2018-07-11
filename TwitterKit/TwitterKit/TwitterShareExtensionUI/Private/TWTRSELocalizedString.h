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

#import "TWTRSELocalizedResources.h"

@import Foundation;

FOUNDATION_EXTERN Class<TWTRSELocalizedResources> TSELocalized;

/*
 * Always start names with the "TSEUI_LOCALIZABLE_" prefix.
 * Otherwise English localizable string definitions in en.lproj/Localizable.strings
 * will be removed in periodical cleanup.
 */

/* "Cancel" */
#define TSEUI_LOCALIZABLE_CANCEL_ACTION_LABEL @"CANCEL_ACTION_LABEL"

/* "What's happening?" */
#define TSEUI_LOCALIZABLE_COMPOSE_TEXT_VIEW_PLACEHOLDER @"COMPOSE_TEXT_VIEW_PLACEHOLDER"

/* "Tweet not sent" */
#define TSEUI_LOCALIZABLE_COMPOSITION_SEND_TWEET_ERROR_LABEL @"COMPOSITION_SEND_TWEET_ERROR_LABEL"

/* Please go to iOS Settings > Privacy > Location Services to allow Twitter to access your location. */
#define TSEUI_LOCALIZABLE_LOCATION_SERVICES_ACCESS_DENIED_ALERT_MESSAGE @"LOCATION_SERVICES_ACCESS_DENIED_ALERT_MESSAGE"

/* Allow Twitter to access your location */
#define TSEUI_LOCALIZABLE_LOCATION_SERVICES_ACCESS_DENIED_ALERT_TITLE @"LOCATION_SERVICES_ACCESS_DENIED_ALERT_TITLE"

/* Couldn’t find your location. Please try again later. */
#define TSEUI_LOCALIZABLE_LOCATION_SERVICES_ERROR_ALERT_MESSAGE @"LOCATION_SERVICES_ERROR_ALERT_MESSAGE"

/* "Failed to access location" */
#define TSEUI_LOCALIZABLE_LOCATION_SERVICES_ERROR_ALERT_TITLE @"LOCATION_SERVICES_ERROR_ALERT_TITLE"

/* "OK" */
#define TSEUI_LOCALIZABLE_OK_ACTION_LABEL @"OK_ACTION_LABEL"

/* "Retry" */
#define TSEUI_LOCALIZABLE_RETRY_ACTION_LABEL @"RETRY_ACTION_LABEL"

/* "Tweet" */
#define TSEUI_LOCALIZABLE_SENT_TWEET_ACTION_LABEL @"SEND_TWEET_ACTION_LABEL"

/* "Account" */
#define TSEUI_LOCALIZABLE_SHARE_EXT_ACCOUNT @"SHARE_EXT_ACCOUNT"

/* "Location" */
#define TSEUI_LOCALIZABLE_SHARE_EXT_LOCATION @"SHARE_EXT_LOCATION"

/* "There are no Twitter accounts configured. You can add or create a Twitter account in Settings." */
#define TSEUI_LOCALIZABLE_SHARE_EXT_NO_ACCOUNTS_MESSAGE @"SHARE_EXT_NO_ACCOUNTS_MESSAGE"

/* There are no Twitter accounts configured. You can create or log in to an account in the Twitter app. */
#define TSEUI_LOCALIZABLE_SHARE_EXT_NO_ACCOUNTS_SIGN_IN_MESSAGE @"SHARE_EXT_NO_ACCOUNTS_SIGN_IN_MESSAGE"

/* "No Twitter Account" */
#define TSEUI_LOCALIZABLE_SHARE_EXT_NO_ACCOUNTS_TITLE @"SHARE_EXT_NO_ACCOUNTS_TITLE"

/* "None" */
#define TSEUI_LOCALIZABLE_SHARE_EXT_NONE_VALUE @"SHARE_EXT_NONE_VALUE"

/* "Tweet failed to send" */
#define TSEUI_LOCALIZABLE_SHARE_EXT_TWEET_FAILED_TITLE @"SHARE_EXT_TWEET_FAILED_TITLE"

/* "Twitter" */
#define TSEUI_LOCALIZABLE_SHARE_EXT_TWITTER_TITLE @"SHARE_EXT_TWITTER_TITLE"
