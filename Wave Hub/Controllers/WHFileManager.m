//
//  WHFileManager.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 30/12/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import "WHFileManager.h"

#import <FCFileManager/FCFileManager.h>

@implementation WHFileManager


+ (instancetype)sharedManager
{
    static WHFileManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}


- (void)fetchLocalTracks:(void(^)(NSArray <WHTrackModel *> *newTracks, NSArray <WHTrackModel *> *allTracks))resultBlock{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSArray *mp3Files = [FCFileManager listFilesInDirectoryAtPath:documentPath withExtension:@"mp3" deep:YES];
    
    [[WHDatabaseManager sharedManager] readLocalTrack:^(NSArray <WHTrackModel *> *result) {
        NSMutableArray *allResult = [[NSMutableArray alloc] init];
        NSMutableArray *newResult = [[NSMutableArray alloc] init];
        
        if (result.count == 0) {
            for (NSString *pathStr in mp3Files) {
                WHTrackModel *aTrack = [[WHTrackModel alloc] initWithFileUrl:pathStr];
                [allResult addObject:aTrack];
                [newResult addObject:aTrack];
            }
        }else{
            for (NSString *pathStr in mp3Files) {
                WHTrackModel *aTrack = [[WHTrackModel alloc] initWithFileUrl:pathStr];
                [allResult addObject:aTrack];
                
                BOOL isNew = YES;
                
                for (WHTrackModel *saveTrack in result) {
                    if ([saveTrack isEqual:aTrack]) {
                        isNew = NO;
                    }
                }
                
                if (isNew) {
                    [newResult addObject:aTrack];
                }
                
            }
        }
        
        resultBlock(newResult, allResult);
    }];
    
}

@end
