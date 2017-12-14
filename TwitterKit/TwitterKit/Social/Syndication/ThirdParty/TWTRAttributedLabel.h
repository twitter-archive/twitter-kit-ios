// TWTRAttributedLabel.h
//
// Copyright (c) 2011 Mattt Thompson (http://mattt.me)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

/**
 This header is private to the Twitter Kit SDK and not exposed for public SDK consumption
 */

#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>
@class TWTRTweetEntityRange;
@class TWTRTweetUrlEntity;
@class TWTRTweetHashtagEntity;
@class TWTRTweetCashtagEntity;
@class TWTRTweetUserMentionEntity;

/**
 Vertical alignment for text in a label whose bounds are larger than its text bounds
 */
typedef NS_ENUM(NSInteger, TWTRAttributedLabelVerticalAlignment) {
    TWTRAttributedLabelVerticalAlignmentCenter = 0,
    TWTRAttributedLabelVerticalAlignmentTop = 1,
    TWTRAttributedLabelVerticalAlignmentBottom = 2,
};

/**
 Determines whether the text to which this attribute applies has a strikeout drawn through itself.
 */
extern NSString *const kTWTRStrikeOutAttributeName;

/**
 The background fill color. Value must be a `UIColor`. Default value is `nil` (no fill).
 */
extern NSString *const kTWTRBackgroundFillColorAttributeName;

/**
 The padding for the background fill. Value must be a `UIEdgeInsets`. Default value is `UIEdgeInsetsZero` (no padding).
 */
extern NSString *const kTWTRBackgroundFillPaddingAttributeName;

/**
 The background stroke color. Value must be a `UIColor`. Default value is `nil` (no stroke).
 */
extern NSString *const kTWTRBackgroundStrokeColorAttributeName;

/**
 The background stroke line width. Value must be an `NSNumber`. Default value is `1.0f`.
 */
extern NSString *const kTWTRBackgroundLineWidthAttributeName;

/**
 The background corner radius. Value must be an `NSNumber`. Default value is `5.0f`.
 */
extern NSString *const kTWTRBackgroundCornerRadiusAttributeName;

@protocol TWTRAttributedLabelDelegate;

// Override UILabel @property to accept both NSString and NSAttributedString
@protocol TWTRAttributedLabel <NSObject>
@property (nonatomic, copy) id text;
@end

/**
 `TWTRAttributedLabel` is a drop-in replacement for `UILabel` that supports `NSAttributedString`, as well as automatically-detected and manually-added links to URLs, addresses, phone numbers, and dates.

 # Differences Between `TWTRAttributedLabel` and `UILabel`

 For the most part, `TWTRAttributedLabel` behaves just like `UILabel`. The following are notable exceptions, in which `TWTRAttributedLabel` properties may act differently:

 - `text` - This property now takes an `id` type argument, which can either be a kind of `NSString` or `NSAttributedString` (mutable or immutable in both cases)
 - `lineBreakMode` - This property displays only the first line when the value is `UILineBreakModeHeadTruncation`, `UILineBreakModeTailTruncation`, or `UILineBreakModeMiddleTruncation`
 - `adjustsFontsizeToFitWidth` - Supported in iOS 5 and greater, this property is effective for any value of `numberOfLines` greater than zero. In iOS 4, setting `numberOfLines` to a value greater than 1 with `adjustsFontSizeToFitWidth` set to `YES` may cause `sizeToFit` to execute indefinitely.

 Any properties affecting text or paragraph styling, such as `firstLineIndent` will only apply when text is set with an `NSString`. If the text is set with an `NSAttributedString`, these properties will not apply.

 ### NSCoding

 `TWTRAttributedLabel`, like `UILabel`, conforms to `NSCoding`. However, if the build target is set to less than iOS 6.0, `linkAttributes` and `activeLinkAttributes` will not be encoded or decoded. This is due to an runtime exception thrown when attempting to copy non-object CoreText values in dictionaries.

 @warning Any properties changed on the label after setting the text will not be reflected until a subsequent call to `setText:` or `setText:afterInheritingLabelAttributesAndConfiguringWithBlock:`. This is to say, order of operations matters in this case. For example, if the label text color is originally black when the text is set, changing the text color to red will have no effect on the display of the label until the text is set once again.

 @bug Setting `attributedText` directly is not recommended, as it may cause a crash when attempting to access any links previously set. Instead, call `setText:`, passing an `NSAttributedString`.
 */
@interface TWTRAttributedLabel : UILabel <TWTRAttributedLabel, UIGestureRecognizerDelegate>

///-----------------------------
/// @name Accessing the Delegate
///-----------------------------

/**
 The receiver's delegate.

 @discussion A `TWTRAttributedLabel` delegate responds to messages sent by tapping on links in the label. You can use the delegate to respond to links referencing a URL, address, phone number, date, or date with a specified time zone and duration.
 */
@property (nonatomic, unsafe_unretained) IBOutlet id<TWTRAttributedLabelDelegate> delegate;

/**
 An array of `TWTRTweetEntity` objects for links manually added to the label text.
 */
@property (readonly, nonatomic, strong) NSArray<TWTRTweetEntityRange *> *entities;

/**
 A dictionary containing the `NSAttributedString` attributes to be applied to links detected or manually added to the label text. The default link style is blue and underlined.

 @warning You must specify `linkAttributes` before setting autodecting or manually-adding links for these attributes to be applied.
 */
@property (nonatomic, strong) NSDictionary *linkAttributes;

/**
 A dictionary containing the `NSAttributedString` attributes to be applied to links when they are in the active state. If `nil` or an empty `NSDictionary`, active links will not be styled. The default active link style is red and underlined.
 */
@property (nonatomic, strong) NSDictionary *activeLinkAttributes;

/**
 A dictionary containing the `NSAttributedString` attributes to be applied to links when they are in the inactive state, which is triggered a change in `tintColor` in iOS 7. If `nil` or an empty `NSDictionary`, inactive links will not be styled. The default inactive link style is gray and unadorned.
 */
@property (nonatomic, strong) NSDictionary *inactiveLinkAttributes;

///---------------------------------------
/// @name Acccessing Text Style Attributes
///---------------------------------------

/**
 The shadow blur radius for the label. A value of 0 indicates no blur, while larger values produce correspondingly larger blurring. This value must not be negative. The default value is 0.
 */
@property (nonatomic, assign) CGFloat shadowRadius;

/**
 The shadow blur radius for the label when the label's `highlighted` property is `YES`. A value of 0 indicates no blur, while larger values produce correspondingly larger blurring. This value must not be negative. The default value is 0.
 */
@property (nonatomic, assign) CGFloat highlightedShadowRadius;
/**
 The shadow offset for the label when the label's `highlighted` property is `YES`. A size of {0, 0} indicates no offset, with positive values extending down and to the right. The default size is {0, 0}.
 */
@property (nonatomic, assign) CGSize highlightedShadowOffset;
/**
 The shadow color for the label when the label's `highlighted` property is `YES`. The default value is `nil` (no shadow color).
 */
@property (nonatomic, strong) UIColor *highlightedShadowColor;

/**
 The amount to kern the next character. Default is standard kerning. If this attribute is set to 0.0, no kerning is done at all.
 */
@property (nonatomic, assign) CGFloat kern;

///--------------------------------------------
/// @name Acccessing Paragraph Style Attributes
///--------------------------------------------

/**
 The distance, in points, from the leading margin of a frame to the beginning of the paragraph's first line. This value is always nonnegative, and is 0.0 by default.
 */
@property (nonatomic, assign) CGFloat firstLineIndent;

/**
 @deprecated Use `lineSpacing` instead.
 */
@property (nonatomic, assign) CGFloat leading DEPRECATED_ATTRIBUTE;

/**
 The space in points added between lines within the paragraph. This value is always nonnegative and is 0.0 by default.
 */
@property (nonatomic, assign) CGFloat lineSpacing;

/**
 The minimum line height within the paragraph. If the value is 0.0, the minimum line height is set to the line height of the `font`. 0.0 by default.
 */
@property (nonatomic, assign) CGFloat minimumLineHeight;

/**
 The maximum line height within the paragraph. If the value is 0.0, the maximum line height is set to the line height of the `font`. 0.0 by default.
 */
@property (nonatomic, assign) CGFloat maximumLineHeight;

/**
 The line height multiple. This value is 1.0 by default.
 */
@property (nonatomic, assign) CGFloat lineHeightMultiple;

/**
 The distance, in points, from the margin to the text container. This value is `UIEdgeInsetsZero` by default.

 @discussion The `UIEdgeInset` members correspond to paragraph style properties rather than a particular geometry, and can change depending on the writing direction.

 ## `UIEdgeInset` Member Correspondence With `CTParagraphStyleSpecifier` Values:

 - `top`: `kCTParagraphStyleSpecifierParagraphSpacingBefore`
 - `left`: `kCTParagraphStyleSpecifierHeadIndent`
 - `bottom`: `kCTParagraphStyleSpecifierParagraphSpacing`
 - `right`: `kCTParagraphStyleSpecifierTailIndent`

 */
@property (nonatomic, assign) UIEdgeInsets textInsets;

/**
 The vertical text alignment for the label, for when the frame size is greater than the text rect size. The vertical alignment is `TWTRAttributedLabelVerticalAlignmentCenter` by default.
 */
@property (nonatomic, assign) TWTRAttributedLabelVerticalAlignment verticalAlignment;

///--------------------------------------------
/// @name Accessing Truncation Token Appearance
///--------------------------------------------

/**
 The truncation token that appears at the end of the truncated line. `nil` by default.

 @discussion When truncation is enabled for the label, by setting `lineBreakMode` to either `UILineBreakModeHeadTruncation`, `UILineBreakModeTailTruncation`, or `UILineBreakModeMiddleTruncation`, the token used to terminate the truncated line will be `truncationTokenString` if defined, otherwise the Unicode Character 'HORIZONTAL ELLIPSIS' (U+2026).
 */
@property (nonatomic, strong) NSString *truncationTokenString;

/**
 The attributes to apply to the truncation token at the end of a truncated line. If unspecified, attributes will be inherited from the preceding character.
 */
@property (nonatomic, strong) NSDictionary *truncationTokenStringAttributes;

///--------------------------------------------
/// @name Calculating Size of Attributed String
///--------------------------------------------

/**
 Calculate and return the size that best fits an attributed string, given the specified constraints on size and number of lines.

 @param attributedString The attributed string.
 @param size The maximum dimensions used to calculate size.
 @param numberOfLines The maximum number of lines in the text to draw, if the constraining size cannot accomodate the full attributed string.

 @return The size that fits the attributed string within the specified constraints.
 */
+ (CGSize)sizeThatFitsAttributedString:(NSAttributedString *)attributedString withConstraints:(CGSize)size limitedToNumberOfLines:(NSUInteger)numberOfLines;

///----------------------------------
/// @name Setting the Text Attributes
///----------------------------------

/**
 Sets the text displayed by the label.

 @param text An `NSString` or `NSAttributedString` object to be displayed by the label. If the specified text is an `NSString`, the label will display the text like a `UILabel`, inheriting the text styles of the label. If the specified text is an `NSAttributedString`, the label text styles will be overridden by the styles specified in the attributed string.

 @discussion This method overrides `UILabel -setText:` to accept both `NSString` and `NSAttributedString` objects. This string is `nil` by default.
 */
- (void)setText:(id)text;

/**
 Sets the text displayed by the label, after configuring an attributed string containing the text attributes inherited from the label in a block.

 @param text An `NSString` or `NSAttributedString` object to be displayed by the label.
 @param block A block object that returns an `NSMutableAttributedString` object and takes a single argument, which is an `NSMutableAttributedString` object with the text from the first parameter, and the text attributes inherited from the label text styles. For example, if you specified the `font` of the label to be `[UIFont boldSystemFontOfSize:14]` and `textColor` to be `[UIColor redColor]`, the `NSAttributedString` argument of the block would be contain the `NSAttributedString` attribute
 equivalents of those properties. In this block, you can set further attributes on particular ranges.

 @discussion This string is `nil` by default.
 */
- (void)setText:(id)text afterInheritingLabelAttributesAndConfiguringWithBlock:(NSMutableAttributedString * (^)(NSMutableAttributedString *mutableAttributedString))block;

///----------------------------------
/// @name Accessing the Text Attributes
///----------------------------------

/**
 A copy of the label's current attributedText. This returns `nil` if an attributed string has never been set on the label.
 */
@property (readwrite, nonatomic, copy) NSAttributedString *attributedText;

- (void)addLinksForEntityRanges:(NSArray<TWTRTweetEntityRange *> *)entityRanges;
- (TWTRTweetEntityRange *)entityAtPoint:(CGPoint)point;

@end

/**
 The `TWTRAttributedLabelDelegate` protocol defines the messages sent to an attributed label delegate when links are tapped. All of the methods of this protocol are optional.
 */
@protocol TWTRAttributedLabelDelegate <NSObject>

@optional

/**
 * Called when a URL entity is tapped in the label.
 */
- (void)attributedLabel:(TWTRAttributedLabel *)label didTapTweetURLEntity:(TWTRTweetUrlEntity *)URLEntity;

/**
 * Called when a hashtag entity is tapped in the label.
 */
- (void)attributedLabel:(TWTRAttributedLabel *)label didTapTweetHashtagEntity:(TWTRTweetHashtagEntity *)hashtagEntity;

/**
 * Called when a cashtag entity is tapped in the label.
 */
- (void)attributedLabel:(TWTRAttributedLabel *)label didTapTweetCashtagEntity:(TWTRTweetCashtagEntity *)cashtagEntity;

/**
 * Called when a user mention entity is tapped in the label.
 */
- (void)attributedLabel:(TWTRAttributedLabel *)label didTapTweetUserMentionEntity:(TWTRTweetUserMentionEntity *)userMentionEntity;

@end
