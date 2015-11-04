//
//  WHAppDelegate.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 11/4/15
//  Copyright (c) 2015 Memory Leaks. All rights reserved.
//

#import "WHAppDelegate.h"
#import "WHRootViewController.h"

@implementation WHAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions{
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    WHRootViewController *rootVC = [[WHRootViewController alloc] initWithNibName:@"WHRootViewController" bundle:nil];
    UINavigationController *rootNav = [[UINavigationController alloc] initWithRootViewController:rootVC];
    [self.window setRootViewController:rootNav];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
