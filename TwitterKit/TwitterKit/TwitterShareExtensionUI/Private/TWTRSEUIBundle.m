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

#import "TWTRSEUIBundle.h"

@import Foundation;
@import UIKit.UIImage;

static NSBundle *_TSEUIBundle()
{
    static NSBundle *sTSEUIBundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sTSEUIBundle = [NSBundle bundleForClass:[TWTRSEUIBundle class]];
        sTSEUIBundle = [NSBundle bundleWithURL:[[sTSEUIBundle bundleURL] URLByAppendingPathComponent:@"TwitterShareExtensionUIResources.bundle"]];
    });

    return sTSEUIBundle;
}

@implementation TWTRSEUIBundle

+ (UIImage *)imageNamed:(NSString *)name
{
    return [UIImage imageNamed:name inBundle:_TSEUIBundle() compatibleWithTraitCollection:nil];
}

@end
