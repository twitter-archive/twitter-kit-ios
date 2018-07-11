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

@import UIKit.UIView;

@class TWTRSETweetAttachmentURL;
@class UILabel;
@protocol TWTRSENetworking;

FOUNDATION_EXTERN const CGFloat TWTRSETweetURLAttachmentViewPreferredViewHeight;

NS_ASSUME_NONNULL_BEGIN

/**
 This is an implementation detail of TWTRSETweetAttachmentView, you shouldn't use this class directly.
 @see TWTRSETweetAttachmentView
 */
@interface TWTRSETweetURLAttachmentView : UIView

@property (nonatomic, readonly) UILabel *linkTitleLabel;
@property (nonatomic, readonly) UILabel *linkDomainLabel;

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

- (instancetype)initWithURLAttachment:(TWTRSETweetAttachmentURL *)attachment NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
