//
//  WHFavouriteTableViewController.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 5/11/15.
//  Copyright © 2015 Memory Leaks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WHFavouriteDelegate.h"
@interface WHFavouriteTableViewController : UITableViewController{
    MyFavourite *favourite;
}

@property (assign) id<WHFavouriteDelegate> delegate;

@end
