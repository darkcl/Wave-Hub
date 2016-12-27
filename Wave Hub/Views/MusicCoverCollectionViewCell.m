//
//  MusicCoverCollectionViewCell.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 27/12/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import "MusicCoverCollectionViewCell.h"

#import <DLImageLoader/DLImageLoader.h>

#import "UIImage+WaveHubAddition.h"

@implementation MusicCoverCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setInfo:(WHTrackModel *)info{
    if (info.trackType != WHTrackTypePlaceHolder) {
        trackInfo = info;
        self.loadingIndicator.hidden = YES;
        self.coverImageView.image = nil;
        
        if ([info.albumCoverUrl isKindOfClass:[NSString class]]) {
            [[DLImageLoader sharedInstance] imageFromUrl:[info.albumCoverUrl  stringByReplacingOccurrencesOfString:@"-large" withString:@"-t500x500"]
                                               completed:^(NSError *error, UIImage *image) {
                                                   if (error == nil && image != nil) {
                                                       self.coverImageView.image = image;
                                                   }else{
                                                       self.coverImageView.image = [UIImage musicPlaceHolder];                                               }
                                               }];
        }else{
            self.coverImageView.image = [UIImage musicPlaceHolder];
        }
        
        
    }else{
        self.coverImageView.image = nil;
        self.loadingIndicator.hidden = YES;
    }
}

- (void)cancelImageLoad{
    if (trackInfo.trackType != WHTrackTypePlaceHolder) {
        if ([trackInfo.albumCoverUrl isKindOfClass:[NSString class]]) {
            [[DLImageLoader sharedInstance] cancelOperation:[trackInfo.albumCoverUrl  stringByReplacingOccurrencesOfString:@"-large" withString:@"-t500x500"]];
        }
        
    }else{
        
    }
}

@end
