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

/// Using a C function instead of a category on UIView because categories may not be loaded in apps
/// importing this framework if they don't have the -ObjC flag, which Fabric/TwitterKit can't control;
FOUNDATION_EXTERN void tse_requireContentCompressionResistanceAndHuggingPriority(UIView *view);

// TODO: post-drop-iOS10-dead-code
// - remove #if/#else/#endif AND all code within
// - once removed, address all build issues regarding logic depending upon TFNIsIOS11OrGreater
// Safe to use anytime
#if __IPHONE_11_0 > __IPHONE_OS_VERSION_MIN_REQUIRED
FOUNDATION_EXTERN BOOL TWTRSEUIIsIOS11OrGreater(void);
#else
NS_INLINE BOOL TWTRSEUIIsIOS11OrGreater()
{
    return YES;
}
#endif
