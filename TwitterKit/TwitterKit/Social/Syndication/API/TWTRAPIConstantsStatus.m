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

#import "TWTRAPIConstantsStatus.h"

NSString *const TWTRAPIConstantsStatusShowURL = @"/1.1/statuses/show.json";
NSString *const TWTRAPIConstantsStatusLookUpURL = @"/1.1/statuses/lookup.json";
NSString *const TWTRAPIConstantsStatusUpdateURL = @"/1.1/statuses/update.json";
NSString *const TWTRAPIConstantsStatusFavoriteURL = @"/1.1/favorites/create.json";
NSString *const TWTRAPIConstantsStatusUnfavoriteURL = @"/1.1/favorites/destroy.json";
NSString *const TWTRAPIConstantsStatusRetweetURLWithFormat = @"/1.1/statuses/retweet/%lld.json";
NSString *const TWTRAPIConstantsStatusDestroyURLWithFormat = @"/1.1/statuses/destroy/%lld.json";

#pragma mark - Parameters
NSString *const TWTRAPIConstantsStatusParamStatus = @"status";
NSString *const TWTRAPIConstantsStatusParamTrimUser = @"trim_user";
NSString *const TWTRAPIConstantsStatusParamIncludeMyRetweet = @"include_my_retweet";
NSString *const TWTRAPIConstantsStatusParamIncludeEntities = @"include_entities";
NSString *const TWTRAPIConstantsStatusParamMap = @"map";

#pragma mark - Response field names
NSString *const TWTRAPIConstantsStatusFieldName = @"name";
NSString *const TWTRAPIConstantsStatusFieldCreatedAt = @"created_at";
NSString *const TWTRAPIConstantsStatusFieldDescription = @"description";
NSString *const TWTRAPIConstantsStatusFieldUsername = @"screen_name";
NSString *const TWTRAPIConstantsStatusFieldLocation = @"location";
NSString *const TWTRAPIConstantsStatusFieldPlace = @"place";
NSString *const TWTRAPIConstantsStatusFieldFollowersCount = @"followers_count";
NSString *const TWTRAPIConstantsStatusFieldFriendsCount = @"friends_count";
NSString *const TWTRAPIConstantsStatusFieldStatusesCount = @"statuses_count";
NSString *const TWTRAPIConstantsStatusFieldFavoritesCount = @"favourites_count";

NSString *const TWTRAPIConstantsStatusFieldMode = @"mode";
NSString *const TWTRAPIConstantsStatusFieldQuery = @"query";
NSString *const TWTRAPIConstantsStatusFieldProfileImageUrl = @"profile_image_url_https";
NSString *const TWTRAPIConstantsStatusFieldProfileHeaderUrl = @"profile_banner_url";
NSString *const TWTRAPIConstantsStatusFieldInReplyToUserIDString = @"in_reply_to_user_id_str";
NSString *const TWTRAPIConstantsStatusFieldInReplyToScreenName = @"in_reply_to_screen_name";
NSString *const TWTRAPIConstantsStatusFieldInReplyToStatusIDString = @"in_reply_to_status_id_str";
NSString *const TWTRAPIConstantsStatusFieldRetweetCount = @"retweet_count";
NSString *const TWTRAPIConstantsStatusFieldRetweetedStatus = @"retweeted_status";
NSString *const TWTRAPIConstantsStatusFieldQuotedStatus = @"quoted_status";

NSString *const TWTRAPIConstantsStatusFieldFavoriteCount = @"favorite_count";
NSString *const TWTRAPIConstantsStatusFieldReplyCount = @"reply_count";
NSString *const TWTRAPIConstantsStatusFieldViewCount = @"view_count";
NSString *const TWTRAPIConstantsStatusFieldDescendentReplyCount = @"descendent_reply_count";
NSString *const TWTRAPIConstantsStatusFieldText = @"text";
NSString *const TWTRAPIConstantsStatusFieldFullText = @"full_text";
NSString *const TWTRAPIConstantsStatusFieldFavorited = @"favorited";
NSString *const TWTRAPIConstantsStatusFieldRetweeted = @"retweeted";
NSString *const TWTRAPIConstantsStatusFieldSuspended = @"suspended";
NSString *const TWTRAPIConstantsStatusFieldProtected = @"protected";
NSString *const TWTRAPIConstantsStatusFieldVerified = @"verified";
NSString *const TWTRAPIConstantsStatusFieldIsLifelineInstitution = @"is_lifeline_institution";
NSString *const TWTRAPIConstantsStatusFieldGeoEnabled = @"geo_enabled";
NSString *const TWTRAPIConstantsStatusFieldCoordinates = @"coordinates";
NSString *const TWTRAPIConstantsStatusFieldUser = @"user";
NSString *const TWTRAPIConstantsStatusFieldFollowing = @"following";
NSString *const TWTRAPIConstantsStatusFieldFollowedBy = @"followed_by";
NSString *const TWTRAPIConstantsStatusFieldBlocking = @"blocking";
NSString *const TWTRAPIConstantsStatusFieldCanDM = @"can_dm";
NSString *const TWTRAPIConstantsStatusFieldWantRetweets = @"want_retweets";
NSString *const TWTRAPIConstantsStatusFieldLifelineFollowing = @"lifeline_following";

NSString *const TWTRAPIConstantsStatusFieldMetadata = @"metadata";
NSString *const TWTRAPIConstantsStatusFieldPromotedContent = @"promoted_content";
NSString *const TWTRAPIConstantsStatusFieldSampleUsers = @"users";
NSString *const TWTRAPIConstantsStatusFieldCurrentUserRetweet = @"current_user_retweet";
NSString *const TWTRAPIConstantsStatusFieldTitle = @"title";
NSString *const TWTRAPIConstantsStatusFieldScreenName = @"screen_name";
NSString *const TWTRAPIConstantsStatusFieldCardClassic = @"cards";
NSString *const TWTRAPIConstantsStatusFieldCardCurrent = @"card";
NSString *const TWTRAPIConstantsStatusFieldVersion = @"version";
NSString *const TWTRAPIConstantsStatusFieldWoeID = @"woeid";
NSString *const TWTRAPIConstantsStatusFieldCountry = @"country";
NSString *const TWTRAPIConstantsStatusFieldCountryCode = @"countryCode";
NSString *const TWTRAPIConstantsStatusFieldPossiblySensitive = @"possibly_sensitive";
NSString *const TWTRAPIConstantsStatusFieldIsEmergency = @"is_emergency";
NSString *const TWTRAPIConstantsStatusFieldConfig = @"config";
NSString *const TWTRAPIConstantsStatusFieldValue = @"value";
NSString *const TWTRAPIConstantsStatusFieldLang = @"lang";
NSString *const TWTRAPIConstantsStatusFieldTranslatedLang = @"translated_lang";

#pragma mark - Entity names
NSString *const TWTRAPIConstantsStatusFieldEntities = @"entities";
NSString *const TWTRAPIConstantsStatusFieldEntitiesUrls = @"urls";
NSString *const TWTRAPIConstantsStatusFieldEntitiesHashtags = @"hashtags";
NSString *const TWTRAPIConstantsStatusFieldEntitiesCashTags = @"symbols";
NSString *const TWTRAPIConstantsStatusFieldEntitiesUserMentions = @"user_mentions";
NSString *const TWTRAPIConstantsStatusFieldEntitiesMedia = @"media";
NSString *const TWTRAPIConstantsStatusFieldEntitiesExtended = @"extended_entities";

NSString *const TWTRAPIConstantsStatusFieldIndices = @"indices";
NSInteger const TWTRAPIConstantsStatusIndexDisplayStart = 0;
NSInteger const TWTRAPIConstantsStatusIndexDisplayEnd = 1;

#pragma mark - Url Entity names
NSString *const TWTRAPIConstantsStatusFieldUrlEntitiyUrl = @"url";
NSString *const TWTRAPIConstantsStatusFieldUrlEntityExpandedUrl = @"expanded_url";
NSString *const TWTRAPIConstantsStatusFieldUrlEntityDisplayUrl = @"display_url";

#pragma mark - Hashtag Entity names
NSString *const TWTRAPIConstantsStatusFieldHashtagEntityText = @"text";

#pragma mark - Cashtag Entity names
NSString *const TWTRAPIConstantsStatusFieldCashtagEntityText = @"text";

#pragma mark - Media Entity names
NSString *const TWTRAPIConstantsStatusFieldMediaEntityMediaID = @"id";
NSString *const TWTRAPIConstantsStatusFieldMediaEntityMediaUrl = @"media_url";
NSString *const TWTRAPIConstantsStatusFieldMediaEntityMediaUrlHttps = @"media_url_https";
NSString *const TWTRAPIConstantsStatusFieldMediaEntityType = @"type";
NSString *const TWTRAPIConstantsStatusFieldMediaEntitySizes = @"sizes";
NSString *const TWTRAPIConstantsStatusFieldMediaEntityMedium = @"medium";
NSString *const TWTRAPIConstantsStatusFieldMediaEntityWidth = @"w";
NSString *const TWTRAPIConstantsStatusFieldMediaEntityHeight = @"h";
NSString *const TWTRAPIConstantsStatusFieldMediaEntityVideoInfo = @"video_info";
NSString *const TWTRAPIConstantsStatusFieldMediaEntityEmbeddable = @"embeddable";
NSString *const TWTRAPIConstantsStatusFieldMediaEntityAdditionalMediaInfo = @"additional_media_info";

#pragma mark - User Mention Entity Names
NSString *const TWTRAPIConstantsStatusFieldUserMentionEntityUserID = @"id";
NSString *const TWTRAPIConstantsStatusFieldUserMentionEntityName = @"name";
NSString *const TWTRAPIConstantsStatusFieldUserMentionEntityScreenName = @"screen_name";
