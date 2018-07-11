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

@import UIKit.UIColor;

NS_INLINE const CGFloat TWTRSEUIHexColorElement(NSUInteger hexColorElement)
{
    return (CGFloat)hexColorElement / (CGFloat)255.0;
}

NS_INLINE UIColor *TWTRSEUITwitterColorImagePlaceholder()
{
    return [UIColor colorWithRed:TWTRSEUIHexColorElement(0xCC) green:TWTRSEUIHexColorElement(0xD6) blue:TWTRSEUIHexColorElement(0xDD) alpha:1];
}
