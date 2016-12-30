//
//  WHFileManager.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 30/12/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WHFileManager : NSObject

+ (instancetype)sharedManager;

- (void)fetchLocalTracks:(void(^)(NSArray <WHTrackModel *> *newTracks, NSArray <WHTrackModel *> *allTracks))resultBlock;

@end
