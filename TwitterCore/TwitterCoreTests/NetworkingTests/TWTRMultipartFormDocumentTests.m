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

#import <XCTest/XCTest.h>
#import "TWTRMultipartFormDocument.h"

@interface TWTRMultipartFormDocumentTests : XCTestCase
@property (nonatomic, copy) NSString *boundary;
@property (nonatomic) TWTRMultipartFormElement *textElement;
@property (nonatomic) TWTRMultipartFormElement *textFileElement;
@property (nonatomic) TWTRMultipartFormElement *imageElement;

@end

@implementation TWTRMultipartFormDocumentTests

- (void)setUp
{
    [super setUp];
    self.boundary = @"-BOUNDARY-";
    self.textElement = [[TWTRMultipartFormElement alloc] initWithName:@"singleTextElement" contentType:@"text/plain" fileName:nil content:[@"some text element" dataUsingEncoding:NSUTF8StringEncoding]];
    self.imageElement = [[TWTRMultipartFormElement alloc] initWithName:@"image" contentType:@"application/png" fileName:nil content:[self imagePNGData]];
    self.textFileElement = [[TWTRMultipartFormElement alloc] initWithName:@"a-file" contentType:@"text/html" fileName:@"myfile.html" content:[@"<html>\n</html>" dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)testFormDocumentCreatesBoundary
{
    TWTRMultipartFormDocument *doc = [[TWTRMultipartFormDocument alloc] init];
    XCTAssertNotNil(doc.boundary);
}

- (void)testFormDocumentCreatesUniqueBoundary
{
    TWTRMultipartFormDocument *doc1 = [[TWTRMultipartFormDocument alloc] init];
    TWTRMultipartFormDocument *doc2 = [[TWTRMultipartFormDocument alloc] init];
    XCTAssertNotEqualObjects(doc1.boundary, doc2.boundary);
}

- (void)testDocumentDataNoElements
{
    NSData *expected = [[NSString stringWithFormat:@"--%@--\r\n", self.boundary] dataUsingEncoding:NSUTF8StringEncoding];
    [self performTestWithElements:@[] expectedData:expected];
}

- (void)testDocumentDataSingleTextElement
{
    NSData *expected = [self dataForSingleTextDocument];
    [self performTestWithElements:@[self.textElement] expectedData:expected];
}

- (void)testDocumentDataSingleImageElement
{
    NSData *expected = [self dataForSingleImageDocument];
    [self performTestWithElements:@[self.imageElement] expectedData:expected];
}

- (void)testMultiElementDocument
{
    NSData *expected = [self dataForMultiTextElementsDocument];
    [self performTestWithElements:@[self.textElement, self.textFileElement] expectedData:expected];
}

- (void)performTestWithElements:(NSArray *)elements expectedData:(NSData *)expectedData
{
    TWTRMultipartFormDocument *doc = [[TWTRMultipartFormDocument alloc] initWithFormElements:elements];
    [self injectDefaultBoundary:doc];
    XCTestExpectation *expectation = [self expectationWithDescription:@"load doc"];

    [doc loadBodyDataWithCallbackQueue:dispatch_get_main_queue() completion:^(NSData *data) {
        XCTAssertEqualObjects(data, expectedData);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

#pragma mark - Expected Documents

- (NSData *)dataForSingleTextDocument
{
    return [self dataForSingleElementDocument:self.textElement];
}

- (NSData *)dataForSingleImageDocument
{
    return [self dataForSingleElementDocument:self.imageElement];
}

- (NSData *)dataForSingleElementDocument:(TWTRMultipartFormElement *)element
{
    NSData *header = [[NSString stringWithFormat:@"--%@\r\n"
                                                 @"Content-Disposition: form-data; name=\"%@\"\r\n"
                                                 @"Content-Type: %@\r\n\r\n",
                                                 self.boundary, element.name, element.contentType] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *footer = [[NSString stringWithFormat:@"\r\n--%@--\r\n", self.boundary] dataUsingEncoding:NSUTF8StringEncoding];

    NSMutableData *data = [NSMutableData dataWithData:header];
    [data appendData:element.content];
    [data appendData:footer];
    return data;
}

- (NSData *)dataForMultiTextElementsDocument
{
    NSData *first = [[NSString stringWithFormat:@"--%@\r\n"
                                                @"Content-Disposition: form-data; name=\"%@\"\r\n"
                                                @"Content-Type: %@\r\n\r\n",
                                                self.boundary, self.textElement.name, self.textElement.contentType] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *second = [[NSString stringWithFormat:@"--%@\r\n"
                                                 @"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n"
                                                 @"Content-Type: %@\r\n\r\n",
                                                 self.boundary, self.textFileElement.name, self.textFileElement.fileName, self.textFileElement.contentType] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *footer = [[NSString stringWithFormat:@"\r\n--%@--\r\n", self.boundary] dataUsingEncoding:NSUTF8StringEncoding];

    NSMutableData *data = [NSMutableData dataWithData:first];
    [data appendData:self.textElement.content];
    [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:second];
    [data appendData:self.textFileElement.content];
    [data appendData:footer];

    return data;
}

#pragma mark - Helpers
- (void)injectDefaultBoundary:(TWTRMultipartFormDocument *)doc
{
    [doc setValue:self.boundary forKey:@"boundary"];
}

- (NSData *)imagePNGData
{
#if IS_UIKIT_AVAILABLE
    CGRect rect = CGRectMake(0, 0, 1024, 1024);
    UIGraphicsBeginImageContext(rect.size);

    [[UIColor redColor] set];
    UIRectFrame(rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return UIImagePNGRepresentation(image);
#else
    // TODO: fill this in
    return [NSData data];
#endif
}

@end
