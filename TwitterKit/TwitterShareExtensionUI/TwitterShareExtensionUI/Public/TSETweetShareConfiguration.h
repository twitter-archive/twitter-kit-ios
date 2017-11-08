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


@class TSETweet;
@protocol TSEAccount;
@protocol TSEAutoCompletion;
@protocol TSECardPreviewProvider;
@protocol TSEGeoTagging;
@protocol TSEImageDownloader;
@protocol TSELocalizedResources;
@protocol TSENetworking;
@protocol TSEScribe;
@protocol TSETweetShareViewControllerDelegate;
@protocol TSEWordRangeCalculator;
@protocol TwitterTextProtocol;


NS_ASSUME_NONNULL_BEGIN

@interface TSETweetShareConfiguration : NSObject

@property (nonatomic, readonly, copy) NSArray<id<TSEAccount>> *accounts;
@property (nonatomic, readonly, nullable) id<TSEAccount> initiallySelectedAccount;
@property (nonatomic, readonly, copy, nullable) TSETweet *initialTweet;
@property (nonatomic, readonly, nullable) id<TSEGeoTagging> geoTagging;
@property (nonatomic, readonly, nullable) id<TSEAutoCompletion> autoCompletion;
@property (nonatomic, readonly, nullable) id<TSECardPreviewProvider> cardPreviewProvider;
@property (nonatomic, readonly) id<TSEImageDownloader> imageDownloader;
@property (nonatomic, readonly) id<TSENetworking> networking;
@property (nullable, nonatomic, readonly) id<TSEScribe> scribe;
@property (nonatomic, readonly) Class<TSEWordRangeCalculator> wordRangeCalculator;
@property (nullable, nonatomic, readonly, weak) id<TSETweetShareViewControllerDelegate> delegate;

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
- (instancetype)initWithInitialTweet:(nullable TSETweet *)initialTweet
                            accounts:(NSArray<id<TSEAccount>> *)accounts
            initiallySelectedAccount:(nullable id<TSEAccount>)initiallySelectedAccount
                          geoTagging:(nullable id<TSEGeoTagging>)geoTagging
                      autoCompletion:(nullable id<TSEAutoCompletion>)autoCompletion
                 cardPreviewProvider:(nullable id<TSECardPreviewProvider>)cardPreviewProvider
                     imageDownloader:(id<TSEImageDownloader>)imageDownloader
                  localizedResources:(Class<TSELocalizedResources>)localizedResources
                          networking:(id<TSENetworking>)networking
                         twitterText:(Class<TwitterTextProtocol>)twitterText
                 wordRangeCalculator:(Class<TSEWordRangeCalculator>)wordRangeCalculator
                              scribe:(nullable id<TSEScribe>)scribe
                            delegate:(id<TSETweetShareViewControllerDelegate>)delegate NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
