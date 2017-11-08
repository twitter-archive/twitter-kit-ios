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

#import "TFSScribe.h"
#import <CoreData/CoreData.h>
#import <libkern/OSAtomic.h>
#import "TFSScribeEvent.h"
#import "TFSScribeImpression.h"
#import "TFSSupport.h"

#define MAXIMUM_ITEM_IMPRESSIONS_COUNT 500
#define MAXIMUM_SCRIBE_ITEMS_PER_FLUSH 300
#define MAXIMUM_SCRIBE_RETRIES 5

#define SUSPEND_BIT 1

NSString *const TFSScribeDebugPreferencesKey = @"TwitterScribeDebugPreferencesKey";
NSString *const TFSScribeEventNotification = @"TwitterScribeEventNotification";
NSString *const TFSScribeFlushNotification = @"TwitterScribeFlushNotification";
NSString *const TFSScribeFlushTokenInfoKey = @"token";
const NSInteger TFSScribeServiceUpdateValue = 1;

static NSString *const TFSScribeEventEntityName = @"TFSScribeEvent";
static NSString *const TFSScribeImpressionEntityName = @"TFSScribeImpression";

@implementation TFSScribe {
    dispatch_queue_t _queue;
    NSURL *_storeURL;
    NSURL *_modelURL;
    NSInteger _requestID;
    NSManagedObjectContext *_managedObjectContext;
    uint32_t _flags;
}

+ (BOOL)isDebugEnabled
{
#if UIAUTOMATION
    if (getenv("UIAUTOMATION_ENABLE_SCRIBE_DEBUG")) {
        NSString *enableScribeDebugString = @(getenv("UIAUTOMATION_ENABLES_SCRIBE_DEBUG"));
        if ([enableScribeDebugString boolValue]) {
            TFNLogWarning(TFNLoggingChannelDefault, @"Enabling scribe debugging for UIAUTOMATION.");
            return YES;
        }
    }
#endif

#if EMPLOYEE_BUILD
    return ([[NSUserDefaults standardUserDefaults] boolForKey:TFSScribeDebugPreferencesKey]);
#else
    return NO;
#endif
}

+ (void)setDebugEnabled:(BOOL)enabled
{
#if EMPLOYEE_BUILD
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:TFSScribeDebugPreferencesKey];
#endif
}

- (instancetype)init
{
    return [self initWithStoreURL:nil];
}

- (instancetype)initWithStoreURL:(NSURL *)storeURL
{
    return [self initWithStoreURL:storeURL modelURL:nil];
}

- (instancetype)initWithStoreURL:(NSURL *)storeURL modelURL:(NSURL *)modelURL
{
    self = [super init];
    if (self) {
        _storeURL = storeURL;
        _modelURL = modelURL;
        _queue = dispatch_queue_create("com.twitter.TFSScribeQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)open
{
    [self openWithStartBlock:nil completionBlock:nil];
}

- (void)openWithStartBlock:(dispatch_block_t)startBlock completionBlock:(dispatch_block_t)completionBlock;
{
    dispatch_async(_queue, ^{
        if (startBlock) {
            startBlock();
        }

        [self _setupManagedObjectContext];
        [self _resetScribeEvents];

        if (completionBlock) {
            completionBlock();
        }
    });
}

- (void)close
{
    [self closeWithStartBlock:nil completionBlock:nil];
}

- (void)closeWithStartBlock:(dispatch_block_t)startBlock completionBlock:(dispatch_block_t)completionBlock
{
    dispatch_async(_queue, ^{

        if (startBlock) {
            startBlock();
        }

        NSManagedObjectContext *managedObjectContext = self->_managedObjectContext;
        if (managedObjectContext) {
            NSPersistentStoreCoordinator *persistentStoreCoordinator = managedObjectContext.persistentStoreCoordinator;
            if (persistentStoreCoordinator) {
                NSPersistentStore *persistentStore = [persistentStoreCoordinator persistentStoreForURL:self->_storeURL];
                if (persistentStore) {
                    NSError *error = nil;
                    if (![persistentStoreCoordinator removePersistentStore:persistentStore error:&error]) {
                        [self _handleScribeError:error];
                    }
                }
            }
            self->_managedObjectContext = nil;
        }

        if (completionBlock) {
            completionBlock();
        }
    });
}

- (void)suspend
{
    if (!OSAtomicTestAndSetBarrier(SUSPEND_BIT, &_flags)) {
        dispatch_suspend(_queue);
    }
}

- (void)resume
{
    if (OSAtomicTestAndClearBarrier(SUSPEND_BIT, &_flags)) {
        dispatch_resume(_queue);
    }
}

#pragma mark - Events

- (void)enqueueEvent:(id<TFSScribeEventParameters>)eventParameters
{
    NSDate *timestamp = [NSDate date];
    dispatch_async(_queue, ^{
        [self _performInManagedObjectContext:^(NSManagedObjectContext *managedObjectContext) {
            [self _enqueueEvent:eventParameters timestamp:timestamp managedObjectContext:managedObjectContext];
        }];
    });
}

- (void)_enqueueEvent:(id<TFSScribeEventParameters>)eventParameters timestamp:(NSDate *)timestamp managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSData *contentData = [eventParameters data];
    if (!contentData) {
        return;
    }

    TFSScribeEvent *event = [NSEntityDescription insertNewObjectForEntityForName:TFSScribeEventEntityName inManagedObjectContext:managedObjectContext];
    event.userID = @([[eventParameters userID] longLongValue]);
    event.content = contentData;
    event.requestID = @0;
    event.retryCount = @0;
    event.timestamp = timestamp;

    if ([[self class] isDebugEnabled]) {
        NSDictionary *userInfo = @{ @"request": [eventParameters dictionaryRepresentation] };
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:TFSScribeEventNotification object:self userInfo:userInfo];
        });
    }
}

#pragma mark - Impressions

- (void)enqueueImpression:(NSData *)contentData eventName:(NSString *)eventName query:(NSString *)query clientVersion:(NSString *)clientVersion userID:(NSString *)userID
{
    NSDate *timestamp = [NSDate date];
    dispatch_async(_queue, ^{
        [self _performInManagedObjectContext:^(NSManagedObjectContext *managedObjectContext) {
            [self _enqueueImpression:contentData eventName:eventName query:query clientVersion:clientVersion timestamp:timestamp userID:userID managedObjectContext:managedObjectContext];
        }];
    });
}

- (void)_enqueueImpression:(NSData *)contentData eventName:(NSString *)eventName query:(NSString *)query clientVersion:(NSString *)clientVersion timestamp:(NSDate *)timestamp userID:(NSString *)userID managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    TFSScribeImpression *impression = [NSEntityDescription insertNewObjectForEntityForName:TFSScribeImpressionEntityName inManagedObjectContext:managedObjectContext];
    impression.userID = userID;
    impression.eventName = eventName;
    impression.clientVersion = clientVersion;
    impression.query = query;
    impression.content = contentData;
    impression.timestamp = timestamp;
}

#pragma mark - Flushing

- (void)flushUserID:(NSString *)userID requestHandler:(id<TFSScribeRequestHandler>)requestHandler;
{
    [self flushUserID:userID token:nil requestHandler:requestHandler];
}

- (void)flushUserID:(NSString *)userID token:(NSString *)token requestHandler:(id<TFSScribeRequestHandler>)requestHandler
{
    TFNAssert(userID != nil);
    TFNAssert(requestHandler != nil);

    dispatch_async(_queue, ^{
        // Increment the request ID for this request.
        NSInteger requestID = ++self->_requestID;

        [self _performInManagedObjectContext:^(NSManagedObjectContext *managedObjectContext) {
            // Batch pending impressions into new events.
            [self _batchImpressionsForUserID:userID requestHandler:requestHandler managedObjectContext:managedObjectContext];
        }];

        __block NSString *outgoingEvents = nil;
        [self _performInManagedObjectContext:^(NSManagedObjectContext *managedObjectContext) {
            // Collect events to be scribe this request.
            outgoingEvents = [self _flushEventsWithRequestID:requestID userID:userID managedObjectContext:managedObjectContext];
        }];

        if (!outgoingEvents) {
            NSDictionary *userInfo = token ? @{TFSScribeFlushTokenInfoKey: token} : nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:TFSScribeFlushNotification object:self userInfo:userInfo];
            });
        } else {
            [requestHandler handleScribeOutgoingEvents:outgoingEvents userID:userID completionHandler:^(TFSScribeServiceRequestDisposition disposition) {

                [self _performInManagedObjectContext:^(NSManagedObjectContext *managedObjectContext) {
                    [self _didFlushEventsWithRequestID:requestID disposition:disposition userID:userID managedObjectContext:managedObjectContext];
                }];
                NSDictionary *userInfo = token ? @{TFSScribeFlushTokenInfoKey: token} : nil;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:TFSScribeFlushNotification object:self userInfo:userInfo];
                });
            }];
        }
    });
}

- (void)_batchImpressionsForUserID:(NSString *)userID requestHandler:(id<TFSScribeRequestHandler>)requestHandler managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:TFSScribeImpressionEntityName];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"userID == %@", userID];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES]];

    NSError *error = nil;
    NSArray *impressions = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!impressions) {
        [self _handleScribeError:error];
        return;
    }
    if ([impressions count] == 0) {
        return;
    }

    if ([requestHandler respondsToSelector:@selector(handleImpressionsBatch:batchedImpressionHandler:)]) {
        NSDate *timestamp = [NSDate date];
        [requestHandler handleImpressionsBatch:impressions batchedImpressionHandler:^(id<TFSScribeEventParameters> eventParameters) {
            [self _enqueueEvent:eventParameters timestamp:timestamp managedObjectContext:managedObjectContext];
        }];
    }

    [impressions enumerateObjectsUsingBlock:^(TFSScribeImpression *impression, NSUInteger idx, BOOL *stop) {
        [managedObjectContext deleteObject:impression];
    }];
}

- (NSString *)_flushEventsWithRequestID:(NSInteger)requestID userID:(NSString *)userID managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:TFSScribeEventEntityName];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(userID == %@) AND (requestID == 0)", userID];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]];
    fetchRequest.fetchLimit = MAXIMUM_SCRIBE_ITEMS_PER_FLUSH;

    NSError *error = nil;
    NSArray *events = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!events) {
        [self _handleScribeError:error];
        return nil;
    }
    if ([events count] == 0) {
        return nil;
    }

    __block NSUInteger len = 1;
    [events enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(TFSScribeEvent *event, NSUInteger idx, BOOL *stop) {
        event.requestID = @(requestID);
        len += [event.content length] + 1;
    }];

    char openBracket = '[';
    char closeBracket = ']';
    char comma = ',';
    NSMutableData *data = [[NSMutableData alloc] initWithCapacity:len];
    [data appendBytes:&openBracket length:1];
    [events enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(TFSScribeEvent *event, NSUInteger idx, BOOL *stop) {
        [data appendData:event.content];
        if (idx > 0) {
            [data appendBytes:&comma length:1];
        }
    }];
    [data appendBytes:&closeBracket length:1];

    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (void)_didFlushEventsWithRequestID:(NSInteger)requestID disposition:(TFSScribeServiceRequestDisposition)disposition userID:(NSString *)userID managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:TFSScribeEventEntityName];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(userID == %@) AND (requestID == %i)", userID, requestID];

    NSError *error = nil;
    NSArray *events = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!events) {
        [self _handleScribeError:error];
        return;
    }

    switch (disposition) {
        case TFSScribeServiceRequestDispositionSuccess: {
            // The request completed successfully, so remove the events from the database.
            [events enumerateObjectsUsingBlock:^(TFSScribeEvent *event, NSUInteger idx, BOOL *stop) {
                [managedObjectContext deleteObject:event];
            }];
        } break;

        case TFSScribeServiceRequestDispositionClientError: {
            // If the request was canceled or if there was a network issue that prevented
            // the request from completing, retry the events later.
            [events enumerateObjectsUsingBlock:^(TFSScribeEvent *event, NSUInteger idx, BOOL *stop) {
                event.requestID = @0;
            }];
        } break;

        case TFSScribeServiceRequestDispositionServerError: {
            // If there was an error from the server or OAuth credentials were missing,
            // retry later, but also increase the retry count to help deduplicate scribe
            // events and to prevent repeated retries of bad data.
            [events enumerateObjectsUsingBlock:^(TFSScribeEvent *event, NSUInteger idx, BOOL *stop) {
                NSInteger updatedRetryCount = [event.retryCount integerValue] + 1;
                if (updatedRetryCount >= MAXIMUM_SCRIBE_RETRIES) {
                    [managedObjectContext deleteObject:event];
                } else {
                    event.requestID = @0;
                    event.retryCount = @(updatedRetryCount);
                }
            }];
        } break;
    }
}

- (void)deleteUserID:(NSString *)userID
{
    TFNAssert(userID);

    if ([userID longLongValue] == 0) {
        return;
    }

    dispatch_async(_queue, ^{
        [self _performInManagedObjectContext:^(NSManagedObjectContext *managedObjectContext) {
            [self _deleteEventsForUserID:userID managedObjectContext:managedObjectContext];
            [self _deleteImpressionsForUserID:userID managedObjectContext:managedObjectContext];
        }];
    });
}

- (void)_deleteEventsForUserID:(NSString *)userID managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:TFSScribeEventEntityName];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"userID == %@", userID];

    NSError *error = nil;
    NSArray *events = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!events) {
        [self _handleScribeError:error];
        return;
    }

    [events enumerateObjectsUsingBlock:^(TFSScribeEvent *event, NSUInteger idx, BOOL *stop) {
        [managedObjectContext deleteObject:event];
    }];
}

- (void)_deleteImpressionsForUserID:(NSString *)userID managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:TFSScribeImpressionEntityName];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"userID == %@", userID];

    NSError *error = nil;
    NSArray *impressions = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!impressions) {
        [self _handleScribeError:error];
        return;
    }
    [impressions enumerateObjectsUsingBlock:^(TFSScribeImpression *impression, NSUInteger idx, BOOL *stop) {
        [managedObjectContext deleteObject:impression];
    }];
}

#pragma mark - Data store

- (void)_setupManagedObjectContext
{
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[self _modelURL]];

    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];

    if (_storeURL) {
        NSDictionary *options = @{ NSSQLitePragmasOption: @{@"journal_mode": @"WAL"} };
        if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:_storeURL options:options error:NULL]) {
            // If the coordinator fails to add the persistent store, remove
            // the database files and try again.
            [self _removePersistentStore];

            NSError *error = nil;
            if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:_storeURL options:options error:&error]) {
                [self _handleScribeError:error];
                return;
            }
        }
    } else {
        NSError *error = nil;
        if (![persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error]) {
            [self _handleScribeError:error];
            return;
        }
    }

    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    _managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
    _managedObjectContext.undoManager = nil;
}

- (void)_performInManagedObjectContext:(void (^)(NSManagedObjectContext *managedObjectContext))block
{
    if (!_managedObjectContext || !block) {
        return;
    }

    [_managedObjectContext performBlockAndWait:^{
        @autoreleasepool {
            block(self->_managedObjectContext);
        }
        if ([self->_managedObjectContext hasChanges]) {
            NSError *error = nil;
            if (![self->_managedObjectContext save:&error]) {
                [self _handleScribeError:error];
            }
        }
        [self->_managedObjectContext reset];
    }];
}

- (void)_removePersistentStore
{
    [[NSFileManager defaultManager] removeItemAtURL:_storeURL error:NULL];

    NSString *storeShmPath = [[NSString alloc] initWithFormat:@"%@-shm", _storeURL.absoluteString];
    NSURL *storeShmURL = [[NSURL alloc] initWithString:storeShmPath];
    [[NSFileManager defaultManager] removeItemAtURL:storeShmURL error:NULL];

    NSString *storeWalPath = [[NSString alloc] initWithFormat:@"%@-wal", _storeURL.absoluteString];
    NSURL *storeWalURL = [[NSURL alloc] initWithString:storeWalPath];
    [[NSFileManager defaultManager] removeItemAtURL:storeWalURL error:NULL];
}

- (void)_resetScribeEvents
{
    [self _performInManagedObjectContext:^(NSManagedObjectContext *managedObjectContext) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:TFSScribeEventEntityName];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"requestID > 0"];

        NSError *error = nil;
        NSArray *events = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (!events) {
            [self _handleScribeError:error];
            return;
        }

        [events enumerateObjectsUsingBlock:^(TFSScribeEvent *event, NSUInteger idx, BOOL *stop) {
            event.requestID = @0;
        }];
    }];
}

#if UIAUTOMATION
- (void)clearScribeDatabase
{
    [self _performInManagedObjectContext:^(NSManagedObjectContext *managedObjectContext) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:TFSScribeEventEntityName];
        NSError *error = nil;
        NSArray *events = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (!events) {
            [self _handleScribeError:error];
        } else {
            [events enumerateObjectsUsingBlock:^(TFSScribeEvent *event, NSUInteger idx, BOOL *stop) {
                [_managedObjectContext deleteObject:event];
            }];
        }

        fetchRequest = [NSFetchRequest fetchRequestWithEntityName:TFSScribeImpressionEntityName];
        NSArray *impressions = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (!impressions) {
            [self _handleScribeError:error];
        } else {
            [impressions enumerateObjectsUsingBlock:^(TFSScribeImpression *impression, NSUInteger idx, BOOL *stop) {
                [_managedObjectContext deleteObject:impression];
            }];
        }
    }];
}
#endif

#pragma mark - Private methods

- (void)_handleScribeError:(NSError *)error
{
    [self.errorDelegate scribeService:self didEncounterError:error];
}

- (NSURL *)_modelURL
{
    if (_modelURL) {
        return _modelURL;
    } else {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSURL *modelURL = [bundle URLForResource:@"TFSScribe" withExtension:@"momd"];
        return modelURL;
    }
}

@end
