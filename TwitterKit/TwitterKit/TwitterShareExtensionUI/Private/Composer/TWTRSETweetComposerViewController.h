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

@import UIKit.UIViewController;

@class TWTRSETweetShareConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface TWTRSETweetComposerViewController : UIViewController

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithStyle:(UITableViewStyle)style NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

/**
 Create the view controller that displays the composer text view and other rows to configure the tweet being composed.

 @param configuration (required): The public-API configuration object controlling the behavior necessary by the Share Controller.
 */
- (instancetype)initWithConfiguration:(TWTRSETweetShareConfiguration *)configuration NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
