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

#import "TWTRLogInButton.h"
#import <TwitterCore/TWTRColorUtil.h>
#import "TWTRBirdView.h"
#import "TWTRTranslationsUtil.h"
#import "TWTRTwitter.h"
#import "TWTRViewUtil.h"

#define TWTR_SIGN_IN_BUTTON_HEIGHT 40
#define TWTR_SIGN_IN_BUTTON_WIDTH (TWTR_SIGN_IN_BUTTON_HEIGHT * 7)
#define TWTR_SIGN_IN_BUTTON_BIRD_FONT_HEIGHT_RATIO 1.2

NSString *const TWTRLogInButtonLabelLocalizationKey = @"tw__sign_in_with_twitter_button";

@implementation TWTRLogInButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self tw_commonInit];

        // Hack: If the developer left a title on the button in the nib, remove it.
        // TWTRLogInButton adds the title using a label instead of relying on the UIButton label.
        // TODO: Refactor TWTRLogInButton to use its title label.
        [self setTitle:@"" forState:UIControlStateNormal];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self tw_commonInit];
    }

    return self;
}

- (void)tw_commonInit
{
    [self addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];

    [self setFrame:CGRectMake(0, 0, TWTR_SIGN_IN_BUTTON_WIDTH, TWTR_SIGN_IN_BUTTON_HEIGHT)];
    [self setBackgroundColor:[TWTRColorUtil blueColor]];
    [self setClipsToBounds:YES];
    [self.layer setCornerRadius:4];

    UIImage *normalBackgroundImage = [TWTRColorUtil imageWithColor:[TWTRColorUtil blueColor]];
    UIImage *highlightedBackgroundImage = [TWTRColorUtil imageWithColor:[TWTRColorUtil mediumBlueColor]];
    UIImage *disabledBackgroundImage = [TWTRColorUtil imageWithColor:[TWTRColorUtil darkGrayColor]];
    [self setBackgroundImage:normalBackgroundImage forState:UIControlStateNormal];
    [self setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];
    [self setBackgroundImage:highlightedBackgroundImage forState:UIControlStateSelected];
    [self setBackgroundImage:disabledBackgroundImage forState:UIControlStateDisabled];

    UILabel *label = [[UILabel alloc] init];
    [label setText:TWTRLocalizedString(TWTRLogInButtonLabelLocalizationKey)];
    [label setTextColor:[TWTRColorUtil whiteColor]];
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];

    // put a bird on it
    CGFloat birdSize = label.font.pointSize * TWTR_SIGN_IN_BUTTON_BIRD_FONT_HEIGHT_RATIO;
    TWTRBirdView *twitterBird = [[TWTRBirdView alloc] initWithFrame:CGRectMake(0, 0, birdSize, birdSize)];
    // This is to protect the button against changes to the UIAppearance of UIView
    twitterBird.backgroundColor = [UIColor clearColor];

    UIView *birdAndLabelContainer = [[UIView alloc] init];
    [birdAndLabelContainer setTranslatesAutoresizingMaskIntoConstraints:NO];
    [birdAndLabelContainer setUserInteractionEnabled:NO];
    [birdAndLabelContainer addSubview:label];
    [birdAndLabelContainer addSubview:twitterBird];
    // This is to protect the button against changes to the UIAppearance of UIView
    birdAndLabelContainer.backgroundColor = [UIColor clearColor];

    [self addSubview:birdAndLabelContainer];

    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(twitterBird, label);

    [TWTRViewUtil addVisualConstraints:@"H:|[twitterBird]-[label]|" views:viewsDictionary];
    [TWTRViewUtil addVisualConstraints:@"V:|[twitterBird]|" views:viewsDictionary];
    [TWTRViewUtil addVisualConstraints:@"V:|[label]|" views:viewsDictionary];

    [TWTRViewUtil centerViewInSuperview:birdAndLabelContainer];
}

+ (instancetype)buttonWithLogInCompletion:(TWTRLogInCompletion)completion
{
    TWTRLogInButton *button = [self buttonWithType:UIButtonTypeCustom];

    button.logInCompletion = completion;

    return button;
}

#pragma mark - Touch

- (void)buttonTapped
{
    self.enabled = NO;
    [[TWTRTwitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
        if (self.logInCompletion) {
            self.logInCompletion(session, error);
        } else {
            NSLog(@"%@ was created with no completionBlock set", NSStringFromClass([self class]));
        }
        self.enabled = YES;
    }];
}

#pragma mark - Auto Layout Suppoert

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(TWTR_SIGN_IN_BUTTON_WIDTH, TWTR_SIGN_IN_BUTTON_HEIGHT);
}

#pragma mark - Accessibility

- (NSString *)accessibilityLabel
{
    return TWTRLocalizedString(TWTRLogInButtonLabelLocalizationKey);
}

@end
