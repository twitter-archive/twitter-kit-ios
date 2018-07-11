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

#import "TWTRSEFrameworkLazyLoading.h"
#import <Foundation/Foundation.h>
#include <dlfcn.h>

static void twtr_ensureFrameworkLoadedAtRuntime(NSString *frameworkName)
{
    NSString *path = [NSString stringWithFormat:@"/Library/Frameworks/%@.framework/%@", frameworkName, frameworkName];

    dlopen([path cStringUsingEncoding:NSASCIIStringEncoding], RTLD_NOW);
}

/**
 TwitterKit might not be able to impose these dependencies at compile time for the apps, so we can load them at runtime to make sure they're available, before any of their classes are used.
 */
void twtr_ensureFrameworksLoadedAtRuntime()
{
    twtr_ensureFrameworkLoadedAtRuntime(@"MapKit");
    twtr_ensureFrameworkLoadedAtRuntime(@"CoreLocation");
}
