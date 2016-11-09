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

- (void)setInfo:(WHTrackModel *)track{
    trackInfo = track;
    
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
