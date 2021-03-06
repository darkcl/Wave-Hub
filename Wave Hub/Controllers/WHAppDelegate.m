//
//  WHAppDelegate.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 11/4/15
//  Copyright (c) 2015 Memory Leaks. All rights reserved.
//

#import "WHAppDelegate.h"
#import "DashBoardViewController.h"
#import "ContainerViewController.h"

#import "SplashViewController.h"

#import <FontAwesomeKit/FontAwesomeKit.h>

@implementation WHAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions{
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    SplashViewController *splashVC = [[SplashViewController alloc] initWithNibName:@"SplashViewController" bundle:nil];
    [self.window setRootViewController:splashVC];
    [self.window makeKeyAndVisible];
    
    [[WHWebrequestManager sharedManager]
     loginToSoundCloud:^(id responseObject) {
         DashBoardViewController *rootVC = [[DashBoardViewController alloc] initWithNibName:@"DashBoardViewController" bundle:nil];
         UINavigationController *rootNav = [[UINavigationController alloc] initWithRootViewController:rootVC];
         
         [rootNav.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
         [rootNav.navigationBar setShadowImage:[[UIImage alloc] init]];
         rootNav.navigationBar.barTintColor = [UIColor whiteColor];
         
         rootNav.delegate = self;
         [rootNav.navigationBar setTranslucent:NO];
         
         ContainerViewController *container = [[ContainerViewController alloc] initWithContentViewController:rootNav];
         
         [self.window setRootViewController:container];
         [self.window makeKeyAndVisible];
     }
     failure:^(NSError *error) {
         [UIAlertView showWithTitle:error.localizedDescription
                            message:nil
                  cancelButtonTitle:@"OK"
                  otherButtonTitles:nil
                           tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
                               
                           }];
     }
     withViewController:splashVC];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    UIMutableUserNotificationAction *action1;
    action1 = [[UIMutableUserNotificationAction alloc] init];
    [action1 setActivationMode:UIUserNotificationActivationModeBackground];
    [action1 setTitle:@"Like"];
    [action1 setIdentifier:@"com.darkcl.wave-hub.like"];
    [action1 setDestructive:NO];
    [action1 setAuthenticationRequired:NO];
    
    UIMutableUserNotificationAction *action2;
    action2 = [[UIMutableUserNotificationAction alloc] init];
    [action2 setActivationMode:UIUserNotificationActivationModeBackground];
    [action2 setTitle:@"Dislike"];
    [action2 setIdentifier:@"com.darkcl.wave-hub.dislike"];
    [action2 setDestructive:YES];
    [action2 setAuthenticationRequired:NO];
    
    UIMutableUserNotificationCategory *actionCategory;
    actionCategory = [[UIMutableUserNotificationCategory alloc] init];
    [actionCategory setIdentifier:@"ACTIONABLE"];
    [actionCategory setActions:@[action1, action2]
                    forContext:UIUserNotificationActionContextDefault];
    
    NSSet *categories = [NSSet setWithObject:actionCategory];
    UIUserNotificationType types = (UIUserNotificationTypeAlert|
                                    UIUserNotificationTypeSound|
                                    UIUserNotificationTypeBadge);
    
    UIUserNotificationSettings *settings;
    settings = [UIUserNotificationSettings settingsForTypes:types
                                                 categories:categories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    return YES;
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler {
    
    if ([identifier isEqualToString:@"com.darkcl.wave-hub.like"]) {
        
        NSLog(@"You chose like.");
    }
    else if ([identifier isEqualToString:@"com.darkcl.wave-hub.dislike"]) {
        
        NSLog(@"You chose dislike.");
    }
    if (completionHandler) {
        
        completionHandler();
    }
}
@end
