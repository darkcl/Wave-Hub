//
//  WHFavouriteDelegate.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 5/1/16.
//  Copyright © 2016 Memory Leaks. All rights reserved.
//

@class MyFavourite;

@protocol WHFavouriteDelegate <NSObject>

@required
- (void)didUpdateFavourite:(MyFavourite *)info;

@end
