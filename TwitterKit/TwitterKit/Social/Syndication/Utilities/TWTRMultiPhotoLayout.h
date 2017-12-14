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
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TWTRMultiPhotoLayout : NSObject

/**
 *  Add constraints to lay out a set of views in a type of grid
 *  appropriate for images. This class doesn't know anything about
 *  the types of views.
 *
 *  Precondition: these views must be siblings under a parent UIView
 *
 *  @param views NSArray of 1-4 views.
 */
+ (void)layoutViews:(NSArray<UIView *> *)views;

@end

NS_ASSUME_NONNULL_END
