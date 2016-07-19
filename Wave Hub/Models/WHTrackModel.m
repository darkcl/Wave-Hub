//
//  WHTrackModel.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 16/11/15.
//  Copyright © 2015 Memory Leaks. All rights reserved.
//

#import "WHTrackModel.h"

#import <NPAudioStream/NPAudioStream.h>

#import <OrigamiEngine/ORGMEngine.h>
#import <OrigamiEngine/CueSheet.h>
#import "CueSheet+WaveHubAddition.h"

#import <Block-KVO/MTKObserving.h>

@interface WHTrackModel() <NPAudioStreamDelegate> {
    WHTrackCompletion complete;
    WHTrackProgress progress;
    WHTrackError failure;
    
    NSTimer *progressUpdateTimer;
    NPAudioStream *_streamPlayer;
}

@property (nonatomic, strong) ORGMEngine *localPlayer;

@end

@implementation WHTrackModel

- (id)init{
    if (self = [super init]) {
        _nextHref = nil;
    }
    return self;
}

- (id)initWithNextHref:(NSString *)url{
    if (self = [super init]) {
        _nextHref = url;
        _trackType = WHTrackTypePlaceHolder;
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
    if ([object isKindOfClass:[WHTrackModel class]]) {
        WHTrackModel *otherTrack = (WHTrackModel *)object;
        return [_trackUrl isEqual:otherTrack.trackUrl];
    }else{
        return NO;
    }
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
    
    if (_trackType != WHTrackTypeLocal) {
        [self playOnlineSound];
    }else{
        [self playLocalSound];
    }
}

- (void)stop{
    if (_trackType != WHTrackTypeLocal) {
        [_streamPlayer pause];
    }else{
        // TODO: Local file handling
    }
}

- (void)pause{
    if (_trackType != WHTrackTypeLocal) {
        [_streamPlayer pause];
    }else{
        // TODO: Local file handling
    }
}

- (void)resume{
    if (_trackType != WHTrackTypeLocal) {
        [_streamPlayer play];
    }else{
        // TODO: Local file handling
    }
}

- (void)playOnlineSound{
    _streamPlayer = [[NPAudioStream alloc] init];
    
    [_streamPlayer setUrls:@[_trackUrl]];
    NSLog(@"Play %@", _trackUrl);
    _streamPlayer.repeatMode = NPAudioStreamRepeatModeOff;
    _streamPlayer.delegate = self;
    [_streamPlayer selectIndexForPlayback:0];
}

- (void)playLocalSound{
    
}

- (BOOL)isPlaying{
    if (_trackType != WHTrackTypeLocal) {
        return (_streamPlayer.status == NPAudioStreamStatusPlaying);
    }else{
        return NO;
    }
}

- (float)progress{
    if (_trackType != WHTrackTypeLocal) {
        if (self.isPlaying) {
            return (float)(CMTimeGetSeconds(_streamPlayer.currentTime) / CMTimeGetSeconds(_streamPlayer.duration));
        }else{
            return 0.0f;
        }
    }else{
        return 0.0f;
    }
}

- (NSDictionary *)currentDisplayInfo{
    
    if (_trackType != WHTrackTypeLocal) {
        double time = (self.duration / 1000);
        return @{MPMediaItemPropertyTitle:self.trackTitle,
                 MPMediaItemPropertyArtist:self.author,
                 MPMediaItemPropertyMediaType: @(MPMediaTypeMusic),
                 MPNowPlayingInfoPropertyElapsedPlaybackTime: @(CMTimeGetSeconds(_streamPlayer.currentTime)),
                 MPMediaItemPropertyPlaybackDuration: @(time),
                 MPNowPlayingInfoPropertyPlaybackRate: @1};
    }else{
        return nil;
    }
    
}

#pragma mark - Streaming Delegate

- (void)didCompleteAudioStream:(NPAudioStream *)audioStream{
    double time = (self.duration / 1000);
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:@{MPMediaItemPropertyTitle:self.trackTitle,
                                                                MPMediaItemPropertyArtist:self.author,
                                                                MPMediaItemPropertyMediaType: @(MPMediaTypeMusic),
                                                                MPMediaItemPropertyPlaybackDuration: @(time),
                                                                MPNowPlayingInfoPropertyPlaybackRate: @0}];
    if (complete != nil) {
        complete();
    }
}

- (void)audioStream:(NPAudioStream *)audioStream
didUpdateTrackCurrentTime:(CMTime)currentTime{
    float playingProgress = (float)(CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(audioStream.duration));
    
    if (progress != nil) {
        progress(playingProgress);
    }
}

- (void)audioStream:(NPAudioStream *)audioStream didBeginPlaybackForTrackAtIndex:(NSInteger)index{
    double time = (self.duration / 1000);
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:@{MPMediaItemPropertyTitle:self.trackTitle,
                                                                MPMediaItemPropertyArtist:self.author,
                                                                MPMediaItemPropertyMediaType: @(MPMediaTypeMusic),
                                                                MPNowPlayingInfoPropertyElapsedPlaybackTime: @(CMTimeGetSeconds(audioStream.currentTime)),
                                                                MPMediaItemPropertyPlaybackDuration: @(time),
                                                                MPNowPlayingInfoPropertyPlaybackRate: @1}];
}

@end
