//
//  DashBoardPlaylistsTableViewCell.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 28/12/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import "DashBoardPlaylistsTableViewCell.h"
#import "DashBoardPlaylistCollectionViewCell.h"

@implementation DashBoardPlaylistsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setInfo:(NSArray <WHPlaylistModel *> *)info{
    playlists = info;
    [self.collectionView registerNib:[UINib nibWithNibName:@"DashBoardPlaylistCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"DashBoardPlaylistCollectionViewCell"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView reloadData];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 15, 0, 0);
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return playlists.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DashBoardPlaylistCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DashBoardPlaylistCollectionViewCell" forIndexPath:indexPath];
    
    // Configure the cell
    WHPlaylistModel *info = playlists[indexPath.row];
    [cell setInfo:info];
    
    
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    DashBoardPlaylistCollectionViewCell *dashboardCell = (DashBoardPlaylistCollectionViewCell *)cell;
    [dashboardCell cancelLoadImage];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(160, 195);
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.didSelectPlaylist) {
        self.didSelectPlaylist(playlists[indexPath.row]);
    }
}

@end
