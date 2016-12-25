//
//  SplashViewController.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 25/12/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import "SplashViewController.h"

#import "WHAppDelegate.h"
#import "DashBoardViewController.h"
#import "ContainerViewController.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)loginSoundCloudButtonPressed:(id)sender {
    
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
         
         WHAppDelegate *appDelegate = (WHAppDelegate *)[[UIApplication sharedApplication] delegate];
         
         
         [appDelegate.window setRootViewController:container];
         [appDelegate.window makeKeyAndVisible];
     }
     failure:^(NSError *error) {
         [UIAlertView showWithTitle:error.localizedDescription
                            message:nil
                  cancelButtonTitle:@"OK"
                  otherButtonTitles:nil
                           tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
                               
                           }];
     }
     withViewController:self];
}

@end
