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

#import "TWTRImageLoaderCache.h"
#import <TwitterCore/TWTRAssertionMacros.h>
#import "TWTRImageLoaderImageUtils.h"
#import "TWTRPersistentStore.h"

@implementation TWTRImageLoaderNilCache

- (void)setImage:(UIImage *)image forKey:(NSString *)key
{
}

- (void)setImageData:(NSData *)imageData forKey:(NSString *)key
{
}

- (UIImage *)fetchImageForKey:(NSString *)key
{
    return nil;
}

- (UIImage *)removeImageForKey:(NSString *)key
{
    return nil;
}

- (void)removeAllImages
{
}

@end

@interface TWTRImageLoaderDiskCache ()

@property (nonatomic, readonly) TWTRPersistentStore *persistentStore;

@end

@implementation TWTRImageLoaderDiskCache

- (nullable instancetype)initWithPath:(NSString *)path maxSize:(NSUInteger)size;
{
    TWTRParameterAssertOrReturnValue(path, nil);

    if (self = [super init]) {
        _persistentStore = [[TWTRPersistentStore alloc] initWithPath:path maxSize:size];
        if (!_persistentStore) {  // cannot init at path
            return nil;
        }
    }

    return self;
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key
{
    TWTRParameterAssertOrReturn(image && key);

    // TODO: remove fixed 1.0 compressionQuality when we add support for customizing compression per
    //       type of image e.g. thumbnail vs. main image
    NSData *const imageData = [TWTRImageLoaderImageUtils imageDataFromImage:image compressionQuality:0.9];
    [self setImageData:imageData forKey:key];
}

- (void)setImageData:(NSData *)imageData forKey:(NSString *)key
{
    TWTRParameterAssertOrReturn(imageData && key);

    [self.persistentStore setObject:imageData forKey:key];
}

- (UIImage *)fetchImageForKey:(NSString *)key
{
    TWTRParameterAssertOrReturnValue(key, nil);

    NSData *imageData = [self.persistentStore objectForKey:key];
    return [UIImage imageWithData:imageData];
}

- (UIImage *)removeImageForKey:(NSString *)key
{
    TWTRParameterAssertOrReturnValue(key, nil);

    UIImage *image = [self fetchImageForKey:key];
    [self.persistentStore removeObjectForKey:key];
    return image;
}

- (void)removeAllImages
{
    [self.persistentStore removeAllObjects];
}

@end
