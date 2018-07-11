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

#import "TWTRSEImageProvider.h"
#import "TWTRSETweetAttachment.h"

@import MobileCoreServices;
@import UIKit.UIImage;

typedef NS_ENUM(NSInteger, TWTRSEItemProviderLoadImageMode) {
    TWTRSEItemProviderLoadImageModeLoadImageClass = 0,
    TWTRSEItemProviderLoadImageModeLoadFileURLClass,
    TWTRSEItemProviderLoadImageModeLoadImageType,
    TWTRSEItemProviderLoadImageModeLoadFileURLType,
};

@interface TWTRSEImageProvider ()
@property (nonatomic) NSItemProvider *itemProvider;
@property (nullable, nonatomic) UIImage *cachedImage;
@end

static NSMapTable<NSItemProvider *, TWTRSEImageProvider *> *sProviders;

@implementation TWTRSEImageProvider

+ (instancetype)imageProviderWithItemProvider:(NSItemProvider *)itemProvider
{
    TWTRSEImageProvider *imageProvider;
    if (!sProviders) {
        sProviders = [NSMapTable<NSItemProvider *, TWTRSEImageProvider *> weakToStrongObjectsMapTable];
    } else {
        imageProvider = [self existingImageProviderForItemProvider:itemProvider];
    }

    if (!imageProvider) {
        imageProvider = [[self alloc] init];
        imageProvider.itemProvider = itemProvider;
        [sProviders setObject:imageProvider forKey:itemProvider];
    }

    return imageProvider;
}

+ (TWTRSEImageProvider *)existingImageProviderForItemProvider:(NSItemProvider *)itemProvider
{
    for (NSItemProvider *existingItemProvider in [sProviders keyEnumerator]) {
        if ([existingItemProvider isEqual:itemProvider]) {
            return [sProviders objectForKey:existingItemProvider];
        }
    }
    return nil;
}

+ (void)reset
{
    [sProviders removeAllObjects];
}

typedef void (^TWTRSEImageInternalFailureBlock)(NSError *_Nullable);

- (void)_tseui_loadWithOptions:(NSDictionary *)options mode:(TWTRSEItemProviderLoadImageMode)mode success:(TWTRSEImageSuccessBlock)successBlock failure:(TWTRSEImageInternalFailureBlock)failureBlock
{
    __weak typeof(self) weakSelf = self;

    switch (mode) {
        case TWTRSEItemProviderLoadImageModeLoadImageClass: {
            if (@available(iOS 11, *)) {
                if ([_itemProvider canLoadObjectOfClass:[UIImage class]]) {
                    [_itemProvider loadObjectOfClass:[UIImage class]
                                   completionHandler:^(UIImage *itemImage, NSError *error) {
                                       if (itemImage) {
                                           weakSelf.cachedImage = itemImage;
                                           successBlock(itemImage);
                                       } else {
                                           failureBlock(error);
                                       }
                                   }];
                    break;
                }
            }

            failureBlock(nil);

            break;
        }
        case TWTRSEItemProviderLoadImageModeLoadFileURLClass: {
            if (@available(iOS 11, *)) {
                if ([_itemProvider canLoadObjectOfClass:[NSURL class]]) {
                    [_itemProvider loadObjectOfClass:[NSURL class]
                                   completionHandler:^(NSURL *url, NSError *error) {
                                       UIImage *imageFromDisk = nil;
                                       if (url.isFileURL) {
                                           NSData *data = [NSData dataWithContentsOfURL:url];
                                           if (data) {
                                               imageFromDisk = [UIImage imageWithData:data];
                                               weakSelf.cachedImage = imageFromDisk;
                                           }
                                       }

                                       if (imageFromDisk) {
                                           successBlock(imageFromDisk);
                                       } else {
                                           failureBlock(error);
                                       }
                                   }];
                    break;
                }
            }

            failureBlock(nil);

            break;
        }
        case TWTRSEItemProviderLoadImageModeLoadImageType: {
            [_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage
                                             options:options
                                   completionHandler:^(UIImage *itemImage, NSError *error) {
                                       if (itemImage) {
                                           weakSelf.cachedImage = itemImage;
                                           successBlock(itemImage);
                                       } else {
                                           failureBlock(error);
                                       }
                                   }];
            break;
        }
        case TWTRSEItemProviderLoadImageModeLoadFileURLType: {
            [_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage
                                             options:options
                                   completionHandler:^(NSURL *url, NSError *error) {
                                       UIImage *imageFromDisk = nil;
                                       if (url.isFileURL) {
                                           NSData *data = [NSData dataWithContentsOfURL:url];
                                           if (data) {
                                               imageFromDisk = [UIImage imageWithData:data];
                                           }
                                       }

                                       if (imageFromDisk) {
                                           weakSelf.cachedImage = imageFromDisk;
                                           successBlock(imageFromDisk);
                                       } else {
                                           failureBlock(error);
                                       }
                                   }];
            break;
        }
        default: {
            NSDictionary *userInfo = @{(NSString *)kUTTypeImage: @"unexpected load image mode!!", @"loadImageMode": [NSString stringWithFormat:@"%ld", (long)mode]};
            failureBlock([NSError errorWithDomain:TWTRSETweetShareExtensionErrorDomain code:NSItemProviderUnavailableCoercionError userInfo:userInfo]);
            break;
        }
    }
}

- (void)loadWithOptions:(NSDictionary *)options success:(TWTRSEImageSuccessBlock)successBlock failure:(TWTRSEImageFailureBlock)failureBlock
{
    if (_cachedImage) {
        successBlock(_cachedImage);
        return;
    }

    void (^loadImageTypeBlock)(NSError *_Nullable) = ^(NSError *_Nullable loadObjectOfClassError) {
        [self _tseui_loadWithOptions:options
            mode:TWTRSEItemProviderLoadImageModeLoadImageType
            success:^(UIImage *_Nonnull typeLoadImage) {
                successBlock(typeLoadImage);
            }
            failure:^(NSError *_Nullable loadImageTypeError) {
                [self _tseui_loadWithOptions:options
                    mode:TWTRSEItemProviderLoadImageModeLoadFileURLType
                    success:^(UIImage *_Nonnull typeLoadFileURLImage) {
                        successBlock(typeLoadFileURLImage);
                    }
                    failure:^(NSError *_Nullable loadFileURLTypeError) {
                        NSError *error = loadObjectOfClassError;
                        if (nil == error) {
                            if (loadImageTypeError && loadFileURLTypeError) {
                                NSDictionary *userInfo = @{@"loadImageTypeError": [loadImageTypeError localizedDescription], @"loadFileURLClassError": [loadFileURLTypeError localizedDescription]};
                                error = [NSError errorWithDomain:TWTRSETweetShareExtensionErrorDomain
                                                            code:-1002  // NSItemProviderItemUnavailableError-2
                                                        userInfo:userInfo];
                            } else {
                                error = loadImageTypeError ?: loadFileURLTypeError;
                                if (nil == error) {
                                    error = [NSError errorWithDomain:TWTRSETweetShareExtensionErrorDomain code:NSItemProviderUnknownError userInfo:@{@"description": @"unknown failure loading image"}];
                                }
                            }
                        }
                        failureBlock(error);
                    }];
            }];
    };

    if (@available(iOS 11, *)) {
        [self _tseui_loadWithOptions:options
            mode:TWTRSEItemProviderLoadImageModeLoadImageClass
            success:^(UIImage *_Nonnull classLoadImage) {
                successBlock(classLoadImage);
            }
            failure:^(NSError *_Nullable loadImageClassError) {
                [self _tseui_loadWithOptions:options
                    mode:TWTRSEItemProviderLoadImageModeLoadFileURLClass
                    success:^(UIImage *_Nonnull classLoadFileURLImage) {
                        successBlock(classLoadFileURLImage);
                    }
                    failure:^(NSError *_Nullable loadFileURLClassError) {
                        NSError *error;
                        if (loadImageClassError && loadFileURLClassError) {
                            NSDictionary *userInfo = @{@"loadImageClassError": [loadImageClassError localizedDescription], @"loadFileURLClassError": [loadFileURLClassError localizedDescription]};
                            error = [NSError errorWithDomain:TWTRSETweetShareExtensionErrorDomain
                                                        code:-1102  // NSItemProviderUnexpectedValueClassError-2
                                                    userInfo:userInfo];
                        } else {
                            error = loadImageClassError ?: loadFileURLClassError;
                        }
                        loadImageTypeBlock(error);
                    }];
            }];
    } else {
        loadImageTypeBlock(nil);
    }
}

@end
