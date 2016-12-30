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
#import "ORGMEngine+WaveHubAddition.h"
#import "CueSheet+WaveHubAddition.h"
#import "NSData+WaveHubAddition.h"

#import <Block-KVO/MTKObserving.h>

@interface WHTrackModel(){
    WHTrackCompletion complete;
    WHTrackProgress progress;
    WHTrackError failure;
    
    FSAudioStream *remoteStreamer;
    
    FSAudioStream *localPlayer;
}

@end

@implementation WHTrackModel

- (id)init{
    if (self = [super init]) {
        _nextHref = nil;
        remoteStreamer = [FSAudioStream sharedInstance];
        localPlayer = [FSAudioStream sharedInstance];
        
        _trackType = WHTrackTypeSoundCloud;
    }
    return self;
}

- (id)initWithNextHref:(NSString *)url{
    if (self = [super init]) {
        _nextHref = url;
        _trackType = WHTrackTypePlaceHolder;
        remoteStreamer = [FSAudioStream sharedInstance];
        localPlayer = [FSAudioStream sharedInstance];
    }
    return self;
}

- (id)initWithActivityInfo:(NSDictionary *)dict{
    if (self = [super init]) {
        
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
        _userImageUrl = dict[@"user"][@"avatar_url"];
        _duration = [dict[@"duration"] floatValue];
        _responseDict = dict;
        
        remoteStreamer = [FSAudioStream sharedInstance];
        localPlayer = [FSAudioStream sharedInstance];
        
        _trackType = WHTrackTypeSoundCloud;
    }
    return self;
}

- (id)initWithFileUrl:(NSString *)fileUrl{
    if (self = [super init]) {
        _trackUrl = [NSURL fileURLWithPath:fileUrl];
        
        _trackType = WHTrackTypeLocal;
        
        AVURLAsset *assest = [AVURLAsset URLAssetWithURL:_trackUrl options:nil];
        NSArray *metadata = [assest availableMetadataFormats];
        for (NSString *format in metadata) {
            for (AVMetadataItem *item in [assest metadataForFormat:format]) {
                _duration = (CMTimeGetSeconds(assest.duration) * 1000);
                
                if ([[item commonKey] isEqualToString:@"title"]) {
//                    NSLog(@" title : %@", (NSString *)[item value]);
                    
                    _trackTitle = (NSString *)[item value];
                }
                if ([[item commonKey] isEqualToString:@"artist"]) {
//                    NSLog(@" artist : %@", (NSString *)[item value]);
                    
                    _author = (NSString *)[item value];
                }
                if ([[item commonKey] isEqualToString:@"albumName"]) {
//                    NSLog(@" albumName : %@", (NSString *)[item value]);
                    
                    _albumTitle = (NSString *)[item value];
                }
                if ([[item commonKey] isEqualToString:@"artwork"]) {
                    NSData *aData = (NSData *)[item value];
                    
                    if (aData != nil) {
                        UIImage *img = [UIImage imageWithData:aData];
                        _albumCoverImage = img;
                    }
                    
                    
                    
                }
            }
        }
        
        _md5hash = [[[NSData alloc] initWithContentsOfFile:fileUrl] md5String];
        
        remoteStreamer = [FSAudioStream sharedInstance];
        localPlayer = [FSAudioStream sharedInstance];
    }
    
    return self;
}

- (NSString *)trackId{
    if (self.responseDict) {
        return [self.responseDict[@"id"] stringValue];
    }else{
        return nil;
    }
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
        
        
        if ([_trackUrl.absoluteString rangeOfString:@"?client_id=47724625bbc02bbc335e84f2ed87c001"].location != NSNotFound) {
            _trackType = WHTrackTypeSoundCloud;
        }
        
        remoteStreamer = [FSAudioStream sharedInstance];
        localPlayer = [FSAudioStream sharedInstance];
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
    
    if (self.trackType == otherTrack.trackType) {
        if (self.trackType == WHTrackTypeLocal) {
            return [_md5hash isEqualToString:otherTrack.md5hash];
        }else{
            return [_responseDict isEqual:otherTrack.responseDict];
        }
    }else{
        return NO;
    }
    
}

- (WHSoundCloudActiviyType)activityType{
    if (self.responseDict != nil && [self.responseDict isKindOfClass:[NSDictionary class]]) {
        NSString *typeString = self.responseDict[@"kind"];
        if ([typeString isEqualToString:@"track"]) {
            return WHSoundCloudActiviyTypeNewTrack;
        }else if ([typeString isEqualToString:@"track-repost"]){
            return WHSoundCloudActiviyTypeRepostTrack;
        }else if ([typeString isEqualToString:@"playlist"]){
            return WHSoundCloudActiviyTypePlaylist;
        }else{
            return WHSoundCloudActiviyTypeUnknown;
        }
    }else{
        return WHSoundCloudActiviyTypeUnknown;
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
    
    
    if (self.trackType == WHTrackTypeLocal) {
        // Handle sandbox
        
        if (_trackType == WHTrackTypeLocal) {
            NSString *absStr = _trackUrl.absoluteString;
            NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            NSArray *allComp = [absStr pathComponents];
            
            NSInteger docIdx = [allComp indexOfObject:@"Documents"] + 1;
            
            NSArray *relPath = [allComp objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(docIdx, allComp.count - docIdx)]];
            
            _trackUrl = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@/%@",documentPath,[relPath componentsJoinedByString:@"/"]]];
        }
        
        NSLog(@"Play %@", _trackUrl);
        __weak typeof(self) weakSelf = self;
        
        localPlayer.strictContentTypeChecking = NO;
        [localPlayer setOnCompletion:^{
            __strong typeof(self) strongSelf = weakSelf;
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:@{MPMediaItemPropertyTitle:strongSelf.trackTitle,
                                                                        MPMediaItemPropertyArtist:strongSelf.author,
                                                                        MPMediaItemPropertyMediaType: @(MPMediaTypeMusic),
                                                                        MPMediaItemPropertyPlaybackDuration: @(strongSelf->remoteStreamer.duration.playbackTimeInSeconds),
                                                                        MPNowPlayingInfoPropertyPlaybackRate: @0}];
            
            completionBlock();
        }];
        
        [localPlayer setOnFailure:^(FSAudioStreamError err, NSString *errMsg) {
            failureBlock([NSError errorWithDomain:@"com.darkcl.wave-hub.stream" code:0 userInfo:@{NSLocalizedDescriptionKey: errMsg}]);
        }];
        
        [localPlayer setOnStateChange:^(FSAudioStreamState state) {
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
        
        [localPlayer playFromURL:_trackUrl];
    }else if (self.trackType == WHTrackTypeSoundCloud) {
        
        NSLog(@"Play %@", _trackUrl);
        __weak typeof(self) weakSelf = self;
        
        remoteStreamer.strictContentTypeChecking = NO;
        [remoteStreamer setOnCompletion:^{
            __strong typeof(self) strongSelf = weakSelf;
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:@{MPMediaItemPropertyTitle:strongSelf.trackTitle,
                                                                        MPMediaItemPropertyArtist:strongSelf.author,
                                                                        MPMediaItemPropertyMediaType: @(MPMediaTypeMusic),
                                                                        MPMediaItemPropertyPlaybackDuration: @(strongSelf->remoteStreamer.duration.playbackTimeInSeconds),
                                                                        MPNowPlayingInfoPropertyPlaybackRate: @0}];
            
            completionBlock();
        }];
        
        [remoteStreamer setOnFailure:^(FSAudioStreamError err, NSString *errMsg) {
            failureBlock([NSError errorWithDomain:@"com.darkcl.wave-hub.stream" code:0 userInfo:@{NSLocalizedDescriptionKey: errMsg}]);
        }];
        
        [remoteStreamer setOnStateChange:^(FSAudioStreamState state) {
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
        
        [remoteStreamer playFromURL:_trackUrl];
    }
}

- (void)stop{
    if (self.trackType == WHTrackTypeSoundCloud) {
        [remoteStreamer stop];
    }else{
        [localPlayer stop];
    }
}

- (void)pause{
    if (self.trackType == WHTrackTypeSoundCloud) {
        [remoteStreamer pause];
    }else{
        [localPlayer pause];
    }
}

- (void)resume{
    if (self.trackType == WHTrackTypeSoundCloud) {
        [remoteStreamer pause];
    }else{
        [localPlayer pause];
    }
}

- (BOOL)isPlaying{
    if (self.trackType == WHTrackTypeSoundCloud) {
        return (remoteStreamer.isPlaying);
    }else{
        return (localPlayer.isPlaying);
    }
}

- (float)progress{
    if (!self.isPlaying) {
        return 0.0;
    }else{
        if (self.trackType == WHTrackTypeSoundCloud) {
            return (float)(remoteStreamer.currentTimePlayed.playbackTimeInSeconds / remoteStreamer.duration.playbackTimeInSeconds);
        }else{
            return (float)(localPlayer.currentTimePlayed.playbackTimeInSeconds / localPlayer.duration.playbackTimeInSeconds);
        }
    }
    
}

- (void)seekTime:(float)fprogress{
    if (self.trackType == WHTrackTypeSoundCloud) {
        FSStreamPosition aPosition;
        aPosition = remoteStreamer.duration;
        aPosition.position = fprogress;
        [remoteStreamer seekToPosition:aPosition];
    }else{
        FSStreamPosition aPosition;
        aPosition = remoteStreamer.duration;
        aPosition.position = fprogress;
        [remoteStreamer seekToPosition:aPosition];
    }
    
}

- (NSDictionary *)currentDisplayInfo{
    
    if (self.trackType == WHTrackTypeSoundCloud) {
        return @{MPMediaItemPropertyTitle:self.trackTitle,
                 MPMediaItemPropertyArtist:self.author,
                 MPMediaItemPropertyMediaType: @(MPMediaTypeMusic),
                 MPNowPlayingInfoPropertyElapsedPlaybackTime: @(remoteStreamer.currentTimePlayed.playbackTimeInSeconds),
                 MPMediaItemPropertyPlaybackDuration: @(remoteStreamer.duration.playbackTimeInSeconds),
                 MPNowPlayingInfoPropertyPlaybackRate: @1};
    }else if (self.trackType == WHTrackTypeLocal){
        return @{MPMediaItemPropertyTitle:self.trackTitle,
                 MPMediaItemPropertyArtist:self.author,
                 MPMediaItemPropertyMediaType: @(MPMediaTypeMusic),
                 MPNowPlayingInfoPropertyElapsedPlaybackTime: @(remoteStreamer.currentTimePlayed.playbackTimeInSeconds),
                 MPMediaItemPropertyPlaybackDuration: @(remoteStreamer.duration.playbackTimeInSeconds),
                 MPNowPlayingInfoPropertyPlaybackRate: @1};
    }else{
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:@{MPMediaItemPropertyTitle:@"Retrieving URL",
                                                                    MPMediaItemPropertyArtist:@"-",
                                                                    MPMediaItemPropertyMediaType: @(MPMediaTypeMusic),
                                                                    MPNowPlayingInfoPropertyElapsedPlaybackTime: @(0),
                                                                    MPMediaItemPropertyPlaybackDuration: @(1),
                                                                    MPNowPlayingInfoPropertyPlaybackRate: @0}];
    }
}

- (NSDictionary *)currentPauseDisplayInfo{
    if (self.trackType == WHTrackTypeSoundCloud) {
        return @{MPMediaItemPropertyTitle:self.trackTitle,
                 MPMediaItemPropertyArtist:self.author,
                 MPMediaItemPropertyMediaType: @(MPMediaTypeMusic),
                 MPNowPlayingInfoPropertyElapsedPlaybackTime: @(remoteStreamer.currentTimePlayed.playbackTimeInSeconds),
                 MPMediaItemPropertyPlaybackDuration: @(remoteStreamer.duration.playbackTimeInSeconds),
                 MPNowPlayingInfoPropertyPlaybackRate: @0};
    }else{
        return @{MPMediaItemPropertyTitle:self.trackTitle,
                 MPMediaItemPropertyArtist:self.author,
                 MPMediaItemPropertyMediaType: @(MPMediaTypeMusic),
                 MPNowPlayingInfoPropertyElapsedPlaybackTime: @(remoteStreamer.currentTimePlayed.playbackTimeInSeconds),
                 MPMediaItemPropertyPlaybackDuration: @(remoteStreamer.duration.playbackTimeInSeconds),
                 MPNowPlayingInfoPropertyPlaybackRate: @0};
    }
    
    
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
