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

#import "TWTRGenericKeychainItem.h"
#import "TWTRAssertionMacros.h"
#import "TWTRSecItemWrapper.h"
#import "TWTRUtils.h"

NSString *const TWTRGenericKeychainItemErrorDomain = @"TWTRGenericKeychainItemErrorDomain";

@implementation TWTRGenericKeychainQuery

- (instancetype)initWithService:(NSString *)service account:(NSString *)account genericValue:(NSString *)genericValue accessGroup:(NSString *)accessGroup
{
    self = [super init];
    if (self) {
        _service = [service copy];
        _account = [account copy];
        _genericValue = [genericValue copy];
        _accessGroup = [accessGroup copy];
    }
    return self;
}

+ (instancetype)queryForAllItems
{
    return [[self alloc] initWithService:nil account:nil genericValue:nil accessGroup:nil];
}

+ (instancetype)queryForService:(NSString *)service
{
    return [[self alloc] initWithService:service account:nil genericValue:nil accessGroup:nil];
}

+ (instancetype)queryForAccount:(NSString *)account
{
    return [[self alloc] initWithService:nil account:account genericValue:nil accessGroup:nil];
}

+ (instancetype)queryForService:(NSString *)service account:(NSString *)account
{
    return [[self alloc] initWithService:service account:account genericValue:nil accessGroup:nil];
}

+ (instancetype)queryForGenericValue:(NSString *)genericValue
{
    return [[self alloc] initWithService:nil account:nil genericValue:genericValue accessGroup:nil];
}

+ (instancetype)queryForAccessGroup:(NSString *)accessGroup
{
    return [[self alloc] initWithService:nil account:nil genericValue:nil accessGroup:accessGroup];
}

- (NSMutableDictionary *)queryDictionary;
{
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    query[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;

    void (^updateQuery)(CFTypeRef, NSString *) = ^(CFTypeRef key, NSString *obj) {
        if (key && obj.length) {
            query[(__bridge id)key] = obj;
        }
    };

    updateQuery(kSecAttrService, self.service);
    updateQuery(kSecAttrAccount, self.account);
    updateQuery(kSecAttrGeneric, self.genericValue);

#if TARGET_IPHONE_SIMULATOR
// Ignore the access group if running on the iPhone simulator.
// If a SecItem contains an access group attribute, SecItemAdd and SecItemUpdate on the
// simulator will return -25243 (errSecNoAccessForItem).
#else
    updateQuery(kSecAttrAccessGroup, self.accessGroup);
#endif

    return query;
}

@end

@implementation TWTRGenericKeychainItem

- (instancetype)initWithService:(NSString *)service account:(NSString *)account secret:(NSData *)secret
{
    return [self initWithService:service account:account secret:secret genericValue:nil];
}

- (instancetype)initWithService:(NSString *)service account:(NSString *)account secret:(NSData *)secret genericValue:(nullable NSString *)genericValue
{
    return [self initWithService:service account:account secret:secret genericValue:genericValue accessGroup:nil];
}

- (instancetype)initWithService:(NSString *)service account:(NSString *)account secret:(NSData *)secret genericValue:(nullable NSString *)genericValue accessGroup:(nullable NSString *)accessGroup
{
    TWTRParameterAssertOrReturnValue(service, nil);
    TWTRParameterAssertOrReturnValue(account, nil);
    TWTRParameterAssertOrReturnValue(secret, nil);

    self = [super init];
    if (self) {
        _service = [service copy];
        _account = [account copy];
        _secret = [secret copy];
        _genericValue = [genericValue copy];
        _accessGroup = [accessGroup copy];
    }
    return self;
}

+ (instancetype)keychainItemFromRawObject:(NSDictionary *)rawObject
{
    NSString *service = rawObject[(__bridge id)kSecAttrService];
    NSString *account = rawObject[(__bridge id)kSecAttrAccount];
    NSString *genericValue = rawObject[(__bridge id)kSecAttrGeneric];
    NSString *accessGroup = rawObject[(__bridge id)kSecAttrAccessGroup];
    NSDate *modificationDate = rawObject[(__bridge id)kSecAttrModificationDate];

    NSData *secret = rawObject[(__bridge id)kSecValueData];

    TWTRGenericKeychainItem *instance = nil;
    if (service && account && secret) {
        instance = [[TWTRGenericKeychainItem alloc] initWithService:service account:account secret:secret genericValue:genericValue accessGroup:accessGroup];
        instance->_lastSavedDate = modificationDate;
    }

    return instance;
}

#pragma mark - Equality
- (NSUInteger)hash
{
    return self.service.hash ^ self.account.hash;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[TWTRGenericKeychainItem class]]) {
        return [self isEqualToKeychainItem:object];
    } else {
        return NO;
    }
}

- (BOOL)isEqualToKeychainItem:(TWTRGenericKeychainItem *)other
{
    const BOOL serviceEqual = [TWTRUtils isEqualOrBothNil:self.service other:other.service];
    const BOOL accountEqual = [TWTRUtils isEqualOrBothNil:self.account other:other.account];
    const BOOL secretEqual = [TWTRUtils isEqualOrBothNil:self.secret other:other.secret];
    const BOOL genericEqual = [TWTRUtils isEqualOrBothNil:self.genericValue other:other.genericValue];

    return serviceEqual && accountEqual && secretEqual && genericEqual;
}

#pragma mark - Keychain Access
/**
 * Call this method when you want to access the keychain in a threadsafe
 * manner. This method is not reentrant.
 */
+ (void)synchronouslyAccessKeychain:(void (^)(void))block;
{
    TWTRParameterAssertOrReturn(block);

    static dispatch_queue_t queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.twitterkit.generic-keychain-item-queue", DISPATCH_QUEUE_SERIAL);
    });

    dispatch_sync(queue, ^{
        block();
    });
}

- (BOOL)storeInKeychain:(NSError **)error
{
    return [self storeInKeychainReplacingExisting:YES error:error];
}

- (BOOL)storeInKeychainReplacingExisting:(BOOL)replaceExisting error:(NSError **)error;
{
    __block BOOL success = YES;

    [[self class] synchronouslyAccessKeychain:^{

        if (replaceExisting) {
            NSError *deleteError = nil;
            if (![self unsynchronizedRemoveFromKeychain:error]) {
                NSLog(@"Could not delete existing item: %@", deleteError);  // TODO: Update this.
            }
        }

        NSDictionary *query = [self fullRawRepresentation];
        OSStatus status = [TWTRSecItemWrapper secItemAdd:(__bridge CFDictionaryRef)query withResult:NULL];

        if (status != errSecSuccess) {
            if (error) {
                *error = [[self class] errorWithStatus:status];
            }
            success = NO;
        } else {
            // Fetch from the keychain so we can guarantee we have the same timestamp that is assigned by the keychain
            TWTRGenericKeychainItem *fetchedItem = [self existingKeychainItem];
            self->_lastSavedDate = fetchedItem.lastSavedDate;
        }
    }];

    return success;
}

- (BOOL)removeFromKeychain:(NSError **)error
{
    __block BOOL success = YES;

    [[self class] synchronouslyAccessKeychain:^{
        success = [self unsynchronizedRemoveFromKeychain:error];
    }];

    return success;
}

+ (BOOL)removeAllItemsForQuery:(TWTRGenericKeychainQuery *)query error:(NSError **)error;
{
    __block BOOL success = YES;

    [[self class] synchronouslyAccessKeychain:^{
        NSArray *items = [self unsynchronizedStoredItemsMatchingQuery:query error:error];

        if (!items) {
            success = NO;
        }

        for (TWTRGenericKeychainItem *item in items) {
            if (![item unsynchronizedRemoveFromKeychain:error]) {
                success = NO;
                break;
            }
        }
    }];

    return success;
}

#pragma mark - Unsychronized Methods
/**
 * This method removes the item from the keychain in an unsynchronized manner.
 * This method can safely be called from with the synchronouslyAccessKeychain: method.
 */
- (BOOL)unsynchronizedRemoveFromKeychain:(NSError **)error
{
    NSDictionary *query = [self simpleRawRepresentation];

    OSStatus status = [TWTRSecItemWrapper secItemDelete:(__bridge CFDictionaryRef)query];
    if (status != errSecSuccess && status != errSecItemNotFound) {
        if (error) {
            *error = [[self class] errorWithStatus:status];
        }
        return NO;
    }
    return YES;
}

/**
 * This method fetches all the items that match the query but in an unsynchronized manner.
 * This method can safely be called from with the synchronouslyAccessKeychain: method.
 */
+ (NSArray *)unsynchronizedStoredItemsMatchingQuery:(TWTRGenericKeychainQuery *)query error:(NSError **)error
{
    NSMutableDictionary *queryDict = [query queryDictionary];
    return [self storedItemsMatchingQueryDictionary:queryDict error:error];
}

#pragma mark - Query
+ (NSArray *)storedItemsMatchingQuery:(TWTRGenericKeychainQuery *)query error:(NSError **)error
{
    NSArray *__block items = nil;

    [[self class] synchronouslyAccessKeychain:^{
        items = [self unsynchronizedStoredItemsMatchingQuery:query error:error];
    }];

    return items;
}

+ (NSArray *)storedItemsMatchingQueryDictionary:(NSDictionary *)queryDict error:(NSError **)error
{
    NSMutableArray *objects = nil;
    NSMutableDictionary *query = [queryDict mutableCopy];

    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitAll;
    query[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    query[(__bridge id)kSecReturnAttributes] = (__bridge id)kCFBooleanTrue;

    CFTypeRef cfResponse = NULL;
    OSStatus status = [TWTRSecItemWrapper secItemCopyMatching:(__bridge CFDictionaryRef)query withResult:&cfResponse];
    NSArray *rawObjects = CFBridgingRelease(cfResponse);

    if (status == errSecSuccess || status == errSecItemNotFound) {
        objects = [NSMutableArray array];
        for (NSDictionary *rawObject in rawObjects) {
            TWTRGenericKeychainItem *item = [self keychainItemFromRawObject:rawObject];
            if (item) {
                [objects addObject:item];
            }
        }
    } else {
        if (error) {
            *error = [self errorWithStatus:status];
        }
    }

    return objects;
}

- (NSDictionary *)fullRawRepresentation
{
    TWTRGenericKeychainQuery *query = [[TWTRGenericKeychainQuery alloc] initWithService:self.service account:self.account genericValue:self.genericValue accessGroup:self.accessGroup];
    NSMutableDictionary *representation = [query queryDictionary];
    representation[(__bridge id)kSecValueData] = self.secret;
    return representation;
}

- (NSDictionary *)simpleRawRepresentation
{
    TWTRGenericKeychainQuery *query = [TWTRGenericKeychainQuery queryForService:self.service account:self.account];
    return [query queryDictionary];
}

- (TWTRGenericKeychainItem *)existingKeychainItem
{
    NSDictionary *queryDict = [self simpleRawRepresentation];
    return [[[self class] storedItemsMatchingQueryDictionary:queryDict error:nil] firstObject];
}

#pragma mark - Helper methods
+ (NSError *)errorWithStatus:(OSStatus)status;
{
    NSString *errorDescription = [self errorDescriptionForKeychainOsCode:status];
    NSDictionary *userInfo = errorDescription ? @{NSLocalizedDescriptionKey: errorDescription} : nil;
    return [NSError errorWithDomain:TWTRGenericKeychainItemErrorDomain code:status userInfo:userInfo];
}

+ (NSString *)errorDescriptionForKeychainOsCode:(OSStatus)status;
{
    NSString *errorDescription = nil;
    switch (status) {
        // source: Frameworks/Security/SecBase.h
        case errSecSuccess:
            errorDescription = @"No error.";
            break;
        case errSecUnimplemented:
            errorDescription = @"Function or operation not implemented.";
            break;
        case errSecIO:
            errorDescription = @"I/O error (bummers)";
            break;
#if IS_UIKIT_AVAILABLE
        case errSecOpWr:
            errorDescription = @"file already open with with write permission";
            break;
#endif
        case errSecParam:
            errorDescription = @"One or more parameters passed to a function where not valid.";
            break;
        case errSecAllocate:
            errorDescription = @"Failed to allocate memory.";
            break;
        case errSecUserCanceled:
            errorDescription = @"User canceled the operation.";
            break;
        case errSecBadReq:
            errorDescription = @"Bad parameter or invalid state for operation.";
            break;
        case errSecInternalComponent:
            errorDescription = @"Internal Component (?)";
            break;
        case errSecNotAvailable:
            errorDescription = @"No keychain is available. You may need to restart your computer.";
            break;
        case errSecDuplicateItem:
            errorDescription = @"The specified item already exists in the keychain.";
            break;
        case errSecItemNotFound:
            errorDescription = @"The specified item could not be found in the keychain.";
            break;
        case errSecInteractionNotAllowed:
            errorDescription = @"User interaction is not allowed.";
            break;
        case errSecDecode:
            errorDescription = @"Unable to decode the provided data.";
            break;
        // errSecNoAccessForItem is not defined in SecBase.h for iOS but the error is still used
        case -25243:
            errorDescription = @"The specified item has no access control. There may be a problem with your access group";
            break;
        case errSecAuthFailed:
            errorDescription = @"The user name or passphrase you entered is not correct.";
            break;
        default:
            errorDescription = @"Unknown Keychain error code.";
            break;
    }

    return [NSString stringWithFormat:@"Error Code: %i: %@", (int)status, errorDescription];
}

@end
