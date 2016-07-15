//
//  WHDatabaseManager.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 13/11/15.
//  Copyright © 2015 Memory Leaks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YapDatabase/YapDatabase.h>

@class MyFavourite;

typedef void(^DatabaseReturn)(id result);

@interface WHDatabaseManager : NSObject{
    YapDatabase *db;
}

+ (instancetype)sharedManager;

- (void)insertSongs:(NSArray *)songs;
- (void)readSongs:(DatabaseReturn)successBlock;

- (void)creatNewPlaylistWithName:(NSString *)playlistName songs:(NSArray *)songs;
- (void)readPlaylists:(DatabaseReturn)successBlock;

//- (void)saveMyFavourite:(MyFavourite *)favourite;
//- (void)readMyFavourite:(DatabaseReturn)successBlock;

- (void)saveTrackFromFavouriteArray:(NSArray <WHTrackModel *> *)favourites;

- (void)readTrackFromFavourite:(DatabaseReturn)successBlock;

@end
