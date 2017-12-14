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

FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusShowURL;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusLookUpURL;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusUpdateURL;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFavoriteURL;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusUnfavoriteURL;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusRetweetURLWithFormat;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusDestroyURLWithFormat;

// parameters
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusParamStatus;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusParamTrimUser;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusParamIncludeMyRetweet;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusParamIncludeEntities;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusParamMap;

// Response field names
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldName;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldCreatedAt;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldDescription;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldUsername;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldLocation;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldPlace;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldFollowersCount;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldFriendsCount;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldStatusesCount;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldFavoritesCount;

FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldMode;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldQuery;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldProfileImageUrl;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldProfileHeaderUrl;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldInReplyToUserIDString;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldInReplyToScreenName;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldInReplyToStatusIDString;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldRetweetCount;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldRetweetedStatus;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldQuotedStatus;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldFavoriteCount;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldReplyCount;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldViewCount;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldDescendentReplyCount;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldText;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldFullText;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldFavorited;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldRetweeted;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldSuspended;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldProtected;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldVerified;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldIsLifelineInstitution;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldGeoEnabled;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldCoordinates;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldUser;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldFollowing;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldFollowedBy;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldBlocking;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldCanDM;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldWantRetweets;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldLifelineFollowing;

FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldMetadata;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldPromotedContent;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldSampleUsers;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldCurrentUserRetweet;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldTitle;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldScreenName;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldCardClassic;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldCardCurrent;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldVersion;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldWoeID;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldCountry;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldCountryCode;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldPossiblySensitive;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldIsEmergency;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldConfig;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldValue;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldLang;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldTranslatedLang;

// Entity names
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldEntities;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldEntitiesUrls;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldEntitiesHashtags;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldEntitiesCashTags;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldEntitiesUserMentions;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldEntitiesMedia;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldEntitiesExtended;

FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldIndices;
FOUNDATION_EXTERN NSInteger const TWTRAPIConstantsStatusIndexDisplayStart;
FOUNDATION_EXTERN NSInteger const TWTRAPIConstantsStatusIndexDisplayEnd;

// Url Entity names
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldUrlEntitiyUrl;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldUrlEntityExpandedUrl;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldUrlEntityDisplayUrl;

// Hashtag Entity names
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldHashtagEntityText;

// Cashtag Entity names
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldCashtagEntityText;

// Media Entity names
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldMediaEntityMediaID;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldMediaEntityMediaUrl;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldMediaEntityMediaUrlHttps;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldMediaEntityType;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldMediaEntitySizes;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldMediaEntityMedium;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldMediaEntityWidth;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldMediaEntityHeight;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldMediaEntityVideoInfo;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldMediaEntityEmbeddable;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldMediaEntityAdditionalMediaInfo;

// User Mention Entity Names
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldUserMentionEntityUserID;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldUserMentionEntityName;
FOUNDATION_EXTERN NSString *const TWTRAPIConstantsStatusFieldUserMentionEntityScreenName;
