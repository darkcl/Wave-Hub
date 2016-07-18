//
//  WHSoundManager.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 12/11/15.
//  Copyright © 2015 Memory Leaks. All rights reserved.
//

#import "WHSoundManager.h"
#import <NPQueuePlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "WHTrackModel.h"

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteControlPlayPressed:) name:remoteControlPlayButtonTapped object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteControlPausePressed:) name:remoteControlPauseButtonTapped object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteControlStopPressed:) name:remoteControlStopButtonTapped object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteControlForwardPressed:) name:remoteControlForwardButtonTapped object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteControlBackwardPressed:) name:remoteControlBackwardButtonTapped object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteControlOtherPressed:) name:remoteControlOtherButtonTapped object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:)
                                                     name:AVAudioSessionRouteChangeNotification
                                                   object:nil];
        playType = WHSoundManagerPlayTypeLoop;
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

- (void)reloadTracksData{
    if (_dataSource && [_dataSource respondsToSelector:@selector(currentPlayingTracks)]) {
        currentTracks = [_dataSource currentPlayingTracks];
    }
}

#pragma mark - Player Logic

- (void)playerForward{
    [_playingTrack stop];
    _playingTrack = _playingTrack.nextTrack;
    
    [self startPlayTrack];
}

- (void)playerBackward{
    [_playingTrack stop];
    
    _playingTrack = _playingTrack.prevTrack;
    [self startPlayTrack];
}

- (void)playerPause{
    [_playingTrack pause];
}

- (void)playerPlay{
    [_playingTrack resume];
}

- (void)playerStop{
    
}

- (void)playerChangeMode:(WHSoundManagerPlayType)playerMode{
    
}

- (void)playerSeekTime:(double)time{
    
}

- (BOOL)isPlaying{
    return _playingTrack.isPlaying;
}

- (void)startPlayTrack{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdatePlayingTrack:)]) {
        [self.delegate didUpdatePlayingTrack:_playingTrack];
    }
    
    [_playingTrack playTrackWithCompletion:^{
        [self playerForward];
    } progress:^(float progress) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdatePlayingProgress:)]) {
            [self.delegate didUpdatePlayingProgress:progress];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
        
        [self playerForward];
    }];
}

- (void)playTrack:(WHTrackModel *)aTrack
       forceStart:(BOOL)forceStart{
    if (_dataSource && [_dataSource respondsToSelector:@selector(currentPlayingTracks)]) {
        [_playingTrack stop];
        
        currentTracks = [_dataSource currentPlayingTracks];
        [self generatePlaylistWithTracks:currentTracks];
        
        _playingTrack = aTrack;
        
        [self startPlayTrack];
    }else{
        NSLog(@"Required to implement dataSource protocol");
    }
}

- (void)generatePlaylistForLoop:(NSArray <WHTrackModel *> *)tracks{
    NSInteger idx = 0;
    
    for (WHTrackModel *aTrack in tracks) {
        if (idx != 0 && idx != (int)tracks.count - 1) {
            aTrack.prevTrack = tracks[idx-1];
            aTrack.nextTrack = tracks[idx+1];
        }else if(idx == 0){
            aTrack.prevTrack = [tracks lastObject];
            aTrack.nextTrack = tracks[idx+1];
        }else if(idx == (int)tracks.count - 1){
            aTrack.prevTrack = tracks[idx-1];
            aTrack.nextTrack = [tracks lastObject];
        }
        aTrack.displayIndex = idx;
        idx++;
    }
}

- (void)generatePlaylistWithTracks:(NSArray <WHTrackModel *> *)tracks{
    switch (playType) {
        case WHSoundManagerPlayTypeOnce:
            
            break;
        case WHSoundManagerPlayTypeLoop:
            [self generatePlaylistForLoop:tracks];
            break;
        case WHSoundManagerPlayTypeLoopOnce:
            
            break;
        case WHSoundManagerPlayTypeRandom:
            
            break;
        default:
            break;
    }
}

#pragma mark - AVAudioSession

- (void)audioRouteChangeListenerCallback:(NSNotification *)notification{
    NSDictionary *interuptionDict = notification.userInfo;
    
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (routeChangeReason) {
            
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:{
            NSLog(@"AVAudioSessionRouteChangeReasonNewDeviceAvailable");
            NSLog(@"Headphone/Line plugged in");
        }
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:{
            NSLog(@"AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
            NSLog(@"Headphone/Line was pulled. Stopping player....");
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
    if (_delegate && [_delegate respondsToSelector:@selector(soundDidStop)]) {
        [_delegate soundDidStop];
    }
}

- (void)remoteControlStopPressed:(id)sender{
    [self playerStop];
    if (_delegate && [_delegate respondsToSelector:@selector(soundDidStop)]) {
        [_delegate soundDidStop];
    }
}

- (void)remoteControlForwardPressed:(id)sender{
    [self playerForward];
}

- (void)remoteControlBackwardPressed:(id)sender{
    [self playerBackward];
}

- (void)remoteControlOtherPressed:(id)sender{
    
}

@end
