//
//  DashboardWhatsNewTableViewCell.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 25/12/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import "DashboardWhatsNewTableViewCell.h"

#import "WHTrackModel.h"

#import "UIImage+WaveHubAddition.h"

#import <DLImageLoader/DLImageLoader.h>

@implementation DashboardWhatsNewTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)startLoadingCover:(NSString *)url{
    
    if (url != nil && ![url isKindOfClass:[NSNull class]]) {
        tempUrl = [url stringByReplacingOccurrencesOfString:@"-large" withString:@"-t500x500"];
        [[DLImageLoader sharedInstance] imageFromUrl:tempUrl
                                           completed:^(NSError *error, UIImage *image) {
                                               if (error == nil && image != nil) {
                                                   self.coverImageView.image = image;
                                               }else{
                                                   self.coverImageView.image = [UIImage musicPlaceHolder];
                                               }
                                           }];
    }
}

- (NSString *)timeFormatted:(int)totalMillSeconds{
    
    int totalSeconds = totalMillSeconds/ 1000;
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

- (void)setInfo:(WHTrackModel *)info{
    trackInfo = info;
    
    if ([trackInfo isEqual:[WHSoundManager sharedManager].playingTrack]) {
        self.titleLabel.textColor = [UIColor wh_playingLabelColor];
        self.remarkLabel.textColor = [UIColor wh_playingLabelColor];
        
    }else{
        self.titleLabel.textColor = [UIColor wh_songTitleColor];
        self.remarkLabel.textColor = [UIColor wh_songTitleColor];
    }
    
    self.coverImageView.image = [UIImage musicPlaceHolder];
    self.userImageView.image = nil;
    
    self.titleLabel.text = info.trackTitle;
    self.userNameLabel.text = info.author ? info.author : @"";
    self.remarkLabel.text = [self timeFormatted:(int)info.duration];
    
    [self startLoadingCover:info.albumCoverUrl];
    
    [[DLImageLoader sharedInstance] imageFromUrl:info.userImageUrl
                                       completed:^(NSError *error, UIImage *image) {
                                           if (error == nil && image != nil) {
                                               self.userImageView.image = image;
                                           }else{
                                               self.userImageView.image = nil;
                                           }
                                       }];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)cancelImageLoad{
    [[DLImageLoader sharedInstance] cancelOperation:tempUrl];
    [[DLImageLoader sharedInstance] cancelOperation:trackInfo.userImageUrl];
}

@end
