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

@end
