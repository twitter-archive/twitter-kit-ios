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
//  Lay out 1-4 views in a grid

#import "TWTRMultiPhotoLayout.h"
#import <TwitterCore/TWTRAssertionMacros.h>
#import <UIKit/UIKit.h>
#import "TWTRViewUtil.h"

@implementation NSArray (TWTRViewConstraints)

- (NSDictionary *)namedViewsDictionary
{
    NSMutableDictionary *views = [NSMutableDictionary dictionary];

    // Option #1
    switch (self.count) {
        case 4:
            views[@"view4"] = self[3];
        case 3:
            views[@"view3"] = self[2];
        case 2:
            views[@"view2"] = self[1];
        case 1:
            views[@"view1"] = self[0];
        default:
            break;
    }

    return views;
}

@end

@implementation TWTRMultiPhotoLayout

+ (void)layoutViews:(NSArray<UIView *> *)views
{
    TWTRParameterAssertOrReturn(views.count > 0);
    TWTRParameterAssertOrReturn(views.count <= 4);
    TWTRParameterAssertOrReturn(views.firstObject.superview != nil);

    NSDictionary *viewsDict = [views namedViewsDictionary];

    if (views.count == 1) {
        [self addSingleViewConstraints:viewsDict];
    } else if (views.count == 2) {
        [self addDoubleViewConstraints:viewsDict];
    } else if (views.count == 3) {
        [self addTripleViewConstraints:viewsDict];
    } else if (views.count == 4) {
        [self addQuadrupleViewConstraints:viewsDict];
    }
}

/* One Image:
 ┌──────────────────┐
 │                  │
 │     Image #1     │
 │                  │
 └──────────────────┘
 */
+ (void)addSingleViewConstraints:(NSDictionary *)views
{
    [TWTRViewUtil addVisualConstraints:@"H:|[view1]|" views:views];
    [TWTRViewUtil addVisualConstraints:@"V:|[view1]|" views:views];
}

/* Two Images:
 ┌────────────┬────────────┐
 │            │            │
 │  Image #1  │  Image #2  │
 │            │            │
 └────────────┴────────────┘
 */
+ (void)addDoubleViewConstraints:(NSDictionary *)views
{
    [TWTRViewUtil addVisualConstraints:@"H:|[view1]-0.5-[view2(==view1)]|" views:views];

    [TWTRViewUtil addVisualConstraints:@"V:|[view1]|" views:views];
    [TWTRViewUtil addVisualConstraints:@"V:|[view2]|" views:views];
}

/* Three Images:
  ┌─────────────┬───────────┐
  │             │ Image #2  │
  │  Image #1   ├───────────┤
  │             │ Image #3  │
  └─────────────┴───────────┘
 */
+ (void)addTripleViewConstraints:(NSDictionary *)views
{
    [TWTRViewUtil addVisualConstraints:@"H:|[view1(>=view2)]-0.5-[view2]|" views:views];

    [TWTRViewUtil addVisualConstraints:@"V:|[view2]-0.5-[view3(==view2)]-0@900-|" options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight views:views];
    [TWTRViewUtil addVisualConstraints:@"V:|[view1]|" views:views];
}

/* Four Images:
 ┌───────────┬───────────┐
 │ Image #1  │ Image #2  │
 ├───────────┼───────────┤
 │ Image #3  │ Image #4  │
 └───────────┴───────────┘
 */
+ (void)addQuadrupleViewConstraints:(NSDictionary *)views
{
    [TWTRViewUtil addVisualConstraints:@"H:|[view1(==view2)]-0.5-[view2]|" views:views];
    [TWTRViewUtil addVisualConstraints:@"H:|[view3(==view4)]-0.5-[view4]|" views:views];

    [TWTRViewUtil addVisualConstraints:@"V:|[view1(==view3)]-0.5-[view3]-0@900-|" views:views];
    [TWTRViewUtil addVisualConstraints:@"V:|[view2(==view4)]-0.5-[view4]-0@900-|" views:views];
}

@end
