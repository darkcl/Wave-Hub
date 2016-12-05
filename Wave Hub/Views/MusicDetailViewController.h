//
//  MusicDetailViewController.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 15/7/2016.
//  Copyright © 2016 Memory Leaks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicTableViewCell.h"
@class WHSoundCloudUser, WHTrackModel;

@interface MusicDetailViewController : UIViewController<YSLTransitionAnimatorDataSource, UIViewControllerTransitioningDelegate, UITableViewDelegate, UITableViewDataSource, WHSoundManagerDatasource, MusicTableViewCellDelegate> {
    UIImageView *transitionImageView;
    
    WHTrackModel *trackInfo;
    WHTrackModel *currentTrack;
    
    NSArray <WHTrackModel *> *sourceTracks;
    
    WHSoundCloudUser *userInfo;
    
    NSArray <WHTrackModel *> *userTracks;
    WHTrackModel *currentPlayingTrack;
    
    WHSoundCloudUser *currentUser;
}

- (id)initWithTrackInfo:(WHTrackModel *)info withDataSources:(NSArray <WHTrackModel *> *)tracks;

@end
