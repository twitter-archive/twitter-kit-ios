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

#import "TWTRGuestSession.h"
#import "TWTRAssertionMacros.h"
#import "TWTRAuthenticationConstants.h"
#import "TWTRGuestSession_Private.h"
#import "TWTRUtils.h"

NSString *const TWTRGuestSessionCreationDateKey = @"TWTRGuestSessionCreationDateKey";
static NSTimeInterval const TWTRGuestSessionExpirationDuration = 3600;  // One hour

@interface TWTRGuestSession ()

/**
 * The date at which the session was created with initWithSessionDictionary:
 */
@property (nonatomic, readonly, nullable) NSDate *creationDate;

@end

@implementation TWTRGuestSession

- (instancetype)initWithSessionDictionary:(NSDictionary *)sessionDictionary
{
    return [self initWithSessionDictionary:sessionDictionary creationDate:nil];
}

- (instancetype)initWithSessionDictionary:(NSDictionary *)sessionDictionary creationDate:(NSDate *)date
{
    TWTRParameterAssertOrReturnValue(sessionDictionary, nil);
    NSString *accessToken = sessionDictionary[TWTRAuthAppOAuthTokenKey];
    NSString *guestToken = sessionDictionary[TWTRGuestAuthOAuthTokenKey];

    return [self initWithAccessToken:accessToken guestToken:guestToken creationDate:date];
}

- (instancetype)initWithAccessToken:(NSString *)accessToken guestToken:(NSString *)guestToken
{
    return [self initWithAccessToken:accessToken guestToken:guestToken creationDate:nil];
}

- (instancetype)initWithAccessToken:(NSString *)accessToken guestToken:(NSString *)guestToken creationDate:(NSDate *)creationDate
{
    TWTRParameterAssertOrReturnValue(accessToken, nil);
    TWTRParameterAssertOrReturnValue(guestToken, nil);
    self = [super init];
    if (self) {
        _accessToken = [accessToken copy];
        _guestToken = [guestToken copy];
        _creationDate = creationDate;
    }
    return self;
}

- (NSUInteger)hash
{
    return self.accessToken.hash ^ self.guestToken.hash;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[TWTRGuestSession class]]) {
        return [self isEqualToGuestSession:object];
    } else {
        return NO;
    }
}

- (BOOL)isEqualToGuestSession:(TWTRGuestSession *)object
{
    return [TWTRUtils isEqualOrBothNil:self.accessToken other:object.accessToken] && [TWTRUtils isEqualOrBothNil:self.guestToken other:object.guestToken];
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"accessToken: %@, guestToken: %@", self.accessToken, self.guestToken];
}

- (BOOL)probablyNeedsRefreshing
{
    NSTimeInterval age = [self.creationDate timeIntervalSinceNow];

    return age < -TWTRGuestSessionExpirationDuration;
}

#pragma mark - NSCoding
- (id)initWithCoder:(NSCoder *)coder
{
    NSString *accessToken = [coder decodeObjectForKey:TWTRAuthAppOAuthTokenKey];
    NSString *guestToken = [coder decodeObjectForKey:TWTRGuestAuthOAuthTokenKey];

    NSDate *creationDate = [coder decodeObjectForKey:TWTRGuestSessionCreationDateKey];

    return [self initWithAccessToken:accessToken guestToken:guestToken creationDate:creationDate];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.accessToken forKey:TWTRAuthAppOAuthTokenKey];
    [coder encodeObject:self.guestToken forKey:TWTRGuestAuthOAuthTokenKey];
    [coder encodeObject:self.creationDate forKey:TWTRGuestSessionCreationDateKey];
}

@end
