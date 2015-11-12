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

typedef NS_ENUM(NSInteger, WHSoundManagerType) {
    WHSoundManagerTypeCue,
    WHSoundManagerTypeM3u
};

@interface WHSoundManager : NSObject <ORGMEngineDelegate>{
    ORGMEngine *player;
    
    NSMutableArray *queue;
    
    NSURL *expectedNextUrl;
    
    WHSoundManagerType currentType;
    
    //cue
    NSInteger currentCueIdx;
    NSURL *currentCueSheetUrl;
    
}

+ (WHSoundManager *)sharedManager;

- (void)playUrl:(NSString *)url forceStart:(BOOL)forceStart;
- (void)playCue:(CueSheet *)cueSheet withTrack:(CueSheetTrack *)track forceStart:(BOOL)forceStart;

- (NSArray *)cueFilesInAppDocument;

@end
