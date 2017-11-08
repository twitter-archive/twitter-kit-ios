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

@import UIKit;

@class TSETweetAttachmentCocoaItemProvider;

NS_ASSUME_NONNULL_BEGIN

/**
 This is an implementation detail of TSETweetAttachmentView, you shouldn't use this class directly.
 @see TSETweetAttachmentView
 */
@interface TSETweetCocoaItemProviderAttachmentView : UIView

- (instancetype)initWithItemProviderAttachment:(TSETweetAttachmentCocoaItemProvider *)attachment;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
