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

@import UIKit;

@interface TWTRSEFonts : NSObject
@property (nonatomic, nullable, class) NSDictionary<NSString *, NSDictionary<NSString *, id> *> *fontDictionary;

@property (nonatomic, nullable, readonly, class) UIFont *composerTextFont;
@property (nonatomic, nullable, readonly, class) UIColor *composerTextColor;

@property (nonatomic, nullable, readonly, class) UIFont *composerPlaceholderFont;
@property (nonatomic, nullable, readonly, class) UIColor *composerPlaceholderColor;

@property (nonatomic, nullable, readonly, class) UIFont *characterCountFont;
@property (nonatomic, nullable, readonly, class) UIColor *characterCountLimitColor;

@property (nonatomic, nullable, readonly, class) UIFont *cardTitleFont;
@property (nonatomic, nullable, readonly, class) UIColor *cardTitleColor;

@property (nonatomic, nullable, readonly, class) UIFont *cardSubtitleFont;
@property (nonatomic, nullable, readonly, class) UIColor *cardSubtitleColor;

@property (nonatomic, nullable, readonly, class) UIFont *userFullNameFont;
@property (nonatomic, nullable, readonly, class) UIColor *userFullNameColor;

@property (nonatomic, nullable, readonly, class) UIFont *userUsernameFont;
@property (nonatomic, nullable, readonly, class) UIColor *userUsernameColor;

@property (nonatomic, nullable, readonly, class) UIFont *placeNameFont;
@property (nonatomic, nullable, readonly, class) UIColor *placeNameColor;

@property (nonatomic, nullable, readonly, class) UIFont *placeAddressFont;
@property (nonatomic, nullable, readonly, class) UIColor *placeAddressColor;

@property (nonatomic, nullable, readonly, class) UIFont *navigationButtonFont;
@property (nonatomic, nullable, readonly, class) UIColor *navigationButtonColor;

@end
