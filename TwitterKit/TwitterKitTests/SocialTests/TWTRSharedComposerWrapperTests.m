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
#import "TWTRComposerNetworking.h"
#import "TWTRFixtureLoader.h"
#import "TWTRSharedComposerWrapper.h"
#import "TWTRTweet.h"
#import "TWTRTwitter.h"
#import "TWTRTwitter_Private.h"
#import "TwitterShareExtensionUI.h"

@interface TWTRSETweetShareViewController ()
@property (nonatomic, nonnull, readonly) TWTRSETweetShareConfiguration *configuration;
@end

@interface TWTRComposerNetworking ()
@property (nonatomic) NSData *pendingVideoData;
@end

UIImage *videoThumbnail(NSURL *url);

@interface TWTRSharedComposerWrapperTests : XCTestCase

@end

@implementation TWTRSharedComposerWrapperTests

+ (void)setUp
{
    [[TWTRTwitter sharedInstance] startWithConsumerKey:@"key" consumerSecret:@"secret"];
}

#pragma mark - Init

- (void)testInit_usesText
{
    TWTRSharedComposerWrapper *composer = [[TWTRSharedComposerWrapper alloc] initWithInitialText:@"Initial text" image:nil videoURL:nil];
    XCTAssertEqualObjects(composer.configuration.initialTweet.text, @"Initial text");
}

- (void)testInit_usesImage
{
    UIImage *image = [[UIImage alloc] init];
    TWTRSharedComposerWrapper *composer = [[TWTRSharedComposerWrapper alloc] initWithInitialText:nil image:image videoURL:nil];
    TWTRSETweetAttachmentImage *attachment = (TWTRSETweetAttachmentImage *)composer.configuration.initialTweet.attachment;

    XCTAssertEqualObjects(attachment.image, image);
}

- (void)testInit_usesVideoThumbnail
{
    NSURL *videoFileURL = [TWTRFixtureLoader videoFileURL];
    TWTRSharedComposerWrapper *composer = [[TWTRSharedComposerWrapper alloc] initWithInitialText:nil image:nil videoURL:videoFileURL];
    TWTRSETweetAttachmentImage *attachment = (TWTRSETweetAttachmentImage *)composer.configuration.initialTweet.attachment;

    XCTAssertNotNil(attachment.image);

    UIImage *thumbnail = videoThumbnail(videoFileURL);
    NSData *expected = UIImagePNGRepresentation(attachment.image);
    NSData *actual = UIImagePNGRepresentation(thumbnail);
    XCTAssertEqualObjects(expected, actual);
}

- (void)testInitWithVideoURL_setsVideoDataOnComposerNetworking
{
    NSURL *videoFileURL = [TWTRFixtureLoader videoFileURL];
    TWTRSharedComposerWrapper *composer = [[TWTRSharedComposerWrapper alloc] initWithInitialText:nil image:nil videoURL:videoFileURL];

    XCTAssertEqualObjects(composer.networking.pendingVideoData, [TWTRFixtureLoader videoData]);
}

- (void)testInitWithVideoURL_errorBothAttachmentTypes
{
    UIImage *image = [UIImage new];
    NSURL *videoFileURL = [TWTRFixtureLoader videoFileURL];

    // Invalid, only one attachment type should be provided
    XCTAssertNil([[TWTRSharedComposerWrapper alloc] initWithInitialText:nil image:image videoURL:videoFileURL]);
}

- (void)testInitWithVideoURL_errorsOnAssetURL
{
    NSURL *videoFileURL = [NSURL URLWithString:@"assets-library://983kd8ff9fjsfd.MOV"];

    // Invalid, asset library URLs are not supported
    XCTAssertNil([[TWTRSharedComposerWrapper alloc] initWithInitialText:nil image:nil videoURL:videoFileURL]);
}

#pragma mark - Video Data

- (void)testInitWithVideoData_errorWhenNoPreviewImage
{
    NSData *videoData = [TWTRFixtureLoader videoData];
    // Invalid, videoData upload must have preview image attached to it
    XCTAssertNil([[TWTRSharedComposerWrapper alloc] initWithInitialText:nil image:nil videoData:videoData]);
}

- (void)testInitWithVideoData_setsVideoDataOnComposerNetworking
{
    NSData *videoData = [TWTRFixtureLoader videoData];
    UIImage *previewImage = [UIImage new];
    TWTRSharedComposerWrapper *composer = [[TWTRSharedComposerWrapper alloc] initWithInitialText:nil image:previewImage videoData:videoData];
    XCTAssertEqualObjects(composer.networking.pendingVideoData, [TWTRFixtureLoader videoData]);
}

#pragma mark - TWTRSETweetShareViewControllerDelegate Protocol Methods

- (void)testWantsToCancel_dismissesViewController
{
    // Set up expectation
    TWTRSharedComposerWrapper *composer = [[TWTRSharedComposerWrapper alloc] initWithInitialText:nil image:nil videoURL:nil];
    id mockComposer = OCMPartialMock(composer);
    OCMExpect([mockComposer dismissViewControllerAnimated:YES completion:OCMOCK_ANY]);

    // Trigger dismiss
    [composer shareViewControllerWantsToCancelComposerWithPartiallyComposedTweet:[TWTRSETweet new]];

    OCMVerifyAll(mockComposer);
}

- (void)testWantsToCancel_cancelsPendingUpload
{
    NSURL *videoFileURL = [TWTRFixtureLoader videoFileURL];
    TWTRSharedComposerWrapper *composer = [[TWTRSharedComposerWrapper alloc] initWithInitialText:nil image:nil videoURL:videoFileURL];

    // Should have pending data, and then remove it
    XCTAssertNotNil(composer.networking.pendingVideoData);
    [composer shareViewControllerWantsToCancelComposerWithPartiallyComposedTweet:[TWTRSETweet new]];
    XCTAssertNil(composer.networking.pendingVideoData);
}

- (void)testFinishedSending_dismissesViewController
{
    // Set up expectation
    TWTRSharedComposerWrapper *composer = [[TWTRSharedComposerWrapper alloc] initWithInitialText:nil image:nil videoURL:nil];
    id mockComposer = OCMPartialMock(composer);
    OCMExpect([mockComposer dismissViewControllerAnimated:YES completion:OCMOCK_ANY]);

    // Trigger dismiss
    [composer shareViewControllerDidFinishSendingTweet];

    OCMVerifyAll(mockComposer);
}

#pragma mark - TWTRComposerViewControllerDelegate

- (void)testComposerDidCancel_getsCalled
{
    // Set up expectation
    TWTRSharedComposerWrapper *composer = [[TWTRSharedComposerWrapper alloc] initWithInitialText:nil image:nil videoURL:nil];
    id mockDelegate = OCMProtocolMock(@protocol(TWTRComposerViewControllerDelegate));
    composer.delegate = mockDelegate;
    OCMExpect([mockDelegate composerDidCancel:OCMOCK_ANY]);

    // Trigger cancel
    [composer shareViewControllerWantsToCancelComposerWithPartiallyComposedTweet:[TWTRSETweet new]];
    OCMVerifyAll(mockDelegate);
}

- (void)testComposerDidSucceed_getsTweetBack
{
    // Set up expectation
    TWTRSharedComposerWrapper *composer = [[TWTRSharedComposerWrapper alloc] initWithInitialText:nil image:nil videoURL:nil];
    id mockDelegate = OCMProtocolMock(@protocol(TWTRComposerViewControllerDelegate));
    composer.delegate = mockDelegate;
    TWTRTweet *tweet = [TWTRFixtureLoader obamaTweet];
    OCMExpect([mockDelegate composerDidSucceed:OCMOCK_ANY withTweet:tweet]);

    // Trigger success
    [composer didFinishSendingTweet:tweet];
    OCMVerifyAll(mockDelegate);
}

- (void)testComposerDidFail_getsErrorBack
{
    // Set up expectation
    TWTRSharedComposerWrapper *composer = [[TWTRSharedComposerWrapper alloc] initWithInitialText:nil image:nil videoURL:nil];
    id mockDelegate = OCMProtocolMock(@protocol(TWTRComposerViewControllerDelegate));
    composer.delegate = mockDelegate;
    NSError *error = [NSError errorWithDomain:@"TWTRErrorDomain" code:0 userInfo:nil];
    OCMExpect([mockDelegate composerDidFail:OCMOCK_ANY withError:error]);

    // Trigger fail
    [composer didAbortSendingTweetWithError:error];
    OCMVerifyAll(mockDelegate);
}

@end
