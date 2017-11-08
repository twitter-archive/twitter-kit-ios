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

#import "TSELocalizedString.h"
#import "TSETweet.h"
#import "TSETweetShareConfiguration.h"

@implementation TSETweetShareConfiguration

- (instancetype)initWithInitialTweet:(TSETweet *)initialTweet
                            accounts:(NSArray<id<TSEAccount>> *)accounts
            initiallySelectedAccount:(id<TSEAccount>)initiallySelectedAccount
                          geoTagging:(id<TSEGeoTagging>)geoTagging
                      autoCompletion:(id<TSEAutoCompletion>)autoCompletion
                 cardPreviewProvider:(id<TSECardPreviewProvider>)cardPreviewProvider
                     imageDownloader:(id<TSEImageDownloader>)imageDownloader
                  localizedResources:(Class<TSELocalizedResources>)localizedResources
                          networking:(id<TSENetworking>)networking
                         twitterText:(Class<TwitterTextProtocol>)twitterText
                 wordRangeCalculator:(Class<TSEWordRangeCalculator>)wordRangeCalculator
                              scribe:(id<TSEScribe>)scribe
                            delegate:(id<TSETweetShareViewControllerDelegate>)delegate
{
    NSParameterAssert(accounts);
    NSParameterAssert(imageDownloader);
    NSParameterAssert(networking);
    NSParameterAssert(delegate);

    TSELocalized = localizedResources;
    [TSETweet setTwitterText:twitterText];

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
        _scribe = scribe;
        _delegate = delegate;
    }

    return self;
}

@end
