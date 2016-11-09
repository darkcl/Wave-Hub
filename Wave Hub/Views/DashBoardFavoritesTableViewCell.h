//
//  DashBoardFavoritesTableViewCell.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 9/11/2016.
//  Copyright © 2016 Memory Leaks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DashBoardFavoritesTableViewCell : UITableViewCell <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>{
    NSArray <WHTrackModel *> *favorites;
}

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

- (void)setInfo:(NSArray <WHTrackModel *> *)tracks;

@end
