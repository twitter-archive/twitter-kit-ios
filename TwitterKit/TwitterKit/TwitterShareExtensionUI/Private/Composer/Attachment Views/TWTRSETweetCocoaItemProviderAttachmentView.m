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

#import "TWTRSETweetCocoaItemProviderAttachmentView.h"
#import "TWTRSECardPreviewProvider.h"
#import "TWTRSEImageDownloader.h"
#import "TWTRSEImageProvider.h"
#import "TWTRSETweetAttachment.h"
#import "TWTRSETweetAttachmentView.h"
#import "TWTRSETweetURLAttachmentView.h"

@import MobileCoreServices;

static const CGFloat kSpinnerPadding = 15.0;

@interface TWTRSETweetCocoaItemProviderAttachmentView ()

@property (nonatomic) TWTRSETweetAttachmentCocoaItemProvider *attachment;

@property (nonatomic) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic) TWTRSETweetAttachmentView *underlyingAttachmentView;

@property (nonatomic) BOOL hasStartedLoadingAttachment;

@property (nonatomic) BOOL isLoading;

@end

@implementation TWTRSETweetCocoaItemProviderAttachmentView {
    dispatch_queue_t _itemProviderQueue;
}

- (instancetype)initWithItemProviderAttachment:(TWTRSETweetAttachmentCocoaItemProvider *)attachment
{
    NSParameterAssert(attachment);

    if ((self = [super init])) {
        _attachment = attachment;
        _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        if (_attachment.cardPreviewProvider) {
            _itemProviderQueue = dispatch_queue_create("com.twitter.TSETweetCocoaItemProviderAttachmentViewCardPreviewQueue", DISPATCH_QUEUE_SERIAL);
        }

        [self addSubview:_loadingIndicator];

        [self setUpBasicConstraints];
    }

    return self;
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];

    if (newWindow) {
        [self startLoadingAttachmentIfNeeded];
    }
}

- (NSDictionary<NSString *, NSValue *> *)_tseui_previewImageOptionsForMaxImageSize:(CGSize)maxImageSize
{
    NSValue *const maxImageSizeValue = [NSValue valueWithCGSize:maxImageSize];
    return @{NSItemProviderPreferredImageSizeKey: maxImageSizeValue};
}

- (void)_tseui_loadImageWithOptions:(NSDictionary<NSString *, NSValue *> *)options attachmentImageHandler:(NSItemProviderCompletionHandler)attachmentImageHandler
{
    TWTRSEImageProvider *imageProvider = [TWTRSEImageProvider imageProviderWithItemProvider:_attachment.itemProvider];
    [imageProvider loadWithOptions:options
        success:^(UIImage *_Nonnull image) {
            attachmentImageHandler(image, nil);
        }
        failure:^(NSError *_Nonnull error) {
            attachmentImageHandler(nil, error);
        }];
}

- (void)startLoadingAttachmentIfNeeded
{
    if (self.hasStartedLoadingAttachment) {
        return;
    }

    self.hasStartedLoadingAttachment = YES;
    self.isLoading = YES;

    NSItemProvider *itemProvider = self.attachment.itemProvider;

    __weak typeof(self) weakSelf = self;
    if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
        NSDictionary<NSString *, NSValue *> *providerImageOptions = [self _tseui_previewImageOptionsForMaxImageSize:[UIScreen mainScreen].bounds.size];
        [self _tseui_loadImageWithOptions:providerImageOptions
                   attachmentImageHandler:^(UIImage *_Nonnull image, NSError *_Null_unspecified error) {
                       dispatch_block_t updateAttachmentImage = ^{
                           if (image) {
                               [weakSelf updateWithImage:image];
                           } else {  // even if the error is nil, update the UI
                               [weakSelf updateWithError:error];
                           }
                       };
                       if ([NSThread isMainThread]) {
                           updateAttachmentImage();
                       } else {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               updateAttachmentImage();
                           });
                       }
                   }];
    } else if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
        [self _tseui_loadMetadataForURLWithCompletion:^(NSURL *URL, UIImage *image, NSError *error) {
            dispatch_block_t updateAttachmentCardPreview = ^{
                if (URL) {
                    [weakSelf updateWithURL:URL previewImage:image];  // e.g. via Safari, App Store, et al.
                } else {
                    [weakSelf updateWithError:error];
                }
            };
            if ([NSThread isMainThread]) {
                updateAttachmentCardPreview();
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    updateAttachmentCardPreview();
                });
            }
        }];
    } else {
        NSAssert(NO, @"Unsupported attachment type: %@", itemProvider);
        self.isLoading = NO;
    }
}

- (void)_tseui_loadMetadataForURLWithCompletion:(void (^)(NSURL *URL, UIImage *image, NSError *error))loadMetadataCompletion
{
    __weak typeof(self) weakSelf = self;
    NSItemProviderCompletionHandler urlCompletionHandler = ^(NSURL *URL, NSError *error) {
        __strong typeof(self) self0 = weakSelf;
        if (!self0) {
            return;
        }
        if (!URL) {
            loadMetadataCompletion(nil, nil, error);
            return;
        }
        void (^fallbackLoadImageBlock)(NSItemProviderCompletionHandler) = ^(NSItemProviderCompletionHandler fallbackCompletionBlock) {
            const CGSize maxURLAttachmentPreviewImageSize = {.width = TWTRSETweetURLAttachmentViewPreferredViewHeight, .height = TWTRSETweetURLAttachmentViewPreferredViewHeight};
            __strong typeof(self) self1 = weakSelf;
            if (!self1) {
                return;
            }
            [self1 _tseui_loadImageWithOptions:[self1 _tseui_previewImageOptionsForMaxImageSize:maxURLAttachmentPreviewImageSize]
                        attachmentImageHandler:^(UIImage *fallbackImage, NSError *fallbackError) {
                            fallbackCompletionBlock(fallbackImage, fallbackError);
                        }];
        };

        if (self0.attachment.cardPreviewProvider && self.attachment.imageDownloader) {
            // want to get the cardPreview, but won't always be able to get it.
            // start two tasks in parallel:
            // (1) API request to get previewImage URL from cards, then download that image (goes to net)
            // (2) itemProvider request to get a fallback image in case (1) doesn't work (may go to XPC)
            //
            // the most likely case is (2) finishes before (1), because (2) is likely an XPC call into another
            // app, whereas (1) is a network call.  in this case:
            // - if (1) succeeds (second), the result image is returned and the fallback result is ignored
            // - if (1) fails (second), then the result of (2) will be sitting there, and will be used
            //
            // in the much less likely case of (1) finishing before (2):
            // - if (1) succeds (first), then its value will be returned immediately; (2) later exits early
            // - if (1) fails (first), then whatever happens in (2) will fire in the fallback handler

            // all of these __block variables should be synchronous behind the _itemProviderQueue !
            __block UIImage *blockFallbackImage;
            __block NSError *downloadErrorToReport;
            __block BOOL downloadImageSucceeded = NO;
            __block BOOL downloadImageFailedWithError = NO;
            __block BOOL fallbackLoadImageFinished = NO;

            // all calls to this should be in the _itemProviderQueue so it doesn't get called twice
            void (^fallbackLoadMetaDataCompletion)(NSError *) = ^(NSError *previewError) {
                NSError *finalError = (blockFallbackImage) ? nil : previewError;
                loadMetadataCompletion(URL, blockFallbackImage, finalError);
            };

            // (1) ... will do a little work, and then wait for a network call before calling completion
            [self0.attachment.cardPreviewProvider lookupImageURLStringForURLString:URL.absoluteString
                                                                        completion:^(NSString *urlString, NSError *_Nullable cardPreviewError) {
                                                                            __strong typeof(self) self1 = weakSelf;
                                                                            if (!self1) {
                                                                                return;
                                                                            }
                                                                            if (0 != urlString.length) {
                                                                                NSURL *url = [NSURL URLWithString:urlString];
                                                                                [self1.attachment.imageDownloader downloadImageFromURL:url
                                                                                                                            completion:^(UIImage *_Nullable image, NSError *_Nullable downloadError) {
                                                                                                                                __strong typeof(self) self2 = weakSelf;
                                                                                                                                if (!self2) {
                                                                                                                                    return;
                                                                                                                                }
                                                                                                                                dispatch_async(self2->_itemProviderQueue, ^{
                                                                                                                                    if (image) {
                                                                                                                                        downloadImageSucceeded = YES;
                                                                                                                                        loadMetadataCompletion(URL, image, downloadError);
                                                                                                                                    } else {
                                                                                                                                        if (fallbackLoadImageFinished) {
                                                                                                                                            fallbackLoadMetaDataCompletion(downloadError);
                                                                                                                                        } else {
                                                                                                                                            downloadImageFailedWithError = YES;
                                                                                                                                            downloadErrorToReport = downloadError;  // may be nil, that's ok
                                                                                                                                        }
                                                                                                                                    }
                                                                                                                                });
                                                                                                                            }];
                                                                            } else {
                                                                                dispatch_async(self1->_itemProviderQueue, ^{
                                                                                    if (fallbackLoadImageFinished) {
                                                                                        fallbackLoadMetaDataCompletion(cardPreviewError);
                                                                                    } else {
                                                                                        downloadImageFailedWithError = YES;
                                                                                        downloadErrorToReport = cardPreviewError;  // may be nil, that's ok
                                                                                    }
                                                                                });
                                                                            }
                                                                        }];

            // (2) ... this makes a call that returns pretty quickly; the completion block then is called pretty quickly
            fallbackLoadImageBlock(^(UIImage *fallbackPreviewImage, NSError *fallbackPreviewError) {
                __strong typeof(self) self1 = weakSelf;
                if (!self1) {
                    return;
                }
                dispatch_async(self1->_itemProviderQueue, ^{
                    if (downloadImageSucceeded) {
                        return;  // no need to continue
                    }

                    fallbackLoadImageFinished = YES;

                    blockFallbackImage = fallbackPreviewImage;  // used now if download failed; otherwise, used or ignored later

                    if (downloadImageFailedWithError) {
                        fallbackLoadMetaDataCompletion(downloadErrorToReport ?: fallbackPreviewError);  // arg may be nil, that's ok
                    }
                });
            });
        } else {
            // if no card preview code, just do the fallback approach, getting the info from the itemProvider
            fallbackLoadImageBlock(^(UIImage *fallbackPreviewImage, NSError *fallbackPreviewError) {
                loadMetadataCompletion(URL, fallbackPreviewImage, fallbackPreviewError);
            });
        }
    };

    [_attachment.itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:urlCompletionHandler];
}

- (void)updateWithURL:(NSURL *)url previewImage:(UIImage *)previewImage
{
    [self updateWithUnderlyingAttachment:[[TWTRSETweetAttachmentURL alloc] initWithTitle:self.attachment.title URL:url previewImage:previewImage]];
}

- (void)updateWithImage:(UIImage *)image
{
    [self updateWithUnderlyingAttachment:[[TWTRSETweetAttachmentImage alloc] initWithImage:image]];
}

- (void)updateWithError:(NSError *)error
{
    NSLog(@"Error loading item: %@", error);
    self.isLoading = NO;
}

- (void)updateWithUnderlyingAttachment:(id<TWTRSETweetAttachment>)attachment
{
    self.isLoading = NO;
    self.underlyingAttachmentView = [[TWTRSETweetAttachmentView alloc] initWithAttachment:attachment];
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self addSubview:self.underlyingAttachmentView];
                         [self setUpUnderlyingAttachmentViewConstraints];
                     }];
}

- (void)setIsLoading:(BOOL)isLoading
{
    if (isLoading != _isLoading) {
        _isLoading = isLoading;

        self.loadingIndicator.hidden = !isLoading;

        [self invalidateIntrinsicContentSize];
    }
}

- (void)setUpBasicConstraints
{
    self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.loadingIndicator.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [self.loadingIndicator.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    [self.loadingIndicator.topAnchor constraintGreaterThanOrEqualToAnchor:self.topAnchor constant:kSpinnerPadding].active = YES;
}

- (void)setUpUnderlyingAttachmentViewConstraints
{
    self.underlyingAttachmentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.underlyingAttachmentView.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
    [self.underlyingAttachmentView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.underlyingAttachmentView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
    [self.heightAnchor constraintEqualToAnchor:self.underlyingAttachmentView.heightAnchor].active = YES;
}

@end
