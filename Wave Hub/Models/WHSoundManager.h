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

#import "WHFavouriteDelegate.h"

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

@interface WHSoundManager : NSObject <ORGMEngineDelegate, WHFavouriteDelegate, AVAudioPlayerDelegate, NPAudioStreamDataSource, NPAudioStreamDelegate>{
    ORGMEngine *player;
    
    NSMutableArray *queue;
    
    NSURL *expectedNextUrl;
    
    WHSoundManagerType currentType;
    WHSoundManagerPlayType loopingMode;
    
    //cue
    NSInteger currentCueIdx;
    NSURL *currentCueSheetUrl;
    
    //SoundCloud Favourite
    // will delete
//    AVAudioPlayer *audioPlayer;
    
    NPAudioStream *soundcloudStreamer;
    
    MyFavourite *favourite;
    int currentFavouriteIdx;
    
}

+ (WHSoundManager *)sharedManager;

- (void)playUrl:(NSString *)url forceStart:(BOOL)forceStart;
- (void)playCue:(CueSheet *)cueSheet withTrack:(CueSheetTrack *)track forceStart:(BOOL)forceStart;
- (void)playMyFavourite:(MyFavourite *)favourite withIndex:(int)idx forceStart:(BOOL)forceStart;

- (NSArray *)cueFilesInAppDocument;

- (void)playerChangeMode:(WHSoundManagerPlayType)playerMode;
- (void)playerForward;
- (void)playerBackward;
- (void)playerPause;
- (void)playerPlay;
- (void)playerStop;
- (void)playerSeekTime:(double)time;

@end
