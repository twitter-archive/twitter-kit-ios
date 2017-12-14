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

#import "TWTRMediaType.h"

static NSString *const TWTRTweetMediaEntityContentTypeGif = @"animated_gif";
static NSString *const TWTRTweetMediaEntityContentTypePhoto = @"photo";
static NSString *const TWTRTweetMediaEntityContentTypeVideo = @"video";
static NSString *const TWTRTweetMediaEntityContentTypeVine = @"vine";

TWTRMediaType TWTRMediaTypeFromStringContentType(NSString *contentType)
{
    if ([contentType isEqualToString:TWTRTweetMediaEntityContentTypeGif]) {
        return TWTRMediaTypeGIF;
    } else if ([contentType isEqualToString:TWTRTweetMediaEntityContentTypePhoto]) {
        return TWTRMediaTypePhoto;
    } else if ([contentType isEqualToString:TWTRTweetMediaEntityContentTypeVideo]) {
        return TWTRMediaTypeVideo;
    } else {
        NSLog(@"Unrecognizable Tweet media entity content type.");
        return -1;
    }
}

NSString *NSStringFromTWTRMediaType(TWTRMediaType entityType)
{
    switch (entityType) {
        case TWTRMediaTypeGIF:
            return TWTRTweetMediaEntityContentTypeGif;
        case TWTRMediaTypeVideo:
            return TWTRTweetMediaEntityContentTypeVideo;
        case TWTRMediaTypePhoto:
            return TWTRTweetMediaEntityContentTypePhoto;
        case TWTRMediaTypeVine:
            return TWTRTweetMediaEntityContentTypeVine;
    }
}
