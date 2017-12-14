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

#import <UIKit/UIKit.h>

/**
 *  When this is enabled, it will replace the implementation of NSLayoutConstraint with a more descriptive format.
 */
#define TWTR_AUTO_LAYOUT_DEBUGGING_ENABLED defined(DEBUG)

#if TWTR_AUTO_LAYOUT_DEBUGGING_ENABLED

/**
 *  Use to tag a view with a name so that it shows up on the enhanced autolayout's constraint descriptions.
 *  Usage:
 *  TWTRSetAutoLayoutDebugIdentifier(self.view, @"VC's view");
 *  @note This code doens't get compiled on RELEASE builds.
 */
#define TWTRSetAutoLayoutDebugIdentifier(VIEW, IDENTIFIER) VIEW.twtr_autolayoutIdentifier = (IDENTIFIER)

@interface UIView (TWTRAutolayoutDebugging)

@property (nonatomic, copy) NSString *twtr_autolayoutIdentifier;

@end

#else
#define TWTRSetAutoLayoutDebugIdentifier(...)
#endif
