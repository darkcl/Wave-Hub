//
//  DashBoardFavoriteCollectionViewCell.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 9/11/2016.
//  Copyright © 2016 Memory Leaks. All rights reserved.
//

#import "DashBoardFavoriteCollectionViewCell.h"

#import <DLImageLoader/DLImageLoader.h>

#import "UIImage+WaveHubAddition.h"

@implementation DashBoardFavoriteCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - Spinning

- (void)rotateImageView
{
    [UIView animateWithDuration:3.0 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self.coverImageView setTransform:CGAffineTransformRotate(self.coverImageView.transform, M_PI_2)];
    }completion:^(BOOL finished){
        if (finished && [self->trackInfo isEqual:[WHSoundManager sharedManager].playingTrack]) {
            [self rotateImageView];
        }else{
            [self.coverImageView.layer removeAllAnimations];
            self.coverImageView.transform = CGAffineTransformIdentity;
        }
    }];
}

- (void)setInfo:(WHTrackModel *)track{
    trackInfo = track;
    
    [self.coverImageView.layer removeAllAnimations];
    self.coverImageView.transform = CGAffineTransformIdentity;
    
    if ([trackInfo isEqual:[WHSoundManager sharedManager].playingTrack]) {
        self.authorLabel.textColor = [UIColor wh_playingLabelColor];
        self.songNameLabel.textColor = [UIColor wh_playingLabelColor];
        [self rotateImageView];
        
    }else{
        self.authorLabel.textColor = [UIColor wh_userTitleColor];
        self.songNameLabel.textColor = [UIColor wh_songTitleColor];
        [self.coverImageView.layer removeAllAnimations];
        self.coverImageView.transform = CGAffineTransformIdentity;
    }
    
    self.authorLabel.text = track.author;
    self.songNameLabel.text = track.trackTitle;
    
    if (track.albumCoverImage != nil){
        self.coverImageView.image = track.albumCoverImage;
    }else{
        if ([track.albumCoverUrl isKindOfClass:[NSString class]]) {
            [[DLImageLoader sharedInstance] imageFromUrl:track.albumCoverUrl
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
    }
}

- (void)cancelLoadImage{
    self.coverImageView.image = [UIImage musicPlaceHolder];
    if ([trackInfo.albumCoverUrl isKindOfClass:[NSString class]]) {
        
        
        [[DLImageLoader sharedInstance] cancelOperation:trackInfo.albumCoverUrl];
    }
}

- (IBAction)playPauseTogglePressed:(id)sender {
    if (self.didPressedPlay) {
        self.didPressedPlay(trackInfo);
    }
}

@end
