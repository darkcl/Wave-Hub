//
//  MusicTableViewCell.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 14/7/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import "MusicTableViewCell.h"
#import <DLImageLoader/DLImageLoader.h>
#import <FontAwesomeKit/FAKFontAwesome.h>
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

- (NSString *)timeFormatted:(int)totalMillSeconds{
    
    int totalSeconds = totalMillSeconds/ 1000;
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
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

- (void)setInfo:(WHTrackModel *)info isCurrentlyPlaying:(BOOL)isCurrentlyPlaying{
    trackInfo = info;
    
    self.titleLabel.text = info.trackTitle;
    self.authorLabel.text = info.author ? info.author : @"";
    self.durationLabel.text = [self timeFormatted:(int)info.duration];
    
    self.progressView.hidden = YES;
    if (isCurrentlyPlaying) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateProgress:)
                                                     name:WHSoundProgressDidChangeNotifiction
                                                   object:nil];
        
        self.progressView.hidden = NO;
        self.progressView.progress = [[WHSoundManager sharedManager] playingTrack].progress;
        
        FAKFontAwesome *buttonIcon = [FAKFontAwesome pauseIconWithSize:17];
        [buttonIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
        [self.togglePlayPauseButton setAttributedTitle:buttonIcon.attributedString forState:UIControlStateNormal];
    }else{
        self.progressView.hidden = YES;
        self.progressView.progress = 0.0;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        FAKFontAwesome *buttonIcon =  [FAKFontAwesome playIconWithSize:17];
        [buttonIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
        [self.togglePlayPauseButton setAttributedTitle:buttonIcon.attributedString forState:UIControlStateNormal];
    }
}

- (void)updateProgress:(NSNotification *)info{
    if ([info.object isKindOfClass:[NSNumber class]]) {
        NSNumber *aNumber = (NSNumber *)info.object;
        float progress = [aNumber floatValue];
        [self.progressView setProgress:progress animated:NO];
    }
}

- (IBAction)togglePlayPauseButtonPressed:(id)sender {
    if (_cellDelegate && [_cellDelegate respondsToSelector:@selector(didTogglePlayPause:)]) {
        [_cellDelegate didTogglePlayPause:trackInfo];
    }
}

@end
