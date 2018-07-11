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

#pragma mark imports

#import "UIView+TSEExtensions.h"

#pragma mark -

void tse_requireContentCompressionResistanceAndHuggingPriority(UIView *view)
{
    [view setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [view setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

    [view setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [view setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
}

// TODO: post-drop-iOS10-dead-code: remove #if/#endif and all code within
#if __IPHONE_11_0 > __IPHONE_OS_VERSION_MIN_REQUIRED
BOOL TWTRSEUIIsIOS11OrGreater()
{
    static BOOL sIsIOS11OrGreater;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sIsIOS11OrGreater = (11 <= [NSProcessInfo processInfo].operatingSystemVersion.majorVersion && [NSBundle mainBundle]);
    });
    return sIsIOS11OrGreater;
}
#endif
