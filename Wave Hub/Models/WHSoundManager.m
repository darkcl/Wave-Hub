//
//  WHSoundManager.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 12/11/15.
//  Copyright © 2015 Memory Leaks. All rights reserved.
//

#import "WHSoundManager.h"

static const NSString *remoteControlPlayButtonTapped = @"play pressed";
static const NSString *remoteControlPauseButtonTapped = @"pause pressed";
static const NSString *remoteControlStopButtonTapped = @"stop pressed";
static const NSString *remoteControlForwardButtonTapped = @"forward pressed";
static const NSString *remoteControlBackwardButtonTapped = @"backward pressed";
static const NSString *remoteControlOtherButtonTapped = @"other pressed";

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteControlPlayPressed:) name:remoteControlPlayButtonTapped object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteControlPausePressed:) name:remoteControlPauseButtonTapped object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteControlStopPressed:) name:remoteControlStopButtonTapped object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteControlForwardPressed:) name:remoteControlForwardButtonTapped object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteControlBackwardPressed:) name:remoteControlBackwardButtonTapped object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteControlOtherPressed:) name:remoteControlOtherButtonTapped object:nil];
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
    currentType = WHSoundManagerTypeCue;
    
    NSString *toTrack = [cueSheet.cueUrl.absoluteString stringByAppendingString:[NSString stringWithFormat:@"#%@",track.track]];
    [self playUrl:toTrack forceStart:YES];
    
    currentCueIdx = [cueSheet.tracks indexOfObject:track];
    currentCueSheetUrl = cueSheet.cueUrl;
}

#pragma mark - Remote Control Callback

- (void)remoteControlPlayPressed:(id)sender{
    if ([player currentState] == ORGMEngineStatePaused) {
        [player resume];
    }
}

- (void)remoteControlPausePressed:(id)sender{
    [player pause];
}

- (void)remoteControlStopPressed:(id)sender{
    [player stop];
}

- (void)remoteControlForwardPressed:(id)sender{
    if (currentType == WHSoundManagerTypeCue) {
        CueSheet *currentCueSheet = [[CueSheet alloc] initWithURL:currentCueSheetUrl];
        currentCueSheet.cueUrl = currentCueSheetUrl;
        CueSheetTrack *track;
        if (currentCueIdx == (NSInteger)currentCueSheet.tracks.count - 1) {
            track = currentCueSheet.tracks[0];
            
            currentCueIdx = 0;
        }else{
            track = currentCueSheet.tracks[currentCueIdx + 1];
            
            currentCueIdx += 1;
        }
        [self playCue:currentCueSheet
            withTrack:track
           forceStart:YES];
    }
}

- (void)remoteControlBackwardPressed:(id)sender{
    if (currentType == WHSoundManagerTypeCue) {
        CueSheet *currentCueSheet = [[CueSheet alloc] initWithURL:currentCueSheetUrl];
        currentCueSheet.cueUrl = currentCueSheetUrl;
        CueSheetTrack *track;
        if (currentCueIdx == 0) {
            track = currentCueSheet.tracks[(NSInteger)currentCueSheet.tracks.count - 1];
            
            currentCueIdx = (NSInteger)currentCueSheet.tracks.count - 1;
        }else{
            track = currentCueSheet.tracks[currentCueIdx - 1];
            
            currentCueIdx -= 1;
        }
        [self playCue:currentCueSheet
            withTrack:track
           forceStart:YES];
    }
}

- (void)remoteControlOtherPressed:(id)sender{
    
}

#pragma mark - ORGMEngineDelegate

- (NSURL *)engineExpectsNextUrl:(ORGMEngine *)engine{
//    if (queue.count > 0) {
//        return queue[0];
//    }else{
//        return nil;
//    }
    CueSheet *currentCueSheet = [[CueSheet alloc] initWithURL:currentCueSheetUrl];
    currentCueSheet.cueUrl = currentCueSheetUrl;
    CueSheetTrack *track;
    if (currentCueIdx == (NSInteger)currentCueSheet.tracks.count - 1) {
        track = currentCueSheet.tracks[0];
        
        currentCueIdx = 0;
    }else{
        track = currentCueSheet.tracks[currentCueIdx + 1];
        
        currentCueIdx += 1;
    }
    expectedNextUrl = [NSURL URLWithString:[currentCueSheet.cueUrl.absoluteString stringByAppendingString:[NSString stringWithFormat:@"#%@",track.track]]];
    
    NSLog(@"Play Next: %@", expectedNextUrl.absoluteString);
    return expectedNextUrl;
}

- (void)engine:(ORGMEngine *)engine didChangeState:(ORGMEngineState)state{
    switch (state) {
        case ORGMEngineStatePlaying:{
            NSLog(@"Meta Data: %@", [engine metadata]);
            NSDictionary *metadata = [engine metadata];
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:@{MPMediaItemPropertyTitle:metadata[@"title"],
                                                                        MPMediaItemPropertyArtist:metadata[@"artist"],
                                                                        MPMediaItemPropertyMediaType: @(MPMediaTypeMusic),
                                                                        MPMediaItemPropertyPlay backDuration: @([engine trackTime]),
                                                                        MPNowPlayingInfoPropertyPlaybackRate: @1}];
        }
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
