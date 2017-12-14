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

#import "TWTRMediaEntitySize.h"
#import <TwitterCore/TWTRAssertionMacros.h>
#import <TwitterCore/TWTRDictUtil.h>

static NSString *const TWTRMediaEntitySizeResizingModeCropString = @"crop";
static NSString *const TWTRMediaEntitySizeResizingModeFitString = @"fit";
static NSString *const TWTRNameKey = @"name";
static NSString *const TWTRResizingModeKey = @"resizingMode";
static NSString *const TWTRSizeKey = @"size";

NSString *NSStringFromTWTRMediaEntitySizeResizingMode(TWTRMediaEntitySizeResizingMode resizingMode)
{
    switch (resizingMode) {
        case TWTRMediaEntitySizeResizingModeFit:
            return TWTRMediaEntitySizeResizingModeFitString;
        case TWTRMediaEntitySizeResizingModeCrop:
            return TWTRMediaEntitySizeResizingModeCropString;
        default:
            return @"";
    }
}

TWTRMediaEntitySizeResizingMode TWTRMediaEntitySizeResizingModeFromString(NSString *resizingModeString)
{
    if ([resizingModeString isEqualToString:TWTRMediaEntitySizeResizingModeCropString]) {
        return TWTRMediaEntitySizeResizingModeCrop;
    } else if ([resizingModeString isEqualToString:TWTRMediaEntitySizeResizingModeFitString]) {
        return TWTRMediaEntitySizeResizingModeFit;
    } else {
        NSLog(@"[TwitterKit] Unknown TWTRMediaEntitySizeResizingMode; default to TWTRMediaEntitySizeResizingModeFit");
        return TWTRMediaEntitySizeResizingModeFit;
    }
}

@implementation TWTRMediaEntitySize

- (instancetype)initWithName:(NSString *)name resizingMode:(TWTRMediaEntitySizeResizingMode)resizingMode size:(CGSize)size
{
    TWTRParameterAssertOrReturnValue(name, nil);

    self = [super init];

    if (self) {
        _name = [name copy];
        _resizingMode = resizingMode;
        _size = size;
    }
    return self;
}

+ (NSDictionary<NSString *, TWTRMediaEntitySize *> *)mediaEntitySizesWithJSONDictionary:(NSDictionary *)dictionary
{
    NSMutableDictionary<NSString *, TWTRMediaEntitySize *> *mediaEntitySizes = [NSMutableDictionary dictionary];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *sizeName, NSDictionary *sizeDictionary, BOOL *stop) {
        NSString *const resizeMode = [TWTRDictUtil twtr_stringForKey:@"resize" inDict:sizeDictionary];
        const NSUInteger width = [TWTRDictUtil twtr_unsignedIntegerForKey:@"w" inDict:sizeDictionary];
        const NSUInteger height = [TWTRDictUtil twtr_unsignedIntegerForKey:@"h" inDict:sizeDictionary];
        TWTRMediaEntitySize *mediaSize = [[TWTRMediaEntitySize alloc] initWithName:sizeName resizingMode:TWTRMediaEntitySizeResizingModeFromString(resizeMode) size:CGSizeMake(width, height)];
        mediaEntitySizes[sizeName] = mediaSize;
    }];

    return mediaEntitySizes;
}

- (NSUInteger)hash
{
    return [self.name hash];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[TWTRMediaEntitySize class]]) {
        return [self isEqualToMediaEntitySize:object];
    } else {
        return NO;
    }
}

- (BOOL)isEqualToMediaEntitySize:(TWTRMediaEntitySize *)otherSize
{
    return [otherSize.name isEqualToString:self.name] && otherSize.resizingMode == self.resizingMode && CGSizeEqualToSize(otherSize.size, self.size);
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"<TWTRMediaEntitySize> %@, %@, %@", self.name, NSStringFromTWTRMediaEntitySizeResizingMode(self.resizingMode), NSStringFromCGSize(self.size)];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    NSString *name = [decoder decodeObjectForKey:TWTRNameKey];
    TWTRMediaEntitySizeResizingMode resizingMode = TWTRMediaEntitySizeResizingModeFromString([decoder decodeObjectForKey:TWTRResizingModeKey]);
    CGSize size = [decoder decodeCGSizeForKey:TWTRSizeKey];

    return [self initWithName:name resizingMode:resizingMode size:size];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.name forKey:TWTRNameKey];
    [encoder encodeObject:NSStringFromTWTRMediaEntitySizeResizingMode(self.resizingMode) forKey:TWTRResizingModeKey];
    [encoder encodeCGSize:self.size forKey:TWTRSizeKey];
}

@end
