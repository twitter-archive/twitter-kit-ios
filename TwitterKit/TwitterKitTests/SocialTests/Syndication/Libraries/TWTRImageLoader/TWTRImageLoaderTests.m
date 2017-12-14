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
#import "TWTRFixtureLoader.h"
#import "TWTRImageLoader.h"
#import "TWTRImageLoaderCache.h"
#import "TWTRImageLoaderTaskManager.h"
#import "TWTRTestCase.h"
#import "TWTRTestImageLoaderCache.h"

@interface TWTRImageLoaderTests : TWTRTestCase

@property (nonatomic) id URLSessionMock;
@property (nonatomic) id<TWTRImageLoaderCache> cache;
@property (nonatomic) TWTRImageLoader *imageLoader;
@property (nonatomic) id sessionTaskMock;
@property (nonatomic) id<TWTRImageLoaderTaskManager> taskManager;

@end

@implementation TWTRImageLoaderTests

- (void)setUp
{
    [super setUp];

    self.URLSessionMock = OCMClassMock([NSURLSession class]);
    self.cache = [[TWTRTestImageLoaderCache alloc] initWithImageFixturesDictionary:@{}];
    self.taskManager = [[TWTRImageLoaderTaskManager alloc] init];
    self.imageLoader = [[TWTRImageLoader alloc] initWithSession:self.URLSessionMock cache:self.cache taskManager:self.taskManager];
    self.sessionTaskMock = OCMClassMock([NSURLSessionTask class]);
}

- (void)testInit_nilCacheOk
{
    TWTRImageLoader *imageLoader = [[TWTRImageLoader alloc] initWithSession:self.URLSessionMock cache:nil taskManager:self.taskManager];
    XCTAssertNotNil(imageLoader);
}

- (void)testFetchImageWithURL_uniqueIDForDifferentURLs
{
    OCMStub([self.URLSessionMock dataTaskWithURL:OCMOCK_ANY completionHandler:OCMOCK_ANY]).andReturn(self.sessionTaskMock);
    id requestID1 = [self.imageLoader fetchImageWithURL:[NSURL URLWithString:@"http://example.com"] completion:^(UIImage *image, NSError *error){
    }];
    id requestID2 = [self.imageLoader fetchImageWithURL:[NSURL URLWithString:@"http://example.com/foo"] completion:^(UIImage *image, NSError *error){
    }];
    XCTAssertNotEqualObjects(requestID1, requestID2);
}

- (void)testFetchImageWithURL_uniqueIDForSameURLs
{
    OCMStub([self.URLSessionMock dataTaskWithURL:OCMOCK_ANY completionHandler:OCMOCK_ANY]).andReturn(self.sessionTaskMock);
    id requestID1 = [self.imageLoader fetchImageWithURL:[NSURL URLWithString:@"http://example.com"] completion:^(UIImage *image, NSError *error){
    }];
    id requestID2 = [self.imageLoader fetchImageWithURL:[NSURL URLWithString:@"http://example.com"] completion:^(UIImage *image, NSError *error){
    }];
    XCTAssertNotEqualObjects(requestID1, requestID2);
}

- (void)testFetchImageWithURL_returnsImage
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"should have returned from fetch..."];

    NSURL *url = [NSURL URLWithString:@"http://example.com/foo.jpg"];
    NSData *imageData = [TWTRFixtureLoader dataFromFile:@"test" ofType:@"png"];
    NSURLResponse *response = [[NSURLResponse alloc] init];
    [[[[self.URLSessionMock stub] andReturn:self.sessionTaskMock] andDo:^(NSInvocation *invocation) {
        void (^taskResponseCompletion)(NSData *data, NSURLResponse *response, NSError *error);
        [invocation getArgument:&taskResponseCompletion atIndex:3];
        taskResponseCompletion(imageData, response, nil);
    }] dataTaskWithURL:url
        completionHandler:OCMOCK_ANY];

    [self.imageLoader fetchImageWithURL:url completion:^(UIImage *image, NSError *error) {
        XCTAssertNotNil(image);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testFetchImageWithURL_returnsNilImageIfError
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"should have returned from fetch..."];

    NSURL *url = [NSURL URLWithString:@"http://example.com/foo.jpg"];
    NSURLResponse *response = [[NSURLResponse alloc] init];
    [[[[self.URLSessionMock stub] andReturn:self.sessionTaskMock] andDo:^(NSInvocation *invocation) {
        void (^taskResponseCompletion)(NSData *data, NSURLResponse *response, NSError *error);
        [invocation getArgument:&taskResponseCompletion atIndex:3];
        NSError *error = [[NSError alloc] initWithDomain:@"error" code:0 userInfo:nil];
        taskResponseCompletion(nil, response, error);
    }] dataTaskWithURL:url
        completionHandler:OCMOCK_ANY];

    [self.imageLoader fetchImageWithURL:url completion:^(UIImage *image, NSError *error) {
        XCTAssertNil(image);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testFetchImageWithURL_noNetworkRequestIfCached
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"should have returned from fetch..."];

    NSString *URLString = @"http://example.com/foo.jpg";
    NSURL *url = [NSURL URLWithString:URLString];
    UIImage *imageFixture = [[UIImage alloc] init];
    TWTRTestImageLoaderCache *cache = [[TWTRTestImageLoaderCache alloc] initWithImageFixturesDictionary:@{URLString: imageFixture}];
    TWTRImageLoader *imageLoader = [[TWTRImageLoader alloc] initWithSession:self.URLSessionMock cache:cache taskManager:self.taskManager];
    [imageLoader fetchImageWithURL:url completion:^(UIImage *image, NSError *error) {
        XCTAssertNotNil(image);
        OCMVerifyAll(self.URLSessionMock);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testFetchImageWithURL_cachesFetchedImage
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"should have cached fetched image..."];

    NSString *URLString = @"http://example.com/foo.jpg";
    NSURL *url = [NSURL URLWithString:URLString];
    NSData *imageData = [TWTRFixtureLoader dataFromFile:@"test" ofType:@"png"];
    NSURLResponse *response = [[NSURLResponse alloc] init];
    [[[[self.URLSessionMock stub] andReturn:self.sessionTaskMock] andDo:^(NSInvocation *invocation) {
        void (^taskResponseCompletion)(NSData *data, NSURLResponse *response, NSError *error);
        [invocation getArgument:&taskResponseCompletion atIndex:3];
        taskResponseCompletion(imageData, response, nil);
    }] dataTaskWithURL:url
        completionHandler:OCMOCK_ANY];

    [self.imageLoader fetchImageWithURL:url completion:^(UIImage *image, NSError *error) {
        XCTAssertNotNil([self.cache fetchImageForKey:URLString]);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

- (void)testCancelImageWithRequestID_cancelNonexistentTask
{
    id badRequestID = @"badID";
    XCTAssertNoThrow([self.imageLoader cancelImageWithRequestID:badRequestID]);
}

- (void)testCancelImageWithRequestID_cancelsTask
{
    NSURL *url = [NSURL URLWithString:@"http://example.com/foo.jpg"];
    id sessionTaskMock = OCMClassMock([NSURLSessionTask class]);
    [OCMStub([self.URLSessionMock dataTaskWithURL:url completionHandler:OCMOCK_ANY]) andReturn:sessionTaskMock];
    OCMExpect([sessionTaskMock cancel]);
    id requestID = @"requestID";
    // have to manually set up the task in testing since the `fetchImageWithURL:completion:` is async
    // so we don't know when the task will be added to the `taskManager` to cancel
    [self.taskManager addTask:sessionTaskMock withRequestID:requestID];

    [self.imageLoader cancelImageWithRequestID:requestID];
    [self waitForCompletionWithTimeout:0.1 check:^BOOL {
        OCMVerifyAllWithDelay(sessionTaskMock, 0.1);
        return YES;
    }];
}

#pragma mark - TWTRSEImageDownloader Protocol Methods

- (void)testDownloadImage_fetchesImage
{
    // Parameters
    NSURL *url = [NSURL URLWithString:@"http://fakeurl.com"];
    TWTRSEImageDownloadCompletion completion = ^(UIImage *_Nullable image, NSError *_Nullable error) {
    };

    // Set up expectation
    id mockLoader = OCMPartialMock(self.imageLoader);
    OCMExpect([mockLoader fetchImageWithURL:url completion:completion]);

    // Make the call
    [mockLoader downloadImageFromURL:url completion:completion];

    // Verify
    OCMVerifyAll(mockLoader);
}

- (void)testCancelDownload_cancelsImage
{
    // Set up expectation
    id mockLoader = OCMPartialMock(self.imageLoader);
    OCMExpect([mockLoader cancelImageWithRequestID:@"d83kc8hf"]);

    // Make the call
    [mockLoader cancelImageDownloadWithToken:@"d83kc8hf"];

    // Verify
    OCMVerifyAll(mockLoader);
}

@end
