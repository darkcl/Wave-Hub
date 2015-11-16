//
//  UIViewController+WaveHubAddition.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 16/11/15.
//  Copyright © 2015 Memory Leaks. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WHContainerViewController.h"

@interface UIViewController (WaveHubAddition)

@property(nonatomic,readonly,retain) WHContainerViewController *containerViewController;

@end
