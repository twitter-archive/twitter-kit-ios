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

#import "TWTRSETweetTextView.h"

@implementation TWTRSETweetTextView

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.contentInset = UIEdgeInsetsZero;
    self.contentOffset = CGPointZero;
}

- (NSUInteger)numberOfLines
{
    NSLayoutManager *layoutManager = [self layoutManager];
    NSUInteger numberOfLines = (NSUInteger)(0 == self.text.length || '\n' == [self.text characterAtIndex:self.text.length - 1]);
    NSUInteger index = 0, numberOfGlyphs = [layoutManager numberOfGlyphs];
    NSRange lineRange;
    for (; index < numberOfGlyphs; numberOfLines++) {
        (void)[layoutManager lineFragmentRectForGlyphAtIndex:index effectiveRange:&lineRange];
        index = NSMaxRange(lineRange);
    }
    return numberOfLines;
}

@end
