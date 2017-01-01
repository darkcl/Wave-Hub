//
//  DashboardWhatsNewTableViewCell.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 25/12/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WHTrackModel;

@interface DashboardWhatsNewTableViewCell : UITableViewCell{
    WHTrackModel *trackInfo;
    
    NSString *tempUrl;
}

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *remarkLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;


- (void)setInfo:(WHTrackModel *)info;
- (void)cancelImageLoad;

@end
