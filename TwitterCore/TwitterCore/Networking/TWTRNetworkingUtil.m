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

#import "TWTRNetworkingUtil.h"
// See https://tools.ietf.org/html/rfc5849#section-3.6 OAuth signature safe escaping
static NSString *const CharactersToBeEscapedInQueryString = @"%:/?&=;+!@#$(){}',*[] \"\n|^<>`";
static NSString *const CharactersToLeaveUnescapedInQueryStringPairKey = @".~-_";

@implementation TWTRNetworkingUtil

+ (NSString *)queryStringFromParameters:(NSDictionary *)parameters
{
    NSMutableArray *mutablePairs = [NSMutableArray array];
    for (NSString *key in [[parameters allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
        NSString *keyValuePair = [NSString stringWithFormat:@"%@=%@", [TWTRNetworkingUtil percentEscapedQueryStringWithString:key encoding:NSUTF8StringEncoding], [TWTRNetworkingUtil percentEscapedQueryStringWithString:parameters[key] encoding:NSUTF8StringEncoding]];
        [mutablePairs addObject:keyValuePair];
    }
    return [mutablePairs componentsJoinedByString:@"&"];
}

+ (NSString *)percentEscapedQueryStringWithString:(NSString *)string encoding:(NSStringEncoding)encoding
{
    NSCharacterSet *encodeCharacters = [NSCharacterSet characterSetWithCharactersInString:CharactersToBeEscapedInQueryString];
    return [string stringByAddingPercentEncodingWithAllowedCharacters:[encodeCharacters invertedSet]];
}

+ (NSDictionary *)parametersFromQueryString:(NSString *)queryString
{
    NSArray *pairs = [queryString componentsSeparatedByString:@"&"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [pairs enumerateObjectsUsingBlock:^(NSString *keyValueStr, NSUInteger idx, BOOL *stop) {
        NSArray *keyValue = [keyValueStr componentsSeparatedByString:@"="];
        if ([keyValue count] >= 2) {
            NSString *key = [TWTRNetworkingUtil percentUnescapedQueryStringWithString:keyValue[0] encoding:NSUTF8StringEncoding];
            NSString *value = [TWTRNetworkingUtil percentUnescapedQueryStringWithString:keyValue[1] encoding:NSUTF8StringEncoding];
            parameters[key] = value;
        }
    }];
    return parameters;
}

+ (NSString *)percentUnescapedQueryStringWithString:(NSString *)string encoding:(NSStringEncoding)encoding
{
    return [string stringByRemovingPercentEncoding];
}

@end
