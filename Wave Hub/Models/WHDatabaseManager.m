//
//  WHDatabaseManager.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 13/11/15.
//  Copyright © 2015 Memory Leaks. All rights reserved.
//

#import "WHDatabaseManager.h"
#import "WHTrackModel.h"

@implementation WHDatabaseManager

+ (instancetype)sharedManager
{
    static WHDatabaseManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init{
    if (self = [super init]) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"edit_with_risk.db"];
        db = [[YapDatabase alloc] initWithPath:dbPath];
    }
    return self;
}

#pragma mark - Favorite

- (void)saveTrackFromFavouriteArray:(NSArray <WHTrackModel *> *)favourites{
    YapDatabaseConnection *connection = [db newConnection];
    [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
       
        
        [transaction setObject:favourites forKey:@"favourites_track" inCollection:@"wave_hub"];
    }];
}

- (void)addFavoriteTrack:(WHTrackModel *)aTrack{
    YapDatabaseConnection *connection = [db newConnection];
    [connection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
        NSMutableArray *result = [NSMutableArray arrayWithArray:[transaction objectForKey:@"favourites_track" inCollection:@"wave_hub"]];
        [result insertObject:aTrack atIndex:0];
        [self saveTrackFromFavouriteArray:result];
    }];
}

- (void)removeFavoriteTrack:(WHTrackModel *)aTrack{
    YapDatabaseConnection *connection = [db newConnection];
    [connection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
        NSMutableArray *result = [NSMutableArray arrayWithArray:[transaction objectForKey:@"favourites_track" inCollection:@"wave_hub"]];
        [result removeObject:aTrack];
        [self saveTrackFromFavouriteArray:result];
    }];
}

- (void)readTrackFromFavourite:(DatabaseReturn)successBlock{
    YapDatabaseConnection *connection = [db newConnection];
    [connection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
        successBlock([transaction objectForKey:@"favourites_track" inCollection:@"wave_hub"]);
    }];
}

#pragma mark - Activity

- (void)saveTrackFromActivityArray:(NSArray <WHTrackModel *> *)activities{
    YapDatabaseConnection *connection = [db newConnection];
    [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
        [transaction setObject:activities forKey:@"activity_track" inCollection:@"wave_hub"];
    }];
}

- (void)readTrackFromActivity:(DatabaseReturn)successBlock{
    YapDatabaseConnection *connection = [db newConnection];
    [connection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
        successBlock([transaction objectForKey:@"activity_track" inCollection:@"wave_hub"]);
    }];
}

- (void)addActivityTrack:(WHTrackModel *)aTrack{
    
}

- (void)removeActivityTrack:(WHTrackModel *)aTrack{
    
}

#pragma mark - Playlists

- (void)saveMyPlaylistsArray:(NSArray <WHPlaylistModel *> *)playlists{
    YapDatabaseConnection *connection = [db newConnection];
    [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
        [transaction setObject:playlists forKey:@"my_play_list" inCollection:@"wave_hub"];
    }];
}

- (void)readFromMyPlaylists:(DatabaseReturn)successBlock{
    YapDatabaseConnection *connection = [db newConnection];
    [connection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
        successBlock([transaction objectForKey:@"my_play_list" inCollection:@"wave_hub"]);
    }];
}

- (void)addPlaylist:(WHPlaylistModel *)aPlaylist{
    YapDatabaseConnection *connection = [db newConnection];
    [connection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
        NSMutableArray *result = [NSMutableArray arrayWithArray:[transaction objectForKey:@"my_play_list" inCollection:@"wave_hub"]];
        [result insertObject:aPlaylist atIndex:0];
        [self saveMyPlaylistsArray:result];
    }];
}

- (void)removePlaylist:(WHPlaylistModel *)aPlaylist{
    YapDatabaseConnection *connection = [db newConnection];
    [connection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
        NSMutableArray *result = [NSMutableArray arrayWithArray:[transaction objectForKey:@"my_play_list" inCollection:@"wave_hub"]];
        [result removeObject:aPlaylist];
        [self saveMyPlaylistsArray:result];
    }];
}

#pragma mark - Local Track

- (void)saveLocalTrack:(NSArray <WHTrackModel *> *)tracks{
    YapDatabaseConnection *connection = [db newConnection];
    [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
        [transaction setObject:tracks forKey:@"local_file_list" inCollection:@"wave_hub"];
    }];
}

- (void)readLocalTrack:(DatabaseReturn)successBlock{
    YapDatabaseConnection *connection = [db newConnection];
    [connection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
        successBlock([transaction objectForKey:@"local_file_list" inCollection:@"wave_hub"]);
    }];
}

- (void)updateLocalTrack:(WHTrackModel *)track{
    YapDatabaseConnection *connection = [db newConnection];
    [connection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
        NSMutableArray *result = [NSMutableArray arrayWithArray:[transaction objectForKey:@"local_file_list" inCollection:@"wave_hub"]];
        if ([result containsObject:track]) {
            [result replaceObjectAtIndex:[result indexOfObject:track] withObject:track];
            [self saveLocalTrack:result];
        }
        
    }];
}

@end
