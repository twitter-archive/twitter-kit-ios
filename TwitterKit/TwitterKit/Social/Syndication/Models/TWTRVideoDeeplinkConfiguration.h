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

/**
 This header is private to the Twitter Kit SDK and not exposed for public SDK consumption
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TWTRVideoDeeplinkConfiguration : NSObject

/**
 * Text to show to a user to describe the action which will take place when this
 * deep link is triggered. An example might be "Open in Vine."
 */
@property (nonatomic, readonly, copy) NSString *displayText;

/**
 * The URL which will be opened with -[UIApplication openURL:]
 */
@property (nonatomic, readonly) NSURL *targetURL;

/**
 * The URL which will be used for metrics reporting.
 */
@property (nonatomic, readonly) NSURL *metricsURL;

/**
 * Creates a new instance of a deep link configuration
 *
 * @param displayText text to display for any call to action indicators
 * @param targetURL   the URL to deep link to
 * @param metricsURL  a URL which will be used for metrics reporting
 */
- (instancetype)initWithDisplayText:(NSString *)displayText targetURL:(NSURL *)targetURL metricsURL:(NSURL *)metricsURL;

@end

NS_ASSUME_NONNULL_END
