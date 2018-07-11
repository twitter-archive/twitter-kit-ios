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

#import "TWTRImageLoader.h"
#import <TwitterCore/TWTRAssertionMacros.h>
#import "TWTRConstants_Private.h"
#import "TWTRImageLoaderCache.h"
#import "TWTRImageLoaderTaskManager.h"
#import "TWTRSEImageDownloader.h"
#import "TWTRTwitter_Private.h"

#define TWTRImageLoaderQueueName [NSString stringWithFormat:@"%@.image-loader.current-tasks", TWTRBundleID]

@interface TWTRImageLoader () <TWTRSEImageDownloader>

/**
 *  Instance of configured `NSURLSession` to fetch images with.
 */
@property (nonatomic, readonly) NSURLSession *URLSession;

/**
 *  Cache store to cache fetched images in. Nil if no caching is desired.
 */
@property (nonatomic, readonly, nonnull) id<TWTRImageLoaderCache> cache;

/**
 *  Task manager that coordinates all network requests.
 */
@property (nonatomic, readonly) id<TWTRImageLoaderTaskManager> taskManager;

/**
 *  The concurrent queue on which all blocks image loader uses run on.
 */
@property (nonatomic, readonly) dispatch_queue_t privateConcurrentQueue;

@end

@implementation TWTRImageLoader

- (instancetype)initWithSession:(NSURLSession *)URLSession cache:(id<TWTRImageLoaderCache>)cache taskManager:(id<TWTRImageLoaderTaskManager>)taskManager
{
    TWTRParameterAssertOrReturnValue(URLSession && taskManager, nil);

    if (self = [super init]) {
        _URLSession = URLSession;
        _cache = cache ?: [[TWTRImageLoaderNilCache alloc] init];
        _taskManager = taskManager;
        _privateConcurrentQueue = dispatch_queue_create([TWTRImageLoaderQueueName cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_CONCURRENT);
    }

    return self;
}

- (id<NSCopying>)fetchImageWithURL:(NSURL *)url completion:(TWTRImageLoaderFetchCompletion)completion
{
    TWTRParameterAssertOrReturnValue(completion, nil);
    NSError *parameterError;
    TWTRParameterAssertSettingError(url, &parameterError);
    if (parameterError) {
        completion(nil, parameterError);
        return nil;
    }

    NSString *const imageKey = [url absoluteString];
    const id requestID = [[self class] generateRequestID];

    TWTRImageLoaderFetchCompletion backfillCacheCompletion = [self backfillCacheOnFetchCompletionWithImageKey:imageKey postBackfillCompletion:completion];
    [self fetchCachedImageWithImageKey:imageKey
                    cacheHitCompletion:completion
                   cacheMissCompletion:^{
                       [self fetchImageWithImageURL:url requestID:requestID completion:backfillCacheCompletion];
                   }];

    return requestID;
}

- (void)cancelImageWithRequestID:(id<NSCopying>)requestID
{
    TWTRParameterAssertOrReturn(requestID);

    dispatch_barrier_async(self.privateConcurrentQueue, ^{
        [[self.taskManager removeTaskWithRequestID:requestID] cancel];
    });
}

#pragma mark - Logic Flow Helpers

/**
 *  Tries to fetch image with given key from cache asynchronously. This method runs concurrently on the
 *  global queue.
 *
 *  @param imageKey            ID of the image to fetch
 *  @param cacheHitCompletion  completion block to run on the main queue if image is found in cache
 *  @param cacheMissCompletion completion block to run on the default global queue if image is not found in cache
 */
- (void)fetchCachedImageWithImageKey:(NSString *)imageKey cacheHitCompletion:(TWTRImageLoaderFetchCompletion)cacheHitCompletion cacheMissCompletion:(void (^)())cacheMissCompletion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *cachedImage = [self.cache fetchImageForKey:imageKey];
        if (cachedImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                cacheHitCompletion(cachedImage, nil);
            });
            return;
        }

        cacheMissCompletion();
    });
}

/**
 *  Fetches image over network.
 *
 *  @param imageURL   URL of the image to fetch
 *  @param requestID  ID to associate the task with
 *  @param completion completion to run on the default global queue when the fetch completes whether
 *                    it succeeds or fails
 */
- (void)fetchImageWithImageURL:(NSURL *)imageURL requestID:(id<NSCopying>)requestID completion:(TWTRImageLoaderFetchCompletion)completion
{
    TWTRParameterAssertOrReturn(completion);
    NSError *parameterError;
    TWTRParameterAssertSettingError(imageURL && requestID, &parameterError);
    if (parameterError) {
        completion(nil, parameterError);
    }

    NSURLSessionTask *fetchTask = [self.URLSession dataTaskWithURL:imageURL
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                     NSError *localizedError = [TWTRImageLoader localizedErrorFromResponse:response networkError:error];
                                                     if ([data length] == 0 || localizedError) {
                                                         completion(nil, localizedError);
                                                         return;
                                                     }

                                                     dispatch_barrier_async(self.privateConcurrentQueue, ^{
                                                         [self.taskManager removeTaskWithRequestID:requestID];
                                                         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                             // TODO: add background image decoding later. Doing init phase here only offers
                                                             // very minimal gain
                                                             UIImage *image = [UIImage imageWithData:data];
                                                             completion(image, nil);
                                                         });
                                                     });
                                                 }];

    dispatch_barrier_async(self.privateConcurrentQueue, ^{
        [self.taskManager addTask:fetchTask withRequestID:requestID];
    });
    [fetchTask resume];
}

/**
 *  Factory method for generating a completion block that caches the fetched image to cache.
 *
 *  @param imageKey               key of the image to save to cache as
 *  @param postBackfillCompletion completion block to run on the main queue after the image is cached
 *
 *  @return a proxy completion block that stores image to cache
 */
- (TWTRImageLoaderFetchCompletion)backfillCacheOnFetchCompletionWithImageKey:(NSString *)imageKey postBackfillCompletion:(TWTRImageLoaderFetchCompletion)postBackfillCompletion
{
    TWTRParameterAssertOrReturnValue(imageKey, nil);

    const TWTRImageLoaderFetchCompletion backfillCacheOnFetchCompletion = ^(UIImage *_Nullable image, NSError *_Nullable error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (image) {
                [self.cache setImage:image forKey:imageKey];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                postBackfillCompletion(image, error);
            });
        });
    };
    return backfillCacheOnFetchCompletion;
}

#pragma mark - TWTRSEImageDownloader Protocol Methods

- (id)downloadImageFromURL:(NSURL *)URL completion:(TWTRSEImageDownloadCompletion)completion
{
    return [self fetchImageWithURL:URL completion:completion];
}

- (void)cancelImageDownloadWithToken:(id)previousDownloadToken
{
    [self cancelImageWithRequestID:previousDownloadToken];
}

#pragma mark - Helpers

/**
 *  Returns error object accounting for both client and server errors.
 *
 *  @param response     request response from the server
 *  @param networkError original error object from making the request
 *
 *  @return instance of `NSError` if there was either a client or server error in the response
 */
+ (NSError *)localizedErrorFromResponse:(NSURLResponse *)response networkError:(NSError *)networkError
{
    if (networkError) {
        return networkError;
    }

    NSIndexSet *acceptableResponseCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
    NSHTTPURLResponse *httpResponse = [response isKindOfClass:[NSHTTPURLResponse class]] ? (NSHTTPURLResponse *)response : nil;
    if (httpResponse && ![acceptableResponseCodes containsIndex:(NSUInteger)httpResponse.statusCode]) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]};
        return [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSURLErrorBadServerResponse userInfo:userInfo];
    }

    return nil;
}

/**
 *  Generates a new unique identifier.
 *
 *  @return a new unique identifier
 */
+ (id)generateRequestID
{
    return (id)[NSUUID UUID];
}

@end
