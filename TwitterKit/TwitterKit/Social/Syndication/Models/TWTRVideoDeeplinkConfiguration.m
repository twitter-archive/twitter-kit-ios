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

#import "TWTRVideoDeeplinkConfiguration.h"
#import <TwitterCore/TWTRAssertionMacros.h>
#import "TWTRVideoPlaybackConfiguration.h"

@implementation TWTRVideoDeeplinkConfiguration

- (instancetype)initWithDisplayText:(NSString *)displayText targetURL:(NSURL *)targetURL metricsURL:(NSURL *)metricsURL
{
    TWTRParameterAssertOrReturnValue(displayText, nil);
    TWTRParameterAssertOrReturnValue(targetURL, nil);
    TWTRParameterAssertOrReturnValue(metricsURL, nil);

    self = [super init];
    if (self) {
        _displayText = [displayText copy];
        _targetURL = targetURL;
        _metricsURL = metricsURL;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[TWTRVideoDeeplinkConfiguration class]]) {
        return [self isEqualToDeeplinkConfiguration:object];
    }
    return NO;
}

- (BOOL)isEqualToDeeplinkConfiguration:(TWTRVideoDeeplinkConfiguration *)other
{
    return [self.displayText isEqualToString:other.displayText] && [self.targetURL isEqual:other.targetURL] && [self.metricsURL isEqual:other.metricsURL];
}

@end
