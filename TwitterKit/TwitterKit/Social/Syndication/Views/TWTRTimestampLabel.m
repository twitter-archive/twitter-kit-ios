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

#import "TWTRTimestampLabel.h"
#import <TwitterCore/TWTRDateUtil.h>
#import "TWTRDateFormatter.h"

static const NSTimeInterval TWTRRefreshInterval = 30.0;
static const NSTimeInterval TWTRRefreshTolerance = 5.0;

@interface TWTRTimestampLabel ()

@property (nonatomic) dispatch_source_t timer;

@end

@implementation TWTRTimestampLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, TWTRRefreshInterval * NSEC_PER_SEC, TWTRRefreshTolerance * NSEC_PER_SEC);
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(self.timer, ^{
        [weakSelf updateText];
    });
    dispatch_resume(self.timer);
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    [self updateText];
}

- (void)updateText
{
    if (self.date) {
        NSString *dateText = [TWTRDateFormatter elapsedTimeStringSinceDate:self.date];
        self.text = [NSString stringWithFormat:@" • %@", dateText];
    } else {
        self.text = @"";
    }

    self.accessibilityLabel = [TWTRDateUtil accessibilityTextForDate:self.date] ?: @"";
}

@end
