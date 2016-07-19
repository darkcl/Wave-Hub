//
//  MusicDetailViewController.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 15/7/2016.
//  Copyright © 2016 Memory Leaks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicDetailViewController : UIViewController<YSLTransitionAnimatorDataSource, UIViewControllerTransitioningDelegate, WHSoundManagerDatasource> {
    UIImageView *transitionImageView;
    
    WHTrackModel *trackInfo;
    WHTrackModel *currentTrack;
    
    NSArray <WHTrackModel *> *sourceTracks;
}

- (id)initWithTrackInfo:(WHTrackModel *)info withDataSources:(NSArray <WHTrackModel *> *)tracks;

@end
