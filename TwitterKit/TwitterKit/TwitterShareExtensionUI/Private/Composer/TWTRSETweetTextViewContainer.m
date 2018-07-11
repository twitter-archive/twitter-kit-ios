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

#import <tgmath.h>

#import "TWTRSEFonts.h"
#import "TWTRSELocalizedString.h"
#import "TWTRSETweet.h"
#import "TWTRSETweetAttachment.h"
#import "TWTRSETweetAttachmentView.h"
#import "TWTRSETweetTextView.h"
#import "TWTRSETweetTextViewContainer.h"
#import "UIView+TSEExtensions.h"

#pragma mark - static const definitions

static const CGFloat kCursorRectVerticalOutsetForScroll = 4.0;

static const CGFloat kAttachmentViewPadding = 4.0;

static const NSTimeInterval kScrollRetryDelay = 0.1;

static const UIEdgeInsets kComposeTextViewTextContainerInsets = {.top = 8, .left = 12, .bottom = 8, .right = 8};

#pragma mark -

@interface TWTRSETweetTextViewContainer () <UITextViewDelegate>

@property (nonatomic, readonly) TWTRSETweetTextView *textView;
@property (nonatomic, readonly) UILabel *placeholderLabel;

@property (nonatomic, readonly) UILabel *characterCounterLabel;

@property (nonatomic, nullable, copy) TWTRSETweet *tweet;
@property (nonatomic, nullable) TWTRSETweetAttachmentView *attachmentView;

@property (nonatomic, nullable) UIColor *characterCountBelowLimitColor;
@property (nonatomic, nullable) UIColor *characterCountOverLimitColor;

@property (nonatomic, nullable) NSLayoutConstraint *textViewHeightConstraint;
@property (nonatomic) NSUInteger numberOfLinesToDisplay;
@property (nonatomic, readonly) NSUInteger minNumberOfLinesToDisplay;

@end

@implementation TWTRSETweetTextViewContainer {
    dispatch_once_t _containerConstraintsToken;
    dispatch_once_t _attachmentViewConstraintsToken;
}

@dynamic minNumberOfLinesToDisplay;

- (instancetype)init
{
    if ((self = [super init])) {
        _textView = [[TWTRSETweetTextView alloc] initWithFrame:CGRectZero];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.font = [TWTRSEFonts composerTextFont];
        _textView.keyboardType = UIKeyboardTypeTwitter;
        _textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
        _textView.scrollsToTop = NO;
        _textView.textColor = [TWTRSEFonts composerTextColor];
        _textView.textContainerInset = kComposeTextViewTextContainerInsets;
        _textView.delegate = self;

        _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _placeholderLabel.backgroundColor = [UIColor clearColor];
        _placeholderLabel.font = [TWTRSEFonts composerPlaceholderFont];
        _placeholderLabel.numberOfLines = 1;
        _placeholderLabel.textAlignment = NSTextAlignmentRight;
        _placeholderLabel.text = [TSELocalized localizedString:TSEUI_LOCALIZABLE_COMPOSE_TEXT_VIEW_PLACEHOLDER];
        _placeholderLabel.textColor = [TWTRSEFonts composerPlaceholderColor];

        _characterCounterLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _characterCounterLabel.backgroundColor = [UIColor clearColor];
        _characterCounterLabel.font = [TWTRSEFonts characterCountFont];
        _characterCounterLabel.numberOfLines = 1;
        _characterCounterLabel.textAlignment = NSTextAlignmentRight;  // varies from Apple SLShareViewController, but stays out of the way better

        _characterCountOverLimitColor = [TWTRSEFonts characterCountLimitColor];
        _characterCountBelowLimitColor = _placeholderLabel.textColor;

        _numberOfLinesToDisplay = self.minNumberOfLinesToDisplay;  // even with empty text, provide a bit of buffer

        [self addSubview:_placeholderLabel];
        [self addSubview:_textView];
        [self addSubview:_characterCounterLabel];

        [self _tseui_updateCharacterCount];

        if (@available(iOS 11.0, *)) {
            _textView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }

        self.translatesAutoresizingMaskIntoConstraints = NO;
        _textView.translatesAutoresizingMaskIntoConstraints = NO;
        _placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _characterCounterLabel.translatesAutoresizingMaskIntoConstraints = NO;

        [self setNeedsUpdateConstraints];
    }

    return self;
}

- (CGFloat)textViewHeight
{
    return _textView.bounds.size.height;
}

- (void)_tseui_updateTextViewConstraintConstant
{
    CGFloat h = ceil(_textView.font.lineHeight * _numberOfLinesToDisplay + _textView.textContainerInset.top + _textView.textContainerInset.bottom);
    _textViewHeightConstraint.active = NO;
    _textViewHeightConstraint = [_textView.heightAnchor constraintEqualToConstant:h];
    _textViewHeightConstraint.active = YES;
}

- (void)updateConstraints
{
    dispatch_once(&_containerConstraintsToken, ^{
        tse_requireContentCompressionResistanceAndHuggingPriority(self);
        tse_requireContentCompressionResistanceAndHuggingPriority(self.characterCounterLabel);
        tse_requireContentCompressionResistanceAndHuggingPriority(self.placeholderLabel);

        [self.textView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.textView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

        [self.textView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
        [self.textView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
        [self.textView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;

        // borrowed this from @niw's code in TwitterPlatform/TFNTwitterPlaceholderTextView.m
        CGFloat placeholderInsetsLeadingAnchorConstant = self.textView.textContainerInset.left + self.textView.textContainer.lineFragmentPadding;
        [self.placeholderLabel.leadingAnchor constraintEqualToAnchor:self.textView.leadingAnchor constant:placeholderInsetsLeadingAnchorConstant].active = YES;
        [self.placeholderLabel.topAnchor constraintEqualToAnchor:self.textView.topAnchor constant:kComposeTextViewTextContainerInsets.top].active = YES;

        const UILayoutGuide *defaultMargins = self.layoutMarginsGuide;
        [self.characterCounterLabel.trailingAnchor constraintEqualToAnchor:defaultMargins.trailingAnchor constant:-kComposeTextViewTextContainerInsets.left].active = YES;
        [self.characterCounterLabel.bottomAnchor constraintLessThanOrEqualToAnchor:defaultMargins.bottomAnchor].active = YES;
        [self.characterCounterLabel.centerYAnchor constraintEqualToAnchor:self.textView.bottomAnchor].active = YES;
    });
    [self _tseui_updateLineCount];
    [super updateConstraints];
}

- (void)addAttachmentViewConstraints
{
    dispatch_once(&_attachmentViewConstraintsToken, ^{
        self.attachmentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.attachmentView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [self.attachmentView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [self.attachmentView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

        const UILayoutGuide *defaultMargins = self.layoutMarginsGuide;
        const CGFloat attachmentViewPadding = kAttachmentViewPadding * (CGFloat)(TWTRSEUIIsIOS11OrGreater() ? 1 : 3);
        [self.attachmentView.leadingAnchor constraintEqualToAnchor:defaultMargins.leadingAnchor constant:attachmentViewPadding].active = YES;
        [self.attachmentView.topAnchor constraintEqualToAnchor:self.characterCounterLabel.bottomAnchor constant:kAttachmentViewPadding / 2.0].active = YES;
        [self.attachmentView.widthAnchor constraintEqualToAnchor:defaultMargins.widthAnchor constant:(CGFloat)-2.0 * attachmentViewPadding].active = YES;
        [self.attachmentView.bottomAnchor constraintEqualToAnchor:defaultMargins.bottomAnchor constant:(CGFloat)1.5 * (kAttachmentViewPadding - attachmentViewPadding)].active = YES;
    });
}

- (void)_tseui_updateCharacterCount
{
    self.characterCounterLabel.text = [NSString stringWithFormat:@"%@", @([self.tweet remainingCharacters])];
    self.characterCounterLabel.textColor = ([self.tweet isNearOrOverCharacterLimit]) ? _characterCountOverLimitColor : _characterCountBelowLimitColor;
}

- (void)_tseui_updateLineCount
{
    NSUInteger textViewNumberOfLines = _textView.numberOfLines;
    NSUInteger min = self.minNumberOfLinesToDisplay;
    if (textViewNumberOfLines == _numberOfLinesToDisplay && textViewNumberOfLines >= min) {
        return;
    }

    _numberOfLinesToDisplay = MAX(min, textViewNumberOfLines);
    [self _tseui_updateTextViewConstraintConstant];
}

- (NSUInteger)minNumberOfLinesToDisplay
{
    return (UIUserInterfaceSizeClassRegular == self.traitCollection.verticalSizeClass) ? 3 : 2;
}

- (void)configureWithTweet:(TWTRSETweet *)tweet
{
    NSParameterAssert(tweet);

    _placeholderLabel.hidden = tweet.text.length > 0;
    if ([_placeholderLabel isHidden]) {
        _placeholderLabel.alpha = 0;  // for later animation
    }

    // Hold on to the same instance so that changes to the text made outside are taken into account in `_tseui_updateCharacterCount`.
    _tweet = tweet;
    self.textView.text = tweet.text;

    if (tweet.attachment) {
        if ([tweet.attachment isKindOfClass:[TWTRSETweetAttachmentCocoaItemProvider class]]) {
            TWTRSETweetAttachmentCocoaItemProvider *cocoaItemProviderAttachment = (TWTRSETweetAttachmentCocoaItemProvider *)tweet.attachment;
            __weak typeof(self) weakSelf = self;
            [cocoaItemProviderAttachment afterURLLoadPerform:^{
                __strong typeof(self) strongSelf = weakSelf;
                [strongSelf _tseui_updateCharacterCount];  // will account for attachment URL
            }];
        }
        self.attachmentView = [[TWTRSETweetAttachmentView alloc] initWithAttachment:tweet.attachment];
        [self addSubview:self.attachmentView];

        [self addAttachmentViewConstraints];
    }

    [self _tseui_updateCharacterCount];
    [self _tseui_updateLineCount];
    [self _tseui_notifyDelegateWithUpdatedText];
}

- (void)updateText:(NSString *)text
{
    if (text != self.textView.text && ![self.textView.text isEqual:text]) {
        self.textView.text = text;

        [self _tseui_updateLineCount];
        [self _tseui_notifyDelegateWithUpdatedText];
    }
}

- (void)setTextSelection:(NSRange)textSelection
{
    if (!NSEqualRanges(textSelection, _textSelection)) {
        _textSelection = textSelection;

        if (textSelection.location != NSNotFound && NSMaxRange(textSelection) <= self.textView.text.length) {
            self.textView.selectedRange = textSelection;
        } else {
            NSAssert(textSelection.location != NSNotFound && NSMaxRange(textSelection) <= self.textView.text.length, @"(range %@ exceeds text length %u)", NSStringFromRange(textSelection), (unsigned)self.textView.text.length);
        }
    }
}

- (void)_tseui_notifyDelegateWithUpdatedText
{
    [self.delegate tweetTextViewDidUpdateText:self.textView.text textSelection:self.textView.selectedRange];
}

- (NSUndoManager *)undoManager
{
    return self.textView.undoManager;
}

- (void)_scrollToCursorWithRetry:(BOOL)retry
{
    // caretRectForPosition returns wrong values right after layout.
    // cross-reference the calculation and retry (only once) if necessary.

    if (!_textView.selectedTextRange || !_textView.isFirstResponder) {
        return;
    }

    UITextPosition *pos = _textView.selectedTextRange.start;
    CGRect caretRect = [_textView caretRectForPosition:pos];
    if (!CGRectIsNull(caretRect)) {
        UITextPosition *posCheck = [_textView closestPositionToPoint:CGPointMake(CGRectGetMidX(caretRect), CGRectGetMidY(caretRect))];
        if ([_textView comparePosition:posCheck toPosition:pos] == NSOrderedSame) {
            CGRect cursorRect = CGRectInset([_textView convertRect:caretRect toView:self], 0.0, -kCursorRectVerticalOutsetForScroll);
            [_textView scrollRectToVisible:cursorRect animated:YES];
        } else if (retry) {
            __weak typeof(self) weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kScrollRetryDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                __strong typeof(self) strongSelf = weakSelf;
                [strongSelf _scrollToCursorWithRetry:NO];
            });
        }
    }
}

- (void)_tseui_hidePlaceholder:(BOOL)hidden
{
    if (![_placeholderLabel isHidden] && hidden) {
        [UIView animateWithDuration:0.2
            animations:^{
                self->_placeholderLabel.alpha = 0;
            }
            completion:^(BOOL finished) {
                self->_placeholderLabel.hidden = YES;
            }];
    } else if ([_placeholderLabel isHidden] && !hidden) {
        _placeholderLabel.hidden = NO;
        [UIView animateWithDuration:0.2
                         animations:^{
                             self->_placeholderLabel.alpha = 1;
                         }];
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    [self _tseui_hidePlaceholder:(0 != textView.text.length)];
    [self _tseui_updateLineCount];
    [self _tseui_notifyDelegateWithUpdatedText];
    [self _tseui_updateCharacterCount];
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    [self _tseui_notifyDelegateWithUpdatedText];
}

@end
