//
//  UserProfileViewController.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 17/7/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WHSoundCloudUser, WHTrackModel;

@interface UserProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, WHSoundManagerDelegate, WHSoundManagerDatasource> {
    WHSoundCloudUser *userInfo;
    
    NSArray <WHTrackModel *> *userTracks;
}

- (id)initWithUser:(WHSoundCloudUser *)aUser;

@end
