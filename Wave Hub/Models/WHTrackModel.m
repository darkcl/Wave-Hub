//
//  WHTrackModel.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 16/11/15.
//  Copyright © 2015 Memory Leaks. All rights reserved.
//

#import "WHTrackModel.h"

#import <OrigamiEngine/ORGMEngine.h>
#import <OrigamiEngine/CueSheet.h>


#import <FreeStreamer/FSAudioStream.h>
#import <FreeStreamer/FSAudioController.h>
#import <FreeStreamer/FSXMLHttpRequest.h>
#import <FreeStreamer/FSCheckContentTypeRequest.h>
#import <FreeStreamer/FSParsePlaylistRequest.h>
#import <FreeStreamer/FSParseRssPodcastFeedRequest.h>
#import <FreeStreamer/FSPlaylistItem.h>

#import "FSAudioStream+WaveHubAddition.h"
#import "CueSheet+WaveHubAddition.h"

#import <Block-KVO/MTKObserving.h>

@interface WHTrackModel(){
    WHTrackCompletion complete;
    WHTrackProgress progress;
    WHTrackError failure;
    
    FSAudioStream *_localPlayer;
}

@end

@implementation WHTrackModel

- (id)init{
    if (self = [super init]) {
        _nextHref = nil;
        _localPlayer = [FSAudioStream sharedInstance];
    }
    return self;
}

- (id)initWithNextHref:(NSString *)url{
    if (self = [super init]) {
        _nextHref = url;
        _trackType = WHTrackTypePlaceHolder;
        _localPlayer = [FSAudioStream sharedInstance];
    }
    return self;
}

- (id)initWithInfo:(NSDictionary *)dict{
    if (self = [super init]) {
        _trackUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?client_id=47724625bbc02bbc335e84f2ed87c001", dict[@"stream_url"]]];
        _trackTitle = dict[@"title"];
        _albumTitle = @"-";
        _albumCoverUrl = dict[@"artwork_url"];
        _author = dict[@"user"][@"username"];
        _duration = [dict[@"duration"] floatValue];
        _responseDict = dict;
        
        _localPlayer = [FSAudioStream sharedInstance];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder{
    if ((self = [super init])) {
        _trackUrl = [decoder decodeObjectForKey:@"trackUrl"];
        _md5hash = [decoder decodeObjectForKey:@"md5hash"];
        _trackTitle = [decoder decodeObjectForKey:@"trackTitle"];
        _albumTitle = [decoder decodeObjectForKey:@"albumTitle"];
        _author = [decoder decodeObjectForKey:@"author"];
        _albumCoverUrl = [decoder decodeObjectForKey:@"albumCoverUrl"];
        _albumCoverImage = [decoder decodeObjectForKey:@"albumCoverImage"];
        _trackType = [decoder decodeIntForKey:@"trackType"];
        _duration = [decoder decodeFloatForKey:@"duration"];
        _responseDict = [decoder decodeObjectForKey:@"responseDict"];
        
        _localPlayer = [FSAudioStream sharedInstance];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:_trackUrl forKey:@"trackUrl"];
    [encoder encodeInt:_trackType forKey:@"trackType"];
    [encoder encodeFloat:_duration forKey:@"duration"];
    [encoder encodeObject:_md5hash forKey:@"md5hash"];
    [encoder encodeObject:_trackTitle forKey:@"trackTitle"];
    [encoder encodeObject:_albumTitle forKey:@"albumTitle"];
    [encoder encodeObject:_author forKey:@"author"];
    [encoder encodeObject:_albumCoverUrl forKey:@"albumCoverUrl"];
    [encoder encodeObject:_albumCoverImage forKey:@"albumCoverImage"];
    [encoder encodeObject:_responseDict forKey:@"responseDict"];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"%@", self.responseDict];
}

- (BOOL)isEqual:(id)object{
    WHTrackModel *otherTrack = (WHTrackModel *)object;
    return [_trackUrl isEqual:otherTrack.trackUrl];
}

#pragma mark - Player Logic

- (void)likeEvent:(id)sender{
    NSLog(@"LIKE");
}

- (void)dislikeEvent:(id)sender{
    NSLog(@"DISLIKE");
}

- (void)playTrackWithCompletion:(WHTrackCompletion)completionBlock
                       progress:(WHTrackProgress)progressBlock
                        failure:(WHTrackError)failureBlock{
    complete = completionBlock;
    progress = progressBlock;
    failure = failureBlock;
    
    NSLog(@"Play %@", _trackUrl);
    __weak typeof(self) weakSelf = self;
    
    
    
    _localPlayer.strictContentTypeChecking = NO;
    [_localPlayer setOnCompletion:^{
        __strong typeof(self) strongSelf = weakSelf;
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:@{MPMediaItemPropertyTitle:strongSelf.trackTitle,
                                                                    MPMediaItemPropertyArtist:strongSelf.author,
                                                                    MPMediaItemPropertyMediaType: @(MPMediaTypeMusic),
                                                                    MPMediaItemPropertyPlaybackDuration: @(strongSelf->_localPlayer.duration.playbackTimeInSeconds),
                                                                    MPNowPlayingInfoPropertyPlaybackRate: @0}];

        completionBlock();
    }];
    
    [_localPlayer setOnFailure:^(FSAudioStreamError err, NSString *errMsg) {
        failureBlock([NSError errorWithDomain:@"com.darkcl.wave-hub.stream" code:0 userInfo:@{NSLocalizedDescriptionKey: errMsg}]);
    }];
    
    [_localPlayer setOnStateChange:^(FSAudioStreamState state) {
        __strong typeof(self) strongSelf = weakSelf;
        switch (state) {
            case kFsAudioStreamPlaying:{
                [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:strongSelf.currentDisplayInfo];
                
                NSLog(@"Stream Playing");
            }
                break;
            case kFsAudioStreamPaused:{
                [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:strongSelf.currentPauseDisplayInfo];
                
                NSLog(@"Stream Pause");
            }
                break;
            case kFsAudioStreamStopped:{
                NSLog(@"Stream Stop");
            }
                break;
            case kFsAudioStreamRetrievingURL:{
                [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:@{MPMediaItemPropertyTitle:@"Retrieving URL",
                                                                            MPMediaItemPropertyArtist:@"-",
                                                                            MPMediaItemPropertyMediaType: @(MPMediaTypeMusic),
                                                                            MPNowPlayingInfoPropertyElapsedPlaybackTime: @(0),
                                                                            MPMediaItemPropertyPlaybackDuration: @(1),
                                                                            MPNowPlayingInfoPropertyPlaybackRate: @0}];
            }
                break;
            case kFsAudioStreamBuffering:{
                [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:@{MPMediaItemPropertyTitle:@"Bufferring",
                                                                            MPMediaItemPropertyArtist:@"-",
                                                                            MPMediaItemPropertyMediaType: @(MPMediaTypeMusic),
                                                                            MPNowPlayingInfoPropertyElapsedPlaybackTime: @(0),
                                                                            MPMediaItemPropertyPlaybackDuration: @(1),
                                                                            MPNowPlayingInfoPropertyPlaybackRate: @0}];
            }
                break;
            default:
                break;
        }
    }];
    
    [_localPlayer playFromURL:_trackUrl];
}

- (void)stop{
    [_localPlayer stop];
    
}

- (void)pause{
    [_localPlayer pause];
}

- (void)resume{
    [_localPlayer pause];    
}

- (BOOL)isPlaying{
    return (_localPlayer.isPlaying);
}

- (float)progress{
    if (!self.isPlaying) {
        return 0.0;
    }else{
        return (float)(_localPlayer.currentTimePlayed.playbackTimeInSeconds / _localPlayer.duration.playbackTimeInSeconds);
    }
    
}

- (NSDictionary *)currentDisplayInfo{
    
    return @{MPMediaItemPropertyTitle:self.trackTitle,
             MPMediaItemPropertyArtist:self.author,
             MPMediaItemPropertyMediaType: @(MPMediaTypeMusic),
             MPNowPlayingInfoPropertyElapsedPlaybackTime: @(_localPlayer.currentTimePlayed.playbackTimeInSeconds),
             MPMediaItemPropertyPlaybackDuration: @(_localPlayer.duration.playbackTimeInSeconds),
             MPNowPlayingInfoPropertyPlaybackRate: @1};
    
}

- (NSDictionary *)currentPauseDisplayInfo{
    
    return @{MPMediaItemPropertyTitle:self.trackTitle,
             MPMediaItemPropertyArtist:self.author,
             MPMediaItemPropertyMediaType: @(MPMediaTypeMusic),
             MPNowPlayingInfoPropertyElapsedPlaybackTime: @(_localPlayer.currentTimePlayed.playbackTimeInSeconds),
             MPMediaItemPropertyPlaybackDuration: @(_localPlayer.duration.playbackTimeInSeconds),
             MPNowPlayingInfoPropertyPlaybackRate: @0};
    
}

//#pragma mark - Streaming Delegate
//
//- (void)didCompleteAudioStream:(NPAudioStream *)audioStream{
//    if (complete != nil) {
//        complete();
//    }
//}
//
//- (void)audioStream:(NPAudioStream *)audioStream
//didUpdateTrackCurrentTime:(CMTime)currentTime{
//    float playingProgress = (float)(CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(audioStream.duration));
//    
//    if (progress != nil) {
//        progress(playingProgress);
//    }
//}
//
//- (void)audioStream:(NPAudioStream *)audioStream didBeginPlaybackForTrackAtIndex:(NSInteger)index{
//}

@end
