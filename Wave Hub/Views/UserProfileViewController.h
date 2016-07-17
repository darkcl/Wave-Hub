//
//  UserProfileViewController.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 17/7/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicTableViewCell.h"
@class WHSoundCloudUser, WHTrackModel;

@interface UserProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, WHSoundManagerDelegate, WHSoundManagerDatasource, MusicTableViewCellDelegate> {
    WHSoundCloudUser *userInfo;
    
    NSArray <WHTrackModel *> *userTracks;
    
    float currentPlayingProgress;
    NSInteger currentPlayingIndex;
}

- (id)initWithUser:(WHSoundCloudUser *)aUser;

@end
