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

#import "TWTRMultipartFormDocument.h"
#import "TWTRAssertionMacros.h"

static NSString *const TWTRMultipartFormDataType = @"multipart/form-data";
static NSString *const TWTRBoundaryKey = @"boundary";
static NSString *const TWTRContentDispositionKey = @"Content-Disposition";
static NSString *const TWTRFormDataContentDisposition = @"form-data";
static NSString *const TWTRContentTypeKey = @"Content-Type";

@implementation TWTRMultipartFormElement

- (instancetype)initWithName:(NSString *)name contentType:(NSString *)contentType fileName:(nullable NSString *)fileName content:(NSData *)content
{
    TWTRParameterAssertOrReturnValue(name, nil);
    TWTRParameterAssertOrReturnValue(contentType, nil);
    TWTRParameterAssertOrReturnValue(content, nil);

    self = [super init];
    if (self) {
        _name = [name copy];
        _contentType = [contentType copy];
        _fileName = [fileName copy];
        _content = [content copy];
    }
    return self;
}

- (NSData *)documentData
{
    NSMutableData *data = [NSMutableData data];

    void (^appendString)(NSString *) = ^(NSString *str) {
        [data appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
    };

    NSMutableString *disposition = [NSMutableString stringWithFormat:@"%@: %@; name=\"%@\"", TWTRContentDispositionKey, TWTRFormDataContentDisposition, self.name];

    if (self.fileName) {
        [disposition appendFormat:@"; filename=\"%@\"", self.fileName];
    }
    [disposition appendString:@"\r\n"];

    appendString(disposition);
    appendString([NSString stringWithFormat:@"%@: %@\r\n\r\n", TWTRContentTypeKey, self.contentType]);

    [data appendData:self.content];

    appendString(@"\r\n");

    return data;
}

@end

@interface TWTRMultipartFormDocument ()

@property (nonatomic, readonly) dispatch_io_t writeChannel;
@property (nonatomic, readonly) dispatch_queue_t serialIOHandlerQueue;
@property (nonatomic, readonly) NSArray *formElements;

@end

@implementation TWTRMultipartFormDocument

- (instancetype)init
{
    return [self initWithFormElements:@[]];
}

- (instancetype)initWithFormElements:(NSArray *)formElements
{
    self = [super init];
    if (self) {
        _serialIOHandlerQueue = dispatch_queue_create("com.twittercore.sdk.ios.multipartdocument", 0);
        _formElements = [formElements copy];

        NSString *uniqueBoundary = [NSString stringWithFormat:@"TWTRB0UNDARY%@", [[NSUUID UUID] UUIDString]];
        _boundary = [uniqueBoundary copy];
        _contentTypeHeaderField = [NSString stringWithFormat:@"%@; %@=%@", TWTRMultipartFormDataType, TWTRBoundaryKey, uniqueBoundary];
    }
    return self;
}

- (void)loadBodyDataWithCallbackQueue:(dispatch_queue_t)callbackQueue completion:(TWTRMultipartFormDocumentLoadDataCallback)completion
{
    TWTRParameterAssertOrReturn(completion);
    TWTRParameterAssertOrReturn(callbackQueue);

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [self documentData];

        dispatch_async(callbackQueue, ^{
            completion(data);
        });
    });
}

#pragma mark - Private Helper Methods
- (NSData *)documentData
{
    NSMutableData *data = [NSMutableData data];

    NSData *header = [[NSString stringWithFormat:@"--%@\r\n", self.boundary] dataUsingEncoding:NSUTF8StringEncoding];

    for (TWTRMultipartFormElement *element in self.formElements) {
        [data appendData:header];
        [data appendData:[element documentData]];
    }

    NSData *footer = [[NSString stringWithFormat:@"--%@--\r\n", self.boundary] dataUsingEncoding:NSUTF8StringEncoding];
    [data appendData:footer];
    return data;
}

@end
