//
//  WHTrackModel.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 16/11/15.
//  Copyright © 2015 Memory Leaks. All rights reserved.
//

#import "WHTrackModel.h"

@implementation WHTrackModel

- (id)init{
    if (self = [super init]) {
        
    }
    return self;
}

- (id)initWithInfo:(NSDictionary *)dict{
    if (self = [super init]) {
        _trackUrl = dict[@"stream_url"];
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

@end
