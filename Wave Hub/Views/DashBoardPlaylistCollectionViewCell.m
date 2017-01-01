//
//  DashBoardPlaylistCollectionViewCell.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 28/12/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import "DashBoardPlaylistCollectionViewCell.h"

#import <DLImageLoader/DLImageLoader.h>

#import "UIImage+WaveHubAddition.h"

@implementation DashBoardPlaylistCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setInfo:(WHPlaylistModel *)info{
    playlist = info;
    self.playlistTitleLabel.text = info.playlistTitle;
    if ([info.coverImageUrl isKindOfClass:[NSString class]] && info.coverImageUrl != nil) {
        [[DLImageLoader sharedInstance] imageFromUrl:info.coverImageUrl
                                           completed:^(NSError *error, UIImage *image) {
                                               if (error == nil && image != nil) {
                                                   self.coverImageView.image = image;
                                               }else{
                                                   self.coverImageView.image = [UIImage musicPlaceHolder];
                                               }
                                           }];
    }else{
        self.coverImageView.image = [UIImage musicPlaceHolder];
    }
    
    self.containerView.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0].CGColor;
    self.containerView.layer.shadowRadius = 3.0;
    self.containerView.layer.shadowOffset = CGSizeMake(0, 3);
    self.containerView.layer.shadowOpacity = 0.3f;
}

- (void)cancelLoadImage{
    if (playlist.coverImageUrl != nil) {
        [[DLImageLoader sharedInstance] cancelOperation:playlist.coverImageUrl];
    }
}

@end
