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

#import <Foundation/Foundation.h>
#import <TwitterKit/TWTRJSONConvertible.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Represents a user on Twitter.
 */
@interface TWTRUser : NSObject <NSCoding, NSCopying, TWTRJSONConvertible>

#pragma mark - Properties

/**
 *  The ID of the Twitter User.
 */
@property (nonatomic, copy, readonly) NSString *userID;

/**
 *  The user's name as it appears on their profile.
 *
 *  @warning This can be modified by the user at any time.
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 *  The user's username on Twitter.
 *
 *  @warning This can be modified by the user at any time.
 */
@property (nonatomic, copy, readonly) NSString *screenName;

/**
 *  Whether the user has been verified by Twitter.
 */
@property (nonatomic, readonly) BOOL isVerified;

/**
 *  Whether the user is protected.
 */
@property (nonatomic, readonly) BOOL isProtected;

/**
 *  The HTTPS URL of the user's profile image.
 */
@property (nonatomic, copy, readonly) NSString *profileImageURL;

/**
 *  The URL of a smaller version of the user's profile image.
 */
@property (nonatomic, copy, readonly) NSString *profileImageMiniURL;

/**
 *  The URL of a larger version of the user's profile image.
 */
@property (nonatomic, copy, readonly) NSString *profileImageLargeURL;

/**
 *  The formatted version of the user's `screenName` with the `@` sign for display purposes.
 */
@property (nonatomic, copy, readonly) NSString *formattedScreenName;

/**
 * Returns the URL for deeplinking to the the user's profile.
 */
@property (nonatomic, copy, readonly) NSURL *profileURL;

@end

NS_ASSUME_NONNULL_END
