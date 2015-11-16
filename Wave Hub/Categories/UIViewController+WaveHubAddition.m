//
//  UIViewController+WaveHubAddition.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 16/11/15.
//  Copyright © 2015 Memory Leaks. All rights reserved.
//

#import "UIViewController+WaveHubAddition.h"

@implementation UIViewController (WaveHubAddition)
@dynamic containerViewController;

- (WHContainerViewController *)containerViewController {
    id containerView = self;
    while (![containerView isKindOfClass:[WHContainerViewController class]] && containerView) {
        if ([containerView respondsToSelector:@selector(parentViewController)])
            containerView = [containerView parentViewController];
        if ([containerView respondsToSelector:@selector(splitViewController)] && !containerView)
            containerView = [containerView splitViewController];
    }
    return containerView;
}

@end
