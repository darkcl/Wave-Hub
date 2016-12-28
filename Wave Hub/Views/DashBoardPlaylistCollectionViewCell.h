//
//  DashBoardPlaylistCollectionViewCell.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 28/12/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DashBoardPlaylistCollectionViewCell : UICollectionViewCell {
    WHPlaylistModel *playlist;
}
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *playlistTitleLabel;

- (void)setInfo:(WHPlaylistModel *)info;

- (void)cancelLoadImage;

@end
