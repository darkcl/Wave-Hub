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

@interface WHSoundManager()

@property (nonatomic, strong) MPRemoteCommand * mprcNext, * mprcPlay, * mprcPause, * mprcPrevious;

@property (nonatomic, strong) MPFeedbackCommand * mpfbLike, * mpfbDislike, * mpfbBookMark;

@end

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

- (void)addActiveProgressViews:(UIProgressView *)progressView{
    [activeProgressViews addObject:progressView];
}

- (void)removeActiveProgressViews:(UIProgressView *)progressView{
    [activeProgressViews removeObject:progressView];
}

- (void)updateProgress{
    if (self.isPlaying) {
        for (UIProgressView *aProgressView in activeProgressViews) {
            aProgressView.progress = self.playingTrack.progress;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:WHSoundTrackProgressNotifiction
                                                            object:[NSNumber numberWithDouble:self.playingTrack.progress]];
    }else{
        for (UIProgressView *aProgressView in activeProgressViews) {
            aProgressView.progress = 0.0;
        }
    }
}

- (id)init{
    if (self = [super init]) {
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        
        self.mprcNext = [MPRemoteCommandCenter sharedCommandCenter].nextTrackCommand;
        [self.mprcNext addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) {
            return MPRemoteCommandHandlerStatusSuccess;
        }];
        [self.mprcNext setEnabled:YES];
        [self.mprcNext addTarget:self action:@selector(nextTrackCommand:)];
        self.mprcPlay = [MPRemoteCommandCenter sharedCommandCenter].playCommand;
        [self.mprcPlay addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) {
            return MPRemoteCommandHandlerStatusSuccess;
        }];
        [self.mprcPlay setEnabled:YES];
        [self.mprcPlay addTarget:self action:@selector(playCommand:)];
        self.mprcPause = [MPRemoteCommandCenter sharedCommandCenter].pauseCommand;
        [self.mprcPause addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) {
            return MPRemoteCommandHandlerStatusSuccess;
        }];
        [self.mprcPause setEnabled:NO];
        [self.mprcPause addTarget:self action:@selector(pauseCommand:)];
        
        self.mprcPrevious = [MPRemoteCommandCenter sharedCommandCenter].previousTrackCommand;
        [self.mprcPrevious addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) {
            return MPRemoteCommandHandlerStatusSuccess;
        }];
        [self.mprcPrevious setEnabled:YES];
        [self.mprcPrevious addTarget:self action:@selector(previousTrackCommand:)];
        activeProgressViews = [[NSMutableArray alloc] init];
        updateTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:updateTimer forMode:NSRunLoopCommonModes];
        
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

#pragma mark - Remote command

- (void)bookmarkCommand:(MPFeedbackCommandEvent *)sender
{
    NSLog(@"Bookmark");
}

- (void)dislikeCommand:(MPFeedbackCommandEvent *)sender
{
    NSLog(@"Dislike");
}

- (void)likeCommand:(MPFeedbackCommandEvent *)sender
{
    NSLog(@"Like");
}

- (void)previousTrackCommand:(MPRemoteCommandEvent *)sender
{
    NSLog(@"Previous Track");
    [self playerBackward];
}

- (void)playCommand:(MPRemoteCommandEvent *)sender
{
    NSLog(@"Play in MPRemoteCommandEvent");
    [self playerPlay];
}

- (void)pauseCommand:(MPRemoteCommandEvent *)sender
{
    NSLog(@"Pause in MPRemoteCommandEvent");
    [self playerPause];
}

- (void)nextTrackCommand:(MPRemoteCommandEvent *)sender
{
    NSLog(@"Next Track");
    [self playerForward];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
            NSLog(@"Play in RemoteControlEvent");
            [self playerPlay];
            break;
        case UIEventSubtypeRemoteControlPause:
            NSLog(@"Pause in RemoteControlEvent");
            [self playerPause];
            break;
        default:
            break;
    }
}

#pragma mark - Player Logic

- (void)playerForward{
//    [_playingTrack stop];
    _playingTrack = _playingTrack.nextTrack;
    
    [self startPlayTrack];
}

- (void)playerBackward{
//    [_playingTrack stop];
    
    _playingTrack = _playingTrack.prevTrack;
    [self startPlayTrack];
}

- (void)playerPause{
    [[NSNotificationCenter defaultCenter] postNotificationName:WHSoundTrackDidChangeNotifiction object:[NSNull null]];
    
    MPNowPlayingInfoCenter *infoCenter = [MPNowPlayingInfoCenter defaultCenter];
    
    // Get currently playing information from other method:
    NSMutableDictionary *displayInfo = [NSMutableDictionary dictionaryWithDictionary:[_playingTrack currentDisplayInfo]];
    
    // A playback rate of 0.0f corresponds to a "not playing" state.
    float playbackRate = 0.0f;
    [displayInfo setObject:[NSNumber numberWithFloat:playbackRate] forKey:MPNowPlayingInfoPropertyPlaybackRate];
    
    // This will update the lock screen button and hide the progress bar if the playback rate is 0.0f:
    infoCenter.nowPlayingInfo = displayInfo;
    [_playingTrack pause];
}

- (void)playerPlay{
    [[NSNotificationCenter defaultCenter] postNotificationName:WHSoundTrackDidChangeNotifiction object:_playingTrack];
    MPNowPlayingInfoCenter *infoCenter = [MPNowPlayingInfoCenter defaultCenter];
    
    // Get currently playing information from other method:
    NSMutableDictionary *displayInfo = [NSMutableDictionary dictionaryWithDictionary:[_playingTrack currentDisplayInfo]];
    
    // A playback rate of 0.0f corresponds to a "not playing" state.
    float playbackRate = 1.0f;
    [displayInfo setObject:[NSNumber numberWithFloat:playbackRate] forKey:MPNowPlayingInfoPropertyPlaybackRate];
    
    // This will update the lock screen button and hide the progress bar if the playback rate is 0.0f:
    infoCenter.nowPlayingInfo = displayInfo;
    [_playingTrack resume];
}

- (void)playerStop{
    
}

- (void)playerChangeMode:(WHSoundManagerPlayType)playerMode{
    
}

- (void)playerSeekTime:(float)time{
    [self.playingTrack seekTime:time];
}

- (BOOL)isPlaying{
    return _playingTrack.isPlaying;
}

- (void)startPlayTrack{
    if (_playingTrack.activityType == WHSoundCloudActiviyTypePlaylist) {
        // Load more
        [[WHWebrequestManager sharedManager] fetchTracksWithPlaylistId:_playingTrack.trackId
                                                               success:^(NSArray *responseObject) {
                                                                   self.playingPlayList = self.playingTrack;
                                                                   
                                                                   NSMutableArray *result = [NSMutableArray arrayWithArray:self->currentTracks];
                                                                   [result replaceObjectsInRange:NSMakeRange([result indexOfObject:self.playingTrack], 1) withObjectsFromArray:responseObject];
                                                                   
                                                                   self->currentTracks =  result;
                                                                   WHTrackModel *continueOnTrack = [responseObject firstObject];
                                                                   
                                                                   [self generatePlaylistForLoop:self->currentTracks];
                                                                   [[NSNotificationCenter defaultCenter] postNotificationName:WHSoundPlayerDidLoadMore object:result];
                                                                   
                                                                   [self playTrack:continueOnTrack forceStart:YES];
                                                               }
                                                               failure:^(NSError *error) {
                                                                   
                                                               }];
    }else if (_playingTrack.trackType == WHTrackTypePlaceHolder) {
        // Load more
        [[WHWebrequestManager sharedManager] fetchTracksWithUrl:_playingTrack.nextHref
                                                        success:^(NSArray *responseObject) {
                                                            NSMutableArray *result = [NSMutableArray arrayWithArray:self->currentTracks];
                                                            [result removeLastObject];
                                                            [result addObjectsFromArray:responseObject];
                                                            self->currentTracks =  result;
                                                            WHTrackModel *continueOnTrack = [responseObject firstObject];
                                                            [self generatePlaylistForLoop:self->currentTracks];
                                                            [[NSNotificationCenter defaultCenter] postNotificationName:WHSoundPlayerDidLoadMore object:result];
                                                            
                                                            [self playTrack:continueOnTrack forceStart:YES];
                                                        }
                                                        failure:^(NSError *error) {
                                                            
                                                        }];
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdatePlayingTrack:)]) {
            [self.delegate didUpdatePlayingTrack:_playingTrack];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:WHSoundTrackDidChangeNotifiction object:_playingTrack];
        self.mprcPlay.enabled = YES;
        [_playingTrack playTrackWithCompletion:^{
            [self playerForward];
        } progress:^(float progress) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdatePlayingProgress:)]) {
                [self.delegate didUpdatePlayingProgress:progress];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:WHSoundProgressDidChangeNotifiction object:[NSNumber numberWithFloat:progress]];
        } failure:^(NSError *error) {
            NSLog(@"%@", error);
            
            [self playerForward];
        }];
    }
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
            aTrack.nextTrack = [tracks firstObject];
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

- (NSArray <WHTrackModel *> *)nowPlayingTrackWithLimit:(NSInteger)limit{
    return currentTracks;
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
            [_playingTrack stop];
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
