//
//  WHDatabaseManager.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 13/11/15.
//  Copyright © 2015 Memory Leaks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YapDatabase/YapDatabase.h>

typedef void(^DatabaseReturn)(id result);

@interface WHDatabaseManager : NSObject{
    YapDatabase *db;
}

+ (instancetype)sharedManager;


#pragma mark - Favorite

- (void)saveTrackFromFavouriteArray:(NSArray <WHTrackModel *> *)favourites;

- (void)readTrackFromFavourite:(DatabaseReturn)successBlock;

- (void)addFavoriteTrack:(WHTrackModel *)aTrack;

- (void)removeFavoriteTrack:(WHTrackModel *)aTrack;

#pragma mark - Activity

- (void)saveTrackFromActivityArray:(NSArray <WHTrackModel *> *)activities;

- (void)readTrackFromActivity:(DatabaseReturn)successBlock;

- (void)addActivityTrack:(WHTrackModel *)aTrack;

- (void)removeActivityTrack:(WHTrackModel *)aTrack;

#pragma mark - Playlists

- (void)saveMyPlaylistsArray:(NSArray <WHPlaylistModel *> *)playlists;

- (void)readFromMyPlaylists:(DatabaseReturn)successBlock;

- (void)addPlaylist:(WHPlaylistModel *)aTrack;

- (void)removePlaylist:(WHPlaylistModel *)aTrack;

#pragma mark - Local Files

- (void)saveLocalTrack:(NSArray <WHTrackModel *> *)tracks;

- (void)readLocalTrack:(DatabaseReturn)successBlock;

- (void)updateLocalTrack:(WHTrackModel *)track;

@end
