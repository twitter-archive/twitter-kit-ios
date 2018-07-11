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

@import Foundation.NSObject;

@class NSItemProvider;
@class NSURL;
@class UIImage;
@class UIView;
@protocol TWTRSECardPreviewProvider;
@protocol TWTRSEImageDownloader;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString *const TWTRSETweetShareExtensionErrorDomain;

#pragma mark -

@protocol TWTRSETweetAttachment <NSObject>
@property (nullable, nonatomic, readonly) NSString *urlString;
@end

@interface TWTRSETweetAttachmentImage : NSObject <TWTRSETweetAttachment>

@property (nonatomic, readonly) UIImage *image;

- (instancetype)initWithImage:(UIImage *)image;

@end

@interface TWTRSETweetAttachmentURL : NSObject <TWTRSETweetAttachment>

@property (nonatomic, readonly, copy, nullable) NSString *title;
@property (nonatomic, readonly, copy) NSURL *URL;
@property (nonatomic, readonly, copy, nullable) UIImage *previewImage;

- (instancetype)initWithTitle:(nullable NSString *)title URL:(NSURL *)url previewImage:(nullable UIImage *)previewImage;

@end

/**
 An attachment that is able to render a custom view below a tweet.
 */
@protocol TWTRSETweetAttachmentCustomCardViewProvider <TWTRSETweetAttachment>

/**
 The view's `-intrinsicContentSize` property will be consulted to size this view, with some constraints
 for max width and height.
 */
@property (nonatomic, readonly) UIView *embeddedCardView;

@end

/**
 An attachment that is able to render the contents of an `NSItemProvider`
 (like those from an iOS share extension).
 */
@interface TWTRSETweetAttachmentCocoaItemProvider : NSObject <TWTRSETweetAttachment>

/**

 @param title A title to render alongside the attachment (optional)
 @param itemProvider (required) The item provider that will be loaded to render this attachment.
        Only the `kUTTypeURL` and `kUTTypeFileURL` UTI types are currenly supported.
        For `kUTTypeText`, consider adding the text to the text of the `initialTweet` property.
 */
- (instancetype)initWithTitle:(nullable NSString *)title itemProvider:(NSItemProvider *)itemProvider cardPreviewProvider:(nullable id<TWTRSECardPreviewProvider>)cardPreviewProvider imageDownloader:(nullable id<TWTRSEImageDownloader>)imageDownloader;

@property (nonatomic, readonly, copy, nullable) NSString *title;
@property (nonatomic, readonly, copy) NSItemProvider *itemProvider;
@property (nonatomic, readonly, copy, nullable) id<TWTRSECardPreviewProvider> cardPreviewProvider;
@property (nonatomic, readonly, copy, nullable) id<TWTRSEImageDownloader> imageDownloader;

typedef void (^TWTRSETweetAttachmentAfterURLLoadBlock)(void);

- (void)afterURLLoadPerform:(TWTRSETweetAttachmentAfterURLLoadBlock)block;

@end

NS_ASSUME_NONNULL_END
