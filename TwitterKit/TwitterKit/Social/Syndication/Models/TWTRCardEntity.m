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

#import "TWTRCardEntity.h"
#import <TwitterCore/TWTRDictUtil.h>
#import <TwitterCore/TWTRMultiThreadUtil.h>
#import "TWTRCardEntity+Subclasses.h"
#import "TWTRPlayerCardEntity.h"

NSString *const TWTRCardSiteValueToUserIDStringTransformerName = @"TWTRCardSiteValueToUserIDStringTransformer";
NSString *const TWTRCardEntityBindingValueStringTransformerName = @"TWTRCardEntityBindingValueStringTransformer";
NSString *const TWTRCardEntityBindingValueImageTransformerName = @"TWTRCardEntityBindingValueImageTransformer";

static NSString *const TWTRCardEntityURLEncodingKey = @"TWTRCardEntityURLEncodingKey";
static NSString *const TWTRCardEntitySiteValueTransformerUserValueKey = @"user_value";
static NSString *const TWTRCardEntityUserValueIDStringKey = @"id_str";
static NSString *const TWTRBindingValueTransformerStringValueKey = @"string_value";
static NSString *const TWTRCardEntityImageValueImageURLKey = @"imageURL";
static NSString *const TWTRCardEntityImageValueImageSizeKey = @"imageSize";

@implementation TWTRCardEntity

+ (void)initialize
{
    // This registration is done locally to avoid overhead at load time. We only want to
    // make this call when we parse cards which is usually not done until later in the
    // application lifecycle
    if (self == [TWTRCardEntity class]) {
        [self registerClass:[TWTRPlayerCardEntity class]];
    }
}

- (instancetype)initWithURLString:(NSString *)URLString
{
    self = [super init];
    if (self) {
        _URLString = [URLString copy];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    _URLString = [[aDecoder decodeObjectForKey:TWTRCardEntityURLEncodingKey] copy];
    return [super init];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.URLString forKey:TWTRCardEntityURLEncodingKey];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (NSUInteger)hash
{
    return [self.URLString hash];
}

+ (nullable instancetype)cardEntityFromJSONDictionary:(NSDictionary *)dictionary;
{
    NSArray<Class> *classes = [self cardEntityClasses];
    NSInteger foundIdx = [classes indexOfObjectPassingTest:^BOOL(Class _Nonnull klass, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([klass respondsToSelector:@selector(canInitWithJSONDictionary:)]) {
            BOOL canInit = [klass canInitWithJSONDictionary:dictionary];
            if (canInit) {
                *stop = YES;
                return YES;
            }
        }
        return NO;
    }];

    if (foundIdx != NSNotFound) {
        Class klass = classes[foundIdx];
        return [[klass alloc] initWithJSONDictionary:dictionary];
    }

    return nil;
}

+ (BOOL)canInitWithJSONDictionary:(NSDictionary<NSString *, id> *)JSONDictionary
{
    return NO;
}

// This method is not thread safe
+ (void)registerClass:(Class)entityClass
{
    [self unregisterClass:entityClass];

    NSMutableArray *classes = [self cardEntityClasses];
    [classes insertObject:entityClass atIndex:0];
}

// This method is not thread safe
+ (void)unregisterClass:(Class)entityClass
{
    NSMutableArray *classes = [self cardEntityClasses];
    [classes removeObject:entityClass];
}

+ (NSMutableArray<Class> *)cardEntityClasses
{
    static NSMutableArray<Class> *classes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        classes = [NSMutableArray array];
    });

    return classes;
}

@end

#pragma mark - Binding Values

@implementation TWTRCardEntityImageValue

- (instancetype)initWithURLString:(NSString *)imageURLString height:(CGFloat)height width:(CGFloat)width
{
    self = [super init];
    if (self) {
        _imageURLString = [imageURLString copy];
        _imageSize = CGSizeMake(width, height);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.imageURLString forKey:TWTRCardEntityImageValueImageURLKey];
    [coder encodeCGSize:self.imageSize forKey:TWTRCardEntityImageValueImageSizeKey];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    NSString *URLString = [coder decodeObjectForKey:TWTRCardEntityImageValueImageURLKey];
    CGSize size = [coder decodeCGSizeForKey:TWTRCardEntityImageValueImageSizeKey];
    return [self initWithURLString:URLString height:size.height width:size.width];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (NSUInteger)hash
{
    return [self.imageURLString hash];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[TWTRCardEntityImageValue class]]) {
        return [self isEqualToCardEntityImageValue:object];
    } else {
        return NO;
    }
}

- (BOOL)isEqualToCardEntityImageValue:(TWTRCardEntityImageValue *)other
{
    return [self.imageURLString isEqualToString:other.imageURLString] && CGSizeEqualToSize(self.imageSize, other.imageSize);
}

@end

#pragma mark - Value Transformers
@interface TWTRCardSiteValueToUserIDStringTransformer : NSValueTransformer
@end

@implementation TWTRCardSiteValueToUserIDStringTransformer

- (id)transformedValue:(NSDictionary *)value
{
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *userValue = [TWTRDictUtil twtr_dictForKey:TWTRCardEntitySiteValueTransformerUserValueKey inDict:value];
        return [TWTRDictUtil twtr_stringForKey:TWTRCardEntityUserValueIDStringKey inDict:userValue];
    }
    return nil;
}

@end

@interface TWTRCardEntityBindingValueStringTransformer : NSValueTransformer
@end

@implementation TWTRCardEntityBindingValueStringTransformer

- (id)transformedValue:(NSDictionary *)value
{
    if ([value isKindOfClass:[NSDictionary class]]) {
        return [TWTRDictUtil twtr_stringForKey:TWTRBindingValueTransformerStringValueKey inDict:value];
    }
    return nil;
}

@end

@interface TWTRCardEntityBindingValueImageTransformer : NSValueTransformer
@end

@implementation TWTRCardEntityBindingValueImageTransformer

- (TWTRCardEntityImageValue *)transformedValue:(NSDictionary *)value
{
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *imageDict = [TWTRDictUtil twtr_dictForKey:@"image_value" inDict:value];
        NSString *URLString = imageDict[@"url"];
        CGFloat height = [imageDict[@"height"] floatValue];
        CGFloat width = [imageDict[@"width"] floatValue];

        if (URLString && height > 0 && width > 0) {
            return [[TWTRCardEntityImageValue alloc] initWithURLString:URLString height:height width:width];
        }
    }
    return nil;
}

@end
