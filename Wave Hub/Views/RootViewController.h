//
//  RootViewController.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 13/7/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, WHSoundManagerDelegate> {
    MyFavourite *favourite;
    NPAudioStream *streamer;
    
    float currentPlayingProgress;
    NSInteger currentPlayingIndex;
}

@property (assign) id<WHFavouriteDelegate> delegate;

@end
