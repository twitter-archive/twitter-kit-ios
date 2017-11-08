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
    _DMTextCharacterLimit = [TWTRDictUtil unsignedIntegerForKey:@"dm_text_character_limit" fromDict:dictionary];
    _charactersReservedPerMedia = [TWTRDictUtil unsignedIntegerForKey:@"characters_reserved_per_media" fromDict:dictionary];
    _maxMediaPerUpload = [TWTRDictUtil unsignedIntegerForKey:@"max_media_per_upload" fromDict:dictionary];
    _nonUsernamePaths = [TWTRDictUtil arrayForKey:@"non_username_paths" fromDict:dictionary];
    _photoSizeLimit = [TWTRDictUtil unsignedIntegerForKey:@"photo_size_limit" fromDict:dictionary];
    NSDictionary *photoSizes = [TWTRDictUtil dictForKey:@"photo_sizes" fromDict:dictionary];
    _photoSizes = [[TWTRMediaEntitySize mediaEntitySizesWithJSONDictionary:photoSizes] allValues];
    _shortURLLength = [TWTRDictUtil unsignedIntegerForKey:@"short_url_length" fromDict:dictionary];
    _shortURLLengthHTTPS = [TWTRDictUtil unsignedIntegerForKey:@"short_url_length_https" fromDict:dictionary];
}

@end
