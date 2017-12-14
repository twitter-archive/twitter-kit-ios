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

/**
 This header is private to the Twitter Kit SDK and not exposed for public SDK consumption
 */

#import <Foundation/Foundation.h>

/**
 *  Parse an `NSDictionary` or `NSArray` from an `NSData` JSON response
 *  from the Twitter API.
 *
 *  Uses `NSJSONSerialization` under the hood.
 */
@interface TWTRJSONSerialization : NSObject

/**
 *  Parse a JSON response into an `NSDictionary` object.
 *
 *  @param responseData An NSData object representing a dictionary in JSON format.
 *  @param error        An error encountered parsing this JSON. nil unless there
 *                      was an error parsing the JSON.
 *
 *  @return Returns a dictionary filled with the contents of the JSON payload if
            successful or nil parsing failed.
 */
+ (NSDictionary *)dictionaryFromData:(NSData *)responseData error:(NSError **)error __attribute__((nonnull));

/**
 *  Parse a JSON response into an `NSArray` object.
 *
 *  @param responseData An NSData object representing an array in JSON format.
 *  @param error        nil if the parsing succeeds. A valid NSError object if
 *
 *
 *  @return An array filled with the contents of the JSON payload if parsing is
 *          successful. nil if parsing fails for any reason.
 */
+ (NSArray *)arrayFromData:(NSData *)responseData error:(NSError **)error __attribute__((nonnull));

@end
