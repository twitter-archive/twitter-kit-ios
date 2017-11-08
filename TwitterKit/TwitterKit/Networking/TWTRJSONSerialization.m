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

#import "TWTRJSONSerialization.h"
#import <TwitterCore/TWTRConstants.h>

@implementation TWTRJSONSerialization

+ (NSArray *)arrayFromData:(NSData *)responseData error:(NSError **)error
{
    return [[self class] collectionFromData:responseData error:error validationHandler:^(id JSONResponse) {
        if (![JSONResponse isKindOfClass:[NSArray class]]) {
            NSLog(@"[TwitterKit] Attempted to parse non-array JSON as array.");
            return NO;
        }

        return YES;
    }];
}

+ (NSDictionary *)dictionaryFromData:(NSData *)responseData error:(NSError **)error
{
    return [[self class] collectionFromData:responseData error:error validationHandler:^(id JSONResponse) {
        if (![JSONResponse isKindOfClass:[NSDictionary class]]) {
            NSLog(@"[TwitterKit] Attempted to parse non-dictionary JSON as dictionary.");
            return NO;
        }

        return YES;
    }];
}

+ (id)collectionFromData:(NSData *)responseData error:(NSError **)error validationHandler:(BOOL (^)(id JSONResponse))validationHandler
{
    NSError *serializationError;

    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&serializationError];
    if (!jsonResponse) {
        NSLog(@"[TwitterKit] Serialization error: %@", serializationError);
        *error = serializationError;
    }

    if (!validationHandler(jsonResponse)) {
        if (error == NULL) {
            return nil;
        }

        *error = [NSError errorWithDomain:TWTRErrorDomain code:TWTRErrorCodeMismatchedJSONType userInfo:nil];
        jsonResponse = nil;
    };

    return jsonResponse;
}

@end
