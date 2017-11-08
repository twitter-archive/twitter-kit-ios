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

#import "TWTRPersistentStore.h"
#import <TwitterCore/TWTRUtils.h>
#import "TWTROSVersionInfo.h"

@interface TWTRPersistentStoreObject : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, assign) uint64_t size;
@property (nonatomic, strong) NSDate *accessDate;

@end

@implementation TWTRPersistentStoreObject

@end

@interface TWTRPersistentStore ()

@property (nonatomic, copy) NSString *path;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign) uint64_t totalSize;
@property (nonatomic) NSUInteger maxSize;

@end

@implementation TWTRPersistentStore

- (instancetype)initWithPath:(NSString *)path maxSize:(NSUInteger)size
{
    self = [super init];
    if (self) {
        if (!path) {
            return nil;
        }

        [self setPath:path];
        [self setMaxSize:size];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [self setItems:array];

        if (![self createStoreStructure]) {
            return nil;
        } else {
            [self parseStoredObjects];
        }
    }

    return self;
}

- (BOOL)setObject:(id<NSCoding>)value forKey:(NSString *)key
{
    if (!value || !([key length] > 0)) {
        NSLog(@"[%@] Missing value or empty key. Not caching", [self class]);
        return NO;
    }

    key = [TWTRUtils urlEncodedStringForString:key];
    @synchronized(self)
    {
        if (![self path]) {
            NSLog(@"[%@] Base path is missing.", [self class]);
            return NO;
        }

        if (![self isValidValue:value]) {
            NSLog(@"[%@] Invalid value to cache.", [self class]);
            return NO;
        }

        // Make sure the filename isn't too long
        if (key.length > NAME_MAX) {
            // occurs on Cards image URL's (like Vine thumbnails)
            // just don't cache them for now
            return NO;
        }

        // Make sure the path isn't too long
        NSString *path = [self pathForKey:key];
        if (![self isValidPath:path]) {
            NSLog(@"[%@] Invalid path.", [self class]);
            return NO;
        }

        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
        if (![self isValidData:data]) {
            NSLog(@"[%@] Not valid data", [self class]);
            return NO;
        }

        BOOL success = [data writeToFile:path atomically:YES];
        if (success) {
            TWTRPersistentStoreObject *object = [[TWTRPersistentStoreObject alloc] init];
            [object setKey:key];
            [object setSize:(uint64_t)[data length]];
            [object setAccessDate:[NSDate date]];
            [[self items] addObject:object];
            [self setTotalSize:[self totalSize] + [data length]];

            // Are we over the store size limit?
            if ([self totalSize] >= [self maxSize]) {
                [self pruneStoredObjects];
            }
        } else {
            NSLog(@"[%@] Could not write to file.", [self class]);
        }

        return success;
    }
}

- (id)objectForKey:(NSString *)key
{
    if (!key) {
        return nil;
    }

    key = [TWTRUtils urlEncodedStringForString:key];
    @synchronized(self)
    {
        NSUInteger idx = [self indexOfObjectForKey:key];
        if (idx == NSNotFound) {
            return nil;
        }

        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *dataPath = [self pathForKey:key];
        BOOL isDirectory;
        BOOL exists = [fileManager fileExistsAtPath:dataPath isDirectory:&isDirectory];

        if (!exists || isDirectory) {
            return nil;
        }

        id<NSCoding> archivedObject = nil;

        if ([TWTROSVersionInfo majorVersion] >= 9) {
            // iOS 9 will just return nil when trying to
            // unarchive an object from a corrupt file
            archivedObject = [NSKeyedUnarchiver unarchiveObjectWithFile:dataPath];
            if (!archivedObject) {
                [self cleanCorruptItemAtPath:dataPath withIndex:idx usingFileManager:fileManager];
                return nil;
            }
        } else {
            // iOS 8 and below will throw an exception when
            // trying to unarchive an object from a corrupt file
            @try {
                archivedObject = [NSKeyedUnarchiver unarchiveObjectWithFile:dataPath];
            } @catch (NSException *exception) {
                [self cleanCorruptItemAtPath:dataPath withIndex:idx usingFileManager:fileManager];

                return nil;
            }
        }

        // Update the mod date.
        [fileManager setAttributes:@{NSFileModificationDate: [NSDate date]} ofItemAtPath:dataPath error:NULL];

        return archivedObject;
    }
}

- (void)cleanCorruptItemAtPath:(NSString *)path withIndex:(NSUInteger)index usingFileManager:(NSFileManager *)fileManager
{
    // Remove the corrupt file.
    [fileManager removeItemAtPath:path error:nil];

    TWTRPersistentStoreObject *object = self.items[index];
    self.totalSize = self.totalSize - object.size;

    [self.items removeObjectAtIndex:index];
}

- (BOOL)removeObjectForKey:(NSString *)key
{
    if (!key) {
        return NO;
    }

    @synchronized(self)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *dataPath = [[self path] stringByAppendingPathComponent:key];

        BOOL isDirectory;
        BOOL exists = [fileManager fileExistsAtPath:dataPath isDirectory:&isDirectory];

        if (!exists) {
            return NO;
        }

        BOOL success = [fileManager removeItemAtPath:dataPath error:nil];
        if (success) {
            NSUInteger idx = [self indexOfObjectForKey:key];
            TWTRPersistentStoreObject *obj = [[self items] objectAtIndex:idx];
            [self setTotalSize:[self totalSize] - [obj size]];
            [[self items] removeObjectAtIndex:idx];
        }

        return success;
    }
}

- (void)removeAllObjects
{
    @synchronized(self)
    {
        [[self items] removeAllObjects];

        NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:[self path]];
        for (NSString *path in enumerator) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
    }
}

- (BOOL)createStoreStructure
{
    BOOL isDirectory;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL exists = [fileManager fileExistsAtPath:[self path] isDirectory:&isDirectory];
    if (!exists || !isDirectory) {
        if (![fileManager createDirectoryAtPath:[self path] withIntermediateDirectories:YES attributes:@{} error:NULL]) {
            return NO;
        }
    }

    return YES;
}

- (void)parseStoredObjects
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    uint64_t totalSize = 0;
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:[NSURL fileURLWithPath:[self path]] includingPropertiesForKeys:@[NSURLNameKey, NSURLTotalFileSizeKey, NSURLContentModificationDateKey] options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];

    for (NSURL *url in enumerator) {
        NSString *fileName;
        NSNumber *fileSize;
        NSDate *accessDate;
        [url getResourceValue:&fileName forKey:NSURLNameKey error:NULL];
        [url getResourceValue:&fileSize forKey:NSURLTotalFileSizeKey error:NULL];
        [url getResourceValue:&accessDate forKey:NSURLContentAccessDateKey error:NULL];

        if (!fileName || !fileSize || !accessDate) {
            [fileManager removeItemAtURL:url error:nil];

            continue;
        }

        TWTRPersistentStoreObject *object = [[TWTRPersistentStoreObject alloc] init];
        [object setKey:fileName];
        uint64_t size = (uint64_t)[fileSize unsignedLongLongValue];
        [object setSize:size];
        [object setAccessDate:accessDate];
        [[self items] addObject:object];

        totalSize += size;
    }

    [[self items] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@keypath(TWTRPersistentStoreObject.new, key) ascending:YES]]];
    [self setTotalSize:totalSize];
}

- (NSString *)pathForKey:(NSString *)key
{
    if (!key) {
        return nil;
    }

    return [[self path] stringByAppendingPathComponent:key];
}

- (BOOL)isValidValue:(id<NSCoding>)value
{
    NSObject *object = (NSObject *)value;
    if (![object conformsToProtocol:@protocol(NSCoding)]) {
        return NO;
    }

    return YES;
}

- (BOOL)isValidData:(NSData *)data
{
    // Is this item too large to add?
    if ([data length] > [self maxSize]) {
        return NO;
    }

    return YES;
}

- (BOOL)isValidPath:(NSString *)path
{
    if ([path length] > PATH_MAX) {
        return NO;
    }

    return YES;
}

- (void)pruneStoredObjects
{
    NSMutableIndexSet *removedIndexSet = [[NSMutableIndexSet alloc] init];
    for (TWTRPersistentStoreObject *object in [self items]) {
        [removedIndexSet addIndex:[[self items] indexOfObject:object]];
        [self setTotalSize:[self totalSize] - [object size]];
        [[NSFileManager defaultManager] removeItemAtPath:[[self path] stringByAppendingPathComponent:[object key]] error:nil];

        if ([self totalSize] <= [self maxSize]) {
            break;
        }
    }

    [[self items] removeObjectsAtIndexes:removedIndexSet];
}

- (NSUInteger)indexOfObjectForKey:(NSString *)key
{
    NSUInteger index = [[self items] indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        TWTRPersistentStoreObject *object = (TWTRPersistentStoreObject *)obj;
        if ([[object key] isEqualToString:key]) {
            *stop = YES;
            return YES;
        }

        return NO;
    }];

    return index;
}

@end
