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

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "TWTRAttributedLabel.h"
#import "TWTRFixtureLoader.h"
#import "TWTRTweetLabel.h"
#import "TWTRTweetUrlEntity.h"
#import "TWTRTweet_Private.h"

@interface TWTRTweetEntityRange ()
- (instancetype)initWithEntity:(TWTRTweetEntity *)entity textRange:(NSRange)range;
@end

@interface TWTRTweetLabelTests : XCTestCase

@property (nonatomic, strong) TWTRTweetLabel *tweetLabel;

@end

@implementation TWTRTweetLabelTests

- (void)setUp
{
    [super setUp];
    self.tweetLabel = [[TWTRTweetLabel alloc] init];
}

- (void)testNumberOfLines
{
    XCTAssert(self.tweetLabel.numberOfLines == 0);
}

- (void)testLineBreakMode
{
    XCTAssert(self.tweetLabel.lineBreakMode == NSLineBreakByWordWrapping);
}

- (void)testSetPreferredMaximumLayoutWidth
{
    id mockLabel = [OCMockObject partialMockForObject:self.tweetLabel];
    [[[mockLabel expect] ignoringNonObjectArgs] setPreferredMaxLayoutWidth:5];
    [mockLabel layoutSubviews];

    [mockLabel verify];
}

- (void)testLinkColor_setColor
{
    UIColor *green = [UIColor greenColor];
    [self.tweetLabel setLinkColor:green];

    XCTAssert([self.tweetLabel.linkAttributes[NSForegroundColorAttributeName] isEqual:green]);
}

- (void)testLinkColor_handlesNilColor
{
    XCTAssertNoThrow([self.tweetLabel setLinkColor:nil]);
}

- (void)testLinkColor
{
    self.tweetLabel.linkColor = [UIColor greenColor];

    UIColor *actualColor = self.tweetLabel.linkAttributes[NSForegroundColorAttributeName];
    UIColor *desiredColor = [UIColor greenColor];
    XCTAssert([actualColor isEqual:desiredColor]);
}

- (void)testLinks
{
    NSString *expectedURL = @"http://t.co/JteTVkVqWn";

    id mockLabel = [OCMockObject partialMockForObject:self.tweetLabel];
    [[mockLabel expect] addLinksForEntityRanges:[OCMArg checkWithBlock:^BOOL(NSArray<TWTRTweetEntityRange *> *obj) {
                            for (TWTRTweetEntityRange *e in obj) {
                                if ([e.entity isKindOfClass:[TWTRTweetUrlEntity class]]) {
                                    NSString *URL = [((TWTRTweetUrlEntity *)e.entity)url];
                                    return [URL isEqual:expectedURL];
                                }
                            }
                            return NO;
                        }]];

    [mockLabel setTextFromTweet:[TWTRFixtureLoader gatesTweet]];

    [mockLabel verify];
}

- (void)testHTMLEscapeLabel
{
    TWTRTweet *tweet = [TWTRFixtureLoader obamaTweet];
    [tweet setValue:@"weekend of driving SF &lt;-&gt; LA &lt;-&gt; SF" forKey:@"text"];
    [self.tweetLabel setTextFromTweet:tweet];

    NSString *actualText = self.tweetLabel.text;
    NSString *desiredText = @"weekend of driving SF <-> LA <-> SF";

    XCTAssert([actualText isEqualToString:desiredText]);
}

- (void)testTextAlignment_leftByDefault
{
    [self.tweetLabel setTextFromTweet:[TWTRFixtureLoader obamaTweet]];
    XCTAssert(self.tweetLabel.textAlignment == NSTextAlignmentLeft);
}

- (void)testTextAlignment_rightForArabicTweet
{
    TWTRTweet *arabicTweet = [TWTRFixtureLoader obamaTweet];
    [arabicTweet setValue:@"ar" forKey:@"languageCode"];
    [self.tweetLabel setTextFromTweet:arabicTweet];

    XCTAssert(self.tweetLabel.textAlignment == NSTextAlignmentRight);
}

- (void)testTextAlignment_junkValue
{
    TWTRTweet *junkLanguageTweet = [TWTRFixtureLoader obamaTweet];
    [junkLanguageTweet setValue:@"fsdljkdfslkj" forKey:@"languageCode"];

    XCTAssertNoThrow([self.tweetLabel setTextFromTweet:junkLanguageTweet]);
    XCTAssert(self.tweetLabel.textAlignment == NSTextAlignmentLeft);
}

- (void)testTextAlignment_emptyStringValue
{
    TWTRTweet *junkLanguageTweet = [TWTRFixtureLoader obamaTweet];
    [junkLanguageTweet setValue:@"" forKey:@"languageCode"];

    XCTAssertNoThrow([self.tweetLabel setTextFromTweet:junkLanguageTweet]);
    XCTAssert(self.tweetLabel.textAlignment == NSTextAlignmentLeft);
}

- (void)testTextAlignment_nilValue
{
    TWTRTweet *junkLanguageTweet = [TWTRFixtureLoader obamaTweet];
    [junkLanguageTweet setValue:nil forKey:@"languageCode"];

    XCTAssertNoThrow([self.tweetLabel setTextFromTweet:junkLanguageTweet]);
    XCTAssert(self.tweetLabel.textAlignment == NSTextAlignmentLeft);
}

@end
