//
//  WHContainerViewController.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 16/11/15.
//  Copyright © 2015 Memory Leaks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHContainerViewController : UIViewController{
    UIViewController *contentVC;
}

- (id)initWithContentViewController:(UIViewController *)contentViewController;

- (void)showPlayerView;
- (void)hidePlayerView;

@end
