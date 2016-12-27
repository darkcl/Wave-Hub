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

- (void)insertSongs:(NSArray *)songs{
    YapDatabaseConnection *connection = [db newConnection];
    [self readSongs:^(NSArray *result) {
        if (result != nil && result.count != 0) {
            NSMutableArray *allSongs = [NSMutableArray arrayWithArray:result];
            [allSongs addObjectsFromArray:songs];
            [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
                [transaction setObject:allSongs forKey:@"songs" inCollection:@"wave_hub"];
            }];
        }
    }];
}

- (void)readSongs:(DatabaseReturn)successBlock{
    YapDatabaseConnection *connection = [db newConnection];
    [connection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
        NSArray *allSongs = [transaction objectForKey:@"songs" inCollection:@"wave_hub"];
        successBlock(allSongs);
    }];
}

- (void)creatNewPlaylistWithName:(NSString *)playlistName songs:(NSArray *)songs{
//    YapDatabaseConnection *connection = [db newConnection];
}

- (void)readPlaylists:(DatabaseReturn)successBlock{
//    YapDatabaseConnection *connection = [db newConnection];
}

- (void)saveMyFavourite:(MyFavourite *)favourite{
    YapDatabaseConnection *connection = [db newConnection];
    [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction) {
        [transaction setObject:favourite forKey:@"favourites" inCollection:@"wave_hub"];
    }];
}

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

@end
