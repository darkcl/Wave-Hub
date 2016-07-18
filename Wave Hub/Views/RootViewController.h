//
//  RootViewController.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 13/7/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicTableViewCell.h"

@interface RootViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, WHSoundManagerDelegate, WHSoundManagerDatasource, MusicTableViewCellDelegate, YSLTransitionAnimatorDataSource> {
    NSArray <WHTrackModel *> *favourite;
    
    float currentPlayingProgress;
    NSInteger currentPlayingIndex;
}

@end
