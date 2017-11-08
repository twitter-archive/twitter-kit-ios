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

#import "TWTRAuthConfigStore.h"
#import "TWTRAssertionMacros.h"
#import "TWTRGenericKeychainItem.h"

@interface TWTRAuthConfigStore ()

@property (nonatomic, copy, readonly) NSString *nameSpace;

@end

@implementation TWTRAuthConfigStore

- (instancetype)initWithNameSpace:(NSString *)nameSpace
{
    TWTRParameterAssertOrReturnValue(nameSpace, nil);

    self = [super init];
    if (self) {
        _nameSpace = [nameSpace copy];
    }
    return self;
}

- (void)saveAuthConfig:(TWTRAuthConfig *)authConfig
{
    NSData *secret = [NSKeyedArchiver archivedDataWithRootObject:authConfig];
    TWTRGenericKeychainItem *item = [[TWTRGenericKeychainItem alloc] initWithService:[self nameSpacedServiceKey] account:[self nameSpacedAccountKey] secret:secret];
    [self persistAuthConfig:authConfig withKeychainItem:item];
}

- (TWTRAuthConfig *)lastSavedAuthConfig
{
    TWTRGenericKeychainQuery *query = [self authConfigQuery];
    NSError *error;

    NSArray *items = [TWTRGenericKeychainItem storedItemsMatchingQuery:query error:&error];
    if (!items) {
        NSLog(@"Unable to load saved auth config: %@", error);
    }

    TWTRGenericKeychainItem *item = [items firstObject];
    if (item) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:item.secret];
    } else {
        return nil;
    }
}

- (void)forgetAuthConfig
{
    TWTRGenericKeychainQuery *query = [self authConfigQuery];
    NSError *error;

    if (![TWTRGenericKeychainItem removeAllItemsForQuery:query error:&error]) {
        NSLog(@"Unable to remove auth config with namespace %@: %@", self.nameSpace, error);
    }
}

#pragma mark - Keychain Utility

- (NSString *)nameSpacedServiceKey
{
    static NSString *const TWTRSessionStoreAuthConfigServiceKey = @"TWTRSessionStoreAuthConfigServiceKey";
    return [NSString stringWithFormat:@"%@::%@", self.nameSpace, TWTRSessionStoreAuthConfigServiceKey];
}

- (NSString *)nameSpacedAccountKey
{
    static NSString *const TWTRsessionStoreAuthConfigAccountKey = @"TWTRsessionStoreAuthConfigAccountKey";
    return [NSString stringWithFormat:@"%@::%@", self.nameSpace, TWTRsessionStoreAuthConfigAccountKey];
}

- (TWTRGenericKeychainQuery *)authConfigQuery
{
    NSString *nameSpacedServiceKey = [self nameSpacedServiceKey];
    NSString *nameSpacedAccountKey = [self nameSpacedAccountKey];

    return [TWTRGenericKeychainQuery queryForService:nameSpacedServiceKey account:nameSpacedAccountKey];
}

- (void)persistAuthConfig:(TWTRAuthConfig *)authConfig withKeychainItem:(TWTRGenericKeychainItem *)item
{
    NSError *error;
    if (![item storeInKeychain:&error]) {
        NSLog(@"Unable to store auth config in keychain with namespace = %@: %@", self.nameSpace, error);
    }
}

@end
