//
//  WHSoundManager.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 12/11/15.
//  Copyright © 2015 Memory Leaks. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MediaToolbox/MediaToolbox.h>
#import <OrigamiEngine/ORGMEngine.h>
#import <OrigamiEngine/CueSheet.h>
#import "CueSheet+WaveHubAddition.h"

#import <NPAudioStream/NPAudioStream.h>

typedef NS_ENUM(NSInteger, WHSoundManagerPlayType) {
    WHSoundManagerPlayTypeOnce,
    WHSoundManagerPlayTypeLoop,
    WHSoundManagerPlayTypeLoopOnce,
    WHSoundManagerPlayTypeRandom
};

typedef NS_ENUM(NSInteger, WHSoundManagerType) {
    WHSoundManagerTypeCue,
    WHSoundManagerTypeM3u,
    WHSoundManagerTypeSoundCloud
};

@protocol WHSoundManagerDelegate <NSObject>

- (void)didUpdatePlayingProgress:(float)progress;
- (void)didUpdatePlayingTrack:(WHTrackModel *)info;
- (void)soundDidStop;

@end

@protocol WHSoundManagerDatasource <NSObject>

- (NSArray <WHTrackModel *> *)currentPlayingTracks;

@end

@interface WHSoundManager : NSObject{
    //Traks
    NSArray <WHTrackModel *> *currentTracks;
    WHSoundManagerPlayType playType;
}

@property (nonatomic, strong) WHTrackModel *playingTrack;

- (NSInteger)displayIndexForPlayingTrack:(WHTrackModel *)track;

- (void)reloadTracksData;

+ (WHSoundManager *)sharedManager;

- (void)playTrack:(WHTrackModel *)aTrack
       forceStart:(BOOL)forceStart;

- (void)playerChangeMode:(WHSoundManagerPlayType)playerMode;
- (void)playerForward;
- (void)playerBackward;
- (void)playerPause;
- (void)playerPlay;
- (void)playerStop;
- (void)playerSeekTime:(double)time;

@property (assign) id<WHSoundManagerDelegate>delegate;
@property (assign) id<WHSoundManagerDatasource>dataSource;

- (BOOL)isPlaying;


@end
