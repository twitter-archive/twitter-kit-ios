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

#import "TWTRRuntime.h"

@implementation TWTRRuntime

+ (BOOL)isRunningUnitTests
{
    static dispatch_once_t onceToken;
    static BOOL isTesting;

    dispatch_once(&onceToken, ^{
        // Testing: com.apple.xpc.launchd.oneshot.0x10000005.xctest
        // Normal: UIKitApplication:com.twitter.FabricSampleAppDev[0xd28f]
        NSString *XPCServiceName = [NSProcessInfo processInfo].environment[@"XPC_SERVICE_NAME"];
        if (XPCServiceName.length == 0) {
            // In case the service name variable ever is missing, default
            // to not being in testing mode
            isTesting = NO;
        } else {
            isTesting = ([XPCServiceName rangeOfString:@"xctest"].location != NSNotFound);
        }
    });

    return isTesting;
}

@end
