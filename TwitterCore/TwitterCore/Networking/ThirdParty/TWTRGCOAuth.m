/*

 Copyright 2011 TweetDeck Inc. All rights reserved.

 Design and implementation, Max Howell, @mxcl.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.

 THIS SOFTWARE IS PROVIDED BY TweetDeck Inc. ``AS IS'' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 EVENT SHALL TweetDeck Inc. OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 The views and conclusions contained in the software and documentation are
 those of the authors and should not be interpreted as representing official
 policies, either expressed or implied, of TweetDeck Inc.

 */

#import "TWTRGCOAuth.h"
#import "TWTRNetworkingConstants.h"
#import "TWTRNetworkingUtil.h"

#import <CommonCrypto/CommonHMAC.h>
#import <stdatomic.h>

typedef _Atomic(time_t) twtr_atomic_time_t;

// static variables
static NSString *TWTRGCOAuthUserAgent = nil;
static volatile twtr_atomic_time_t TWTRGCOAuthTimestampOffset = ATOMIC_VAR_INIT(0);
static BOOL TWTRGCOAuthUseHTTPSCookieStorage = YES;

@interface TWTRGCOAuth ()

// properties
@property (nonatomic, copy) NSDictionary *requestParameters;
@property (nonatomic, copy) NSString *HTTPMethod;
@property (nonatomic, copy) NSURL *URL;

// get a nonce string
+ (NSString *)nonce;

// get a timestamp string
+ (NSString *)timeStamp;

// generate properly escaped string for the given parameters
+ (NSString *)queryStringFromParameters:(NSDictionary *)parameters;

// create a request with given oauth values
- (id)initWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret accessToken:(NSString *)accessToken tokenSecret:(NSString *)tokenSecret;

// generate a request
- (NSMutableURLRequest *)request;

// generate authorization header
- (NSString *)authorizationHeader;

// generate signature
- (NSString *)signature;

// generate signature base
- (NSString *)signatureBase;
@end

@implementation TWTRGCOAuth

@synthesize requestParameters = __parameters;
@synthesize HTTPMethod = __method;
@synthesize URL = __url;

#pragma mark - object methods
- (id)initWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret accessToken:(NSString *)accessToken tokenSecret:(NSString *)tokenSecret
{
    self = [super init];
    if (self) {
        OAuthParameters = [[NSDictionary alloc] initWithObjectsAndKeys:[consumerKey copy], @"oauth_consumer_key", [TWTRGCOAuth nonce], @"oauth_nonce", [TWTRGCOAuth timeStamp], @"oauth_timestamp", @"1.0", @"oauth_version", @"HMAC-SHA1", @"oauth_signature_method", [accessToken copy], @"oauth_token",  // leave accessToken last or you'll break XAuth attempts
                                                                       nil];
        signatureSecret = [NSString stringWithFormat:@"%@&%@", [TWTRNetworkingUtil percentEscapedQueryStringWithString:consumerSecret encoding:NSUTF8StringEncoding], [TWTRNetworkingUtil percentEscapedQueryStringWithString:tokenSecret ?: @"" encoding:NSUTF8StringEncoding]];
    }
    return self;
}
- (NSMutableURLRequest *)request
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.URL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    if (TWTRGCOAuthUserAgent) {
        [request setValue:TWTRGCOAuthUserAgent forHTTPHeaderField:@"User-Agent"];
    }
    [request setValue:[self authorizationHeader] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [request setHTTPMethod:self.HTTPMethod];
    [request setHTTPShouldHandleCookies:TWTRGCOAuthUseHTTPSCookieStorage];
    return request;
}
- (NSString *)authorizationHeader
{
    NSMutableArray *entries = [NSMutableArray array];
    NSMutableDictionary *dictionary = [OAuthParameters mutableCopy];
    [dictionary setObject:[self signature] forKey:@"oauth_signature"];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *entry = [NSString stringWithFormat:@"%@=\"%@\"", [TWTRNetworkingUtil percentEscapedQueryStringWithString:key encoding:NSUTF8StringEncoding], [TWTRNetworkingUtil percentEscapedQueryStringWithString:obj encoding:NSUTF8StringEncoding]];
        [entries addObject:entry];
    }];
    return [@"OAuth " stringByAppendingString:[entries componentsJoinedByString:@","]];
}
- (NSString *)signature
{
    // get signature components
    NSData *base = [[self signatureBase] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *secret = [signatureSecret dataUsingEncoding:NSUTF8StringEncoding];

    // hmac
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CCHmacContext cx;
    CCHmacInit(&cx, kCCHmacAlgSHA1, [secret bytes], [secret length]);
    CCHmacUpdate(&cx, [base bytes], [base length]);
    CCHmacFinal(&cx, digest);

    // base 64
    NSData *data = [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
    if ([NSData instancesRespondToSelector:@selector(base64EncodedStringWithOptions:)]) {
        return [data base64EncodedStringWithOptions:0];
    }
    return [data base64EncodedStringWithOptions:0];
}
- (NSString *)signatureBase
{
    // normalize parameters
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters addEntriesFromDictionary:OAuthParameters];
    [parameters addEntriesFromDictionary:self.requestParameters];
    NSMutableArray *entries = [NSMutableArray arrayWithCapacity:[parameters count]];
    NSArray *keys = [[parameters allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *key in keys) {
        NSString *obj = [parameters objectForKey:key];
        NSString *entry = [NSString stringWithFormat:@"%@=%@", [TWTRNetworkingUtil percentEscapedQueryStringWithString:key encoding:NSUTF8StringEncoding], [TWTRNetworkingUtil percentEscapedQueryStringWithString:obj encoding:NSUTF8StringEncoding]];
        [entries addObject:entry];
    }
    NSString *normalizedParameters = [entries componentsJoinedByString:@"&"];

    // construct request url
    NSURL *URL = self.URL;

    // Use CFURLCopyPath so that the path is preserved with trailing slash, then escape the percents ourselves
    NSString *pathWithPrevervedTrailingSlash = [CFBridgingRelease(CFURLCopyPath((CFURLRef)URL)) stringByRemovingPercentEncoding];

    NSString *URLString = [NSString stringWithFormat:@"%@://%@%@", [[URL scheme] lowercaseString], [[TWTRGCOAuth hostAndPortForURL:URL] lowercaseString], pathWithPrevervedTrailingSlash];

    // create components
    NSArray *components = [NSArray arrayWithObjects:[TWTRNetworkingUtil percentEscapedQueryStringWithString:[self HTTPMethod] encoding:NSUTF8StringEncoding], [TWTRNetworkingUtil percentEscapedQueryStringWithString:URLString encoding:NSUTF8StringEncoding], [TWTRNetworkingUtil percentEscapedQueryStringWithString:normalizedParameters encoding:NSUTF8StringEncoding], nil];

    // return
    return [components componentsJoinedByString:@"&"];
}

#pragma mark - class methods

+ (void)setUserAgent:(NSString *)agent
{
    TWTRGCOAuthUserAgent = [agent copy];
}

+ (void)setTimestampOffset:(time_t)offset
{
    atomic_store(&TWTRGCOAuthTimestampOffset, offset);
}

+ (time_t)timestampOffset
{
    return atomic_load(&TWTRGCOAuthTimestampOffset);
}

+ (void)setHTTPShouldHandleCookies:(BOOL)handle
{
    TWTRGCOAuthUseHTTPSCookieStorage = handle;
}

+ (NSString *)nonce
{
    return [[NSUUID UUID] UUIDString];
}

+ (NSString *)timeStamp
{
    time_t t;
    time(&t);
    gmtime(&t);
    time_t offset = [self timestampOffset];
    return [NSString stringWithFormat:@"%lu", (t + offset)];
}
+ (NSString *)queryStringFromParameters:(NSDictionary *)parameters
{
    NSMutableArray *entries = [NSMutableArray array];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *entry = [NSString stringWithFormat:@"%@=%@", [TWTRNetworkingUtil percentEscapedQueryStringWithString:key encoding:NSUTF8StringEncoding], [TWTRNetworkingUtil percentEscapedQueryStringWithString:obj encoding:NSUTF8StringEncoding]];
        [entries addObject:entry];
    }];
    return [entries componentsJoinedByString:@"&"];
}
+ (NSURLRequest *)URLRequestForPath:(NSString *)path HTTPMethod:(NSString *)HTTPMethod parameters:(NSDictionary *)parameters scheme:(NSString *)scheme host:(NSString *)host consumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret accessToken:(NSString *)accessToken tokenSecret:(NSString *)tokenSecret
{
    // check parameters
    if (host == nil || path == nil) {
        return nil;
    }

    // create object
    TWTRGCOAuth *oauth = [[TWTRGCOAuth alloc] initWithConsumerKey:consumerKey consumerSecret:consumerSecret accessToken:accessToken tokenSecret:tokenSecret];
    oauth.HTTPMethod = HTTPMethod;
    oauth.requestParameters = parameters;

    NSString *encodedPath = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    NSString *URLString = [NSString stringWithFormat:@"%@://%@%@", scheme, host, encodedPath];
    if ([[HTTPMethod uppercaseString] isEqualToString:@"GET"]) {
        // Handle GET
        if ([oauth.requestParameters count]) {
            NSString *query = [TWTRGCOAuth queryStringFromParameters:oauth.requestParameters];
            URLString = [NSString stringWithFormat:@"%@?%@", URLString, query];
        }
    }
    oauth.URL = [NSURL URLWithString:URLString];

    NSMutableURLRequest *request = [oauth request];
    if (![[HTTPMethod uppercaseString] isEqualToString:@"GET"] && [oauth.requestParameters count]) {
        // Add the parameters to the request body for non GET requests
        NSString *query = [TWTRGCOAuth queryStringFromParameters:oauth.requestParameters];
        NSData *data = [query dataUsingEncoding:NSUTF8StringEncoding];
        NSString *length = [NSString stringWithFormat:@"%lu", (unsigned long)[data length]];
        [request setHTTPBody:data];
        [request setValue:TWTRContentTypeURLEncoded forHTTPHeaderField:TWTRContentTypeHeaderField];
        [request setValue:length forHTTPHeaderField:TWTRContentLengthHeaderField];
    }

    // return
    return request;
}

+ (NSURLRequest *)URLRequestFromRequest:(NSURLRequest *)request consumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret accessToken:(NSString *)accessToken tokenSecret:(NSString *)tokenSecret
{
    if (!(request && consumerKey && consumerSecret && accessToken && tokenSecret)) {
        return nil;
    }

    NSURL *url = request.URL;
    NSDictionary *bodyParams = nil;
    BOOL isMultipart = [self isMultipartFormRequest:request];
    BOOL isJSON = [self isJSONRequest:request];

    // Need to combine the parameters in the URL query and also anything that has already been encoded
    // into the body so we don't lose parameters when converting request of POST/DELETE to other HTTP methods,
    // this does not apply to multipart forms
    NSDictionary *queryParams = [TWTRNetworkingUtil parametersFromQueryString:url.query];

    if (!isMultipart && !isJSON) {
        NSString *bodyParamsString = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
        NSMutableDictionary *tmpBodyParams = [[TWTRNetworkingUtil parametersFromQueryString:bodyParamsString] mutableCopy];
        [tmpBodyParams addEntriesFromDictionary:queryParams];

        bodyParams = tmpBodyParams;
    }

    NSURLRequest *signedRequest = [TWTRGCOAuth URLRequestForPath:url.path HTTPMethod:request.HTTPMethod parameters:bodyParams scheme:url.scheme host:url.host consumerKey:consumerKey consumerSecret:consumerSecret accessToken:accessToken tokenSecret:tokenSecret];

    // Merge any headers from the given request
    NSDictionary *originalHeaders = [request allHTTPHeaderFields];
    NSMutableDictionary *signedRequestHeaders = [[signedRequest allHTTPHeaderFields] mutableCopy];
    [signedRequestHeaders addEntriesFromDictionary:originalHeaders];
    NSMutableURLRequest *mutableSignedRequest = [signedRequest mutableCopy];
    [mutableSignedRequest setAllHTTPHeaderFields:signedRequestHeaders];

    if (isMultipart || isJSON) {
        /// We need to add the http body back because the signed request strips it.
        /// TODO: there should be a better way to do this.
        mutableSignedRequest.HTTPBody = request.HTTPBody;
    }

    return mutableSignedRequest;
}

+ (NSURLRequest *)URLRequestForPath:(NSString *)path GETParameters:(NSDictionary *)parameters host:(NSString *)host consumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret accessToken:(NSString *)accessToken tokenSecret:(NSString *)tokenSecret
{
    return [self URLRequestForPath:path HTTPMethod:@"GET" parameters:parameters scheme:@"http" host:host consumerKey:consumerKey consumerSecret:consumerSecret accessToken:accessToken tokenSecret:tokenSecret];
}
+ (NSURLRequest *)URLRequestForPath:(NSString *)path GETParameters:(NSDictionary *)parameters scheme:(NSString *)scheme host:(NSString *)host consumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret accessToken:(NSString *)accessToken tokenSecret:(NSString *)tokenSecret
{
    return [self URLRequestForPath:path HTTPMethod:@"GET" parameters:parameters scheme:scheme host:host consumerKey:consumerKey consumerSecret:consumerSecret accessToken:accessToken tokenSecret:tokenSecret];
}
+ (NSURLRequest *)URLRequestForPath:(NSString *)path DELETEParameters:(NSDictionary *)parameters host:(NSString *)host consumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret accessToken:(NSString *)accessToken tokenSecret:(NSString *)tokenSecret
{
    return [self URLRequestForPath:path HTTPMethod:@"DELETE" parameters:parameters scheme:@"http" host:host consumerKey:consumerKey consumerSecret:consumerSecret accessToken:accessToken tokenSecret:tokenSecret];
}
+ (NSURLRequest *)URLRequestForPath:(NSString *)path DELETEParameters:(NSDictionary *)parameters scheme:(NSString *)scheme host:(NSString *)host consumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret accessToken:(NSString *)accessToken tokenSecret:(NSString *)tokenSecret
{
    return [self URLRequestForPath:path HTTPMethod:@"DELETE" parameters:parameters scheme:scheme host:host consumerKey:consumerKey consumerSecret:consumerSecret accessToken:accessToken tokenSecret:tokenSecret];
}
+ (NSURLRequest *)URLRequestForPath:(NSString *)path POSTParameters:(NSDictionary *)parameters host:(NSString *)host consumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret accessToken:(NSString *)accessToken tokenSecret:(NSString *)tokenSecret
{
    return [self URLRequestForPath:path HTTPMethod:@"POST" parameters:parameters scheme:@"https" host:host consumerKey:consumerKey consumerSecret:consumerSecret accessToken:accessToken tokenSecret:tokenSecret];
}
+ (NSURLRequest *)URLRequestForPath:(NSString *)path POSTParameters:(NSDictionary *)parameters scheme:(NSString *)scheme host:(NSString *)host consumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret accessToken:(NSString *)accessToken tokenSecret:(NSString *)tokenSecret
{
    return [self URLRequestForPath:path HTTPMethod:@"POST" parameters:parameters scheme:scheme host:host consumerKey:consumerKey consumerSecret:consumerSecret accessToken:accessToken tokenSecret:tokenSecret];
}

/*
 Get host:port from URL unless port is 80 or 443 (http://tools.ietf.org/html/rfc5849#section-3.4.1.2). Otherwis reurn only host.
 */
+ (NSString *)hostAndPortForURL:(NSURL *)url
{
    if ([url port] != nil && [[url port] intValue] != 80 && [[url port] intValue] != 443) {
        return [NSString stringWithFormat:@"%@:%@", [url host], [url port]];
    } else {
        return [url host];
    }
}

+ (BOOL)isMultipartFormRequest:(NSURLRequest *)request
{
    NSString *contentType = [[request allHTTPHeaderFields][@"Content-Type"] lowercaseString];
    if (contentType.length == 0) {
        return NO;
    }
    NSRange range = [contentType rangeOfString:@"multipart/form-data"];
    return range.location != NSNotFound;
}

+ (BOOL)isJSONRequest:(NSURLRequest *)request
{
    NSString *contentType = [[request allHTTPHeaderFields][@"Content-Type"] lowercaseString];
    if (contentType.length == 0) {
        return NO;
    }
    NSRange range = [contentType rangeOfString:@"application/json"];
    return range.location != NSNotFound;
}

@end
