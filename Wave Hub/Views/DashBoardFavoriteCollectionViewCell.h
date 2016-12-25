//
//  DashBoardFavoriteCollectionViewCell.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 9/11/2016.
//  Copyright © 2016 Memory Leaks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DashBoardFavoriteCollectionViewCell : UICollectionViewCell{
    WHTrackModel *trackInfo;
    
    BOOL animate;
    BOOL animationCompleting;
    BOOL animationPending;
}

@property (strong, nonatomic) IBOutlet UIImageView *coverImageView;
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UILabel *songNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *playPauseToggleButton;

@property (nonatomic, strong) void(^didPressedPlay)(WHTrackModel *info);

- (void)setInfo:(WHTrackModel *)track;

- (void)cancelLoadImage;

@end
