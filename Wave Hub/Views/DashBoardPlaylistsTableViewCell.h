//
//  DashBoardPlaylistsTableViewCell.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 28/12/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DashBoardPlaylistsTableViewCell : UITableViewCell <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    NSArray <WHPlaylistModel *> *playlists;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (void)setInfo:(NSArray <WHPlaylistModel *> *)info;

@property (nonatomic, strong) void(^didSelectPlaylist)(WHPlaylistModel *track);

@end
