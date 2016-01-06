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
        currentFavouriteIdx = 0;
        queue = [[NSMutableArray alloc] init];
        
        [AVAudioSession sharedInstance];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteControlPlayPressed:) name:remoteControlPlayButtonTapped object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteControlPausePressed:) name:remoteControlPauseButtonTapped object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteControlStopPressed:) name:remoteControlStopButtonTapped object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteControlForwardPressed:) name:remoteControlForwardButtonTapped object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteControlBackwardPressed:) name:remoteControlBackwardButtonTapped object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteControlOtherPressed:) name:remoteControlOtherButtonTapped object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:)
                                                     name:AVAudioSessionRouteChangeNotification
                                                   object:nil];
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

- (void)playerForward{
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
    }else if(currentType == WHSoundManagerTypeSoundCloud) {
        [self playMyFavourite:favourite
                    withIndex:currentFavouriteIdx + 1
                   forceStart:YES];
    }
}

- (void)playerBackward{
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
    }else if(currentType == WHSoundManagerTypeSoundCloud) {
        [self playMyFavourite:favourite
                    withIndex:currentFavouriteIdx - 1
                   forceStart:YES];
    }
}

- (void)playerPause{
    if (currentType == WHSoundManagerTypeSoundCloud) {
        [audioPlayer pause];
    }else{
        [player pause];
    }
    
}

- (void)playerPlay{
    if (currentType == WHSoundManagerTypeSoundCloud) {
        [audioPlayer play];
    }else{
        [player resume];
    }
}

- (void)playerStop{
    if (currentType == WHSoundManagerTypeSoundCloud) {
        [audioPlayer stop];
    }else{
        [player stop];
    }
}

- (void)playerChangeMode:(WHSoundManagerPlayType)playerMode{
    loopingMode = playerMode;
}

- (void)playerSeekTime:(double)time{
    if (currentType == WHSoundManagerTypeSoundCloud) {
        [audioPlayer playAtTime:time];
    }else{
        [player seekToTime:time];
    }
}

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
    
    if ([audioPlayer isPlaying]) {
        [audioPlayer stop];
    }
    
    currentType = WHSoundManagerTypeCue;
    
    NSString *toTrack = [cueSheet.cueUrl.absoluteString stringByAppendingString:[NSString stringWithFormat:@"#%@",track.track]];
    [self playUrl:toTrack forceStart:YES];
    
    currentCueIdx = [cueSheet.tracks indexOfObject:track];
    currentCueSheetUrl = cueSheet.cueUrl;
}

- (void)playMyFavourite:(MyFavourite *)favouriteInfo
              withIndex:(int)idx
             forceStart:(BOOL)forceStart{
    currentType = WHSoundManagerTypeSoundCloud;
    
    favourite = favouriteInfo;
    
    int resultIdx = idx;
    if ((int)favourite.collection.count == resultIdx) {
        resultIdx = 0;
    }
    
    if (resultIdx < 0) {
        resultIdx = 0;
    }
    currentFavouriteIdx = resultIdx;
//    int nextIdx = resultIdx + 1;
//    
//    if (nextIdx == (int)favourite.collection.count) {
//        expectedNextUrl = nil;
//    }else{
//        Collection *info = favourite.collection[nextIdx];
//        NSArray *paths = NSSearchPathForDirectoriesInDomains
//        (NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//        expectedNextUrl = [NSURL URLWithString:[NSString stringWithFormat:@"file:/%@/%@.wav",
//                              documentsDirectory, info.uri.lastPathComponent]];
//    }
    if (player.currentState == ORGMEngineStatePlaying){
        [player stop];
    }
    
    [[WHWebrequestManager sharedManager] streamCollection:favourite.collection[currentFavouriteIdx]
                                                  success:^(NSURL *responseObject) {
                                                      NSError *playerError;
                                                      self->audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:responseObject
                                                                                                           error:&playerError];
                                                      self->audioPlayer.delegate = self;
                                                      if (playerError) {
                                                          NSLog(@"%@", playerError);
                                                      }else{
                                                          [self->audioPlayer play];
                                                          Collection *info = self->favourite.collection[self->currentFavouriteIdx];
                                                          [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:@{MPMediaItemPropertyTitle:info.title,
                                                                                                                      MPMediaItemPropertyArtist:info.user.username,
                                                                                                                      MPMediaItemPropertyMediaType: @(MPMediaTypeMusic),
                                                                                                                      MPMediaItemPropertyPlaybackDuration: @([self->audioPlayer duration]),
                                                                                                                      MPNowPlayingInfoPropertyPlaybackRate: @1}];
                                                      }
                                                  }
                                                  failure:^(NSError *error) {
                                                      NSLog(@"%@", error);
                                                  }];
    
}


#pragma mark - AVAudioSession

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (currentType == WHSoundManagerTypeSoundCloud) {
        [self playerForward];
    }
}

- (void)audioRouteChangeListenerCallback:(NSNotification *)notification{
    NSDictionary *interuptionDict = notification.userInfo;
    
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (routeChangeReason) {
            
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:{
            NSLog(@"AVAudioSessionRouteChangeReasonNewDeviceAvailable");
            NSLog(@"Headphone/Line plugged in");
            if ([player currentState] == ORGMEngineStatePaused) {
                [player resume];
            }
        }
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:{
            NSLog(@"AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
            NSLog(@"Headphone/Line was pulled. Stopping player....");
            if ([player currentState] == ORGMEngineStatePlaying) {
                [player pause];
            }
        }
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
    }
}

#pragma mark - Remote Control Callback

- (void)remoteControlPlayPressed:(id)sender{
    [self playerPlay];
}

- (void)remoteControlPausePressed:(id)sender{
    [self playerPause];
}

- (void)remoteControlStopPressed:(id)sender{
    [self playerStop];
}

- (void)remoteControlForwardPressed:(id)sender{
    [self playerForward];
}

- (void)remoteControlBackwardPressed:(id)sender{
    [self playerBackward];
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
        expectedNextUrl = [NSURL URLWithString:[currentCueSheet.cueUrl.absoluteString stringByAppendingString:[NSString stringWithFormat:@"#%@",track.track]]];
        
        NSLog(@"Play Next: %@", expectedNextUrl.absoluteString);
        return expectedNextUrl;
    }else if (currentType == WHSoundManagerTypeSoundCloud){
        return nil;
    }else{
        return nil;
    }
}

- (void)engine:(ORGMEngine *)engine didChangeState:(ORGMEngineState)state{
    switch (state) {
        case ORGMEngineStatePlaying:{
            if (currentType == WHSoundManagerTypeCue) {
                NSLog(@"Meta Data: %@", [engine metadata]);
                NSDictionary *metadata = [engine metadata];
                [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:@{MPMediaItemPropertyTitle:metadata[@"title"],
                                                                            MPMediaItemPropertyArtist:metadata[@"artist"],
                                                                            MPMediaItemPropertyMediaType: @(MPMediaTypeMusic),
                                                                            MPMediaItemPropertyPlaybackDuration: @([engine trackTime]),
                                                                            MPNowPlayingInfoPropertyPlaybackRate: @1}];
            }
            
        }
            break;
        case ORGMEngineStatePaused:
            
            break;
        case ORGMEngineStateStopped:{
            NSLog(@"Player stopped");
            if (currentType == WHSoundManagerTypeSoundCloud) {
                [self playerForward];
            }
        }
            
            break;
        case ORGMEngineStateError:{
            NSLog(@"Error : %@", [[player currentError] localizedDescription]);
        }
            
            break;
        default:
            break;
    }
}

-(void)didUpdateFavourite:(MyFavourite *)info{
    favourite = info;
}

@end
