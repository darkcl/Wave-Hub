//
//  NowPlayingViewController.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 27/12/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NowPlayingViewController : UIViewController

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) void(^didAddFavorite)(WHTrackModel *aTrack);
@property (nonatomic, strong) void(^didRemoveFavorite)(WHTrackModel *aTrack);

@end
