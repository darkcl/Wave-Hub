//
//  MusicCoverCollectionViewCell.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 27/12/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicCoverCollectionViewCell : UICollectionViewCell {
    WHTrackModel *trackInfo;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;

- (void)setInfo:(WHTrackModel *)info;

- (void)cancelImageLoad;

@end
