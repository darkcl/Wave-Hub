//
//  DashBoardViewController.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 9/11/2016.
//  Copyright © 2016 Memory Leaks. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DashBoardPlayingType) {
    DashBoardPlayingTypeUnknown,
    DashBoardPlayingTypeFavorite,
    DashBoardPlayingTypeActivity,
    DashBoardPlayingTypePlaylist,
    DashBoardPlayingTypeLocalFiles
};

@interface DashBoardViewController : UIViewController{
    DashBoardPlayingType playingType;
}

- (void)reloadFavorite;

#pragma mark - Shortcuts

- (void)goToFavorite;
- (void)goToPlaylist;
- (void)goToWhatsNew;

@end
