//
//  WHRootViewController.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 4/11/15.
//  Copyright © 2015 Memory Leaks. All rights reserved.
//

#import "WHRootViewController.h"

@interface WHRootViewController ()

@end

@implementation WHRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setStatusBarStyle:UIStatusBarStyleContrast];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginSoundCloud:(id)sender {
    [[[WHWebrequestManager sharedManager] soundCloudPort]
     loginWithResult:^(BOOL success) {
         if (success) {
             NSLog(@"Login success");
         }else{
             NSLog(@"Login fail");
         }
     }
     usingParentVC:self
     redirectURL:@"wavehub://oauth"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
