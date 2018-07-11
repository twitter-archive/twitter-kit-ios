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

@import Foundation;

@class TWTRSETweet;
@protocol TWTRSEAccount;
@protocol TWTRSEAutoCompletion;
@protocol TWTRSECardPreviewProvider;
@protocol TWTRSEGeoTagging;
@protocol TWTRSEImageDownloader;
@protocol TWTRSELocalizedResources;
@protocol TWTRSENetworking;
@protocol TWTRSETweetShareViewControllerDelegate;
@protocol TWTRSEWordRangeCalculator;
@protocol TwitterTextProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface TWTRSETweetShareConfiguration : NSObject

@property (nonatomic, readonly, copy) NSArray<id<TWTRSEAccount>> *accounts;
@property (nonatomic, readonly, nullable) id<TWTRSEAccount> initiallySelectedAccount;
@property (nonatomic, readonly, copy, nullable) TWTRSETweet *initialTweet;
@property (nonatomic, readonly, nullable) id<TWTRSEGeoTagging> geoTagging;
@property (nonatomic, readonly, nullable) id<TWTRSEAutoCompletion> autoCompletion;
@property (nonatomic, readonly, nullable) id<TWTRSECardPreviewProvider> cardPreviewProvider;
@property (nonatomic, readonly) id<TWTRSEImageDownloader> imageDownloader;
@property (nonatomic, readonly) id<TWTRSENetworking> networking;
@property (nonatomic, readonly) Class<TWTRSEWordRangeCalculator> wordRangeCalculator;
@property (nullable, nonatomic, readonly, weak) id<TWTRSETweetShareViewControllerDelegate> delegate;

/**
 @param initialTweet (optional): The details of the tweet to prepopulate.
 @param accounts (required): The list of accounts to choose from which to tweet. If empty, the UI will present an alert with an error and not allow to use the composer.
 @param initiallySelectedAccount (optional): The account to default the selection too. If nil, the first account in `accounts` is selected initially. If provided, this must be an object in `accounts`.
 @param geoTagging (optional): An object that can provide places to geo-tag the tweet. If nil, the location option won't be present.
 @param autoCompletion (optional): An object that can provide user and hashtag autoCompletion. If nil, the autoCompletion UI won't be shown.
 @param cardPreviewProvider (optional): An object that can provide a card preview image. If nil, the cardPreview UI will rely on the itemProvider to retrieve an image
 @param imageDownloader (required): An object that can download images (used to retrieve user avatars).
 @param networking (required): An object that is able to make network requests on behalf of a Twitter user.
 @param twitterText (required): the instantiator's version of TwitterText
 @param wordRangeCalculator (required): the instantiator's version of code to calculate text ranges on strings
 @param delegate (required): An object that can respond to lifecycle events of this controller to be able to dismiss it when the user takes action on it.
 */
- (instancetype)initWithInitialTweet:(nullable TWTRSETweet *)initialTweet
                            accounts:(NSArray<id<TWTRSEAccount>> *)accounts
            initiallySelectedAccount:(nullable id<TWTRSEAccount>)initiallySelectedAccount
                          geoTagging:(nullable id<TWTRSEGeoTagging>)geoTagging
                      autoCompletion:(nullable id<TWTRSEAutoCompletion>)autoCompletion
                 cardPreviewProvider:(nullable id<TWTRSECardPreviewProvider>)cardPreviewProvider
                     imageDownloader:(id<TWTRSEImageDownloader>)imageDownloader
                  localizedResources:(Class<TWTRSELocalizedResources>)localizedResources
                          networking:(id<TWTRSENetworking>)networking
                         twitterText:(Class<TwitterTextProtocol>)twitterText
                 wordRangeCalculator:(Class<TWTRSEWordRangeCalculator>)wordRangeCalculator
                            delegate:(id<TWTRSETweetShareViewControllerDelegate>)delegate NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
