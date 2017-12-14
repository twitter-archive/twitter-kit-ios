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

#import "TWTRValueTransformers.h"
#import <TwitterCore/TWTRAPIConstants.h>
#import <TwitterCore/TWTRDateFormatters.h>
#import <TwitterCore/TWTRDictUtil.h>
#import "TWTRCardEntity.h"
#import "TWTRJSONConvertible.h"
#import "TWTRViewUtil.h"

NSString *const TWTRServerDateValueTransformerName = @"TWTRServerDateValueTransfomer";
NSString *const TWTRMyRetweetIDValueTransformerName = @"TWTRMyRetweetIDValueTransformer";
NSString *const TWTRNSURLValueTransformerName = @"TWTRNSURLValueTransformer";
NSString *const TWTRAspectRatioArrayTransformerName = @"TWTRAspectRatioArrayTransformer";
NSString *const TWTRCardEntityJSONValueTransformerName = @"TWTRCardEntityJSONValueTransformer";

@interface TWTRServerDateValueTransfomer : NSValueTransformer
@end

@implementation TWTRServerDateValueTransfomer

+ (Class)transformedValueClass
{
    return [NSDate class];
}

- (id)transformedValue:(id)value
{
    if ([value isKindOfClass:[NSString class]]) {
        return [[TWTRDateFormatters serverParsingDateFormatter] dateFromString:value];
    }
    return nil;
}

@end

@interface TWTRMyRetweetIDValueTransformer : NSValueTransformer
@end

@implementation TWTRMyRetweetIDValueTransformer

- (id)transformedValue:(NSDictionary *)value
{
    if ([value isKindOfClass:[NSDictionary class]]) {
        return [TWTRDictUtil twtr_stringForKey:TWTRAPIConstantsFieldIDString inDict:value];
    } else {
        return nil;
    }
}

@end

@interface TWTRNSURLValueTransformer : NSValueTransformer
@end

@implementation TWTRNSURLValueTransformer

- (id)transformedValue:(id)value
{
    if ([value isKindOfClass:[NSString class]]) {
        return [[NSURL alloc] initWithString:value];
    } else {
        return nil;
    }
}

@end

@interface TWTRAspectRatioArrayTransformer : NSValueTransformer
@end

@implementation TWTRAspectRatioArrayTransformer

- (id)transformedValue:(NSArray *)value
{
    if ([value isKindOfClass:[NSArray class]] && value.count == 2) {
        id first = value[0];
        id second = value[1];

        if ([first isKindOfClass:[NSNumber class]] && [second isKindOfClass:[NSNumber class]]) {
            float width = [first floatValue];
            float height = [second floatValue];
            return @([TWTRViewUtil aspectRatioForWidth:width height:height]);
        }
    }
    return nil;
}

@end

@implementation TWTRJSONConvertibleTransformer

+ (instancetype)transformerWithTargetClass:(Class)targetClass
{
    return [[self alloc] initWithTargetClass:targetClass];
}

- (instancetype)initWithTargetClass:(Class)targetClass
{
    self = [super init];
    if (self) {
        _targetClass = targetClass;
    }
    return self;
}

- (id)transformedValue:(id)value
{
    if (![self.targetClass conformsToProtocol:@protocol(TWTRJSONConvertible)]) {
        [NSException raise:NSInvalidArgumentException format:@"TWTRJSONConvertibleTransformer must have a targetClass which conforms to TWTRJSONConvertible"];
        return nil;
    }

    if ([value isKindOfClass:[NSDictionary class]]) {
        return [[self.targetClass alloc] initWithJSONDictionary:value];
    } else if ([value isKindOfClass:[NSArray class]]) {
        return [self transformedArray:value];
    } else {
        return nil;
    }
}

- (id)transformedArray:(NSArray *)inputArray
{
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:inputArray.count];

    for (NSDictionary *JSON in inputArray) {
        id obj = [self transformedValue:JSON];
        if ([obj isKindOfClass:self.targetClass]) {
            [values addObject:obj];
        } else {
            // Fail
            return nil;
        }
    }

    return values;
}

@end

@interface TWTRCardEntityJSONValueTransformer : NSValueTransformer
@end

@implementation TWTRCardEntityJSONValueTransformer

- (id)transformedValue:(NSDictionary *)value
{
    if ([value isKindOfClass:[NSDictionary class]]) {
        return [TWTRCardEntity cardEntityFromJSONDictionary:value];
    }
    return nil;
}

@end
