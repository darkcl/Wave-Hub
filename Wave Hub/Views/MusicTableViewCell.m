//
//  MusicTableViewCell.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 14/7/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import "MusicTableViewCell.h"
#import <DLImageLoader/DLImageLoader.h>
#import "UIImage+WaveHubAddition.h"
@implementation MusicTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)startLoadingCover:(NSString *)url{
//    _coverImageView.alpha = 0.0;
    
    if (url != nil && ![url isKindOfClass:[NSNull class]]) {
        tempUrl = [url stringByReplacingOccurrencesOfString:@"-large" withString:@"-t500x500"];
        [[DLImageLoader sharedInstance] imageFromUrl:tempUrl
                                           completed:^(NSError *error, UIImage *image) {
                                               if (!error) {
                                                   NSString *loadingUrl = [url stringByReplacingOccurrencesOfString:@"-large" withString:@"-t500x500"];
                                                   if ([loadingUrl isEqualToString:self->tempUrl]) {
                                                       self.coverImageView.image = image;
                                                   }
                                               }
                                           }];
    }
}

- (void)cancelLoadingCover{
    self.coverImageView.image = [UIImage musicPlaceHolder];
    if (!tempUrl) {
        [[DLImageLoader sharedInstance] cancelOperation:tempUrl];
    }
}

- (void)setInfo:(WHTrackModel *)info{
    trackInfo = info;
}

- (IBAction)togglePlayPauseButtonPressed:(id)sender {
    if (_cellDelegate && [_cellDelegate respondsToSelector:@selector(didTogglePlayPause:)]) {
        [_cellDelegate didTogglePlayPause:trackInfo];
    }
}

@end
