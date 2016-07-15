//
//  MusicDetailViewController.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 15/7/2016.
//  Copyright © 2016 Memory Leaks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicDetailViewController : UIViewController<YSLTransitionAnimatorDataSource, WHSoundManagerDelegate> {
    UIImageView *transitionImageView;
    
    NSString *author;
    NSString *musicName;
    
    WHTrackModel *currentTrack;
}

- (id)initWithTrackInfo:(WHTrackModel *)info;

@end
