//
//  AppDelegate.m
//  DemoApp
//
//  Created by Steven Hepting on 4/5/17.
//  Copyright © 2017 Twitter. All rights reserved.
//

#import "AppDelegate.h"
#import <DCIntrospect_ARC/DCIntrospect.h>
#import <FLEX/FLEX.h>
#import <TwitterKit/TWTRKit.h>
#import "DemoApp-Swift.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *twitterConsumerKey = [info objectForKey:@"TwitterConsumerKey"];
    NSString *twitterConsumerSecret = [info objectForKey:@"TwitterConsumerSecret"];

    [[Twitter sharedInstance] startWithConsumerKey:twitterConsumerKey consumerSecret:twitterConsumerSecret];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[RootViewController alloc] init];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

#if TARGET_IPHONE_SIMULATOR
    [[DCIntrospect sharedIntrospector] start];
#endif

    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options
{
    return [[Twitter sharedInstance] application:app openURL:url options:options];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
