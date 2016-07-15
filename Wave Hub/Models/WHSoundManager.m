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
        
        soundcloudStreamer = [[NPAudioStream alloc] init];
        _playingIdx = -1;
        _playingProgress = -1;
        
        AVAudioPlayer *aPlayer = (AVAudioPlayer *)soundcloudStreamer.player;
        [aPlayer setMeteringEnabled:YES];
        
        soundcloudStreamer.delegate = self;
        soundcloudStreamer.dataSource = self;
//        soundcloudStreamer.repeatMode = NPAudioStreamRepeatModeOne;
        
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

- (BOOL)isPlaying{
    return (player.currentState == ORGMEngineStatePlaying) || (soundcloudStreamer.status == NPAudioStreamStatusPlaying);
}

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
        [soundcloudStreamer skipNext];
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
        [soundcloudStreamer skipPrevious];
    }
}

- (void)playerPause{
    if (currentType == WHSoundManagerTypeSoundCloud) {
        [soundcloudStreamer pause];
    }else{
        [player pause];
    }
    
}

- (void)playerPlay{
    if (currentType == WHSoundManagerTypeSoundCloud) {
        [soundcloudStreamer play];
    }else{
        [player resume];
    }
}

- (void)playerStop{
    if (currentType == WHSoundManagerTypeSoundCloud) {
        [soundcloudStreamer pause];
    }else{
        [player stop];
    }
}

- (void)playerChangeMode:(WHSoundManagerPlayType)playerMode{
    loopingMode = playerMode;
}

- (void)playerSeekTime:(double)time{
    if (currentType == WHSoundManagerTypeSoundCloud) {
        [soundcloudStreamer seekToTimeInSeconds:time];
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
    
    if (soundcloudStreamer.status == NPAudioStreamStatusPlaying) {
        [soundcloudStreamer pause];
    }
    
    currentType = WHSoundManagerTypeCue;
    
    NSString *toTrack = [cueSheet.cueUrl.absoluteString stringByAppendingString:[NSString stringWithFormat:@"#%@",track.track]];
    [self playUrl:toTrack forceStart:YES];
    
    currentCueIdx = [cueSheet.tracks indexOfObject:track];
    currentCueSheetUrl = cueSheet.cueUrl;
}

- (void)playMyFavourite:(NSArray <WHTrackModel *> *)favouriteInfo withIndex:(int)idx forceStart:(BOOL)forceStart{
    
    currentType = WHSoundManagerTypeSoundCloud;
    
    favourite = favouriteInfo;
    
    int resultIdx = idx;
    
    if (resultIdx < 0) {
        resultIdx = 0;
    }
    currentFavouriteIdx = resultIdx;
    if (player.currentState == ORGMEngineStatePlaying){
        [player stop];
    }
    
    NSMutableArray *urls = [[NSMutableArray alloc] init];
    for (WHTrackModel *info in favourite) {
        if (info.trackUrl != nil && ![info.trackUrl isKindOfClass:[NSNull class]]) {
            [urls addObject:[NSURL URLWithString:[NSString stringWithFormat:@"%@?client_id=47724625bbc02bbc335e84f2ed87c001", info.trackUrl]]];
        }
    }
    
    [self->soundcloudStreamer setUrls:urls];
    [self->soundcloudStreamer selectIndexForPlayback:resultIdx];
    
}

- (void)playMyFavourite2:(MyFavourite *)favouriteInfo
              withIndex:(int)idx
             forceStart:(BOOL)forceStart{
    
    
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


#pragma mark - SoundCloud Streaming
- (BOOL)shouldPrebufferNextTrackForAudioStream:(NPAudioStream *)audioStream{
    return YES;
}

- (void)audioStream:(NPAudioStream *)audioStream didUpdateTrackCurrentTime:(CMTime)currentTime{
    if (_delegate && [_delegate respondsToSelector:@selector(didUpdatePlayingProgress:)]) {
        [_delegate didUpdatePlayingProgress:(float)(CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(audioStream.duration))];
    }
    
    _playingProgress = (float)(audioStream.duration.value / currentTime.value);
}

- (void)audioStream:(NPAudioStream *)audioStream didBeginPlaybackForTrackAtIndex:(NSInteger)index{
    WHTrackModel *info = favourite[index];
    double time = (info.duration / 1000);
    _playingProgress = index;
    
    if (_delegate && [_delegate respondsToSelector:@selector(didUpdatePlayingIndex:)]) {
        [_delegate didUpdatePlayingIndex:index];
    }
    _playingIdx = index;
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:@{MPMediaItemPropertyTitle:info.trackTitle,
                                                                MPMediaItemPropertyArtist:info.author,
                                                                MPMediaItemPropertyMediaType: @(MPMediaTypeMusic),
                                                                MPMediaItemPropertyPlaybackDuration: @(time),
                                                                MPNowPlayingInfoPropertyPlaybackRate: @1}];
}

- (void)didCompleteAudioStream:(NPAudioStream *)audioStream{
    if (_delegate && [_delegate respondsToSelector:@selector(soundDidStop)]) {
        [_delegate soundDidStop];
    }
//    __block int idx = favourite.collection.count;
//    
//    [[WHWebrequestManager sharedManager] fetchMyFavouriteWithInfo:favourite
//                                                          success:^(MyFavourite *responseObject) {
//                                                              self->currentFavouriteIdx = idx;
//                                                              
//                                                              self->favourite = responseObject;
//                                                              
//                                                              if (self->player.currentState == ORGMEngineStatePlaying){
//                                                                  [self->player stop];
//                                                              }
//                                                              
//                                                              NSMutableArray *urls = [[NSMutableArray alloc] init];
//                                                              for (Collection *info in responseObject.collection) {
//                                                                  [urls addObject:[NSURL URLWithString:[NSString stringWithFormat:@"%@?client_id=47724625bbc02bbc335e84f2ed87c001", info.streamUrl]]];
//                                                              }
//                                                              
//                                                              [self->soundcloudStreamer setUrls:urls];
//                                                              [self->soundcloudStreamer selectIndexForPlayback:idx];
//                                                              
//                                                          }
//                                                          failure:^(NSError *error) {
//                                                              [self->soundcloudStreamer selectIndexForPlayback:0];
//                                                          }];
}

@end
