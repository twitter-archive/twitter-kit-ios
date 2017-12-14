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

#import <Foundation/Foundation.h>
#import "TWTRMediaEntitySize.h"

/**
 *  `TWTRTwitterAPIConfiguration` is an immutable representation of the API configuration response.
 *
 *  @see https://dev.twitter.com/rest/reference/get/help/configuration
 */
@interface TWTRTwitterAPIConfiguration : NSObject

#pragma mark - Properties

@property (nonatomic, readonly) NSUInteger DMTextCharacterLimit;
@property (nonatomic, readonly) NSUInteger charactersReservedPerMedia;
@property (nonatomic, readonly) NSUInteger maxMediaPerUpload;
@property (nonatomic, readonly, copy) NSArray<NSString *> *nonUsernamePaths;
@property (nonatomic, readonly) NSUInteger photoSizeLimit;
@property (nonatomic, readonly, copy) NSArray<TWTRMediaEntitySize *> *photoSizes;
@property (nonatomic, readonly) NSUInteger shortURLLength;
@property (nonatomic, readonly) NSUInteger shortURLLengthHTTPS;

#pragma mark - Init

/**
 *  Creates a new `TWTRMediaEntitySize` from the dictionary of Twitter API JSON response.
 *  @param dictionary A parsed dictionary of a API configuration Twitter API JSON response
 *  @return `TWTRMediaEntitySize` instance.
 */
- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary;

@end
