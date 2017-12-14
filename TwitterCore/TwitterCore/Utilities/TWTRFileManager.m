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

#import "TWTRFileManager.h"
#import "TWTRAuthenticationConstants.h"
#import "TWTRCoreConstants.h"

@implementation TWTRFileManager

+ (NSURL *)cacheDirectory
{
    // This string can't change for backwards compatibility reasons
    static NSString *const TWTRFileManagerSubdirectory = @"com.twitter.sdk.ios";
    NSFileManager *fm = [NSFileManager defaultManager];
    static NSURL *dirPath = nil;

    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        // Find the cache directory in the home directory.
        NSArray *cacheDir = [fm URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
        if ([cacheDir count] > 0) {
            // Append the SDK id to the URL for the
            // Application Support directory
            dirPath = [[cacheDir objectAtIndex:0] URLByAppendingPathComponent:TWTRFileManagerSubdirectory];

            // If the directory does not exist, this method creates it.
            NSError *theError = nil;
            if (![fm createDirectoryAtURL:dirPath withIntermediateDirectories:YES attributes:nil error:&theError]) {
                dirPath = nil;
            }
        }
    });

    return dirPath;
}

+ (BOOL)createFileWithName:(NSString *)fileName inDirectory:(NSURL *)directory
{
    NSFileManager *fm = [NSFileManager defaultManager];
    // If the directory does not exist, this method creates it.
    NSError *theError = nil;
    if (![fm createDirectoryAtURL:directory withIntermediateDirectories:YES attributes:nil error:&theError]) {
        return NO;
    }
    NSString *filePath = [self pathForFileName:fileName inDirectory:directory];
    BOOL success = [fm createFileAtPath:filePath contents:nil attributes:nil];
    return success;
}

+ (BOOL)writeDictionary:(NSDictionary *)dictionary toFileName:(NSString *)fileName inDirectory:(NSURL *)directory
{
    BOOL success = [self createFileWithName:fileName inDirectory:directory];
    if (success == NO) {
        return NO;
    }
    NSString *filePath = [self pathForFileName:fileName inDirectory:directory];
    success = [dictionary writeToFile:filePath atomically:YES];
    return success;
}

+ (NSDictionary *)readDictionaryFromFileName:(NSString *)fileName inDirectory:(NSURL *)directory
{
    NSString *filePath = [self pathForFileName:fileName inDirectory:directory];
    NSDictionary *dictionaryFromFile = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    return dictionaryFromFile;
}

+ (NSString *)pathForFileName:(NSString *)fileName inDirectory:(NSURL *)directory
{
    NSURL *fileURL = [directory URLByAppendingPathComponent:fileName isDirectory:NO];
    NSString *filePath = [fileURL path];
    return filePath;
}

@end
