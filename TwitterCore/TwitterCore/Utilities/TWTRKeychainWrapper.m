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

#import "TWTRKeychainWrapper.h"
#import "TWTRSecItemWrapper.h"

@interface TWTRKeychainWrapper (PrivateMethods)
/*
 The decision behind the following two methods (secItemFormatToDictionary and dictionaryToSecItemFormat) was
 to encapsulate the transition between what the detail view controller was expecting (NSString *) and what the
 Keychain API expects as a validly constructed container class.
 */
- (NSMutableDictionary *)secItemFormatToDictionary:(NSDictionary *)dictionaryToConvert;
- (NSMutableDictionary *)dictionaryToSecItemFormat:(NSDictionary *)dictionaryToConvert;

// Updates the item in the keychain, or adds it if it doesn't exist.
- (BOOL)writeToKeychain;

@end

@implementation TWTRKeychainWrapper

- (id)initWithAccount:(NSString *)account service:(NSString *)service accessGroup:(NSString *)accessGroup
{
    if (self = [super init]) {
        NSParameterAssert(account);
        NSParameterAssert(service);
        // Begin Keychain search setup. The genericPasswordQuery the attributes kSecAttrAccount and
        // kSecAttrService are used as unique identifiers differentiating keychain items from one another
        _genericPasswordQuery = [[NSMutableDictionary alloc] init];

        [_genericPasswordQuery setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];

        [_genericPasswordQuery setObject:account forKey:(__bridge id)kSecAttrAccount];
        [_genericPasswordQuery setObject:service forKey:(__bridge id)kSecAttrService];

        // The keychain access group attribute determines if this item can be shared
        // amongst multiple apps whose code signing entitlements contain the same keychain access group.
        if (accessGroup != nil) {
            [self executeAccessGroupBlockWithBlock:^{
                [self->_genericPasswordQuery setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
            } withBlockToRunOnSimulator:nil];
        }

        // Use the proper search constants, return only the attributes of the first match.
        [_genericPasswordQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
        [_genericPasswordQuery setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];

        NSDictionary *tempQuery = [NSDictionary dictionaryWithDictionary:_genericPasswordQuery];

        CFMutableDictionaryRef outDictionary = NULL;

        OSStatus result = SecItemCopyMatching((__bridge CFDictionaryRef)tempQuery, (CFTypeRef *)&outDictionary);
        if (result == errSecSuccess) {
            // load the saved data from Keychain.
            _keychainItemData = [self secItemFormatToDictionary:(__bridge NSDictionary *)outDictionary];
        } else {
            // Stick these default values into keychain item if nothing found.
            [self resetKeychainItem];

            // Adding the account and service identifiers to the keychain
            [_keychainItemData setObject:account forKey:(__bridge id)kSecAttrAccount];
            [_keychainItemData setObject:service forKey:(__bridge id)kSecAttrService];

            if (accessGroup != nil) {
                [self executeAccessGroupBlockWithBlock:^{
                    [self->_keychainItemData setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
                } withBlockToRunOnSimulator:nil];
            }
        }

        if (outDictionary) {
            CFRelease(outDictionary);
        }
    }

    return self;
}

- (BOOL)setObject:(id)inObject forKey:(id)key
{
    if (inObject == nil) {
        return NO;
    }
    id currentObject = [[self keychainItemData] objectForKey:key];
    if (![currentObject isEqual:inObject]) {
        [[self keychainItemData] setObject:inObject forKey:key];
        return [self writeToKeychain];
    }
    return YES;
}

- (id)objectForKey:(id)key
{
    return [[self keychainItemData] objectForKey:key];
}

- (void)resetKeychainItem
{
    OSStatus result = noErr;
    if (![self keychainItemData]) {
        [self setKeychainItemData:[[NSMutableDictionary alloc] init]];
    } else if ([self keychainItemData]) {
        NSMutableDictionary *tempDictionary = [self dictionaryToSecItemFormat:[self keychainItemData]];
        result = [TWTRSecItemWrapper secItemDelete:(__bridge CFDictionaryRef)tempDictionary];
    }

    // Default attributes for keychain item.
    [[self keychainItemData] setObject:@"" forKey:(__bridge id)kSecAttrAccount];
    [[self keychainItemData] setObject:@"" forKey:(__bridge id)kSecAttrLabel];
    [[self keychainItemData] setObject:@"" forKey:(__bridge id)kSecAttrDescription];
    [[self keychainItemData] setObject:@"" forKey:(__bridge id)kSecAttrService];

    // Default data for keychain item.
    [[self keychainItemData] setObject:@"" forKey:(__bridge id)kSecValueData];
}

- (NSMutableDictionary *)dictionaryToSecItemFormat:(NSDictionary *)dictionaryToConvert
{
    // The assumption is that this method will be called with a properly populated dictionary
    // containing all the right key/value pairs for a SecItem.

    // Create a dictionary to return populated with the attributes and data.
    NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionaryToConvert];

    // Add the Generic Password keychain item class attribute.
    [returnDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];

    // Convert the NSString to NSData to meet the requirements for the value type kSecValueData.
    // This is where to store sensitive data that should be encrypted.
    NSString *passwordString = [dictionaryToConvert objectForKey:(__bridge id)kSecValueData];
    [returnDictionary setObject:[passwordString dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];

    return returnDictionary;
}

- (NSMutableDictionary *)secItemFormatToDictionary:(NSDictionary *)dictionaryToConvert
{
    // The assumption is that this method will be called with a properly populated dictionary
    // containing all the right key/value pairs for the UI element.

    // Create a dictionary to return populated with the attributes and data.
    NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionaryToConvert];

    // Add the proper search key and class attribute.
    [returnDictionary setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [returnDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];

    // Acquire the password data from the attributes.
    NSData *passwordData = NULL;
    OSStatus result __attribute__((unused)) = SecItemCopyMatching((__bridge CFDictionaryRef)returnDictionary, (void *)&passwordData);
    // Make sure this does not fail
    NSAssert(result == noErr, @"No matching item found in keychain");
    // Remove the search, class, and identifier key/value, we don't need them anymore.
    [returnDictionary removeObjectForKey:(__bridge id)kSecReturnData];

    // Add the password to the dictionary, converting from NSData to NSString.
    NSString *password = [[NSString alloc] initWithBytes:[passwordData bytes] length:[passwordData length] encoding:NSUTF8StringEncoding];
    [returnDictionary setObject:password forKey:(__bridge id)kSecValueData];

    return returnDictionary;
}

- (BOOL)writeToKeychain
{
    NSDictionary *attributes = NULL;
    NSMutableDictionary *updateItem = NULL;
    OSStatus result = [TWTRSecItemWrapper secItemCopyMatching:(__bridge CFDictionaryRef)[self genericPasswordQuery] withResult:(void *)&attributes];

    if (result == noErr) {
        // First we need the attributes from the Keychain.
        updateItem = [NSMutableDictionary dictionaryWithDictionary:attributes];
        // Second we need to add the appropriate search key/values.
        [updateItem setObject:[[self genericPasswordQuery] objectForKey:(__bridge id)kSecClass] forKey:(__bridge id)kSecClass];

        // Lastly, we need to set up the updated attribute list being careful to remove the class.
        NSMutableDictionary *tempCheck = [self dictionaryToSecItemFormat:[self keychainItemData]];
        [tempCheck removeObjectForKey:(__bridge id)kSecClass];

        [self executeAccessGroupBlockWithBlock:nil withBlockToRunOnSimulator:^{
            [tempCheck removeObjectForKey:(__bridge id)kSecAttrAccessGroup];
        }];

        // An implicit assumption is that you can only update a single item at a time.
        result = [TWTRSecItemWrapper secItemUpdate:(__bridge CFDictionaryRef)updateItem withAttributes:(__bridge CFDictionaryRef)tempCheck];
        NSAssert(result == noErr, @"Couldn't update the Keychain Item.");
    } else {
        // No previous item found; add the new one.
        result = [TWTRSecItemWrapper secItemAdd:(__bridge CFDictionaryRef)[self dictionaryToSecItemFormat:[self keychainItemData]] withResult:NULL];
        NSAssert(result == errSecSuccess, @"Couldn't add the Keychain Item.");
    }

    return (result == errSecSuccess);
}

- (void)executeAccessGroupBlockWithBlock:(void (^)(void))accessGroupBlock withBlockToRunOnSimulator:(void (^)(void))simulatorAccessGroupBlock
{
#if TARGET_IPHONE_SIMULATOR
    // Remove the access group if running on the iPhone simulator.
    //
    // Apps that are built for the simulator aren't signed, so there's no keychain access group
    // for the simulator to check. This means that all apps can see all keychain items when run
    // on the simulator.
    //
    // If a SecItem contains an access group attribute, SecItemAdd and SecItemUpdate on the
    // simulator will return -25243 (errSecNoAccessForItem).
    //
    // The access group attribute will be included in items returned by SecItemCopyMatching,
    // which is why we need to remove it before updating the item.
    if (simulatorAccessGroupBlock) {
        simulatorAccessGroupBlock();
    }
#else
    if (accessGroupBlock) {
        accessGroupBlock();
    }
#endif
}

@end
