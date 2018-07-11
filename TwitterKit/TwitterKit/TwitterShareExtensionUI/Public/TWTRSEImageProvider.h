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

@import Foundation;

@class UIImage;

NS_ASSUME_NONNULL_BEGIN

typedef void (^TWTRSEImageSuccessBlock)(UIImage *);
typedef void (^TWTRSEImageFailureBlock)(NSError *);

@interface TWTRSEImageProvider : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)imageProviderWithItemProvider:(NSItemProvider *)itemProvider;

+ (nullable TWTRSEImageProvider *)existingImageProviderForItemProvider:(NSItemProvider *)itemProvider;

- (void)loadWithOptions:(NSDictionary *)options success:(TWTRSEImageSuccessBlock)successBlock failure:(TWTRSEImageFailureBlock)failureBlock;

+ (void)reset;

@end

NS_ASSUME_NONNULL_END
