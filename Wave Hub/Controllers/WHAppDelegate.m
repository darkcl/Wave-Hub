//
//  WHAppDelegate.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 11/4/15
//  Copyright (c) 2015 Memory Leaks. All rights reserved.
//

#import "WHAppDelegate.h"
#import "WHRootViewController.h"
#import "WHDashBoardViewController.h"
#import "WHFavouriteTableViewController.h"
#import "WHPlaylistTableViewController.h"
#import "WHLocalSongsTableViewController.h"
#import "WHContainerViewController.h"

#import <FontAwesomeKit/FontAwesomeKit.h>

@implementation WHAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions{
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [Chameleon setGlobalThemeUsingPrimaryColor:[UIColor colorWithHexString:@"#ff7700"] withContentStyle:UIContentStyleContrast];
    WHDashBoardViewController *rootVC = [[WHDashBoardViewController alloc] init];
    [rootVC.tabBar setTranslucent:YES];
    
    WHFavouriteTableViewController *favouriteVC = [[WHFavouriteTableViewController alloc] init];
    UINavigationController *favNav = [[UINavigationController alloc] initWithRootViewController:favouriteVC];
    favNav.hidesNavigationBarHairline = NO;
    
    favouriteVC.title = @"Favourite";
    FAKFontAwesome *starIcon = [FAKFontAwesome starIconWithSize:25];
    favNav.tabBarItem.image = [starIcon imageWithSize:CGSizeMake(40.0, 40.0)];
    
    WHPlaylistTableViewController *playlistVC = [[WHPlaylistTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *playlistNav = [[UINavigationController alloc] initWithRootViewController:playlistVC];
    playlistNav.hidesNavigationBarHairline = NO;
    
    playlistVC.title = @"Playlist";
    FAKFontAwesome *playlistIcon = [FAKFontAwesome musicIconWithSize:25];
    playlistNav.tabBarItem.image = [playlistIcon imageWithSize:CGSizeMake(40.0, 40.0)];
    
    WHLocalSongsTableViewController *localVC = [[WHLocalSongsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *localSongNav = [[UINavigationController alloc] initWithRootViewController:localVC];
    localSongNav.hidesNavigationBarHairline = NO;
    
    localVC.title = @"Local Songs";
    FAKFoundationIcons *phoneIcon = [FAKFoundationIcons usbIconWithSize:25];
    localSongNav.tabBarItem.image = [phoneIcon imageWithSize:CGSizeMake(40.0, 40.0)];
    
    WHContainerViewController *favVC = [[WHContainerViewController alloc] initWithContentViewController:favNav];
    favVC.title = @"Favourite";
    favVC.tabBarItem.image = [starIcon imageWithSize:CGSizeMake(40.0, 40.0)];
    
    WHContainerViewController *platlistVC = [[WHContainerViewController alloc] initWithContentViewController:playlistNav];
    platlistVC.title = @"Playlist";
    platlistVC.tabBarItem.image = [playlistIcon imageWithSize:CGSizeMake(40.0, 40.0)];
    
    WHContainerViewController *localSongVC = [[WHContainerViewController alloc] initWithContentViewController:localSongNav];
    localSongVC.title = @"Local Songs";
    localSongVC.tabBarItem.image = [phoneIcon imageWithSize:CGSizeMake(40.0, 40.0)];
    
    rootVC.viewControllers = @[favVC,
                               platlistVC,
                               localSongVC];
    
    [self.window setRootViewController:rootVC];
    [self.window makeKeyAndVisible];
    
    [[WHWebrequestManager sharedManager]
     loginToSoundCloud:^(id responseObject) {
         
     }
     failure:^(NSError *error) {
         
     }
     withViewController:rootVC];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil]];
    return YES;
}

@end
