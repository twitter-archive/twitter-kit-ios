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

#import "TWTRCoreLanguage.h"

@implementation TWTRCoreLanguage

+ (NSString *)preferredLanguage
{
    static NSString *preferred;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // We are using preferredLanguages instead of preferredLocalizations
        // http://mjtsai.com/blog/2014/12/09/nslocale-preferredlanguages-vs-nsbundle-preferredlocalizations/
        // which will show return the OS's preferred language, not the app's language necessarly.
        // If the OS was in German and the App in English, this method will return "German".
        // (MD) We might want to obey the app's preference but for now I am leaving the same behavior;
        // just centralizing this call.
        preferred = [[NSLocale preferredLanguages] firstObject];
    });

    return preferred;
}

@end
