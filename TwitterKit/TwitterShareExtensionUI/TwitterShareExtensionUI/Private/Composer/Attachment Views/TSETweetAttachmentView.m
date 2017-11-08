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

#import "TSETweetAttachment.h"
#import "TSETweetAttachmentView.h"
#import "TSETweetCocoaItemProviderAttachmentView.h"
#import "TSETweetCustomCardAttachmentView.h"
#import "TSETweetImageAttachmentView.h"
#import "TSETweetURLAttachmentView.h"
#import "UIView+TSEExtensions.h"


#pragma mark -

@interface TSETweetAttachmentView ()

@property (nonatomic, readonly) UIView *attachmentView;

@end

@implementation TSETweetAttachmentView

- (void)_tseui_establishBorder
{
    self.layer.cornerRadius = 4;
    self.layer.masksToBounds = YES;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
}

- (instancetype)initWithAttachment:(id<TSETweetAttachment>)attachment
{
    NSParameterAssert(attachment);

    if ((self = [super initWithFrame:CGRectZero])) {
        if ([attachment isKindOfClass:[TSETweetAttachmentImage class]]) {
            _attachmentView = [[TSETweetImageAttachmentView alloc] initWithImageAttachment:attachment];
        } else if ([attachment isKindOfClass:[TSETweetAttachmentURL class]]) {
            _attachmentView = [[TSETweetURLAttachmentView alloc] initWithURLAttachment:attachment];
            [self _tseui_establishBorder];
        } else if ([attachment conformsToProtocol:@protocol(TSETweetAttachmentCustomCardViewProvider)]) {
            _attachmentView = [[TSETweetCustomCardAttachmentView alloc] initWithCustomCardAttachment:(id<TSETweetAttachmentCustomCardViewProvider>)attachment];
            [self _tseui_establishBorder];
        } else if ([attachment isKindOfClass:[TSETweetAttachmentCocoaItemProvider class]]) {
            _attachmentView = [[TSETweetCocoaItemProviderAttachmentView alloc] initWithItemProviderAttachment:attachment];
        }
        else {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"The provided TSETweetAttachment object is not of any of the known types." userInfo:@{@"Type" : NSStringFromClass([attachment class])}];
        }
        _attachmentView.clipsToBounds = YES;
        [self addSubview:_attachmentView];

        self.attachmentView.translatesAutoresizingMaskIntoConstraints = NO;

        [self.attachmentView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:self.layer.borderWidth].active = YES;
        [self.attachmentView.topAnchor constraintEqualToAnchor:self.topAnchor constant:self.layer.borderWidth].active = YES;
        [self.attachmentView.widthAnchor constraintEqualToAnchor:self.widthAnchor constant:(CGFloat)2.0*self.layer.borderWidth].active = YES;
        [self.heightAnchor constraintEqualToAnchor:self.attachmentView.heightAnchor constant:(CGFloat)2.0*self.layer.borderWidth].active = YES;
    }

    return self;
}

@end
