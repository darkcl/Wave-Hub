//
//  WHSoundManager.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 12/11/15.
//  Copyright © 2015 Memory Leaks. All rights reserved.
//

#import "WHSoundManager.h"

@implementation WHSoundManager

+ (instancetype)sharedManager
{
    static WHSoundManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init{
    if (self = [super init]) {
        player = [[ORGMEngine alloc] init];
        player.delegate = self;
        
        queue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray *)cueFilesInAppDocument{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSArray *filePathsArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:documentsDirectory  error:nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF EndsWith '.cue'"];
    filePathsArray =  [filePathsArray filteredArrayUsingPredicate:predicate];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NSString *cueFiles in filePathsArray) {
        CueSheet *aCueSheet = [[CueSheet alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@/%@",documentsDirectory, cueFiles]]];
        aCueSheet.cueUrl = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@/%@",documentsDirectory, cueFiles]];
        [result addObject:aCueSheet];
    }
    
    return result;
}

#pragma mark - Player Logic

- (void)playUrl:(NSString *)url forceStart:(BOOL)forceStart{
    NSLog(@"Play %@", url);
    
    if (forceStart) {
        [player playUrl:[NSURL URLWithString:url]];
    }else{
        if (player.currentState != ORGMEngineStatePlaying) {
            [player playUrl:[NSURL URLWithString:url]];
        }else{
            [queue insertObject:url atIndex:0];
        }
    }
}

- (void)playCue:(CueSheet *)cueSheet
      withTrack:(CueSheetTrack *)track
     forceStart:(BOOL)forceStart{
    NSString *toTrack = [cueSheet.cueUrl.absoluteString stringByAppendingString:[NSString stringWithFormat:@"#%@",track.track]];
    [[WHSoundManager sharedManager] playUrl:toTrack forceStart:YES];
    
    currentCueIdx = [cueSheet.tracks indexOfObject:track];
    
    if (currentCueIdx == (NSInteger)cueSheet.tracks.count - 1) {
        expectedNextUrl = [NSURL URLWithString:[cueSheet.cueUrl.absoluteString stringByAppendingString:[NSString stringWithFormat:@"#%@",cueSheet.tracks[0]]]];
    }else{
        expectedNextUrl = [NSURL URLWithString:[cueSheet.cueUrl.absoluteString stringByAppendingString:[NSString stringWithFormat:@"#%@",cueSheet.tracks[currentCueIdx + 1]]]];
    }
}

#pragma mark - ORGMEngineDelegate

- (NSURL *)engineExpectsNextUrl:(ORGMEngine *)engine{
//    if (queue.count > 0) {
//        return queue[0];
//    }else{
//        return nil;
//    }
    return expectedNextUrl;
}

- (void)engine:(ORGMEngine *)engine didChangeState:(ORGMEngineState)state{
    switch (state) {
        case ORGMEngineStatePlaying:
            
            break;
        case ORGMEngineStatePaused:
            
            break;
        case ORGMEngineStateStopped:
            
            break;
        case ORGMEngineStateError:{
            NSLog(@"Error : %@", [[player currentError] localizedDescription]);
        }
            
            break;
        default:
            break;
    }
}

@end
