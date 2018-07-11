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

#import "TWTRSETweetShareConfiguration.h"
#import "TWTRSELocalizedString.h"
#import "TWTRSETweet.h"

@implementation TWTRSETweetShareConfiguration

- (instancetype)initWithInitialTweet:(TWTRSETweet *)initialTweet
                            accounts:(NSArray<id<TWTRSEAccount>> *)accounts
            initiallySelectedAccount:(id<TWTRSEAccount>)initiallySelectedAccount
                          geoTagging:(id<TWTRSEGeoTagging>)geoTagging
                      autoCompletion:(id<TWTRSEAutoCompletion>)autoCompletion
                 cardPreviewProvider:(id<TWTRSECardPreviewProvider>)cardPreviewProvider
                     imageDownloader:(id<TWTRSEImageDownloader>)imageDownloader
                  localizedResources:(Class<TWTRSELocalizedResources>)localizedResources
                          networking:(id<TWTRSENetworking>)networking
                         twitterText:(Class<TwitterTextProtocol>)twitterText
                 wordRangeCalculator:(Class<TWTRSEWordRangeCalculator>)wordRangeCalculator
                            delegate:(id<TWTRSETweetShareViewControllerDelegate>)delegate
{
    NSParameterAssert(accounts);
    NSParameterAssert(imageDownloader);
    NSParameterAssert(networking);
    NSParameterAssert(delegate);

    TSELocalized = localizedResources;
    [TWTRSETweet setTwitterText:twitterText];

    if ((self = [super init])) {
        _initialTweet = [initialTweet copy];
        _accounts = [accounts copy];
        _initiallySelectedAccount = initiallySelectedAccount;
        _geoTagging = geoTagging;
        _autoCompletion = autoCompletion;
        _cardPreviewProvider = cardPreviewProvider;
        _imageDownloader = imageDownloader;
        _networking = networking;
        _wordRangeCalculator = wordRangeCalculator;
        _delegate = delegate;
    }

    return self;
}

@end
