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

#import "TWTRTwitterAPIConfiguration.h"
#import <TwitterCore/TWTRDictUtil.h>

@implementation TWTRTwitterAPIConfiguration

- (instancetype)initWithJSONDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        [self setPropertiesFromDict:dictionary];
    }

    return self;
}

- (void)setPropertiesFromDict:(NSDictionary *)dictionary
{
    _DMTextCharacterLimit = [TWTRDictUtil twtr_unsignedIntegerForKey:@"dm_text_character_limit" inDict:dictionary];
    _charactersReservedPerMedia = [TWTRDictUtil twtr_unsignedIntegerForKey:@"characters_reserved_per_media" inDict:dictionary];
    _maxMediaPerUpload = [TWTRDictUtil twtr_unsignedIntegerForKey:@"max_media_per_upload" inDict:dictionary];
    _nonUsernamePaths = [TWTRDictUtil twtr_arrayForKey:@"non_username_paths" inDict:dictionary];
    _photoSizeLimit = [TWTRDictUtil twtr_unsignedIntegerForKey:@"photo_size_limit" inDict:dictionary];
    NSDictionary *photoSizes = [TWTRDictUtil twtr_dictForKey:@"photo_sizes" inDict:dictionary];
    _photoSizes = [[TWTRMediaEntitySize mediaEntitySizesWithJSONDictionary:photoSizes] allValues];
    _shortURLLength = [TWTRDictUtil twtr_unsignedIntegerForKey:@"short_url_length" inDict:dictionary];
    _shortURLLengthHTTPS = [TWTRDictUtil twtr_unsignedIntegerForKey:@"short_url_length_https" inDict:dictionary];
}

@end
