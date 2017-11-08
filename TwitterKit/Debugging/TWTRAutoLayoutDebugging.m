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

#import "TWTRAutoLayoutDebugging.h"

#if TWTR_AUTO_LAYOUT_DEBUGGING_ENABLED

#import <objc/runtime.h>

@implementation UIView (TWTRAutolayoutDebugging)

- (NSString *)twtr_autolayoutIdentifier
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTwtr_autolayoutIdentifier:(NSString *)twtr_autolayoutIdentifier
{
    objc_setAssociatedObject(self, @selector(twtr_autolayoutIdentifier), twtr_autolayoutIdentifier.copy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@interface NSLayoutConstraint (TWTRAutolayoutDebugAdditions)

@end

@implementation NSLayoutConstraint (TWTRAutolayoutDebugAdditions)

#pragma mark - description maps

+ (NSDictionary *)layoutRelationDescriptionsByValue
{
    static dispatch_once_t once;
    static NSDictionary *descriptionMap;
    dispatch_once(&once, ^{
        descriptionMap = @{
            @(NSLayoutRelationEqual): @"==",
            @(NSLayoutRelationGreaterThanOrEqual): @">=",
            @(NSLayoutRelationLessThanOrEqual): @"<=",
        };
    });
    return descriptionMap;
}

+ (NSDictionary *)layoutAttributeDescriptionsByValue
{
    static dispatch_once_t once;
    static NSDictionary *descriptionMap;
    dispatch_once(&once, ^{
        descriptionMap = @{
            @(NSLayoutAttributeTop): @"top",
            @(NSLayoutAttributeLeft): @"left",
            @(NSLayoutAttributeBottom): @"bottom",
            @(NSLayoutAttributeRight): @"right",
            @(NSLayoutAttributeLeading): @"leading",
            @(NSLayoutAttributeTrailing): @"trailing",
            @(NSLayoutAttributeWidth): @"width",
            @(NSLayoutAttributeHeight): @"height",
            @(NSLayoutAttributeCenterX): @"centerX",
            @(NSLayoutAttributeCenterY): @"centerY",
            @(NSLayoutAttributeBaseline): @"baseline",
            @(NSLayoutAttributeFirstBaseline): @"firstBaseline",
            @(NSLayoutAttributeLeftMargin): @"leftMargin",
            @(NSLayoutAttributeRightMargin): @"rightMargin",
            @(NSLayoutAttributeTopMargin): @"topMargin",
            @(NSLayoutAttributeBottomMargin): @"bottomMargin",
            @(NSLayoutAttributeLeadingMargin): @"leadingMargin",
            @(NSLayoutAttributeCenterXWithinMargins): @"centerXWithinMargins",
            @(NSLayoutAttributeCenterYWithinMargins): @"centerYWithinMargins",
        };

    });
    return descriptionMap;
}

+ (NSDictionary *)layoutPriorityDescriptionsByValue
{
    static dispatch_once_t once;
    static NSDictionary *descriptionMap;
    dispatch_once(&once, ^{
        descriptionMap = @{
            @(UILayoutPriorityDefaultHigh): @"high",
            @(UILayoutPriorityDefaultLow): @"low",
            @(UILayoutPriorityRequired): @"required",
            @(UILayoutPriorityFittingSizeLevel): @"fitting size",
        };
    });
    return descriptionMap;
}

#pragma mark - description override

+ (NSString *)descriptionForObject:(id)obj
{
    if ([obj respondsToSelector:@selector(twtr_autolayoutIdentifier)] && [obj twtr_autolayoutIdentifier]) {
        return [NSString stringWithFormat:@"%@:%@", [obj class], [obj twtr_autolayoutIdentifier]];
    }
    return [NSString stringWithFormat:@"%@:%p", [obj class], obj];
}

// Implementation borrowed from https://github.com/Masonry/Masonry/blob/master/Masonry
- (NSString *)description
{
    NSMutableString *description = [[NSMutableString alloc] initWithString:@"<"];

    [description appendString:[self.class descriptionForObject:self]];

    [description appendFormat:@" %@", [self.class descriptionForObject:self.firstItem]];
    if (self.firstAttribute != NSLayoutAttributeNotAnAttribute) {
        [description appendFormat:@".%@", [self.class.layoutAttributeDescriptionsByValue objectForKey:@(self.firstAttribute)]];
    }

    [description appendFormat:@" %@", [self.class.layoutRelationDescriptionsByValue objectForKey:@(self.relation)]];

    if (self.secondItem) {
        [description appendFormat:@" %@", [self.class descriptionForObject:self.secondItem]];
    }
    if (self.secondAttribute != NSLayoutAttributeNotAnAttribute) {
        [description appendFormat:@".%@", [self.class.layoutAttributeDescriptionsByValue objectForKey:@(self.secondAttribute)]];
    }

    if (self.multiplier != 1) {
        [description appendFormat:@" * %g", self.multiplier];
    }

    if (self.constant) {
        if (self.secondAttribute == NSLayoutAttributeNotAnAttribute) {
            [description appendFormat:@" %g", self.constant];
        } else {
            [description appendFormat:@" %@ %g", (self.constant < 0 ? @"-" : @"+"), ABS(self.constant)];
        }
    }

    if (self.priority != UILayoutPriorityRequired) {
        [description appendFormat:@" ^%@", [self.class.layoutPriorityDescriptionsByValue objectForKey:@(self.priority)] ?: [NSNumber numberWithDouble:self.priority]];
    }

    [description appendString:@">"];
    return description;
}

@end

#endif
