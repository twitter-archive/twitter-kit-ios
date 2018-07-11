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

#pragma mark imports

#import "TWTRSETweetAttachment.h"

@import Foundation;
@import MobileCoreServices.UTCoreTypes;

#pragma mark - extern const definitions

NSString *const TWTRSETweetShareExtensionErrorDomain = @"TWTRSETweetShareExtensionErrorDomain";

#pragma mark -

@implementation TWTRSETweetAttachmentImage

- (id)initWithImage:(UIImage *)image
{
    NSParameterAssert(image);

    if ((self = [super init])) {
        _image = image;
    }

    return self;
}

- (NSString *)urlString
{
    return nil;
}

@end

@implementation TWTRSETweetAttachmentURL

- (instancetype)initWithTitle:(nullable NSString *)title URL:(NSURL *)url previewImage:(UIImage *)previewImage
{
    NSParameterAssert(url);

    if ((self = [super init])) {
        _title = [title copy];
        _URL = [url copy];
        _previewImage = previewImage;
    }

    return self;
}

- (NSString *)urlString
{
    return _URL ? _URL.absoluteString : nil;
}

@end

@interface TWTRSETweetAttachmentCocoaItemProvider ()
@property (nullable, nonatomic, readwrite) NSString *urlString;
@end

@implementation TWTRSETweetAttachmentCocoaItemProvider {
    dispatch_queue_t _afterURLLoadQueue;
    NSMutableArray<TWTRSETweetAttachmentAfterURLLoadBlock> *_afterURLLoadBlocks;
}

- (instancetype)initWithTitle:(nullable NSString *)title itemProvider:(NSItemProvider *)itemProvider cardPreviewProvider:(nullable id<TWTRSECardPreviewProvider>)cardPreviewProvider imageDownloader:(nullable id<TWTRSEImageDownloader>)imageDownloader
{
    NSParameterAssert(itemProvider);

    if ((self = [super init])) {
        _title = [title copy];
        _itemProvider = itemProvider;
        _cardPreviewProvider = cardPreviewProvider;
        _imageDownloader = imageDownloader;
        __weak typeof(self) weakSelf = self;
        _afterURLLoadQueue = dispatch_queue_create("com.twitter.TSETweetAttachmentAfterLoadQueue", DISPATCH_QUEUE_SERIAL);

        // the itemProvider should only ever be queried once
        if ([_itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
            _afterURLLoadBlocks = [NSMutableArray arrayWithCapacity:1];
            [_itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL
                                             options:nil
                                   completionHandler:^(NSURL *url, NSError *error) {
                                       __strong typeof(self) strongSelf = weakSelf;
                                       if (strongSelf) {
                                           strongSelf->_urlString = url ? url.absoluteString : nil;
                                           // copy the array of blocks to perform, then perform outside the sync block
                                           __block NSArray<TWTRSETweetAttachmentAfterURLLoadBlock> *afterURLLoadBlocks;
                                           dispatch_sync(strongSelf->_afterURLLoadQueue, ^{
                                               afterURLLoadBlocks = [strongSelf->_afterURLLoadBlocks copy];
                                               strongSelf->_afterURLLoadBlocks = nil;
                                           });
                                           for (TWTRSETweetAttachmentAfterURLLoadBlock afterURLLoadBlock in afterURLLoadBlocks) {
                                               afterURLLoadBlock();
                                           }
                                       }
                                   }];
        }
    }

    return self;
}

- (void)afterURLLoadPerform:(TWTRSETweetAttachmentAfterURLLoadBlock)block
{
    __weak typeof(self) weakSelf = self;

    // can be async since caller expects potential async
    dispatch_async(_afterURLLoadQueue, ^{
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf && strongSelf->_afterURLLoadBlocks) {
            [strongSelf->_afterURLLoadBlocks addObject:block];
        } else {
            block();
        }
    });
}

@end
