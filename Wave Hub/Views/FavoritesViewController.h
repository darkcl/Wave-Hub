//
//  RootViewController.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 13/7/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicTableViewCell.h"

@interface FavoritesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, WHSoundManagerDatasource, MusicTableViewCellDelegate, YSLTransitionAnimatorDataSource> {
    NSArray <WHTrackModel *> *favourite;
    
    WHTrackModel *currentPlayingTrack;
}

- (id)initWithFavorites:(NSArray <WHTrackModel *> *)songs;

@end
