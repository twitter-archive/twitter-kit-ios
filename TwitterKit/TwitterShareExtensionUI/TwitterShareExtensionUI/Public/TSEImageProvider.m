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

#import "TSEImageProvider.h"
#import "TSETweetAttachment.h"

@import MobileCoreServices;
@import UIKit.UIImage;


typedef NS_ENUM(NSInteger, TSEItemProviderLoadImageMode)
{
    TSEItemProviderLoadImageModeLoadImageClass = 0,
    TSEItemProviderLoadImageModeLoadFileURLClass,
    TSEItemProviderLoadImageModeLoadImageType,
    TSEItemProviderLoadImageModeLoadFileURLType,
};

@interface TSEImageProvider ()
@property (nonatomic) NSItemProvider *itemProvider;
@property (nullable, nonatomic) UIImage *cachedImage;
@end

static NSMapTable<NSItemProvider *, TSEImageProvider *> *sProviders;

@implementation TSEImageProvider

+ (instancetype)imageProviderWithItemProvider:(NSItemProvider *)itemProvider
{
    TSEImageProvider *imageProvider;
    if (! sProviders) {
        sProviders = [NSMapTable<NSItemProvider *, TSEImageProvider *> weakToStrongObjectsMapTable];
    } else {
        imageProvider = [self existingImageProviderForItemProvider:itemProvider];
    }

    if (! imageProvider) {
        imageProvider = [[self alloc] init];
        imageProvider.itemProvider = itemProvider;
        [sProviders setObject:imageProvider forKey:itemProvider];
    }

    return imageProvider;
}

+ (TSEImageProvider *)existingImageProviderForItemProvider:(NSItemProvider *)itemProvider
{
    for (NSItemProvider * existingItemProvider in [sProviders keyEnumerator]) {
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

typedef void(^TSEImageInternalFailureBlock)(NSError * _Nullable);

- (void)_tseui_loadWithOptions:(NSDictionary *)options
                          mode:(TSEItemProviderLoadImageMode)mode
                       success:(TSEImageSuccessBlock)successBlock
                       failure:(TSEImageInternalFailureBlock)failureBlock
{
    __weak typeof(self) weakSelf = self;

    switch (mode) {
        case TSEItemProviderLoadImageModeLoadImageClass:
        {
            if (@available(iOS 11, *)) {
                if ([_itemProvider canLoadObjectOfClass:[UIImage class]]) {
                    [_itemProvider loadObjectOfClass:[UIImage class] completionHandler:^(UIImage *itemImage, NSError *error) {
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
        case TSEItemProviderLoadImageModeLoadFileURLClass:
        {
            if (@available(iOS 11, *)) {
                if ([_itemProvider canLoadObjectOfClass:[NSURL class]]) {
                    [_itemProvider loadObjectOfClass:[NSURL class] completionHandler:^(NSURL *url, NSError *error) {
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
        case TSEItemProviderLoadImageModeLoadImageType:
        {
            [_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:options completionHandler:^(UIImage *itemImage, NSError *error) {
                if (itemImage) {
                    weakSelf.cachedImage = itemImage;
                    successBlock(itemImage);
                } else {
                    failureBlock(error);
                }
            }];
            break;
        }
        case TSEItemProviderLoadImageModeLoadFileURLType:
        {
            [_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:options completionHandler:^(NSURL *url, NSError *error) {
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
        default:
        {
            NSDictionary *userInfo = @{
                                       (NSString *)kUTTypeImage: @"unexpected load image mode!!",
                                       @"loadImageMode": [NSString stringWithFormat:@"%ld", (long)mode]
                                      };
            failureBlock([NSError errorWithDomain:TSETweetShareExtensionErrorDomain
                                             code:NSItemProviderUnavailableCoercionError
                                         userInfo:userInfo]);
            break;
        }
    }
}

- (void)loadWithOptions:(NSDictionary *)options success:(TSEImageSuccessBlock)successBlock failure:(TSEImageFailureBlock)failureBlock
{
    if (_cachedImage) {
        successBlock(_cachedImage);
        return;
    }

    void (^loadImageTypeBlock)(NSError * _Nullable) = ^(NSError * _Nullable loadObjectOfClassError) {
        [self _tseui_loadWithOptions:options mode:TSEItemProviderLoadImageModeLoadImageType success:^(UIImage *_Nonnull typeLoadImage) {
            successBlock(typeLoadImage);
        } failure:^(NSError * _Nullable loadImageTypeError) {
            [self _tseui_loadWithOptions:options mode:TSEItemProviderLoadImageModeLoadFileURLType success:^(UIImage *_Nonnull typeLoadFileURLImage) {
                successBlock(typeLoadFileURLImage);
            } failure:^(NSError * _Nullable loadFileURLTypeError) {
                NSError *error = loadObjectOfClassError;
                if (nil == error) {
                    if (loadImageTypeError && loadFileURLTypeError) {
                        NSDictionary *userInfo = @{
                                                   @"loadImageTypeError": [loadImageTypeError localizedDescription],
                                                   @"loadFileURLClassError": [loadFileURLTypeError localizedDescription]
                                                  };
                        error = [NSError errorWithDomain:TSETweetShareExtensionErrorDomain
                                                    code:-1002 // NSItemProviderItemUnavailableError-2
                                                userInfo:userInfo];
                    } else {
                        error = loadImageTypeError ?: loadFileURLTypeError;
                        if (nil == error) {
                            error = [NSError errorWithDomain:TSETweetShareExtensionErrorDomain
                                                        code:NSItemProviderUnknownError
                                                    userInfo:@{@"description": @"unknown failure loading image"}];
                        }
                    }
                }
                failureBlock(error);
            }];
        }];
    };

    if (@available(iOS 11, *)) {
        [self _tseui_loadWithOptions:options mode:TSEItemProviderLoadImageModeLoadImageClass success:^(UIImage * _Nonnull classLoadImage) {
            successBlock(classLoadImage);
        } failure:^(NSError * _Nullable loadImageClassError) {
            [self _tseui_loadWithOptions:options mode:TSEItemProviderLoadImageModeLoadFileURLClass success:^(UIImage * _Nonnull classLoadFileURLImage) {
                successBlock(classLoadFileURLImage);
            } failure:^(NSError * _Nullable loadFileURLClassError) {
                NSError *error;
                if (loadImageClassError && loadFileURLClassError) {
                    NSDictionary *userInfo = @{
                                               @"loadImageClassError": [loadImageClassError localizedDescription],
                                               @"loadFileURLClassError": [loadFileURLClassError localizedDescription]
                                              };
                    error = [NSError errorWithDomain:TSETweetShareExtensionErrorDomain
                                                code:-1102 // NSItemProviderUnexpectedValueClassError-2
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
