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

#import "TWTRScribeClientEventNamespace.h"
#import "TWTRScribeClientEventNamespace_Private.h"
#import "TWTRScribeEvent.h"

NSString *const TWTRScribeClientEventNamespaceEmptyValue = @"";
NSString *const TWTRScribeClientEventNamespaceClientKey = @"client";
NSString *const TWTRScribeClientEventNamespacePageKey = @"page";
NSString *const TWTRScribeClientEventNamespaceSectionKey = @"section";
NSString *const TWTRScribeClientEventNamespaceComponentKey = @"component";
NSString *const TWTRScribeClientEventNamespaceElementKey = @"element";
NSString *const TWTRScribeClientEventNamespaceActionKey = @"action";
NSString *const TWTRScribeClientEventNamespaceTimelineValue = @"timeline";
NSString *const TWTRScribeClientEventNamespacePlayerValue = @"player";
NSString *const TWTRScribeClientEventNamespaceInitialValue = @"initial";
NSString *const TWTRScribeClientEventNamespaceErrorComponent = @"authentication";
NSString *const TWTRScribeClientEventNamespaceErrorElement = @"credentials";
NSString *const TWTRScribeClientEventNamespaceErrorAction = @"error";
NSString *const TWTRScribeClientEventNamespaceCredentialsPage = @"credentials";
NSString *const TWTRScribeClientEventNamespaceImpressionAction = @"impression";
NSString *const TWTRScribeClientEventNamespaceShowAction = @"show";
NSString *const TWTRScribeClientEventNamespaceNavigateAction = @"navigate";
NSString *const TWTRScribeClientEventNamespaceDismissAction = @"dismiss";

@implementation TWTRScribeClientEventNamespace

- (instancetype)initWithClient:(NSString *)client page:(NSString *)page section:(NSString *)section component:(NSString *)component element:(NSString *)element action:(NSString *)action
{
    NSParameterAssert(client);
    NSParameterAssert(page);
    NSParameterAssert(section);
    NSParameterAssert(component);
    NSParameterAssert(element);
    NSParameterAssert(action);

    if (self = [super init]) {
        _client = client;
        _page = page;
        _section = section;
        _component = component;
        _element = element;
        _action = action;
    }

    return self;
}

#pragma mark - TWTRScribeSerializable
+ (NSString *)scribeKey
{
    return @"event_namespace";
}

- (NSDictionary *)dictionaryRepresentation
{
    return @{TWTRScribeClientEventNamespaceClientKey: self.client, TWTRScribeClientEventNamespacePageKey: self.page, TWTRScribeClientEventNamespaceSectionKey: self.section, TWTRScribeClientEventNamespaceComponentKey: self.component, TWTRScribeClientEventNamespaceElementKey: self.element, TWTRScribeClientEventNamespaceActionKey: self.action};
}

#pragma mark - Errors

+ (instancetype)errorNamespace
{
    return [[TWTRScribeClientEventNamespace alloc] initWithClient:TWTRScribeEventImpressionClient page:TWTRScribeEventImpressionPage section:TWTRScribeClientEventNamespaceTimelineValue component:TWTRScribeClientEventNamespaceErrorComponent element:TWTRScribeClientEventNamespaceErrorElement action:TWTRScribeClientEventNamespaceErrorAction];
}

#pragma mark - NSObject Protocol
- (BOOL)isEqual:(id)object
{
    if (object == nil || ![object isKindOfClass:[TWTRScribeClientEventNamespace class]]) {
        return NO;
    }

    TWTRScribeClientEventNamespace *namespace = object;

    return [self.client isEqualToString:namespace.client] && [self.page isEqualToString:namespace.page] && [self.section isEqualToString:namespace.section] && [self.component isEqualToString:namespace.component] && [self.element isEqualToString:namespace.element] && [self.action isEqualToString:namespace.action];
}

- (NSUInteger)hash
{
    return self.client.hash ^ self.page.hash ^ self.section.hash ^ self.component.hash ^ self.element.hash ^ self.action.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@:%@:%@:%@:%@:%@", self.client, self.page, self.section, self.component, self.element, self.action];
}

@end
