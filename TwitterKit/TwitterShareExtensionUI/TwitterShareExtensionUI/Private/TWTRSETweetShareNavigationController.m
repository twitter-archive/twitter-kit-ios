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

#include <tgmath.h>

#import "TWTRSEColors.h"
#import "TWTRSEFonts.h"
#import "TWTRSETweetShareNavigationController.h"

@implementation TWTRSETweetShareNavigationController

+ (void)initialize
{
    if (self == [TWTRSETweetShareNavigationController class]) {
        UINavigationBar *navBarAppearance = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]];
        [navBarAppearance setBarTintColor:[UIColor whiteColor]];
        navBarAppearance.tintColor = [TWTRSEFonts navigationButtonColor];
    }
}

- (UIViewController *)tse_rootViewController
{
    return self.viewControllers.firstObject;
}

// Just calling the setter isn't enough, must implement the getter too.
- (CGSize)preferredContentSize
{
    // Have the root view controller dictate the size
    const CGSize preferredChildSize = [self tse_rootViewController].preferredContentSize;

    const CGSize childPlusNavigationBarSize = CGSizeMake(floor(preferredChildSize.width), floor(preferredChildSize.height + CGRectGetHeight(self.navigationBar.frame)));

    return childPlusNavigationBarSize;
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(id<UIContentContainer>)container
{
    if (container == [self tse_rootViewController]) {
        // Calling the setter lets the parent controller KVO on preferredContentSize know this has changed.
        [self setPreferredContentSize:self.preferredContentSize];
    }
}

@end
